local function luau_newmodule()
	return {
		slist = {},
		plist = {}
	}
end
local function luau_newproto()
	return {
		code = {},
		k = {},
		protos = {}
	}
end
--[[
NOP/REMOVED - 0
A - 1
AB - 2
ABC - 3
AD - 4
AE - 5 
]]
local op_list = {
	[0] = {"NOP", 0},
	{"BREAK", 0},
	{"LOADNIL", 1},
	{"LOADB", 3},
	{"LOADN", 4},
	{"LOADK", 4},
	{"MOVE", 2},
	{"GETGLOBAL", 1},
	{"SETGLOBAL", 1},
	{"GETUPVAL", 2},
	{"SETUPVAL", 2},
	{"CLOSEUPVALS", 1},
	{"GETIMPORT", 4},
	{"GETTABLE", 3},
	{"SETTABLE", 3},
	{"GETTABLEKS", 3},
	{"SETTABLEKS", 3},
	{"GETTABLEN", 3},
	{"SETTABLEN", 3},
	{"NEWCLOSURE", 4},
	{"NAMECALL", 3},
	{"CALL", 3},
	{"RETURN", 2},
	{"JUMP", 4},
	{"JUMPBACK", 4},
	{"JUMPIF", 4},
	{"JUMPIFNOT", 4},
	{"JUMPIFEQ", 4},
	{"JUMPIFLE", 4},
	{"JUMPIFLT", 4},
	{"JUMPIFNOTEQ", 4},
	{"JUMPIFNOTLE", 4},
	{"JUMPIFNOTLT", 4},
	{"ADD", 3},
	{"SUB", 3},
	{"MUL", 3},
	{"DIV", 3},
	{"MOD", 3},
	{"POW", 3},
	{"ADDK", 3},
	{"SUBK", 3},
	{"MULK", 3},
	{"DIVK", 3},
	{"MODK", 3},
	{"POWK", 3},
	{"AND", 3},
	{"OR", 3},
	{"ANDK", 3},
	{"ORK", 3},
	{"CONCAT", 3},
	{"NOT", 2},
	{"MINUS", 2},
	{"LENGTH", 2},
	{"NEWTABLE", 2},
	{"DUPTABLE", 4},
	{"SETLIST", 4},
	{"FORNPREP", 4},
	{"FORNLOOP", 4},
	{"FORGLOOP", 4},
	{"FORGPREP_INEXT", 1},
	{"LOP_DEP_FORGLOOP_INEXT", 0},
	{"FORGPREP_NEXT", 1},
	{"LOP_DEP_FORGLOOP_NEXT", 0},
	{"GETVARARGS", 2},
	{"DUPCLOSURE", 4},
	{"PREPVARARGS", 1},
	{"LOADKX", 1},
	{"JUMPX", 5},
	{"FASTCALL", 3},
	{"COVERAGE", 5},
	{"CAPTURE", 2},
	{"LOP_DEP_JUMPIFEQK", 0},
    {"LOP_DEP_JUMPIFNOTEQK", 0},
	{"FASTCALL1", 3},
	{"FASTCALL2", 3},
	{"FASTCALL2K", 3},
	{"FORGPREP", 4},
	{"JUMPXEQKNIL", 4},
	{"JUMPXEQKB", 4},
	{"JUMPXEQKN", 4},
	{"JUMPXEQKS", 4}
}

local function luau_deserialize(bytecode)
	local position = 1
	local function read_byte()
		local b = string.unpack(">B", bytecode, position)
		position = position + 1
		return b
	end
	local function read_integer()
		local int = string.unpack("I4", bytecode, position)
		position = position + 4
		return int
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
			str = string.unpack("c" .. size, bytecode, position)
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
			local opcode = op_list[i.opcode]
			i.opname = opcode[1]
			i.type = opcode[2]
			if i.type == 3 then --[[ ABC ]]
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				i.B = bit32.band(bit32.rshift(i.value, 16), 0xFF)
				i.C = bit32.band(bit32.rshift(i.value, 24), 0xFF)
			elseif i.type == 2 then --[[ AB ]]
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				i.B = bit32.band(bit32.rshift(i.value, 16), 0xFF)
			elseif i.type == 1 then --[[ A ]]
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
			elseif i.type == 4 then --[[ AD ]]
				i.A = bit32.band(bit32.rshift(i.value, 8), 0xFF)
				local temp = bit32.band(bit32.rshift(i.value, 16), 0xFF)
				i.D = if temp < 0x8000 then temp else temp - 0x10000
			elseif i.type == 5 then --[[ AE ]]
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
				local d = string.unpack("d", bytecode, position)
				position = position + 8
				k.data = d
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
	assert(position == #bytecode + 1, "Deserializer Position Mismatch")
	return module
end
local function luau_load(module, env)
	if (type(module) == "string") then 
		module = luau_deserialize(module)
	end 

	local mainProto = module.plist[module.mainp + 1]
	local stringsList = module.slist
	local function luau_wrapclosure(module, proto, upval)
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
			local result 
			if false then 
				result = table.pack(pcall(luau_execute, debugging, proto.protos, proto.code, varargs))
			else
				result = table.pack(true, luau_execute(debugging, proto.protos, proto.code, varargs))
			end
			if result[1] then
				return table.unpack(result, 2, result.n)
			else
				error(string.format("Fiu VM Error PC: %s Opcode: %s: \n%s", debugging.pc, debugging.name, result[2]), 0)
			end
		end
		return wrapped
	end
	return luau_wrapclosure(module, mainProto)
end

return {
	luau_load = luau_load,
	luau_newproto = luau_newproto,
	luau_newmodule = luau_newmodule,
	luau_deserialize = luau_deserialize,
}
