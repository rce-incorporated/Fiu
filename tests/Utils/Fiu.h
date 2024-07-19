#pragma once

#include "lua.h"
#include "lualib.h"
#include ".././luau/VM/src/lapi.h"
#include ".././luau/VM/src/ltable.h"
#include ".././luau/VM/src/ldebug.h"
#include ".././luau/VM/src/lvm.h"
#include ".././luau/VM/src/lgc.h"

#include "Formatter.h"

#include <vector>

using namespace std;

vector<string> opList = {
	"NOP", "BREAK", "LOADNIL",
	"LOADB", "LOADN", "LOADK",
	"MOVE", "GETGLOBAL", "SETGLOBAL",
	"GETUPVAL", "SETUPVAL", "CLOSEUPVALS",
	"GETIMPORT", "GETTABLE", "SETTABLE",
	"GETTABLEKS", "SETTABLEKS", "GETTABLEN",
	"SETTABLEN", "NEWCLOSURE", "NAMECALL",
	"CALL", "RETURN", "JUMP", "JUMPBACK",
	"JUMPIF", "JUMPIFNOT", "JUMPIFEQ",
	"JUMPIFLE", "JUMPIFLT", "JUMPIFNOTEQ",
	"JUMPIFNOTLE", "JUMPIFNOTLT", "ADD",
	"SUB", "MUL", "DIV", "MOD", "POW",
	"ADDK", "SUBK", "MULK", "DIVK", "MODK",
	"POWK", "AND", "OR", "ANDK", "ORK",
	"CONCAT", "NOT", "MINUS", "LENGTH",
	"NEWTABLE", "DUPTABLE", "SETLIST",
	"FORNPREP", "FORNLOOP", "FORGLOOP",
	"FORGPREP_INEXT", "DEP_FORGLOOP_INEXT",
	"FORGPREP_NEXT", "DEP_FORGLOOP_NEXT",
	"GETVARARGS", "DUPCLOSURE", "PREPVARARGS",
	"LOADKX", "JUMPX", "FASTCALL", "COVERAGE",
	"CAPTURE", "SUBRK", "DIVRK", "FASTCALL1",
	"FASTCALL2", "FASTCALL2K", "FORGPREP",
	"JUMPXEQKNIL", "JUMPXEQKB", "JUMPXEQKN",
	"JUMPXEQKS", "IDIV", "IDIVK"
};

vector<string> fiuProtoField = {
	"maxstacksize", "numparams",
	"nups", "isvararg", "linedefined",
	"debugname", "sizecode", "sizek",
	"sizep", "protos",
	"lineinfoenabled", "instructionlineinfo",
	"code", // "debugcode" is part of "code"
};

vector<string> fiuCodeField = {
	"opmode", "kmode", "aux",
	"A", "B", "C", "D", "E",
	"K", "K0", "K1","K2", "KN", "KC",
	"usesAux"
};

void appendOptionalCode(lua_State* L, string& str)
{
	if (lua_isnil(L, -1))
		str.append(" ?");
	else
	{
		str.append(" ");
		str.append(lua_tostring(L, -1));
	}
}

int tableFind(lua_State* L)
{
	luaL_checktype(L, -2, LUA_TTABLE);
	luaL_checkany(L, -1);

	Table* t = hvalue(luaA_toobject(L, -2));
	const TValue* ne = luaA_toobject(L, -1);

	lua_pop(L, 2);

	for (int i = 1; ;++i)
	{
		const TValue* e = luaH_getnum(t, i);
		if (ttisnil(e))
			break;
		if (equalobj(L, ne, e))
			return i;
	}

	return -1;
}

vector<string> splitString(const char* src, size_t srcLen, string split = " ")
{
	vector<string> ls = {};
	size_t splitLen = split.size();
	if (srcLen == 0 || splitLen == 0)
		return ls;
	
	const char* sep = split.c_str();
	const char* start = src;
	const char* end = src + srcLen;

	for (const char* iter = src; iter <= end - splitLen; iter++)
		if (memcmp(iter, sep, splitLen) == 0)
		{
			ls.push_back(string(start, iter - start));
			start = iter + splitLen;
		}
	
	ls.push_back(string(start, end - start));
	return ls;
}

