local Bytestring = "\003\002\005print\vHello World\001\002\000\000\001\006A\000\000\000\f\000\001\000\000\000\000@\005\001\002\000\021\000\002\001\022\000\001\000\003\003\001\004\000\000\000@\003\002\000\001\000\001\024\000\000\000\000\000\000\001\000\000\000\000\000";
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
	JUMPIFK = "AD",
	JUMPIFNOTK = "AD",
	FASTCALL1 = "ABC",
	FASTCALL2 = "ABC",
	FASTCALL2K = "ABC",
	COVERAGE = "ABC",
	NOP = "ABC",
	BREAK = "ABC"
};
local function deserializer_fail(msg)
	error(msg .. " Incorrect Version Provided", 0);
end;
local function luau_newmodule()
	local m = {};
	m.slist = {};
	m.plist = {};
	return m;
end;
local function luau_newproto()
	local c = {};
	c.code = {};
	c.k = {};
	c.p = {};
	return c;
end;
local function luau_deserialize(chunk)
	local position = 1;
	local module = luau_newmodule();
	local readproto;
	local function read_byte()
		local b = string.unpack(">B", chunk, position);
		position = position + 1;
		return b;
	end;
	local function read_integer()
		local int = string.unpack("I4", chunk, position);
		position = position + 4;
		return int;
	end;
	local function read_double()
		local d = string.unpack("d", chunk, position);
		position = position + 8;
		return d;
	end;
	local function read_variable_integer()
		local result = 0;
		for i = 0, 7 do
			local value = read_byte();
			result = bit32.bor(result, bit32.lshift(bit32.band(value, 127), i * 7));
			if bit32.band(value, 128) == 0 then
				break;
			end;
		end;
		return result;
	end;
	local function read_string()
		local size = read_variable_integer();
		local str;
		if size == 0 then
			return "";
		else
			str = string.unpack("c" .. size, chunk, position);
			position = position + size;
		end;
		return str;
	end;
	local function readproto()
		local p = luau_newproto();
		p.maxstacksize = read_byte();
		p.numparams = read_byte();
		p.nups = read_byte();
		p.isvararg = read_byte() ~= 0;
		p.sizecode = read_variable_integer();
		for i = 1, p.sizecode do
			local i = {};
			i.value = read_integer();
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
			table.insert(p.code, i);
		end;
		p.sizek = read_variable_integer();
		for i = 1, p.sizek do
			local kt = read_byte();
			local k = {};
			if kt == 0 then
				k.type = "nil";
				k.data = nil;
			elseif kt == 1 then
				k.type = "bool";
				k.data = read_byte() ~= 0;
			elseif kt == 2 then
				k.type = "number";
				k.data = read_double();
			elseif kt == 3 then
				k.type = "string";
				k.data = read_variable_integer();
			elseif kt == 4 then
				k.type = "import";
				k.data = read_integer();
			elseif kt == 5 then
				local data = {};
				local dataLength = read_variable_integer();
				for i = 1, dataLength do
					table.insert(data, read_variable_integer());
				end;
				k.type = "table";
				k.data = data;
			elseif kt == 6 then
				k.type = "closure";
				k.data = read_variable_integer();
			end;
			table.insert(p.k, k);
		end;
		p.sizep = read_variable_integer();
		for i = 1, p.sizep do
			table.insert(p.p, read_variable_integer());
		end;
		read_variable_integer();
		read_variable_integer();
		if read_byte() ~= 0 then
			local lineGap = read_byte();
			for i = 1, p.sizecode do
				read_byte();
			end;
			local intervals = bit32.rshift(p.sizecode - 1, lineGap) + 1;
			for i = 1, intervals do
				read_integer();
			end;
		end;
		if read_byte() ~= 0 then
			local sizel = read_variable_integer();
			for i = 1, sizel do
				read_variable_integer();
				read_variable_integer();
				read_variable_integer();
				read_byte();
			end;
		end;
		return p;
	end;
	local luauVersion = read_byte();
	if luauVersion ~= 3 then
		deserializer_fail("Fiu expected Luau bytecode!");
	end;
	local stringCount = read_variable_integer();
	for i = 1, stringCount do
		table.insert(module.slist, read_string());
	end;
	local protoCount = read_variable_integer();
	for i = 1, protoCount do
		table.insert(module.plist, readproto());
	end;
	module.mainp = read_variable_integer();
	return module;
end;
local function luau_wrapclosure(proto, env, upval)
	local function vm_fail(pc, opcode_name, traceback)
		error(string.format("Fiu VM Error PC: %s Opcode: %s: \n", pc, opcode_name) .. traceback, 0);
	end;
	local function wrapped(...)
		local passed = table.pack(...);
		local memory = table.create(proto.maxstacksize);
		local vararg = {
			len = 0,
			list = {}
		};
		table.move(passed, 1, proto.numparams, 0, memory);
		if proto.numparams < passed.n then
			local start = proto.numparams + 1;
			local len = passed.n - proto.numparams;
			vararg.len = len;
			table.move(passed, start, start + len - 1, 1, vararg.list);
		end;
		local state = {
			vararg = vararg,
			memory = memory,
			code = proto.code,
			protos = proto.p,
			pc = 1
		};
		local result = table.pack(pcall(run_lua_func, state, env, upval));
		if result[1] then
			return table.unpack(result, 2, result.n);
		else
			vm_fail(state.pc, proto.code[state.pc].opcode, result[2]);
			return;
		end;
	end;
	return wrapped;
end;
local function luau_load(module, env)
	local proto = module.plist[module.mainp + 1];
	return luau_wrapclosure(proto, env);
end;
local chunk = luau_deserialize(Bytestring);
(luau_load(chunk, getfenv()))();
return {
	luau_load = luau_load,
	luau_wrapclosure = luau_wrapclosure
};
