#include "luau/CLI/Require.h"
#include "luau/CLI/FileUtils.h"
#include "luau/CLI/Coverage.h"
#include "Luau/Compiler.h"

#include "Config.h"

#include "Utils/Formatter.h"
#include "Utils/Context.h"
#include "Utils/Fiu.h"

#include <luacode.h>
#include <lualib.h>
#include <lua.h>

#include <iostream>
#include <optional>
#include <future>
#include <chrono>
#include <vector>
#include <cstring>
#include <filesystem>

using namespace std;

struct TestCompileResult {
	bool success;
	string data;
};

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

TestCompileResult compileTest(string source, Luau::CompileOptions opts, const char* name = "Compiled")
{
	lua_State* L = luaL_newstate();
	string bytecode = Luau::compile(source, opts);
	if (luau_load(L, name, bytecode.data(), bytecode.size(), 0) == 0)
	{
		lua_close(L);
		return {true, bytecode};
	}
	string error = string(lua_tostring(L, -1));
	lua_close(L);
	return {false, error};
}

// Ref: https://github.com/luau-lang/luau/blob/a7683110d71a15bfc823688191476d4c822565cf/CLI/Repl.cpp#L114C1-L120C2
static int finishrequire(lua_State* L)
{
	if (lua_isstring(L, -1))
		lua_error(L);

	return 1;
}

// Ref: https://github.com/luau-lang/luau/blob/a7683110d71a15bfc823688191476d4c822565cf/CLI/Repl.cpp#L97C1-L112C2
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

// Ref: https://github.com/luau-lang/luau/blob/a7683110d71a15bfc823688191476d4c822565cf/CLI/Repl.cpp#L183C1-L245C33
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

// Ref: https://github.com/luau-lang/luau/blob/d21b6fdb936c4fc6f40caa225fc26d6c531beee5/CLI/Repl.cpp#L249C1-L267C2
static int lua_collectgarbage(lua_State* L)
{
	const char* option = luaL_optstring(L, 1, "collect");

	if (strcmp(option, "collect") == 0)
	{
		lua_gc(L, LUA_GCCOLLECT, 0);
		return 0;
	}

	if (strcmp(option, "count") == 0)
	{
		int c = lua_gc(L, LUA_GCCOUNT, 0);
		lua_pushnumber(L, c);
		return 1;
	}

	luaL_error(L, "collectgarbage must be called with 'count' or 'collect'");
}

int testOk(lua_State* L)
{
	lua_pushboolean(L, 1);
	lua_setfield(L, LUA_REGISTRYINDEX, "@TestResult");
	return 0;
}

int luauCompile(lua_State* L)
{
	const char* source = luaL_checkstring(L, 1);
	Luau::CompileOptions options = compleOptions();
	if (!lua_isnone(L, 2) && !lua_isnil(L, 2))
	{
		options = {};
		options.optimizationLevel = 1;
		options.debugLevel = 1;
		options.coverageLevel = 0;
		luaL_checktype(L, 2, LUA_TTABLE);
		lua_getfield(L, 2, "optimizationLevel");
		if (!lua_isnil(L, -1))
			options.optimizationLevel = luaL_checkinteger(L, -1);
		lua_getfield(L, 2, "debugLevel");
		if (!lua_isnil(L, -1))
			options.debugLevel = luaL_checkinteger(L, -1);
		lua_getfield(L, 2, "coverageLevel");
		if (!lua_isnil(L, -1))
			options.coverageLevel = luaL_checkinteger(L, -1);
		lua_getfield(L, 2, "vectorCtor");
		if (!lua_isnil(L, -1))
			options.vectorCtor = luaL_checkstring(L, -1);
		lua_getfield(L, 2, "vectorLib");
		if (!lua_isnil(L, -1))
			options.vectorLib = luaL_checkstring(L, -1);
		lua_getfield(L, 2, "vectorType");
		if (!lua_isnil(L, -1))
			options.vectorType = luaL_checkstring(L, -1);
		lua_pop(L, 6);
	}
	TestCompileResult compileResult = compileTest(source, options);
	if (compileResult.success)
	{
		lua_pushboolean(L, 1);
		lua_pushlstring(L, compileResult.data.c_str(), compileResult.data.size());
		return 2;
	}
	lua_pushboolean(L, 0);
	lua_pushlstring(L, compileResult.data.c_str(), compileResult.data.size());
	return 2;
}

