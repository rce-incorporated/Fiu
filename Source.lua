local Bytestring =
	"\003\002\005print\vHello World\001\002\000\000\001\006A\000\000\000\f\000\001\000\000\000\000@\005\001\002\000\021\000\002\001\022\000\001\000\003\003\001\004\000\000\000@\003\002\000\001\000\001\024\000\000\000\000\000\000\001\000\000\000\000\000"
local function luau_newmodule()
	local m = {}
	m.slist = {}
	m.plist = {}
	return m
end
local function luau_newproto()
	local c = {}
	c.code = {}
	c.k = {}
	c.protos = {}
	return c
end
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
	"JUMPXEQKS",
}
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
	BREAK = "ABC",
}
local function luau_deserialize(chunk)
	local position = 1
	local function read_byte()
		local b = string.unpack(">B", chunk, position)
		position = position + 1
		return b
	end
	local function read_integer()
		local int = string.unpack("I4", chunk, position)
		position = position + 4
		return int
	end
	local function read_double()
		local d = string.unpack("d", chunk, position)
		position = position + 8
		return d
	end
	local function read_variable_integer()
		local result = 0
		for i = 0, 7 do
			local value = read_byte()
			result = bit32.bor(result, bit32.lshift(bit32.band(value, 0x7F), i * 7))
			if bit32.band(value, 0x80) == 0 then
				break
			end
		end
		return result
	end
	local function read_string()
		local size = read_variable_integer()
		local str
		if size == 0 then
			return ""
		else
			str = string.unpack("c" .. size, chunk, position)
			position = position + size
		end
		return str
	end
	local function readproto()
		local p = luau_newproto()
		p.maxstacksize = read_byte()
		p.numparams = read_byte()
		p.nups = read_byte()
		p.isvararg = read_byte() ~= 0
		p.sizecode = read_variable_integer()
		for i = 1, p.sizecode do
			local i = {}
			i.value = read_integer()
			i.opcode = bit32.band(i.value, 0xFF)
			i.opname = op_names[i.opcode]
			i.type = op_list[i.opname]
			if i.type == "ABC" then
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				i.B = bit32.band(bit32.rshift(i.value, 16), 0xFF)
				i.C = bit32.band(bit32.rshift(i.value, 24), 0xFF)
			elseif i.type == "AB" then
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				i.B = bit32.band(bit32.rshift(i.value, 16), 0xFF)
			elseif i.type == "A" then
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
			elseif i.type == "AD" then
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				local temp = bit32.band(bit32.rshift(i.value, 16), 0xFF)
				i.D = if temp < 0x8000 then temp else temp - 0x10000
			elseif i.type == "AE" then
				local temp = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				i.E = if temp < 0x800000 then temp else temp - 0x1000000
			end
			table.insert(p.code, i)
		end
		p.sizek = read_variable_integer()
		for i = 1, p.sizek do
			local kt = read_byte()
			local k = {}
			if kt == 0 then
				k.type = "nil"
				k.data = nil
			elseif kt == 1 then
				k.type = "bool"
				k.data = read_byte() ~= 0
			elseif kt == 2 then
				k.type = "number"
				k.data = read_double()
			elseif kt == 3 then
				k.type = "string"
				k.data = read_variable_integer()
			elseif kt == 4 then
				k.type = "import"
				k.data = read_integer()
			elseif kt == 5 then
				local data = {}
				local dataLength = read_variable_integer()
				for i = 1, dataLength do
					table.insert(data, read_variable_integer())
				end
				k.type = "table"
				k.data = data
			elseif kt == 6 then
				k.type = "closure"
				k.data = read_variable_integer()
			end
			table.insert(p.k, k)
		end
		p.sizep = read_variable_integer()
		for i = 1, p.sizep do
			table.insert(p.protos, read_variable_integer())
		end
		read_variable_integer()
		read_variable_integer()
		if read_byte() ~= 0 then
			local lineGap = read_byte()
			for i = 1, p.sizecode do
				read_byte()
			end
			local intervals = bit32.rshift(p.sizecode - 1, lineGap) + 1
			for i = 1, intervals do
				read_integer()
			end
		end
		if read_byte() ~= 0 then
			local sizel = read_variable_integer()
			for i = 1, sizel do
				read_variable_integer()
				read_variable_integer()
				read_variable_integer()
				read_byte()
			end
		end
		return p
	end
	local luauVersion = read_byte()
	if luauVersion ~= 3 then
		error("Incorrect Bytecode Provided", 0)
	end
	local module = luau_newmodule()
	local stringCount = read_variable_integer()
	for i = 1, stringCount do
		table.insert(module.slist, read_string())
	end
	local protoCount = read_variable_integer()
	for i = 1, protoCount do
		table.insert(module.plist, readproto())
	end
	module.mainp = read_variable_integer()
	return module
