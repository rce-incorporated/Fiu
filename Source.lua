local Bytestring = "\003\002\005print\vHello World\001\002\000\000\001\006A\000\000\000\f\000\001\000\000\000\000@\005\001\002\000\021\000\002\001\022\000\001\000\003\003\001\004\000\000\000@\003\002\000\001\000\001\024\000\000\000\000\000\000\001\000\000\000\000\000";
local luaF_newmodule;
local luaF_newLclosure;
local luaF_dispatch;
local luaU_undump;
local luaF_wrap;
local op_names = {
	[0] = "NOP",
	"BREAK",
	"LOADNIL",
	"LOADB",
	"LOADN",
	"LOADK",
	"MOVE",
	"GETGLOBAL",
	"SETGLOBAL",
	"GETUPVAL",
	"SETUPVAL",
	"CLOSEUPVALS",
	"GETIMPORT",
	"GETTABLE",
	"SETTABLE",
	"GETTABLEKS",
	"SETTABLEKS",
	"GETTABLEN",
	"SETTABLEN",
	"NEWCLOSURE",
	"NAMECALL",
	"CALL",
	"RETURN",
	"JUMP",
	"JUMPBACK",
	"JUMPIF",
	"JUMPIFNOT",
	"JUMPIFEQ",
	"JUMPIFLE",
	"JUMPIFLT",
	"JUMPIFNOTEQ",
	"JUMPIFNOTLE",
	"JUMPIFNOTLT",
	"ADD",
	"SUB",
	"MUL",
	"DIV",
	"MOD",
	"POW",
	"ADDK",
	"SUBK",
	"MULK",
	"DIVK",
	"MODK",
	"POWK",
	"AND",
	"OR",
	"ANDK",
	"ORK",
	"CONCAT",
	"NOT",
	"MINUS",
	"LENGTH",
	"NEWTABLE",
	"DUPTABLE",
	"SETLIST",
	"FORNPREP",
	"FORNLOOP",
	"FORGLOOP",
	"FORGPREP_INEXT",
	"FORGLOOP_INEXT",
	"FORGPREP_NEXT",
	"FORGLOOP_NEXT",
	"GETVARARGS",
	"DUPCLOSURE",
	"PREPVARARGS",
	"LOADKX",
	"JUMPX",
	"FASTCALL",
	"COVERAGE",
	"CAPTURE",
	"JUMPIFEQK",
	"JUMPIFNOEQK",
	"FASTCALL1",
	"FASTCALL2",
	"FASTCALL2K",
	"FORGPREP",
	"JUMPXEQKNIL",
	"JUMPXEQKB",
	"JUMPXEQKN",
	"JUMPXEQKS"
};
local op_list = {
	LOADNIL = "A",
	LOADB = "ABC",
	LOADN = "A",
	LOADK = "AD",
	MOVE = "AB",
	GETGLOBAL = "A",
	SETGLOBAL = "A",
	GETUPVALUE = "AB",
	SETUPVALUE = "AB",
	CLOSEUPVALUES = "A",
	GETIMPORT = "AD",
	GETTABLE = "ABC",
	SETTABLE = "ABC",
	GETTABLEKEY = "AB",
	SETTABLEKEY = "AB",
	GETTABLEINDEX = "AB",
	SETTABLEINDEX = "AB",
	NEWCLOSURE = "AD",
	NAMECALL = "AB",
	CALL = "ABC",
	RETURN = "AB",
	JUMP = "AD",
	JUMPBACK = "AD",
	JUMPIF = "AD",
	JUMPIFNOT = "AD",
	JUMPIFEQ = "AD",
	JUMPIFLE = "AD",
	JUMPIFLT = "AD",
	JUMPIFNOTEQ = "AD",
	JUMPIFNOTLE = "AD",
	JUMPIFNOTLT = "AD",
	ADD = "ABC",
	SUB = "ABC",
	MUL = "ABC",
	DIV = "ABC",
	MOD = "ABC",
	POW = "ABC",
	ADDK = "ABC",
	SUBK = "ABC",
	MULK = "ABC",
	DIVK = "ABC",
	MODK = "ABC",
	POWK = "ABC",
	AND = "ABC",
	OR = "ABC",
	ANDK = "ABC",
	ORK = "ABC",
	CONCAT = "ABC",
	NOT = "AB",
	MINUS = "AB",
	LENGTH = "AB",
	NEWTABLE = "A",
	DUPTABLE = "AD",
	SETLIST = "ABC",
	FORNPREP = "AD",
	FORNLOOP = "AD",
	FORGLOOP = "AD",
	FORGPREP_INEXT = "AD",
	FORGLOOP_INEXT = "AD",
	FORGPREP_NEXT = "AD",
	FORGLOOP_NEXT = "AD",
	GETVARARGS = "AB",
	DUPCLOSURE = "AD",
	PREPVARARGS = "A",
	LOADKX = "ABC",
	JUMPX = "AE",
	JUMPXEQKNIL = "AE",
	JUMPXEQKB = "AE",
	JUMPXEQKN = "AE",
	JUMPXEQKS = "AE",
	FASTCALL = "A",
	CAPTURE = "AB",
	JUMPIFCONSTANT = "AD",
	JUMPIFNOTCONSTANT = "AD",
	FASTCALL1 = "ABC",
	FASTCALL2 = "ABC",
	FASTCALL2K = "ABC",
	COVERAGE = "ABC",
	NOP = "ABC",
	BREAK = "ABC"
};
local function fail(msg)
	error(msg .. " precompiled chunk", 0);