int silentFunction(lua_State* L)
{
	return 0;
}

void loadDebugIO(lua_State* L)
{
	if (DEBUG_LUAU_ENABLE_PRINT == 0)
	{
		lua_pushcfunction(L, silentFunction, "print");
		lua_setglobal(L, "print");
	}
	else
	{
		loadFormattedPrint(L);
	}
	if (DEBUG_LUAU_ENABLE_WARN == 0)
	{
		lua_pushcfunction(L, silentFunction, "warn");
		lua_setglobal(L, "warn");
	}
	else
	{
		loadFormattedWarn(L);
	}
}

void loadFiu(lua_State* L)
{
	// Ref: https://github.com/luau-lang/luau/blob/a7683110d71a15bfc823688191476d4c822565cf/CLI/Repl.cpp#L206C1-L240C29
	lua_State* GL = lua_mainthread(L);
	lua_State* ML = lua_newthread(GL);
	lua_xmove(GL, L, 1);

	luaL_sandboxthread(ML);

	if (luau_load(ML, "Fiu", fiuBytecode.data(), fiuBytecode.size(), 0) == 0)
	{
		if (coverageActive())
			coverageTrack(ML, -1);
		int status = lua_resume(ML, L, 0);
		if (status == 0)
		{
			if (lua_gettop(ML) == 0)
			lua_pushstring(ML, "fiu must return a value");
			else if (!lua_istable(ML, -1) && !lua_isfunction(ML, -1))
			lua_pushstring(ML, "fiu must return a table or function");
		}
		else if (status == LUA_YIELD)
		{
			lua_pushstring(ML, "fiu can not yield");
		}
		else if (!lua_isstring(ML, -1))
		{
			lua_pushstring(ML, "unknown error while running fiu");
		}
	}

	if (lua_isstring(L, -1))
		lua_error(L);
	lua_xmove(ML, L, 1);
}

lua_State* newLuau(const char* chunkName = "Luau")
{
	lua_State* L = luaL_newstate();

	luaL_openlibs(L);

	static const luaL_Reg funcs[] = {
		{"loadstring", lua_loadstring},
		{"collectgarbage", lua_collectgarbage},
		{"MATCH", valueComparator},
		{"OK", testOk},
		{NULL, NULL},
	};

	loadDebugIO(L);

	lua_pushboolean(L, 0);
	lua_setfield(L, LUA_REGISTRYINDEX, "@TestResult");

	lua_pushvalue(L, LUA_GLOBALSINDEX);
	luaL_register(L, NULL, funcs);
	lua_pop(L, 1);

	// Load Luau Module
	lua_newtable(L);
	lua_pushcfunction(L, luauCompile, "Compile");
	lua_setfield(L, -2, "compile");
	lua_setglobal(L, "Luau");

	// Load Fiu Module
	loadFiu(L);
	lua_setglobal(L, "Fiu");

	// Load FiuUtils
	loadFiuUtils(L);

	lua_pushstring(L, "Luau");
	lua_setglobal(L, "TEST_CTX");

	luaL_sandbox(L);
	luaL_sandboxthread(L); // Proxy Global Environment

	return L;
}

lua_State* newFiu(const char* chunkName = "Fiu")
{
	if (fiuBytecode.size() < 1)
		throw runtime_error("Could not read fiu source file");

	lua_State* L = luaL_newstate();

	luaL_openlibs(L);

	static const luaL_Reg funcs[] = {
		{"loadstring", lua_loadstring},
		{"collectgarbage", lua_collectgarbage},
		{"MATCH", valueComparator},
		{"OK", testOk},
		{NULL, NULL},
	};

	loadDebugIO(L);

	lua_pushboolean(L, 0);
	lua_setfield(L, LUA_REGISTRYINDEX, "@TestResult");

	lua_pushvalue(L, LUA_GLOBALSINDEX);
	luaL_register(L, NULL, funcs);
	lua_pop(L, 1);

	lua_pushstring(L, "Fiu");
	lua_setglobal(L, "TEST_CTX");

	// Ref: https://github.com/luau-lang/luau/blob/d21b6fdb936c4fc6f40caa225fc26d6c531beee5/tests/Conformance.test.cpp#L207C1-L211C7
	// In some configurations we have a larger C stack consumption which trips some conformance tests
#if defined(LUAU_ENABLE_ASAN) || defined(_NOOPT) || defined(_DEBUG)
	lua_pushboolean(L, true);
	lua_setglobal(L, "limitedstack");
#endif

	luaL_sandbox(L);
	luaL_sandboxthread(L); // Proxy Global Environment

	lua_pushvalue(L, LUA_GLOBALSINDEX);
	lua_pushvalue(L, LUA_GLOBALSINDEX);
	lua_setfield(L, -1, "_G");

	// Load Fiu Module
	loadFiu(L);

	return L;
}