bool isBlank(string s)
{
	for (char c : s)
		if (!isspace(c))
			return false;
	return true;
}

const char* stripWhiteSpace(const char* src, size_t* len)
{
	while (isspace(*src))
		src++;

	if (len == nullptr)
		len = new size_t(strlen(src));

	while (*len > 0 && isspace(src[*len]))
		*len--;

	return src;
}

void fiuDecodeCode(lua_State* L, const char* src, size_t srcLen)
{
	luaL_checktype(L, -2, LUA_TTABLE); // Constants
	luaL_checktype(L, -1, LUA_TTABLE); // StringList
	int stringList = lua_gettop(L);
	int constants = stringList - 1;

	if (memcmp(src, "~", 1) == 0)
	{
		lua_newtable(L);
		lua_pushunsigned(L, stoul(string(src + 1, srcLen - 1)));
		lua_setfield(L, -2, "value");
		lua_pushstring(L, "auxvalue");
		lua_setfield(L, -2, "opname");
		return;
	}

	vector<string> codeList = splitString(src, srcLen, " ");

	lua_newtable(L);

	int opcode = stoi(codeList.at(0));
	lua_pushinteger(L, opcode);
	lua_setfield(L, -2, "opcode");
	int idx = 1;
	int kmode = 0;
	for (string& field : fiuCodeField)
	{
		string s = codeList.at(idx);
		idx++;
		if (s == "?")
		{
			if (field == "usesAux")
				s = "0";
			else
				continue;
		}
		if (
			field == "K" || field == "K0" || field == "K1" ||
			field == "K2" || field == "KN" || field == "usesAux"
		)
		{
			if (field == "KN" || field == "usesAux" || kmode == 5 || (kmode == 6 && field != "K"))
				lua_pushboolean(L, s == "1");
			else
			{
				lua_rawgeti(L, constants, stoul(s));
				if (lua_isnil(L, -1))
				{
					lua_pushstring(L, uformat("Expected value in constants at index %s", s.c_str()).c_str());
					lua_error(L);
				}
				if (lua_type(L, -1) == LUA_TSTRING)
				{
					int sidx = stoi(lua_tostring(L, -1));
					lua_pushvalue(L, -2);
					lua_rawgeti(L, stringList, sidx);
					if (lua_isnil(L, -1))
					{
						lua_pushstring(L, uformat("Expected value in stringlist at index %d", sidx).c_str());
						lua_error(L);
					}
					lua_setfield(L, -2, field.c_str());
					lua_pop(L, 2);
					continue;
				}
			}
		}
		else if (field == "kmode")
		{
			kmode = stoi(s);
			lua_pushinteger(L, kmode);
		}
		else if (field == "D")
		{
			int n = stoul(s);
			lua_pushinteger(L, n);
		}
		else
		{
			lua_pushunsigned(L, stoul(s));
		}
		lua_setfield(L, -2, field.c_str());
	}

	string opname = opList.at(opcode);
	lua_pushstring(L, opname.c_str());
	lua_setfield(L, -2, "opname");
}

