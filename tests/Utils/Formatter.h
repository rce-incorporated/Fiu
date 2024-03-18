#pragma once

#include "lua.h"
#include "lualib.h"

#include "../Config.h"

#include <string>
#include <cstdio>
#include <utility>
#include <iostream>

template <typename... Args>
std::string uformat(const std::string& format, Args&&... args)
{
	constexpr size_t bufferSize = 512;
	char buffer[bufferSize];
	int result = snprintf(buffer, bufferSize, format.c_str(), std::forward<Args>(args)...);
	if (result < 0 || static_cast<size_t>(result) >= bufferSize)
	{
		return "Error: Formatting failed.";
	}
	return std::string(buffer);
};

std::string applyColor(const char* color, const char* value)
{
	return uformat("%s%s%s", color, value, COLOR_RESET);
};
std::string applyColor(const char* color, const std::string& value)
{
	return applyColor(color, value.c_str());
};

std::string formatValue(lua_State* L, int index, int depth = 0, bool asKey = false)
{
	std::string finalValue;

	const int MAX_FORMAT_DEPTH = 4;
	const std::string INDENT = "    ";

	if (depth >= MAX_FORMAT_DEPTH)
	{
		finalValue = "{ ... }";
	}
	else
	{
		
		int t = lua_type(L, index);
		switch (t)
		{
			case LUA_TNIL:
				finalValue = "nil";
				break;
			case LUA_TBOOLEAN:
				finalValue = lua_toboolean(L, index) ? applyColor(COLOR_YELLOW, "true") : applyColor(COLOR_YELLOW, "false");
				break;
			case LUA_TNUMBER:
				finalValue = applyColor(COLOR_CYAN, luaL_tolstring(L, index, nullptr));
				lua_pop(L, 1);
				break;
			case LUA_TSTRING:
				finalValue = applyColor(COLOR_GREEN, "\"" + std::string(lua_tostring(L, index)) + "\"");
				break;
			case LUA_TTABLE:
				if (asKey)
				{
					finalValue = applyColor(COLOR_MAGENTA, "<"+ std::string(luaL_tolstring(L, index, nullptr)) + ">");
					lua_pop(L, 1);
					break;
				}
				finalValue.append(applyColor(STYLE_DIM, "{"));
				finalValue.append("\n");
				lua_pushnil(L);
				while (int nr = lua_next(L, index) != 0)
				{
					for (int i = 0; i < depth + 1; i++)
					{
						finalValue.append("    ");
					}
					int n = lua_gettop(L);
					
					finalValue.append("[" + formatValue(L, n-1, depth + 1, true) + "] = ");
					finalValue.append(formatValue(L, n, depth + 1) + ", \n");
					
					lua_pop(L, 1);
				}
				for (int i = 0; i < depth; i++)
				{
					finalValue.append("    ");
				}
				finalValue.append(applyColor(STYLE_DIM, "}"));
				break;
			default:
				finalValue = applyColor(COLOR_MAGENTA, "<"+ std::string(luaL_tolstring(L, index, nullptr)) + ">");
				lua_pop(L, 1);
				break;
		}
	}

	return finalValue;
}

int formatPrint(lua_State* L)
{
	int n = lua_gettop(L);
	for (int i = 1; i <= n; i++)
	{
		const char* s;
		if (i > 1)
			fwrite("\t", 1, 1, stdout);
		int t = lua_type(L, i);
		switch (t)
		{
		case LUA_TNIL:
			fwrite("nil", 1, 3, stdout);
			break;
		case LUA_TSTRING:
			size_t l;
			s = luaL_tolstring(L, i, &l);
			fwrite(s, 1, l, stdout);
			lua_pop(L, 1);
			break;
		default:
			std::string sf = formatValue(L, i, 0);
			fwrite(sf.c_str(), 1, sf.size(), stdout);
			break;
		}
	}
	fwrite("\n", 1, 1, stdout);
	return 0;
}

void loadFormattedPrint(lua_State* L)
{
	lua_pushcfunction(L, formatPrint, "print");
	lua_setglobal(L, "print");
}

void loadFormattedWarn(lua_State* L)
{
	lua_pushcfunction(L, [](lua_State* L) -> int
	{
		std::string warnTag = "[" + std::string(applyColor(COLOR_YELLOW, "WARN")) + "] ";
		fwrite(warnTag.c_str(), 1, warnTag.size(), stdout);
		return formatPrint(L);
	}, "warn");
	lua_setglobal(L, "warn");
}