#include "luau/CLI/Require.h"
#include "luau/CLI/FileUtils.h"
#include "luau/CLI/Coverage.h"
#include "Luau/Compiler.h"

#include "Config.h"

#include "Utils/uformat.h"

#include <luacode.h>
#include <lualib.h>
#include <lua.h>

#include <iostream>
#include <optional>
#include <future>
#include <chrono>
#include <vector>
#include <cstring>

using namespace std;

class TestResult
{
	public:
		bool success;
		string output;
	TestResult() : success(false), output("") {}
};

class Tests
{
	public:
		vector<TestResult> results;
		string section;
	Tests(string sectionName) : section(sectionName) {}
};

struct GlobalOptions
{
	int optimizationLevel = 1;
	int debugLevel = 0;
	int coverageLevel = 0;
	const char* vectorCtor = nullptr;
	const char* vectorLib = nullptr;
	const char* vectorType = nullptr;
} globalOptions;

static Luau::CompileOptions compleOptions()
{
	Luau::CompileOptions result = {};
	result.optimizationLevel = globalOptions.optimizationLevel;
	result.debugLevel = globalOptions.debugLevel;
	result.coverageLevel = coverageActive() ? 2 : 0;
	result.vectorCtor = globalOptions.vectorCtor;
	result.vectorLib = globalOptions.vectorLib;
	result.vectorType = globalOptions.vectorType;

	return result;
}

string fiuBytecode;

static int finishrequire(lua_State* L)
{
	if (lua_isstring(L, -1))
		lua_error(L);

	return 1;
}

static int lua_loadstring(lua_State* L)
{
	size_t l = 0;
	const char* s = luaL_checklstring(L, 1, &l);
	const char* chunkname = luaL_optstring(L, 2, s);

	lua_setsafeenv(L, LUA_ENVIRONINDEX, false);

	string bytecode = Luau::compile(string(s, l), compleOptions());
	if (luau_load(L, chunkname, bytecode.data(), bytecode.size(), 0) == 0)
		return 1;

	lua_pushnil(L);
	lua_insert(L, -2); // put before error message
	return 2;          // return nil plus error message
}

static optional<string> readLuauFile(const string& name)
{
	optional<string> source = readFile(name + ".luau");
	if (!source)
	{
		source = readFile(name + ".lua");
	}
	return source;
}

static optional<string> COMPILE_TEST(string source, const char* name = "Compiled")
{
	lua_State* L = luaL_newstate();
	string bytecode = Luau::compile(source, compleOptions());
	if (luau_load(L, name, bytecode.data(), bytecode.size(), 0) == 0)
	{
		lua_close(L);
		return nullopt;
	}
	string error = string(lua_tostring(L, -1));
	lua_close(L);
	return error;
}

static int lua_require(lua_State* L)
{
	string name = luaL_checkstring(L, 1);
	string chunkname = "=" + name;

	luaL_findtable(L, LUA_REGISTRYINDEX, "_MODULES", 1);

	// return the module from the cache
	lua_getfield(L, -1, name.c_str());
	if (!lua_isnil(L, -1))
	{
		// L stack: _MODULES result
		return finishrequire(L);
	}

	lua_pop(L, 1);

	optional<string> source = readLuauFile(name);
	if (!source)
	{
		luaL_argerrorL(L, 1, ("error loading " + name).c_str());
	}

	// module needs to run in a new thread, isolated from the rest
	// note: we create ML on main thread so that it doesn't inherit environment of L
	lua_State* GL = lua_mainthread(L);
	lua_State* ML = lua_newthread(GL);
	lua_xmove(GL, L, 1);
	// new thread needs to have the globals sandboxed
	luaL_sandboxthread(ML);

	// now we can compile & run module on the new thread
	string bytecode = Luau::compile(*source, compleOptions());
	if (luau_load(ML, chunkname.c_str(), bytecode.data(), bytecode.size(), 0) == 0)
	{
		if (coverageActive())
			coverageTrack(ML, -1);
		int status = lua_resume(ML, L, 0);
		if (status == 0)
		{
			if (lua_gettop(ML) == 0)
			lua_pushstring(ML, "module must return a value");
			else if (!lua_istable(ML, -1) && !lua_isfunction(ML, -1))
			lua_pushstring(ML, "module must return a table or function");
		}
		else if (status == LUA_YIELD)
		{
			lua_pushstring(ML, "module can not yield");
		}
		else if (!lua_isstring(ML, -1))
		{
			lua_pushstring(ML, "unknown error while running module");
		}
	}
	// there's now a return value on top of ML; L stack: _MODULES ML
	lua_xmove(ML, L, 1);
	lua_pushvalue(L, -1);
	lua_setfield(L, -4, name.c_str());

	// L stack: _MODULES ML result
	return finishrequire(L);
}