void fiuDecodeProto(lua_State* L, string src, vector<string> protoCode)
{
	luaL_checktype(L, -2, LUA_TTABLE); // StringList
	luaL_checktype(L, -1, LUA_TTABLE); // Constants

	int constants = lua_gettop(L);
	int stringList = constants - 1;

	vector<string> protoList = splitString(src.c_str(), src.size(), " ");

	lua_newtable(L);

	int bytecodeid = stoi(protoList.at(0));
	lua_pushinteger(L, bytecodeid);
	lua_setfield(L, -2, "bytecodeid");

	lua_pushvalue(L, -2);
	lua_setfield(L, -2, "k");

	int idx = 1;
	for (string& field : fiuProtoField)
	{
		string s = protoList.at(idx);
		idx++;
		if (s == "?")
			if (field == "debugname")
				lua_pushstring(L, "(??)");
			else
				continue;
		else if (
			field == "debugname" || field == "isvararg" ||
			field == "protos" || field == "code" ||
			field == "lineinfoenabled" || field == "instructionlineinfo" 
		)
		{
			if (field == "isvararg")
			{
				lua_pushboolean(L, s == "1");
			}
			else if (field == "debugname")
			{
				lua_rawgeti(L, stringList, stoi(s));
			}
			else if (field == "protos")
			{
				if (s.size() == 2)
					lua_newtable(L); // empty table
				else
				{
					vector<string> protoRefs = splitString(s.c_str() + 1, s.size() - 3, ",");
					lua_newtable(L);
					int idx = 1;
					for (string& k : protoRefs)
					{
						lua_pushinteger(L, stoi(k));
						lua_rawseti(L, -2, idx);
						idx++;
					}
				}
			}
			else if (field == "code")
			{
				lua_newtable(L);
				int idx = 1;
				for (string& k : protoCode)
				{
					lua_pushvalue(L, constants); // Constants
					lua_pushvalue(L, stringList); // StringList

					size_t len = k.size();
					const char* nk = stripWhiteSpace(k.c_str(), &len);
					fiuDecodeCode(L, nk, len); // ouput table in stack
					
					lua_pushvalue(L, -4); // code table
					lua_pushvalue(L, -2); // output table
					lua_rawseti(L, -2, idx); // output table -> codeList[idx]
					lua_pop(L, 4); // pops: code table, output table, Constants, StringList
					
					idx++;
				}

				lua_newtable(L); // debugcode
				lua_pushvalue(L, -2); // codeList
				lua_pushnil(L);
				idx = 1;
				while (lua_next(L, -2) != 0)
				{
					luaL_checktype(L, -1, LUA_TTABLE);
					int t = lua_getfield(L, -1, "opcode");
					if (t != LUA_TNIL)
					{
						luaL_checktype(L, -1, LUA_TNUMBER);
						lua_rawseti(L, -5, idx); // output number -> debugcode[idx]
						lua_pop(L, 1);
					}
					else
						lua_pop(L, 2); // nil, likely AUX
					idx++;
				}
				luaL_checktype(L, -1, LUA_TTABLE);
				lua_pushvalue(L, -2);
				lua_setfield(L, -5, "debugcode");
				lua_pop(L, 2); // pops: debugcode, codeList<stack ref>
			}
			else if (field == "lineinfoenabled")
			{
				lua_pushboolean(L, s == "1");
			}
			else if (field == "instructionlineinfo")
			{
				if (s.size() == 2)
					lua_newtable(L); // empty table
				else
				{
					vector<string> lineInfo = splitString(s.c_str() + 1, s.size() - 3, ",");
					lua_newtable(L);
					int idx = 1;
					for (string& k : lineInfo)
					{
						lua_pushinteger(L, stoi(k));
						lua_rawseti(L, -2, idx);
						idx++;
					}
				}
			}
		}
		else
		{
			int n = stoi(s);
			lua_pushinteger(L, n);
		}
		lua_setfield(L, -2, field.c_str());
	}
}

