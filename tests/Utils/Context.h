#pragma once

#include "Luau/Parser.h"

#include "Formatter.h"

#include <optional>
#include <string>
#include <iostream>

std::optional<std::string> readLuauFile(const std::string& name)
{
	std::optional<std::string> source = readFile(name + ".luau");
	if (!source)
		source = readFile(name + ".lua");
	return source;
}

std::vector<Luau::HotComment> getHotComments(std::string source, const Luau::ParseOptions& parseOptions)
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
	std::string message = "";
	std::string ctxA = "";
	std::string ctxB = "";
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
			std::string key = formatValue(L, n-2, 0);
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
			std::string key = formatValue(L, n-2, 0);
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