TestResult RUN_TEST(string testName, string fileName)
{
	TestResult result;
	
	optional<string> fileSource = readLuauFile(fileName);
	if (!fileSource.has_value())
	{
		result.output = uformat("[%s] Test [%s]: Test file could not be read.", ERROR_SYMBOL, testName.c_str());
		return result;
	}

	string testSource = fileSource.value();

	TestCompileResult compileError = compileTest(testSource, compleOptions());
	if (compileError.success)
	{
		vector<Luau::HotComment> hotcomments = getHotComments(testSource, Luau::ParseOptions());
		bool useLuau = false;
		for (const Luau::HotComment& comment : hotcomments)
			if (comment.content == "ctx Luau")
			{
				useLuau = true;
			}

		lua_State* L = useLuau ? newLuau() : newFiu();

		string bytecode = compileError.data;
		try
		{
			future<int> testTask = async([L, bytecode, useLuau, testName]()
			{
				if (useLuau)
				{
					int load = luau_load(L, testName.c_str(), bytecode.data(), bytecode.size(), 0);
					if (load != 0)
						return load;

					return lua_resume(L, L, 0);
				}
				else
				{
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
				}
			});

			future_status status = testTask.wait_for(chrono::seconds(10));

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
					} else
					{
						result.output = uformat("[%s] Test [%s]: No valid confirmation (not OK)", ERROR_SYMBOL, testName.c_str());
					}
				}
				else
				{
					result.output = uformat("[%s] Test [%s]: Error: ", ERROR_SYMBOL, testName.c_str()) + string(lua_tostring(L, -1));
				}
			}
		} catch (const std::future_error& fe)
		{
			result.output = uformat("[%s] Test [%s]: Failed to execute test [Internal: %s]", ERROR_SYMBOL, testName.c_str(), fe.what());
		}

		lua_close(L);
	}
	else
	{
		result.output = uformat("[%s] Test [%s]: Failed to compile test: %s", ERROR_SYMBOL, testName.c_str(), compileError.data.c_str());
	}

	return result;
}