string fiuEncodeCode(lua_State* L)
{
	luaL_checktype(L, -2, LUA_TTABLE); // Code
	luaL_checktype(L, -1, LUA_TTABLE); // Constants

	int constants = lua_gettop(L);
	int code = constants - 1;

	string encoded;

	lua_getfield(L, code, "opcode");
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		lua_getfield(L, code, "value");
		if (lua_isnil(L, -1))
		{
			lua_pushstring(L, "Expected opcode or value");
			lua_error(L);
		}
		encoded = uformat("~ %s", luaL_tolstring(L, -1, nullptr));
		lua_pop(L, 4);
		return encoded;
	}
	encoded = string(lua_tostring(L, -1));
	lua_pop(L, 1);
	int kmode = 1;
	for (string& field : fiuCodeField)
	{
		lua_getfield(L, code, field.c_str());
		if (
			field == "K" || field == "K0" || field == "K1" ||
			field == "K2" || field == "KN" || field == "usesAux"
		)
		{
			if (lua_isnil(L, -1))
				encoded.append(" ?");
			else if (field == "KN" || field == "usesAux" || kmode == 5 || (kmode == 6 && field != "K"))
				encoded.append(
					lua_toboolean(L, -1) ? " 1" :
					field == "usesAux" ? " ?" : " 0");
			else
			{
				lua_pushvalue(L, constants);
				lua_pushvalue(L, -2);
				int idx = tableFind(L);
				if (idx == -1)
				{
					lua_pushstring(L, "Expected value in constants");
					lua_error(L);
				}
				else
					encoded.append(uformat(" %d", idx));
				
			}
			lua_pop(L, 1);
			continue;
		}
		else if (field == "kmode")
		{
			kmode = lua_tointeger(L, -1);
		}
		appendOptionalCode(L, encoded);
		lua_pop(L, 1);
	}

	lua_pop(L, 2);

	return encoded;
}

string fiuEncodeProto(lua_State* L, int compact = 0)
{
	luaL_checktype(L, -2, LUA_TTABLE); // Proto
	luaL_checktype(L, -1, LUA_TTABLE); // StringList
	int proto = lua_gettop(L) - 1;
	int stringList = lua_gettop(L);

	string encoded;

	lua_getfield(L, proto, "k");
	if (lua_isnil(L, -1))
	{
		lua_pushstring(L, "Expected k");
		lua_error(L);
	}
	Table* tt = luaH_clone(L, hvalue(luaA_toobject(L, -1)));
	TValue v;
	sethvalue(L, &v, tt);
	lua_pop(L, 1);
	luaA_pushobject(L, &v);

	int constants = lua_gettop(L);

	lua_getfield(L, proto, "bytecodeid");
	if (lua_isnil(L, -1))
	{
		lua_pushstring(L, "Expected bytecodeid");
		lua_error(L);
	}
	encoded.append(uformat("%d", lua_tointeger(L, -1)));
	lua_pop(L, 1);

	for (string& field : fiuProtoField)
	{
		lua_getfield(L, proto, field.c_str());
		if (lua_isnil(L, -1))
		{
			if (field == "debugname")
			{
				encoded.append(" ?");
				lua_pop(L, 1);
				continue;
			}
			lua_pushstring(L, uformat("Expected value at [%s]", field.c_str()).c_str());
			lua_error(L);
		}
		if (
			field == "debugname" || field == "isvararg" ||
			field == "protos" || field == "code" || field == "debugcode" ||
			field == "lineinfoenabled" || field == "instructionlineinfo"
		)
		{
			if (field == "debugname")
			{
				lua_pushvalue(L, stringList);
				lua_pushvalue(L, -2);
				int index = tableFind(L);
				if (index == -1)
				{
					if (strcmp(lua_tostring(L, -1), "(??)") == 0
						|| strcmp(lua_tostring(L, -1), "(main)") == 0) {
						encoded.append(" ?");
					}
					else
					{
						lua_pushstring(L, "Expected string in stringList");
						lua_error(L);
					}
				}
				else
					encoded.append(uformat(" %d", index));
			}
			else if (field == "isvararg")
				encoded.append(lua_toboolean(L, -1) ? " 1" : " 0");
			else if (field == "code")
			{
				luaL_checktype(L, -1, LUA_TTABLE);
				lua_pushnil(L);
				encoded.append(" {");
				int idx = 0;
				while (int nr = lua_next(L, -2) != 0)
				{
					if (idx % compact == 0)
					{
						encoded.append("\n\t");
					}
					else if (compact > 0)
					{
						encoded.append("; ");
					}
					lua_pushvalue(L, constants); // Constants
					encoded.append(fiuEncodeCode(L));
					idx++;
				}
				encoded.append("\n}");
			}
			else if (field == "protos")
			{
				encoded.append(" [");
				luaL_checktype(L, -1, LUA_TTABLE);
				lua_pushnil(L);
				while (int nr = lua_next(L, -2) != 0)
				{
					encoded.append(uformat("%d,", lua_tointeger(L, -1)));
					lua_pop(L, 1);
				}
				encoded.append("]");
			}
			else if (field == "lineinfoenabled")
				encoded.append(lua_toboolean(L, -1) ? " 1" : " 0");
			else if (field == "instructionlineinfo")
			{
				luaL_checktype(L, -1, LUA_TTABLE);
				lua_pushnil(L);
				encoded.append(" [");
				while (int nr = lua_next(L, -2) != 0)
				{
					encoded.append(uformat("%d,", lua_tointeger(L, -1)));
					lua_pop(L, 1);
				}
				encoded.append("]");
			}
			lua_pop(L, 1);
			continue;
		}
		encoded.append(" ");
		encoded.append(lua_tostring(L, -1));
		lua_pop(L, 1);
	}

	{
		lua_pushnil(L);
		int idx = 1;
		while (int nr = lua_next(L, constants) != 0)
		{
			if (lua_type(L, -1) == LUA_TSTRING)
			{
				lua_pushvalue(L, stringList);
				lua_pushvalue(L, -2);
				int index = tableFind(L);
				if (index == -1)
				{
					lua_pushstring(L, "Expected string in stringList");
					lua_error(L);
				}
				lua_pushstring(L, uformat("%d", index).c_str());
				lua_rawseti(L, constants, idx);
			}
			idx++;
			lua_pop(L, 1);
		}
	}

	return encoded;
}