end
local function luau_load(module, env)
	local mainProto = module.plist[module.mainp + 1]
	local stringsList = module.slist
	local function luau_wrapclosure(module, proto, env, upval)
		local function luau_execute(debugging, protos, code, varargs)
			local top, pc, stack = -1, 1, {}
			local constants = proto.k
			while true do
				local inst = code[pc]
				local op = inst.opcode
				pc = pc + 1
				debugging.pc = pc
				debugging.name = inst.opname
				if op == 5 then --[[ LOADK ]]
					stack[inst.A] = stringsList[constants[inst.D + 1].data]
				elseif op == 12 then --[[ GETIMPORT ]]
					pc = pc + 1
					local extend = code[pc].value
					local count = bit32.rshift(extend, 30)
					local id0 = bit32.band(bit32.rshift(extend, 20), 0x3FF)

					--[[
                    uint id0 = (extend >> 20) & 0x3FF;
                    uint id1 = (extend >> 10) & 0x3FF;
                    uint id2 = (extend >> 00) & 0x3FF;
					]]
					if count == 0 then
						stack[inst.A] = env[stringsList[constants[id0 + 1].data]]
					elseif count == 1 then
					elseif count == 2 then
					end
				elseif op == 21 then --[[ CALL ]]
					local A, B, C = inst.A, inst.B, inst.C

					local params = if B == 0 then top - A else B - 1
					local ret_list = table.pack(stack[A](table.unpack(stack, A + 1, A + params)))
					local ret_num = ret_list.n

					if C == 0 then
						top_index = A + ret_num - 1
					else
						ret_num = C - 1
					end

					table.move(ret_list, 1, ret_num, A, stack)
				elseif op == 22 then --[[ RETURN ]]
					return
				elseif op == 65 then --[[ PREPVARARGS ]]
					local numparams = inst.A
					for i = 1, numparams do
					end
				end
			end
		end
		local function wrapped(...)
			local passed = table.pack(...)
			local stack = table.create(proto.maxstacksize)
			local varargs = {
				len = 0,
				list = {},
			}
			table.move(passed, 1, proto.numparams, 0, stack)
			if proto.numparams < passed.n then
				local start = proto.numparams + 1
				local len = passed.n - proto.numparams
				varargs.len = len
				table.move(passed, start, start + len - 1, 1, varargs.list)
			end
			local debugging = {}
			local result = table.pack(pcall(luau_execute, debugging, proto.protos, proto.code, varargs))
			if result[1] then
				return table.unpack(result, 2, result.n)
			else
				error(string.format("Fiu VM Error PC: %s Opcode: %s: \n%s", debugging.pc, debugging.name, result[2]), 0)
			end
		end
		return wrapped
	end
	return luau_wrapclosure(module, mainProto, env)
end

return {
	luau_load = luau_load,
	luau_newproto = luau_newproto,
	luau_newmodule = luau_newmodule,
	luau_deserialize = luau_deserialize,
}
