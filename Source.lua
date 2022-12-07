local function luau_newmodule()
	return {
		slist = {},
		plist = {},
	}
end

local function luau_newproto()
	return {
		code = {},
		k = {},
		protos = {},
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
	{ "NOP", 0 },
	{ "BREAK", 0 },
	{ "LOADNIL", 1 },
	{ "LOADB", 3 },
	{ "LOADN", 4 },
	{ "LOADK", 4 },
	{ "MOVE", 2 },
	{ "GETGLOBAL", 1, true },
	{ "SETGLOBAL", 1, true },
	{ "GETUPVAL", 2 },
	{ "SETUPVAL", 2 },
	{ "CLOSEUPVALS", 1 },
	{ "GETIMPORT", 4, true },
	{ "GETTABLE", 3 },
	{ "SETTABLE", 3 },
	{ "GETTABLEKS", 3, true },
	{ "SETTABLEKS", 3, true },
	{ "GETTABLEN", 3 },
	{ "SETTABLEN", 3 },
	{ "NEWCLOSURE", 4 },
	{ "NAMECALL", 3, true },
	{ "CALL", 3 },
	{ "RETURN", 2 },
	{ "JUMP", 4 },
	{ "JUMPBACK", 4 },
	{ "JUMPIF", 4 },
	{ "JUMPIFNOT", 4 },
	{ "JUMPIFEQ", 4, true },
	{ "JUMPIFLE", 4, true },
	{ "JUMPIFLT", 4, true },
	{ "JUMPIFNOTEQ", 4, true },
	{ "JUMPIFNOTLE", 4, true },
	{ "JUMPIFNOTLT", 4, true },
	{ "ADD", 3 },
	{ "SUB", 3 },
	{ "MUL", 3 },
	{ "DIV", 3 },
	{ "MOD", 3 },
	{ "POW", 3 },
	{ "ADDK", 3 },
	{ "SUBK", 3 },
	{ "MULK", 3 },
	{ "DIVK", 3 },
	{ "MODK", 3 },
	{ "POWK", 3 },
	{ "AND", 3 },
	{ "OR", 3 },
	{ "ANDK", 3 },
	{ "ORK", 3 },
	{ "CONCAT", 3 },
	{ "NOT", 2 },
	{ "MINUS", 2 },
	{ "LENGTH", 2 },
	{ "NEWTABLE", 2, true },
	{ "DUPTABLE", 4 },
	{ "SETLIST", 3, true },
	{ "FORNPREP", 4 },
	{ "FORNLOOP", 4 },
	{ "FORGLOOP", 4, true },
	{ "FORGPREP_INEXT", 4 },
	{ "LOP_DEP_FORGLOOP_INEXT", 0 },
	{ "FORGPREP_NEXT", 4 },
	{ "LOP_DEP_FORGLOOP_NEXT", 0 },
	{ "GETVARARGS", 2 },
	{ "DUPCLOSURE", 4 },
	{ "PREPVARARGS", 1 },
	{ "LOADKX", 1, true },
	{ "JUMPX", 5 },
	{ "FASTCALL", 3 },
	{ "COVERAGE", 5 },
	{ "CAPTURE", 2 },
	{ "LOP_DEP_JUMPIFEQK", 0 },
	{ "LOP_DEP_JUMPIFNOTEQK", 0 },
	{ "FASTCALL1", 3 },
	{ "FASTCALL2", 3, true },
	{ "FASTCALL2K", 3, true },
	{ "FORGPREP", 4 },
	{ "JUMPXEQKNIL", 4, true },
	{ "JUMPXEQKB", 4, true },
	{ "JUMPXEQKN", 4, true },
	{ "JUMPXEQKS", 4, true },
}