int fiuApiEncodeCode(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TTABLE); // Code
	luaL_checktype(L, 2, LUA_TTABLE); // Constants
	
	string encoded = fiuEncodeCode(L);

	lua_pushstring(L, encoded.c_str());

	return 1;
}

int fiuApiEncodeModule(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TTABLE);

	lua_getfield(L, 1, "typesVersion");
	int typesVersion = lua_gettop(L);
	luaL_checktype(L, -1, LUA_TNUMBER);

	lua_getfield(L, 1, "stringList");
	int stringList = lua_gettop(L);
	luaL_checktype(L, -1, LUA_TTABLE);

	lua_getfield(L, 1, "mainProto");
	int mainProto = lua_gettop(L);
	luaL_checktype(L, -1, LUA_TTABLE);

	lua_getfield(L, 1, "protoList");
	int protoList = lua_gettop(L);
	luaL_checktype(L, -1, LUA_TTABLE);

	lua_pushvalue(L, protoList);
	lua_pushvalue(L, mainProto);
	int index = tableFind(L);
	if (index == -1)
	{
		lua_pushstring(L, "Expected mainProto in protoList");
		lua_error(L);
	}

	lua_newtable(L);
	int constantsList = lua_gettop(L);
	string encoded;

	encoded.append(uformat("%d; ", lua_tointeger(L, typesVersion)));
	encoded.append(uformat("%d; ", index));

	lua_pushvalue(L, protoList);
	lua_pushnil(L);
	int iter = 1;
	while (int nr = lua_next(L, -2) != 0)
	{
		if (iter > 1)
			encoded.append("\n");
		lua_pushvalue(L, -1); // proto
		lua_pushvalue(L, stringList); // StringList
		string encodedProto = fiuEncodeProto(L, 4);
		lua_pushvalue(L, -1); // Constants
		lua_rawseti(L, constantsList, iter);

		encoded.append(encodedProto);
		lua_pop(L, 4); // pops: Constants, StringList, protoList, proto
		iter++;
	}
	
	lua_pushstring(L, encoded.c_str());

	string luaConstantsList = "{\n\t";
	lua_pushvalue(L, constantsList);
	lua_pushnil(L);
	int allocSize = 0;
	while (int nr = lua_next(L, -2) != 0)
	{
		if (allocSize > 23)
		{
			luaConstantsList.append("\n\t");
			allocSize = 0;
		}
		lua_pushnil(L);
		int subSize = 0;
		bool sizeUp = false;
		luaConstantsList.append("{ ");
		while (int nr = lua_next(L, -2) != 0)
		{
			if (subSize / 18 > 1)
			{
				luaConstantsList.append("\n\t\t");
				subSize = 1;
				sizeUp = true;
			}
			
			size_t len = 0;
			int iterSize = 1;
			switch (lua_type(L, -1))
			{
			case LUA_TNUMBER:
				luaConstantsList.append(luaL_tolstring(L, -1, &len));
				lua_pop(L, 1);
				break;
			case LUA_TTABLE:
				luaConstantsList.append("{ ");
				lua_pushnil(L);
				while (int nr = lua_next(L, -2) != 0)
				{
					if (iterSize % 8 == 0)
						luaConstantsList.append("\n\t\t\t");
					size_t lenSub;
					luaConstantsList.append(luaL_tolstring(L, -1, &lenSub));
					lua_pop(L, 1);
					luaConstantsList.append(",");
					len += lenSub;
					lua_pop(L, 1);
					iterSize++;
				}
				if (iterSize / 8 > 1)
					luaConstantsList.append("\n\t\t\t");
				luaConstantsList.append("}");
				break;
			case LUA_TSTRING:
				luaConstantsList.append("\"");
				luaConstantsList.append(luaL_tolstring(L, -1, &len));
				lua_pop(L, 1);
				luaConstantsList.append("\"");
				break;
			case LUA_TNIL:
				luaConstantsList.append("nil");
				len = 3;
				break;
			default:
				break;
			}
			luaConstantsList.append(",");
			subSize += len;
			lua_pop(L, 1);
		}
		if (sizeUp)
			luaConstantsList.append("\n\t");
		allocSize += subSize;
		luaConstantsList.append("},");
		lua_pop(L, 1);
	}
	luaConstantsList.append("\n}");
	lua_pop(L, 1);

	string luaStringList = "{\n\t";
	lua_pushvalue(L, stringList);
	lua_pushnil(L);
	allocSize = 0;
	while (int nr = lua_next(L, -2) != 0)
	{
		if (allocSize > 23)
		{
			luaStringList.append("\n\t");
			allocSize = 0;
		}
		
		luaStringList.append("\"");
		size_t len;
		const char* s = luaL_tolstring(L, -1, &len);
		lua_pop(L, 1);
		for (int i = 0; i < len; i++)
		{
			luaStringList.append("\\");
			luaStringList.append(to_string((unsigned char)(s[1 + i - 1])));
		}
		luaStringList.append("\",");
		allocSize += len;

		lua_pop(L, 1);
	}
	luaStringList.append("\n}");
	lua_pop(L, 1);

	lua_pushstring(L, luaConstantsList.c_str());
	lua_pushstring(L, luaStringList.c_str());

	return 3;
}