int test_ok(lua_State* L)
{
	lua_pushboolean(L, 1);
	lua_setfield(L, LUA_REGISTRYINDEX, "@TestResult");
	return 0;
}

int lua_io_warn(lua_State* L)
{
	fwrite("[", 1, 1, stdout);
	fwrite(COLOR_YELLOW, 1, 7, stdout);
	fwrite("WARN", 1, 4, stdout);
	fwrite(COLOR_RESET, 1, 6, stdout);
	fwrite("] ", 1, 2, stdout);
	int n = lua_gettop(L); // number of arguments
	for (int i = 1; i <= n; i++)
	{
		size_t l;
		const char* s = luaL_tolstring(L, i, &l); // convert to string using __tostring et al
		if (i > 1)
			fwrite("\t", 1, 1, stdout);
		fwrite(s, 1, l, stdout);
		lua_pop(L, 1); // pop result
	}
	fwrite("\n", 1, 1, stdout);
	return 0;
}

int silent_function(lua_State* L)
{
	return 0;
}

lua_State* newFiu(const char* chunkName = "Fiu")
{
	if (fiuBytecode.size() < 1)
		throw runtime_error("Could not read fiu source file");

	lua_State* L = luaL_newstate();

	luaL_openlibs(L);

	static const luaL_Reg funcs[] = {
		{"loadstring", lua_loadstring},
		{"OK", test_ok},
		{NULL, NULL},
	};

	if (FIU_DEBUG_LUAU_ENABLE_PRINT == 0)
	{
		lua_pushcfunction(L, silent_function, "print");
		lua_setglobal(L, "print");
	}
	if (FIU_DEBUG_LUAU_ENABLE_WARN == 0)
	{
		lua_pushcfunction(L, silent_function, "warn");
		lua_setglobal(L, "warn");
	}
	else
	{
		lua_pushcfunction(L, lua_io_warn, "warn");
		lua_setglobal(L, "warn");
	}

	lua_pushboolean(L, 0);
	lua_setfield(L, LUA_REGISTRYINDEX, "@TestResult");

	lua_pushvalue(L, LUA_GLOBALSINDEX);
	luaL_register(L, NULL, funcs);
	lua_pop(L, 1);

	luaL_sandbox(L);

	// Load Fiu
	{
		lua_State* GL = lua_mainthread(L);
		lua_State* ML = lua_newthread(GL);
		lua_xmove(GL, L, 1);

		luaL_sandboxthread(ML);

		if (luau_load(ML, chunkName, fiuBytecode.data(), fiuBytecode.size(), 0) == 0)
		{
			if (coverageActive())
				coverageTrack(ML, -1);
			int status = lua_resume(ML, L, 0);
			if (status == 0)
			{
				if (lua_gettop(ML) == 0)
				lua_pushstring(ML, "module must return a value");
				else if (!lua_istable(ML, -1) && !lua_isfunction(ML, -1))
				lua_pushstring(ML, "module must return a table or function");
			}
			else if (status == LUA_YIELD)
			{
				lua_pushstring(ML, "module can not yield");
			}
			else if (!lua_isstring(ML, -1))
			{
				lua_pushstring(ML, "unknown error while running module");
			}
		}

		if (lua_isstring(L, -1))
			lua_error(L);
		lua_xmove(ML, L, 1);
	}

	luaL_sandboxthread(L); // Proxy Global Environment

	return L;
}