end;
function luaF_newmodule()
	local m = {};
	m.slist = {};
	m.plist = {};
	return m;
end;
function luaF_newLclosure()
	local c = {};
	c.code = {};
	c.k = {};
	c.p = {};
	return c;
end;
function luaU_undump(chunk)
	local position = 1;
	local module = luaF_newmodule();
	local readproto;
	local function readbyte()
		local b = string.unpack(">B", chunk, position);
		position = position + 1;
		return b;
	end;
	local function readinteger()
		local int = string.unpack("I4", chunk, position);
		position = position + 4;
		return int;
	end;
	local function readdouble()
		local d = string.unpack("d", chunk, position);
		position = position + 8;
		return d;
	end;
	local function readvariableinteger()
		local result = 0;
		for i = 0, 7 do
			local value = readbyte();
			result = bit32.bor(result, bit32.lshift(bit32.band(value, 127), i * 7));
			if bit32.band(value, 128) == 0 then
				break;
			end;
		end;
		return result;
	end;
	local function readstring()
		local size = readvariableinteger();
		local str;
		if size == 0 then
			return "";
		else
			str = string.unpack("c" .. size, chunk, position);
			position = position + size;
		end;
		return str;
	end;
	local function readconstant()
		local kt = readbyte();
		if kt == 0 then
			return {
				type = "nil",
				data = nil
			};
		elseif kt == 1 then
			return {
				type = "bool",
				data = readbyte() ~= 0
			};
		elseif kt == 2 then
			return {
				type = "number",
				data = readdouble()
			};
		elseif kt == 3 then
			return {
				type = "string",
				data = readvariableinteger()
			};
		elseif kt == 4 then
			return {
				type = "import",
				data = readinteger()
			};
		elseif kt == 5 then
			local data = {};
			local dataLength = readvariableinteger();
			for i = 1, dataLength do
				table.insert(data, readvariableinteger());
			end;
			return {
				type = "table",
				data = data
			};
		elseif kt == 6 then
			return {
				type = "closure",
				data = readvariableinteger()
			};
		end;
	end;
	local function readinstruction()
		local i = {};
		i.value = readinteger();
		i.opcode = op_names[bit32.band(i.value, 255)];
		i.type = op_list[i.opcode];
		if i.type == "ABC" then
			i.A = bit32.band(bit32.rshift(i.value, 8), 255);
			i.B = bit32.band(bit32.rshift(i.value, 16), 255);
			i.C = bit32.band(bit32.rshift(i.value, 24), 255);
		elseif i.type == "AB" then
			i.A = bit32.band(bit32.rshift(i.value, 8), 255);
			i.B = bit32.band(bit32.rshift(i.value, 16), 255);
		elseif i.type == "A" then
			i.A = bit32.band(bit32.rshift(i.value, 8), 255);
		elseif i.type == "AD" then
			i.A = bit32.band(bit32.rshift(i.value, 8), 255);
			local temp = bit32.band(bit32.rshift(i.value, 16), 255);
			i.D = temp < 32768 and temp or temp - 65536;
		elseif i.type == "AE" then
			local temp = bit32.band(bit32.rshift(i.value, 8), 255);
			i.E = temp < 8388608 and temp or temp - 16777216;
		end;
		return i;
	end;
	local function readproto()
		local p = luaF_newLclosure();
		p.maxstacksize = readbyte();
		p.numparams = readbyte();
		p.nups = readbyte();
		p.isvararg = readbyte() ~= 0;
		p.sizecode = readvariableinteger();
		for i = 1, p.sizecode do
			table.insert(p.code, readinstruction());
		end;
		p.sizek = readvariableinteger();
		for i = 1, p.sizek do
			table.insert(p.k, readconstant());
		end;
		p.sizep = readvariableinteger();
		for i = 1, p.sizep do
			table.insert(p.p, readvariableinteger());
		end;
		readvariableinteger();
		readvariableinteger();
		if readbyte() ~= 0 then
			local lineGap = readbyte();
			for i = 1, p.sizecode do
				readbyte();
			end;
			local intervals = bit32.rshift(p.sizecode - 1, lineGap) + 1;
			for i = 1, intervals do
				readinteger();
			end;
		end;
		if readbyte() ~= 0 then
			local sizel = readvariableinteger();
			for i = 1, sizel do
				readvariableinteger();
				readvariableinteger();
				readvariableinteger();
				readbyte();
			end;
		end;
		return p;
	end;
	local luauVersion = readbyte();
	if luauVersion ~= 3 then
		fail("Fiu expected Luau bytecode!");
	end;
	local stringCount = readvariableinteger();
	for i = 1, stringCount do
		table.insert(module.slist, readstring());
	end;
	local protoCount = readvariableinteger();
	for i = 1, protoCount do
		table.insert(module.plist, readproto());
	end;
end;
luaU_undump(Bytestring);