int fiuApiDecodeCode(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TSTRING); // Encoded code
	luaL_checktype(L, 2, LUA_TTABLE); // Constants
	luaL_checktype(L, 3, LUA_TTABLE); // StringList

	size_t srcLen;
	const char* src = luaL_checklstring(L, 1, &srcLen);

	fiuDecodeCode(L, src, srcLen);

	return 1;
}

int fiuApiDecodeModule(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TSTRING); // Encoded module
	luaL_checktype(L, 2, LUA_TTABLE); // Constants
	luaL_checktype(L, 3, LUA_TTABLE); // StringList

	size_t srcLen;
	const char* src = luaL_checklstring(L, 1, &srcLen);

	vector<string> moduleList;
	
	for (string& k : splitString(src, srcLen, "\n"))
	{
		vector<string> subList = splitString(k.c_str(), k.size(), ";");
		moduleList.insert(moduleList.end(), subList.begin(), subList.end());
	}

	for (string& k : moduleList)
	{
		k = string(stripWhiteSpace(k.c_str(), nullptr));
	}
	
	moduleList.erase(
		remove_if(moduleList.begin(), moduleList.end(), isBlank),
		moduleList.end()
	);
	
	int typesVersion = stoi(moduleList.at(0));
	int mainProtoId = stoi(moduleList.at(1));
	moduleList.erase(moduleList.begin(), moduleList.begin() + 2);

	lua_newtable(L);

	lua_pushinteger(L, typesVersion);
	lua_setfield(L, -2, "typesVersion");

	lua_newtable(L);
	int idx = 1;
	bool isProto = false;
	string protoInfo;
	vector<string> protoCode;
	for (string& k : moduleList)
	{
		const char* lastChar = k.c_str() + k.size() - 1;
		if (isProto)
		{
			if (memcmp(lastChar, "}", 1) == 0)
			{
				isProto = false;
				lua_pushvalue(L, 3); // StringList
				lua_rawgeti(L, 2, idx); // Constants[idx]
				fiuDecodeProto(L, protoInfo, protoCode); // output table in stack

				lua_pushvalue(L, -4); // protoList
				lua_pushvalue(L, -2); // output table
				lua_rawseti(L, -2, idx); // output table -> protoList[idx]

				lua_pop(L, 4); // pops: protoList table, output table, Constants, StringList
				
				lua_rawgeti(L, 2, idx); // Constants[idx]
				lua_pushnil(L);
				while (int nr = lua_next(L, -2) != 0)
				{
					if (lua_type(L, -1) == LUA_TSTRING)
					{
						int key = lua_tonumber(L, -2);
						int index = lua_tonumber(L, -1);
						lua_rawgeti(L, 3, index);
						lua_rawseti(L, -4, key);
					}
					lua_pop(L, 1);
				}
				lua_pop(L, 1);

				idx++;
				protoCode.clear();
			}
			else
				protoCode.push_back(k);
		}
		if (memcmp(lastChar, "{", 1) == 0)
		{
			isProto = true;
			protoInfo = k;
		}
	}
	lua_pushvalue(L, -2);
	lua_rawgeti(L, -2, mainProtoId);
	lua_pushstring(L, "(main)");
	lua_setfield(L, -2, "debugname");
	lua_setfield(L, -2, "mainProto");
	lua_pop(L, 1);
	
	lua_setfield(L, -2, "protoList");

	lua_pushvalue(L, 3);
	lua_setfield(L, -2, "stringList");

	return 1;
}

int fiuApiMakeCode(lua_State* L)
{
	luaL_checktype(L, 1, LUA_TSTRING); // Encoded Module
	luaL_checktype(L, 2, LUA_TSTRING); // Constants
	luaL_checktype(L, 3, LUA_TSTRING); // StringList

	string code = "local encodedModule, constantList, stringList = [[\n";
	code.append(lua_tostring(L, 1));
	code.append("]], ");
	code.append(lua_tostring(L, 2));
	code.append(", ");
	code.append(lua_tostring(L, 3));
	code.append("\n\nassert(MATCH(\n\tFiu.luau_deserialize(compileResult),\n\tFiuUtils.decodeModule(encodedModule, constantList, stringList)\n))\n\nOK()");

	lua_pushlstring(L, code.c_str(), code.size());

	return 1;
}

void loadFiuUtils(lua_State* L)
{
	static const luaL_Reg funcs[] = {
		{"encodeCode", fiuApiEncodeCode},
		{"encodeModule", fiuApiEncodeModule},
		{"decodeCode", fiuApiDecodeCode},
		{"decodeModule", fiuApiDecodeModule},
		{"makeCode", fiuApiMakeCode},
		{NULL, NULL},
	};

	luaL_register(L, "FiuUtils", funcs);
}