TestResult RUN_TEST(string testName, string fileName)
{
	TestResult result;
	
	optional<string> fileSource = readLuauFile(fileName);
	if (!fileSource.has_value())
	{
		result.output = uformat("[%s] Test [%s]: Test file could not be read.\n", ERROR_SYMBOL, testName.c_str());
		return result;
	}

	lua_State* L = newFiu();

	optional<string> compileError = COMPILE_TEST(fileSource.value());
	if (!compileError.has_value())
	{
		string bytecode = Luau::compile(fileSource.value(), compleOptions());
		try {
			future<int> testTask = async([L, bytecode]() {
				lua_getfield(L, -1, "luau_deserialize");
				lua_pushlstring(L, bytecode.c_str(), bytecode.size());

				int deserialize = lua_pcall(L, 1, 1, 0);
				if (deserialize != 0)
				return deserialize;

				lua_getfield(L, -2, "luau_load");
				lua_pushvalue(L, -2);
				lua_pushvalue(L, LUA_GLOBALSINDEX);

				int load = lua_pcall(L, 2, 1, 0);
				if (load != 0)
				return load;

				return lua_resume(L, L, 0);
			});

			future_status status = testTask.wait_for(chrono::seconds(7));

			if (status == future_status::timeout)
			{
				result.output = uformat("[%s] Test [%s]: Timed Out", ERROR_SYMBOL, testName.c_str());
			}
			else if (status == future_status::ready) 
			{
				int presult = 1;
				try
				{
					presult = testTask.get();
				}
				catch(const std::exception& e)
				{

					result.output = uformat("[%s] Test [%s]: Internal Error: %s", ERROR_SYMBOL, testName.c_str(), e.what());
					lua_close(L);
					return result;
				}
				
				if (presult == 0)
				{
					lua_getfield(L, LUA_REGISTRYINDEX, "@TestResult");
					int b = lua_toboolean(L, -1);
					if (b == 1)
					{
						result.success = true;
						result.output = uformat("[%s] Test [%s]: Passed", SUCCESS_SYMBOL, testName.c_str());
					} else {
						result.output = uformat("[%s] Test [%s]: No valid confirmation (not OK)", ERROR_SYMBOL, testName.c_str());
					}
				} else {
					result.output = uformat("[%s] Test [%s]: Error: %s", ERROR_SYMBOL, testName.c_str(), lua_tostring(L, -1));
				}
			}
		} catch (const std::future_error& fe) {
			result.output = uformat("[%s] Test [%s]: Failed to execute test [Internal: %s]", ERROR_SYMBOL, testName.c_str(), fe.what());
		}
	} else {
		result.output = uformat("[%s] Test [%s]: Failed to compile test: %s", ERROR_SYMBOL, testName.c_str(), compileError.value());
		lua_pop(L, 1);
	}

	lua_close(L);

	return result;
}

