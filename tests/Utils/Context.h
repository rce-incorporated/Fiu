#pragma once

#include "Luau/Parser.h"

#include "Formatter.h"

#include <optional>
#include <string>
#include <iostream>
#include <fstream>
#include <filesystem>

using namespace std;

bool isWithinBasePath(filesystem::path base, filesystem::path path) {
	try {
		filesystem::path basePath = filesystem::absolute(base);
		filesystem::path testPath = filesystem::absolute(path);
		
		filesystem::path relativePath = testPath.lexically_relative(basePath);

		return relativePath.string().find("..") == std::string::npos;
	} catch(const filesystem::filesystem_error& e) {
		std::cerr << e.what() << '\n';
		return false;
	}
}

optional<string> readFileWithStream(const char* name)
{
	ifstream fileStream = ifstream(name);
	if (!fileStream)
		return nullopt;
	
	string result;
	string line;
	while (getline(fileStream, line))
	{
		if (!line.empty() && line.back() == '\r')
			line.pop_back();  // remove carriage return character

		result += line + '\n';
	}

	// Skip first line if it's a shebang
	if (result.size() > 2 && result[0] == '#' && result[1] == '!')
		result.erase(0, result.find('\n') + 1);

	return result;
}

optional<string> readLuauFile(const string& name)
{
	optional<string> source = readFile(name + ".luau");
	if (!source)
		source = readFile(name + ".lua");
	return source;
}


void writeFileWithStream(filesystem::path cwd, const string& name, const string& source)
{
	filesystem::path path = name;

	if (!isWithinBasePath(cwd, path))
		throw runtime_error("Path is not within CWD");

	if (!filesystem::exists(path.parent_path()))
		filesystem::create_directories(path.parent_path());

	ofstream file(name);
	file << source;
	file.close();
}

vector<Luau::HotComment> getHotComments(string source, const Luau::ParseOptions& parseOptions)
{
	Luau::Allocator allocator;
	Luau::AstNameTable names(allocator);
	Luau::ParseResult result = Luau::Parser::parse(source.c_str(), source.size(), names, allocator, parseOptions);

	if (!result.errors.empty())
		throw Luau::ParseErrors(result.errors);

	return result.hotcomments;
}

struct CompareResult
{
	bool success;
	string message = "";
	string ctxA = "";
	string ctxB = "";
};

CompareResult compareValue(lua_State* L, int a, int b)
{
	int tA = lua_type(L, a);
	int tB = lua_type(L, b);
	if (tA != tB)
	{
		const char* tnA = lua_typename(L, tA);
		const char* tnB = lua_typename(L, tB);
		return {
			false,
			" != ",
			uformat(" (Type %s)", tnA),
			uformat(" (Type %s)", tnB)
		};
	}
	if (tA == LUA_TTABLE)
	{
		lua_pushnil(L);
		while (int nr = lua_next(L, b) != 0)
		{
			lua_pushvalue(L, -2);
			lua_gettable(L, a);
			int n = lua_gettop(L);
			string key = formatValue(L, n-2, 0);
			CompareResult res = compareValue(L, n, n-1);
			if (!res.success)
			{
				lua_pop(L, 3);
				res.ctxA = uformat("[%s]%s", key.c_str(), res.ctxA.c_str());
				res.ctxB = uformat("[%s]%s", key.c_str(), res.ctxB.c_str());
				return {
					false,
					res.message,
					res.ctxA,
					res.ctxB
				};
			}
			lua_pop(L, 2);
		}

		lua_pushnil(L);
		while (int nr2 = lua_next(L, a) != 0)
		{
			lua_pushvalue(L, -2);
			lua_gettable(L, b);
			int n = lua_gettop(L);
			string key = formatValue(L, n-2, 0);
			CompareResult res = compareValue(L, n, n-1);
			if (!res.success)
			{
				lua_pop(L, 3);
				res.ctxA = uformat("[%s]%s", key.c_str(), res.ctxA.c_str());
				res.ctxB = uformat("[%s]%s", key.c_str(), res.ctxB.c_str());
				return {
					false,
					res.message,
					res.ctxA,
					res.ctxB
				};
			}
			lua_pop(L, 2);
		}

		return {true};
	}
	bool equal = lua_rawequal(L, a, b) == 1;
	const char* sA = luaL_tolstring(L, a, nullptr);
	const char* sB = luaL_tolstring(L, b, nullptr);
	lua_pop(L, 2);
	return {
		equal,
		equal ? "" : " != ",
		equal ? "" : uformat(" (%s)", sA),
		equal ? "" : uformat(" (%s)", sB)
	};
}

int valueComparator(lua_State* L)
{
	if (lua_gettop(L) != 2) {
		lua_pushstring(L, "Comparing requires exactly two arguments");
		lua_error(L);
	}
	CompareResult res = compareValue(L, 2, 1);
	lua_pushboolean(L, res.success);
	if (!res.success)
		lua_pushstring(L, ("A" + res.ctxB + res.message + "B" + res.ctxA).c_str());
	else
		lua_pushnil(L);
	return 2;
}