int main(int argc, char* argv[])
{
	filesystem::path buildSourceDirectory;
	filesystem::path buildOutputDirectory;

	const char* mode = "test";

	int start = 1;

	if (argc > 1 && strcmp(argv[1], "test") == 0)
	{
		start = 2;
	}
	else if (argc > 1 && (strcmp(argv[1], "mdt") == 0 || strcmp(argv[1], "make-deserializer-tests") == 0))
	{
		mode = "mdt";
		start = 2;
	}

	filesystem::path cwd = filesystem::current_path();

	// Parse Arguments
	for (int i = start; i < argc; i++)
	{
		if (strcmp(argv[i], "-t") == 0)
		{
			i++;
			const char* testCaseFile = argv[i];
			TestCases = {
				{"CLI", {testCaseFile}},
			};
		}
		else if (strcmp(argv[i], "-tf") == 0)
		{
			i++;
			vector<string> testCases;
			filesystem::path root = filesystem::path(argv[i]);
			for (const filesystem::directory_entry& entry : filesystem::directory_iterator(cwd / "tests" / root))
			{
				if (entry.is_regular_file())
				{
					testCases.push_back((root / entry.path().stem()).string());
				}
			}

			TestCases = {
				{"CLI", testCases},
			};
		}
		else if (strcmp(argv[i], "-log") == 0)
		{
			i++;
			const char* debugLevel = argv[i];
			DEBUG_LUAU_ENABLE_PRINT = strcmp(debugLevel, "PRINT") == 0 || strcmp(debugLevel, "ALL") == 0;
			DEBUG_LUAU_ENABLE_WARN = strcmp(debugLevel, "WARN") == 0 || strcmp(debugLevel, "ALL") == 0;
		}
		else if (strcmp(argv[i], "-bSrc") == 0)
		{
			i++;
			buildSourceDirectory = cwd / filesystem::path(argv[i]);
		}
		else if (strcmp(argv[i], "-bOut") == 0)
		{
			i++;
			buildOutputDirectory = cwd / filesystem::path(argv[i]);
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
		else
		{
			printf("Error: Unknown argument: %s\n", argv[i]);
			return 1;
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
	TestCompileResult fiuCompileResult = compileTest(fiuSource, compleOptions(), "Fiu");
	if (!fiuCompileResult.success)
	{
		printf("[%s] Failed to Compile 'Fiu': %s\n", ERROR_SYMBOL, fiuCompileResult.data.c_str());
		return 1;
	}
	printf("[%s] Fiu: Compiled\n", SUCCESS_SYMBOL);

	fiuBytecode = Luau::compile(fiuSource, compleOptions());

	// Load Fiu
	{
		lua_State* L;
		try
		{
			L = newFiu();
		}
		catch (const std::exception& e)
		{
			printf("[%s] Failed to create fiu instance: %s\n", ERROR_SYMBOL, e.what());
			return 1;
		}
		// Validate Fiu Export
		for (const pair<const string, string>& s : FiuExport)
		{
			lua_getfield(L, -1, s.first.c_str());
			if (lua_isnil(L, -1))
			{
				printf("  [%s] Missing export '%s' of type '%s'\n", ERROR_SYMBOL, s.first.c_str(), s.second.c_str());
				return 1;
			}
			const string mustBeType = s.second;
			const string typeName = lua_typename(L, lua_type(L, -1));
			if (typeName != mustBeType)
			{
				printf("  [%s] Export '%s' got type '%s', expected '%s'\n", ERROR_SYMBOL, s.first.c_str(), typeName.c_str(), mustBeType.c_str());
				return 1;
			}
			lua_pop(L, 1);

			printf("  [%s] Export '%s' is valid\n", SUCCESS_SYMBOL, s.first.c_str());
		}

		lua_close(L);
	}

	if (strcmp(mode, "mdt") == 0)
	{
		if (buildSourceDirectory.empty() || !filesystem::exists(buildSourceDirectory) || !filesystem::is_directory(buildSourceDirectory))
		{
			printf("Error: Cannot find Source folder\n");
			return 1;
		}
		if (buildOutputDirectory.empty() || filesystem::exists(buildOutputDirectory) && !filesystem::is_directory(buildOutputDirectory))
		{
			printf("Error: Output folder is not a folder.\n");
			return 1;
		}

		for (const filesystem::directory_entry& entry : filesystem::directory_iterator(buildSourceDirectory))
		{
			if (entry.is_regular_file())
			{
				optional<string> src = readFileWithStream(entry.path().string().c_str());
				if (!src.has_value())
				{
					printf("[%s] Error: Could not read file: %s\n", ERROR_SYMBOL, entry.path().string().c_str());
					return 1;
				}
				TestCompileResult compileResult = compileTest(src.value(), compleOptions());
				if (!compileResult.success)
				{
					printf("[%s] Failed to Compile '%s': %s\n", ERROR_SYMBOL, entry.path().string().c_str(), compileResult.data.c_str());
					return 1;
				}
				lua_State* L = newLuau(entry.path().string().c_str());

				string code = "-- file was auto-generated by `fiu-tests`\n--!ctx Luau\n\nlocal ok, compileResult = Luau.compile([[\n";
				code.append(src.value());
				code.append("]], {\n\toptimizationLevel = ");
				code.append(to_string(globalOptions.optimizationLevel));
				code.append(",\n\tdebugLevel = ");
				code.append(to_string(globalOptions.debugLevel));
				code.append(",\n\tcoverageLevel = ");
				code.append(to_string(globalOptions.coverageLevel));
				code.append(",\n\tvectorLib = ");
				if (globalOptions.vectorLib != nullptr)
				{
					code.append("\"");
					code.append(globalOptions.vectorLib);
					code.append("\"");
				}
				else
					code.append("nil");
				code.append(",\n\tvectorCtor = ");
				if (globalOptions.vectorCtor != nullptr)
				{
					code.append("\"");
					code.append(globalOptions.vectorCtor);
					code.append("\"");
				}
				else
					code.append("nil");
				code.append(",\n\tvectorType = ");
				if (globalOptions.vectorType != nullptr)
				{
					code.append("\"");
					code.append(globalOptions.vectorType);
					code.append("\"");
				}
				else
					code.append("nil");
				code.append("\n})\n\nif not ok then\n\terror(`Failed to compile, error: {compileResult}`)\nend\n\n");

				// Fiu.luau_deserialize(compileResult<string>)
				lua_getglobal(L, "Fiu");
				lua_getfield(L, -1, "luau_deserialize");
				lua_pushlstring(L, compileResult.data.c_str(), compileResult.data.size());
				int status = lua_pcall(L, 1, 1, 0);
				if (status != 0)
				{
					printf("[%s] Failed to deserialize bytecode: %s\n", ERROR_SYMBOL, lua_tostring(L, -1));
					return 1;
				}
				lua_remove(L, -2);

				// FiuUtils.encodeModule(module<any>)
				lua_getglobal(L, "FiuUtils");
				lua_getfield(L, -1, "encodeModule");
				lua_pushvalue(L, -3);
				status = lua_pcall(L, 1, 3, 0);
				if (status != 0)
				{
					printf("[%s] Failed to encode module: %s\n", ERROR_SYMBOL, lua_tostring(L, -1));
					return 1;
				}

				// FiuUtils.makeCode(encoded<string>, constants<string>, stringList<string>)
				lua_getfield(L, -6, "makeCode");
				lua_pushvalue(L, -4);
				lua_pushvalue(L, -4);
				lua_pushvalue(L, -4);
				status = lua_pcall(L, 3, 1, 0);
				if (status != 0)
				{
					printf("[%s] Failed to make code: %s\n", ERROR_SYMBOL, lua_tostring(L, -1));
					return 1;
				}

				size_t len;
				const char* codeResult = lua_tolstring(L, -1, &len);

				code.append(codeResult, len);
				code.append("\n");

				lua_close(L);

				compileResult = compileTest(code, compleOptions(), entry.path().string().c_str());
				if (!compileResult.success)
				{
					printf("[%s] Failed to Test Compile '%s': %s\n", ERROR_SYMBOL, entry.path().string().c_str(), compileResult.data.c_str());
					return 1;
				}

				filesystem::path outputPath = buildOutputDirectory / entry.path().filename();
				try
				{
					writeFileWithStream(cwd, outputPath.string(), code);
				}
				catch (const std::exception& e)
				{
					printf("[%s] Error: Could not write file: %s\n", ERROR_SYMBOL, e.what());
					return 1;
				}

				printf("[%s] Compiled '%s' to '%s'\n", SUCCESS_SYMBOL, entry.path().string().c_str(), outputPath.string().c_str());
			}
		}

		return 0;
	}
	else
	{
		if (!buildSourceDirectory.empty())
		{
			printf("Error: -bSrc is only valid in 'mdt' mode\n");
			return 1;
		}
		if (!buildOutputDirectory.empty())
		{
			printf("Error: -bOut is only valid in 'mdt' mode\n");
			return 1;
		}
	}

	// Run Tests
	vector<TestResult> failedTests;
	for (const auto& section : TestCases)
	{
		Tests tests = Tests(section.first);

		bool failed = false;
		for (const string& file : section.second)
		{
			TestResult result = RUN_TEST(file, "./tests/" + file);
			tests.results.push_back(result);
			if (!result.success)
			{
				failed = true;
			}
		}

		for (const TestResult& result : tests.results)
			if (!result.success)
				failedTests.push_back(result);
		
		if (failed)
		{
			printf("[%s] %s: %sSome tests failed%s\n", ERROR_SYMBOL, section.first.c_str(), COLOR_RED, COLOR_RESET);
		}
		else
		{
			printf("[%s] %s: %sAll tests passed%s\n", SUCCESS_SYMBOL, section.first.c_str(), COLOR_GREEN, COLOR_RESET);
			
		}

		for (const TestResult& result : tests.results)
		{
			printf("  %s\n", result.output.c_str());
		}
		printf("\n");
	}

	printf("\n");

	if (failedTests.size() > 0)
	{
		printf("Failed tests\n");
		for (const TestResult& result : failedTests)
		{
			printf("  %s\n", result.output.c_str());
		}
		return 1;
	}
	printf("All tests passed\n");
	return 0;
}