int main(int argc, char* argv[])
{
	// Parse Arguments
	for (int i = 1; i < argc; i++)
	{
		if (strcmp(argv[i], "-t") == 0)
		{
			i++;
			const char* testCaseFile = argv[i];
			TestCases = {
				{"CLI", {testCaseFile}},
			};
		} 
		else if (strcmp(argv[i], "-log") == 0)
		{
			i++;
			const char* debugLevel = argv[i];
			FIU_DEBUG_LUAU_ENABLE_PRINT = strcmp(debugLevel, "PRINT") == 0 || strcmp(debugLevel, "ALL") == 0;
			FIU_DEBUG_LUAU_ENABLE_WARN = strcmp(debugLevel, "WARN") == 0 || strcmp(debugLevel, "ALL") == 0;
		}
		else if (strncmp(argv[i], "-O", 2) == 0)
		{
			int level = atoi(argv[i] + 2);
			if (level < 0 || level > 2)
			{
				printf("Error: Invalid optimization level\n");
				return 1;
			}
			globalOptions.optimizationLevel = level;
		}
		else if (strncmp(argv[i], "-D", 2) == 0)
		{
			int level = atoi(argv[i] + 2);
			if (level < 0 || level > 2)
			{
				printf("Error: Invalid debug level\n");
				return 1;
			}
			globalOptions.debugLevel = level;
		}
		else if (strncmp(argv[i], "-C", 2) == 0)
		{
			int level = atoi(argv[i] + 2);
			if (level < 0 || level > 2)
			{
				printf("Error: Invalid coverage level\n");
				return 1;
			}
			globalOptions.coverageLevel = level;
		}
		else if (strcmp(argv[i], "-vectorCtor") == 0)
		{
			i++;
			const char* vectorCtor = argv[i];
			globalOptions.vectorCtor = vectorCtor;
		}
		else if (strcmp(argv[i], "-vectorLib") == 0)
		{
			i++;
			const char* vectorLib = argv[i];
			globalOptions.vectorLib = vectorLib;
		}
		else if (strcmp(argv[i], "-vectorType") == 0)
		{
			i++;
			const char* vectorType = argv[i];
			globalOptions.vectorType = vectorType;
		}
	}

	// Load Fiu source
	optional<string> fiuFileSource = readLuauFile("./Source");
	if (!fiuFileSource.has_value())
	{
		printf("[%s] Error: Could not read fiu source file\n", ERROR_SYMBOL);
		return 1;
	}

	string fiuSource = fiuFileSource.value();

	// Compile Fiu
	optional<string> fiuError = COMPILE_TEST(fiuSource, "Fiu");
	if (fiuError.has_value())
	{
		printf("[%s] Failed to Compile 'Fiu': %s\n", ERROR_SYMBOL, fiuError.value().c_str());
		return 1;
	}
	printf("[%s] Fiu: Compiled\n", SUCCESS_SYMBOL);

	fiuBytecode = Luau::compile(fiuSource, compleOptions());

	// Load Fiu
	{
		lua_State* L;
		try {
			L = newFiu();
		} catch (const std::exception& e) {
			printf("[%s] Failed to create fiu instance: %s\n", ERROR_SYMBOL, e.what());
			return 1;
		}
		// Validate Fiu Export
		for (const pair<const string, string>& s : FiuExport) {
			lua_getfield(L, -1, s.first.c_str());
			if (lua_isnil(L, -1)) {
				printf("[%s] Fiu: Missing export '%s' of type '%s'\n", ERROR_SYMBOL, s.first.c_str(), s.second.c_str());
				return 1;
			}
			const string mustBeType = s.second;
			const string typeName = lua_typename(L, lua_type(L, -1));
			if (typeName != mustBeType) {
				printf("[%s] Fiu: Export '%s' got type '%s', expected '%s'\n", ERROR_SYMBOL, s.first.c_str(), typeName.c_str(), mustBeType.c_str());
				return 1;
			}
			lua_pop(L, 1);

			printf("[%s] Fiu: Export '%s' is valid\n", SUCCESS_SYMBOL, s.first.c_str());
		}

		lua_close(L);
	}

	// Run Tests
	vector<TestResult> failedTests;
	for (const auto& section : TestCases) {
		Tests tests = Tests(section.first);

		bool failed = false;
		for (const string& file : section.second) {
			TestResult result = RUN_TEST(file, "./tests/" + file);
			tests.results.push_back(result);
			if (!result.success) {
				failed = true;
			}
		}

		for (const TestResult& result : tests.results)
			if (!result.success)
				failedTests.push_back(result);
		
		if (failed) {
			printf("[%s] %s: %sSome tests failed%s\n", ERROR_SYMBOL, section.first.c_str(), COLOR_RED, COLOR_RESET);
		} else {
			printf("[%s] %s: %sAll tests passed%s\n", SUCCESS_SYMBOL, section.first.c_str(), COLOR_GREEN, COLOR_RESET);
			
		}

		for (const TestResult& result : tests.results) {
			printf("  %s\n", result.output.c_str());
		}
	}

	printf("\n");

	if (failedTests.size() > 0) {
		printf("Failed tests\n");
		for (const TestResult& result : failedTests) {
			printf("  %s\n", result.output.c_str());
		}
	} else {
		printf("All tests passed\n");
	}

	return 0;
}