local LUA_MULTRET = -1
local function luau_deserialize(bytecode)
	local position = 1
	local module = luau_newmodule()

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
			local opcode = op_list[i.opcode + 1]
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
				local temp = bit32.band(bit32.rshift(i.value, 16), 0xFFFF)
				i.D = if temp < 0x8000 then temp else temp - 0x10000
			elseif i.type == 5 then --[[ AE ]]
				local temp = bit32.band(bit32.rshift(i.value, 8), 0xFFFFFF)
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
				k.data = module.slist[read_variable_integer()]
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

	local stringCount = read_variable_integer()
	for i = 1, stringCount do
		table.insert(module.slist, read_string())
	end

	local protoCount = read_variable_integer()
	for i = 1, protoCount do
		table.insert(module.plist, readproto())
	end

	module.mainp = read_variable_integer()
	assert(position == #bytecode + 1, "Deserializer position mismatch")

	return module
end
local function luau_load(module, env)
	if type(module) == "string" then
		module = luau_deserialize(module)
	end

	local mainProto = module.plist[module.mainp + 1]
	local function luau_wrapclosure(module, proto, upvals)
		local function luau_execute(debugging, stack, protos, code, varargs)
			local top, pc, open_upvalues, generalized_iterators = -1, 1, {}, {}
			local constants = proto.k

			local function vm_kv(index)
				return constants[index + 1].data
			end

			while true do
				local inst = code[pc]
				local op = inst.opcode
				pc += 1
				debugging.pc = pc
				debugging.name = inst.opname

				if op == 2 then --[[ LOADNIL ]]
					stack[inst.A] = nil
				elseif op == 3 then --[[ LOADB ]]
					stack[inst.A] = inst.B ~= 0
					pc += inst.C
				elseif op == 4 then --[[ LOADN ]]
					stack[inst.A] = inst.D
				elseif op == 5 then --[[ LOADK ]]
					stack[inst.A] = constants[inst.D + 1].data
				elseif op == 6 then --[[ MOVE ]]
					stack[inst.A] = stack[inst.B]
				elseif op == 7 then --[[ GETGLOBAL ]]
					local aux = code[pc].value
					pc += 1
					local kv = constants[aux + 1]
					assert(kv.type == "string", "GETGLOBAL encountered non-string constant!")
					stack[inst.A] = env[kv.data]
				elseif op == 8 then --[[ SETGLOBAL ]]
					local aux = code[pc].value
					pc += 1
					local kv = constants[aux + 1]
					assert(kv.type == "string", "GETGLOBAL encountered non-string constant!")
					env[kv.data] = stack[inst.A]
				elseif op == 9 then --[[ GETUPVAL ]]
					local uv = upvals[inst.B + 1]
					stack[inst.A] = uv.store[uv.index]
				elseif op == 10 then --[[ SETUPVAL ]]
					local uv = upvals[inst.B + 1]
					uv.store[uv.index] = stack[inst.A]
				elseif op == 11 then --[[ CLOSEUPVALS ]]
					for i, uv in pairs(open_upvalues) do
						if uv.index >= inst.A then
							uv.value = uv.store[uv.index]
							uv.store = uv
							uv.index = "value" --// self reference
							open_upvalues[i] = nil
						end
					end
				elseif op == 12 then --[[ GETIMPORT ]]
					local extend = code[pc].value
					pc += 1
					local count = bit32.rshift(extend, 30)
					local id0 = bit32.band(bit32.rshift(extend, 20), 0x3FF)
					if count == 1 then
						stack[inst.A] = env[vm_kv(id0)]
					elseif count == 2 then
						local id1 = bit32.band(bit32.rshift(extend, 10), 0x3FF)
						stack[inst.A] = env[vm_kv(id0)][vm_kv(id1)]
					elseif count == 3 then
						local id1 = bit32.band(bit32.rshift(extend, 10), 0x3FF)
						local id2 = bit32.band(bit32.rshift(extend, 0), 0x3FF)
						stack[inst.A] = env[vm_kv(id0)][vm_kv(id1)][vm_kv(id2)]
					end
				elseif op == 13 then --[[ GETTABLE ]]
					stack[inst.B] = stack[inst.B][stack[inst.C]]
				elseif op == 14 then --[[ SETTABLE ]]
					stack[inst.B][stack[inst.C]] = stack[inst.B]
				elseif op == 15 then --[[ GETTABLEKS ]]
					local index = constants[code[pc].value + 1].data
					pc += 1
					stack[inst.A] = stack[inst.B][index]
				elseif op == 16 then --[[ SETTABLEKS ]]
					local index = constants[code[pc].value + 1].data
					pc += 1
					stack[inst.B][index] = stack[inst.A]
				elseif op == 17 then --[[ GETTABLEN ]]
					stack[inst.A] = stack[inst.B][inst.C]
				elseif op == 18 then --[[ SETTABLEN ]]
					stack[inst.B][inst.C] = stack[inst.A]
				elseif op == 19 then --[[ NEWCLOSURE ]]
					local newPrototype = module.plist[inst.D + 1]

					local upvalues = {}

					for i = 1, newPrototype.nups do
						local pseudo = code[pc]
						local cop = pseudo.opcode

						pc += 1

						assert(cop == 70, "Unhandled opcode passed to NEWCLOSURE")

						local type = pseudo.A

						if type == 0 then -- value
							upvalues[i] = stack[pseudo.B]
						elseif type == 1 then -- reference
							local index = pseudo.B
							local prev = open_upvalues[index]

							if prev == nil then
								prev = {
									index = index,
									store = stack,
								}
								open_upvalues[index] = prev
							end

							upvalues[i] = prev
						elseif type == 2 then -- upvalue
							upvalues[i] = upvals[pseudo.B]
						end
					end

					stack[inst.A] = luau_wrapclosure(module, newPrototype, upvalues)
				elseif op == 20 then --[[ NAMECALL ]]
					local A = inst.A
					local B = inst.B
					local aux = code[pc].value
					pc += 1
					local kv = constants[aux + 1]
					assert(kv.type == "string", "NAMECALL encountered non-string constant!")

					stack[A + 1] = stack[B]
					stack[A] = stack[B][kv.data]
				elseif op == 21 then --[[ CALL ]]
					local A, B, C = inst.A, inst.B, inst.C

					local params = if B == 0 then top - A else B - 1
					local ret_list = table.pack(stack[A](table.unpack(stack, A + 1, A + params)))

					local ret_num = ret_list.n

					if C == 0 then
						top = A + ret_num - 1
					else
						ret_num = C - 1
					end

					table.move(ret_list, 1, ret_num, A, stack)
				elseif op == 22 then --[[ RETURN ]]
					local A = inst.A
					local B = inst.B
					local nresults

					if b == LUA_MULTRET then
						nresults = top - A + 1
					else
						nresults = A + B - 1
					end

					return table.unpack(stack, A, A + nresults - 1)
				elseif op == 23 then --[[ JUMP ]]
					pc += inst.D
				elseif op == 24 then --[[ JUMPBACK ]]
					pc += inst.D
				elseif op == 25 then --[[ JUMPIF ]]
					if stack[inst.A] then
						pc += inst.D
					end
				elseif op == 26 then --[[ JUMPIFNOT ]]
					if not stack[inst.A] then
						pc += inst.D
					end
				elseif op == 27 then --[[ JUMPIFEQ ]]
					local aux = code[pc].value
					if stack[inst.A] == stack[aux] then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 28 then --[[ JUMPIFLE ]]
					local aux = code[pc].value
					if stack[inst.A] < stack[aux] then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 29 then --[[ JUMPIFLT ]]
					local aux = code[pc].value
					if stack[inst.A] <= stack[aux] then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 30 then --[[ JUMPIFNOTEQ ]]
					local aux = code[pc].value
					if stack[inst.A] == stack[aux] then
						pc += 1
					else
						pc += inst.D
					end
				elseif op == 31 then --[[ JUMPIFNOTLE ]]
					local aux = code[pc].value
					if stack[inst.A] < stack[aux] then
						pc += 1
					else
						pc += inst.D
					end
				elseif op == 32 then --[[ JUMPIFNOTLT ]]
					local aux = code[pc].value
					if stack[inst.A] <= stack[aux] then
						pc += 1
					else
						pc += inst.D
					end
				elseif op == 33 then --[[ ADD ]]
					stack[inst.A] = stack[inst.B] + stack[inst.C]
				elseif op == 34 then --[[ SUB ]]
					stack[inst.A] = stack[inst.B] - stack[inst.C]
				elseif op == 35 then --[[ MUL ]]
					stack[inst.A] = stack[inst.B] * stack[inst.C]
				elseif op == 36 then --[[ DIV ]]
					stack[inst.A] = stack[inst.B] / stack[inst.C]
				elseif op == 37 then --[[ MOD ]]
					stack[inst.A] = stack[inst.B] % stack[inst.C]
				elseif op == 38 then --[[ POW ]]
					stack[inst.A] = stack[inst.B] ^ stack[inst.C]
				elseif op == 39 then --[[ ADDK ]]
					stack[inst.A] = stack[inst.B] + constants[inst.C + 1].data
				elseif op == 40 then --[[ SUBK ]]
					stack[inst.A] = stack[inst.B] - constants[inst.C + 1].data
				elseif op == 41 then --[[ MULK ]]
					stack[inst.A] = stack[inst.B] * constants[inst.C + 1].data
				elseif op == 42 then --[[ DIVK ]]
					stack[inst.A] = stack[inst.B] / constants[inst.C + 1].data
				elseif op == 43 then --[[ MODK ]]
					stack[inst.A] = stack[inst.B] % constants[inst.C + 1].data
				elseif op == 44 then --[[ POWK ]]
					stack[inst.A] = stack[inst.B] ^ constants[inst.C + 1].data
				elseif op == 45 then --[[ AND ]]
					local value = stack[inst.B]
					if not not value == false then
						stack[inst.A] = value
					else
						stack[inst.A] = stack[inst.C] or false
					end
				elseif op == 46 then --[[ OR ]]
					local value = stack[inst.B]
					if not not value == true then
						stack[inst.A] = value
					else
						stack[inst.A] = stack[inst.C] or false
					end
				elseif op == 47 then --[[ ANDK ]]
					local value = stack[inst.B]
					if not not value == false then
						stack[inst.A] = value
					else
						stack[inst.A] = constants[inst.C + 1].data or false
					end
				elseif op == 48 then --[[ ORK ]]
					local value = stack[inst.B]
					if not not value == true then
						stack[inst.A] = value
					else
						stack[inst.A] = constants[inst.C + 1].data or false
					end
				elseif op == 49 then --[[ CONCAT ]]
					local s = ""
					for i = inst.B, inst.C do
						s ..= stack[i]
					end
					stack[inst.A] = s
				elseif op == 50 then --[[ NOT ]]
					stack[inst.A] = not stack[inst.B]
				elseif op == 51 then --[[ MINUS ]]
					stack[inst.A] = -stack[inst.B]
				elseif op == 52 then --[[ LENGTH ]]
					stack[inst.A] = #stack[inst.B]
				elseif op == 53 then --[[ NEWTABLE ]]
					stack[inst.A] = table.create(code[pc].value)
					pc += 1
				elseif op == 54 then --[[ DUPTABLE ]]
					local template = constants[inst.D + 1].data
					local serialized = {}
					for _, id in ipairs(template) do
						serialized[constants[id + 1].data] = nil
					end
					stack[inst.A] = serialized
				elseif op == 55 then --[[ SETLIST ]]
					local A = inst.A
					local B = inst.B
					local c = inst.C - 1

					if c == LUA_MULTRET then
						c = top - B
					end

					local index = code[pc].value
					pc += 1

					table.move(stack, A + 1, A + c, index, stack[A])
				elseif op == 56 then --[[ FORNPREP ]]
					local A = inst.A
					local limit = stack[A]
					if type(limit) ~= "number" then
						local number = tonumber(limit)

						if number == nil then
							error("invalid 'for' limit (number expected)")
						end

						stack[A] = number
					end
					local step = stack[A + 1]
					if type(step) ~= "number" then
						local number = tonumber(step)

						if number == nil then
							error("invalid 'for' step (number expected)")
						end

						stack[A + 1] = number
					end
					local index = stack[A + 2]
					if type(index) ~= "number" then
						local number = tonumber(index)

						if number == nil then
							error("invalid 'for' index (number expected)")
						end

						stack[A + 2] = number
					end

					if step > 0 then
						if index >= limit then
							pc += inst.D
						end
					else
						if limit >= index then
							pc += inst.D
						end
					end
				elseif op == 57 then --[[ FORNLOOP ]]
					local limit = stack[inst.A]
					local step = stack[inst.A + 1]
					local index = stack[inst.A + 2] + step

					stack[inst.A + 2] = index

					if step > 0 then
						if index <= limit then
							pc += inst.D
						end
					else
						if limit <= index then
							pc += inst.D
						end
					end
				elseif op == 58 then --[[ FORGLOOP ]]
					local A = inst.A
					local aux = code[pc].value

					top = A + 6

					local it = stack[A]

					if type(it) == "function" then 
						local vals = { stack[A](stack[A + 1], stack[A + 2]) }

						table.move(vals, 1, aux, A + 3, stack)
					else 
						local errored, vals = coroutine.resume(generalized_iterators[inst])

						if vals[1] ~= nil then 
							table.move(vals, 1, aux, A + 3, stack)
						end
					end 

					if stack[A + 3] ~= nil then
						stack[A + 2] = stack[A + 3]
						pc += inst.D
					else
						pc += 1
						generalized_iterators[inst] = nil
					end
				elseif op == 59 then --[[ FORGPREP_INEXT ]]
					if type(stack[inst.A]) ~= "function" then 
						error("FORGPREP_INEXT encountered non-function value")
					end 

					pc += inst.D
				elseif op == 61 then --[[ FORGPREP_NEXT ]]			
					if type(stack[inst.A]) ~= "function" then 
						error("FORGPREP_NEXT encountered non-function value")
					end 
		
					pc += inst.D
				elseif op == 63 then --[[ GETVARARGS ]]
					local A = inst.A
					local b = inst.B - 1

					if b == LUA_MULTRET then
						b = varargs.len
						top = A + b - 1
					end

					table.move(varargs.list, 1, b, A, stack)
				elseif op == 64 then --[[ DUPCLOSURE ]]
					local newPrototype = module.plist[constants[inst.D + 1].data + 1] --// correct behavior would be to reuse the prototype if possible but it would not be useful here

					local upvalues = {}

					for i = 1, newPrototype.nups do
						local pseudo = code[pc]
						local cop = pseudo.opcode

						pc += 1

						assert(cop == 70, "Unhandled opcode passed to NEWCLOSURE")

						local type = pseudo.A

						if type == 0 then -- value
							upvalues[i] = stack[pseudo.B]
						--// references dont get handled by DUPCLOSURE
						elseif type == 2 then -- upvalue
							upvalues[i] = upvals[pseudo.B]
						end
					end

					stack[inst.A] = luau_wrapclosure(module, newPrototype, upvalues)
				elseif op == 65 then --[[ PREPVARARGS ]]
					--[[ Handled by wrapper ]]
				elseif op == 66 then --[[ LOADKX ]]
					local aux = code[pc].value
					pc += 1
					local kv = constants[aux + 1]
					assert(kv.type == "string", "LOADKX encountered non-string constant!")
					stack[inst.A] = kv.data
				elseif op == 67 then --[[ JUMPX ]]
					pc += inst.E
				elseif op == 68 then --[[ FASTCALL ]]
					--[[ Skipped ]]
				elseif op == 70 then --[[ CAPTURE ]]
					--[[ Handled by CLOSURE ]]
					error("Unhandled CAPTURE")
				elseif op == 73 then --[[ FASTCALL1 ]]
					--[[ Skipped ]]
				elseif op == 74 then --[[ FASTCALL2 ]]
					--[[ Skipped ]]
				elseif op == 75 then --[[ FASTCALL2K ]]
					--[[ Skipped ]]
				elseif op == 76 then --[[ FORGPREP ]]
					local it = stack[inst.A]

					if type(it) ~= "function" then 
						local loopInstruction = code[pc + inst.D]
						local iterator
						if generalized_iterators[loopInstruction] == nil then 
							function iterator()
								for r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200 in __FIU__GENERALIZED_ITERATION__ do 
									coroutine.yield({r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200})
								end
							end

							setfenv(iterator, setmetatable({__FIU__GENERALIZED_ITERATION__ = stack[inst.A]}, {__index = env}))

							generalized_iterators[loopInstruction] = coroutine.create(iterator)
						else 
							iterator = generalized_iterators[loopInstruction]
						end
					end

					pc += inst.D
				elseif op == 77 then --[[ JUMPXEQKNIL ]]
					local aux = code[pc].value
					if (ra == nil and 0 or 1) == bit32.rshift(aux, 31) then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 78 then --[[ JUMPXEQKB ]]
					local aux = code[pc].value
					if ((ra and 0 or 1) == (bit32.band(aux, 1) and 0 or 1)) == bit32.rshift(aux, 31) then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 79 then --[[ JUMPXEQKN ]]
					local aux = code[pc].value
					local kv = constants[bit32.band(aux, 0xffffff) + 1]
					assert(kv.type == "number", "JUMPXEQKN encountered non-number constant!")
					local A = stack[inst.A]
					if bit32.rshift(aux, 31) == 0 then
						pc += if A == kv.data then inst.D else 1
					else
						pc += if A ~= kv.data then inst.D else 1
					end
				elseif op == 80 then --[[ JUMPXEQKS ]]
					local aux = code[pc].value
					local kv = constants[bit32.band(aux, 0xffffff) + 1]
					assert(kv.type == "string", "JUMPXEQKS encountered non-string constant!")
					if ((kv.data == stack[inst.A]) and 0 or 1) ~= bit32.rshift(aux, 31) then 
						pc += inst.D 
					else 
						pc += 1
					end
				else
					error("Unsupported Opcode: " .. inst.opname .. " op: " .. op)
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
			if false then -- for debugging issues
				result = table.pack(pcall(luau_execute, debugging, stack, proto.protos, proto.code, varargs))
			else
				result = table.pack(true, luau_execute(debugging, stack, proto.protos, proto.code, varargs))
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
