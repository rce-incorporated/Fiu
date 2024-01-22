local FIU_DEBUGGING = true

-- // Some functions dont have a builtin so its faster to make them locally accessible, error and string.format don't need them since they stop execution
local table_pack = table.pack
local table_create = table.create
local table_move = table.move

local coroutine_create = coroutine.create
local coroutine_yield = coroutine.yield
local coroutine_resume = coroutine.resume

local tonumber = tonumber
local pcall = pcall

local buffer_fromstring = buffer.fromstring
local buffer_readu8 = buffer.readu8
local buffer_readu32 = buffer.readu32
local buffer_readstring = buffer.readstring
local buffer_readf64 = buffer.readf64

-- // opList contains information about the instruction, each instruction is defined in this format:
-- // {OP_NAME, OP_MODE, K_MODE, HAS_AUX}
-- // OP_MODE specifies what type of registers the instruction uses if any
--		0 = NONE
--		1 = A
--		2 = AB
--		3 = ABC
--		4 = AD
--		5 = AE
-- // K_MODE specifies if the instruction has a register that holds a constant table index, which will be directly converted to the constant in the 2nd pass
--		0 = NONE
--		1 = AUX
--		2 = C
--		3 = D
--		4 = AUX import
--		5 = AUX boolean low 1 bit
--		6 = AUX number low 24 bits
-- // HAS_AUX boolean specifies whether the instruction is followed up with an AUX word, which may be used to execute the instruction.

local opList = {
	{ "NOP", 0, 0, false },
	{ "BREAK", 0, 0, false },
	{ "LOADNIL", 1, 0, false },
	{ "LOADB", 3, 0, false },
	{ "LOADN", 4, 0, false },
	{ "LOADK", 4, 3, false },
	{ "MOVE", 2, 0, false },
	{ "GETGLOBAL", 1, 1, true },
	{ "SETGLOBAL", 1, 1, true },
	{ "GETUPVAL", 2, 0, false },
	{ "SETUPVAL", 2, 0, false },
	{ "CLOSEUPVALS", 1, 0, false },
	{ "GETIMPORT", 4, 4, true },
	{ "GETTABLE", 3, 0, false },
	{ "SETTABLE", 3, 0, false },
	{ "GETTABLEKS", 3, 1, true },
	{ "SETTABLEKS", 3, 1, true },
	{ "GETTABLEN", 3, 0, false },
	{ "SETTABLEN", 3, 0, false },
	{ "NEWCLOSURE", 4, 0, false },
	{ "NAMECALL", 3, 1, true },
	{ "CALL", 3, 0, false },
	{ "RETURN", 2, 0, false },
	{ "JUMP", 4, 0, false },
	{ "JUMPBACK", 4, 0, false },
	{ "JUMPIF", 4, 0, false },
	{ "JUMPIFNOT", 4, 0, false },
	{ "JUMPIFEQ", 4, 0, true },
	{ "JUMPIFLE", 4, 0, true },
	{ "JUMPIFLT", 4, 0, true },
	{ "JUMPIFNOTEQ", 4, 0, true },
	{ "JUMPIFNOTLE", 4, 0, true },
	{ "JUMPIFNOTLT", 4, 0, true },
	{ "ADD", 3, 0, false },
	{ "SUB", 3, 0, false },
	{ "MUL", 3, 0, false },
	{ "DIV", 3, 0, false },
	{ "MOD", 3, 0, false },
	{ "POW", 3, 0, false },
	{ "ADDK", 3, 2, false },
	{ "SUBK", 3, 2, false },
	{ "MULK", 3, 2, false },
	{ "DIVK", 3, 2, false },
	{ "MODK", 3, 2, false },
	{ "POWK", 3, 2, false },
	{ "AND", 3, 0, false },
	{ "OR", 3, 0, false },
	{ "ANDK", 3, 2, false },
	{ "ORK", 3, 2, false },
	{ "CONCAT", 3, 0, false },
	{ "NOT", 2, 0, false },
	{ "MINUS", 2, 0, false },
	{ "LENGTH", 2, 0, false },
	{ "NEWTABLE", 2, 0, true },
	{ "DUPTABLE", 4, 3, false },
	{ "SETLIST", 3, 0, true },
	{ "FORNPREP", 4, 0, false },
	{ "FORNLOOP", 4, 0, false },
	{ "FORGLOOP", 4, 0, true },
	{ "FORGPREP_INEXT", 4, 0, false },
	{ "DEP_FORGLOOP_INEXT", 0, 0, false },
	{ "FORGPREP_NEXT", 4, 0, false },
	{ "DEP_FORGLOOP_NEXT", 0, 0, false },
	{ "GETVARARGS", 2, 0, false },
	{ "DUPCLOSURE", 4, 3, false },
	{ "PREPVARARGS", 1, 0, false },
	{ "LOADKX", 1, 1, true },
	{ "JUMPX", 5, 0, false },
	{ "FASTCALL", 3, 0, false },
	{ "COVERAGE", 5, 0, false },
	{ "CAPTURE", 2, 0, false },
	{ "SUBRK", 3, 2, false },
	{ "DIVRK", 3, 2, false },
	{ "FASTCALL1", 3, 0, false },
	{ "FASTCALL2", 3, 0, true },
	{ "FASTCALL2K", 3, 1, true },
	{ "FORGPREP", 4, 0, false },
	{ "JUMPXEQKNIL", 4, 5, true },
	{ "JUMPXEQKB", 4, 5, true },
	{ "JUMPXEQKN", 4, 6, true },
	{ "JUMPXEQKS", 4, 6, true },
	{ "IDIV", 3, 0, false },
	{ "IDIVK", 3, 2, false },
}

local LUA_MULTRET = -1
local LUA_GENERALIZED_TERMINATOR = -2
local function luau_deserialize(bytecode)
	local stream = buffer_fromstring(bytecode)
	local position = 0

	local function readByte()
		local byte = buffer_readu8(stream, position)
		position = position + 1
		return byte
	end

	local function readWord()
		local word = buffer_readu32(stream, position)
		position = position + 4
		return word
	end

	local function readVarInt()
		local result = 0

		for i = 0, 4 do
			local value = readByte()
			result = bit32.bor(result, bit32.lshift(bit32.band(value, 0x7F), i * 7))
			if not bit32.btest(value, 0x80) then
				break
			end
		end

		return result
	end

	local function readString()
		local size = readVarInt()

		if size == 0 then
			return ""
		else
			local str = buffer_readstring(stream, position, size)
			position = position + size

			return str
		end
	end

	local luauVersion = readByte()
	local typesVersion = 0
	if luauVersion == 0 then 
		error("The bytecode that was passed was an error message!",0)
	elseif luauVersion < 3 or luauVersion > 5 then
		error("Unsupported bytecode provided!",0)
	elseif luauVersion >= 4 then
		typesVersion = readByte()
	end

	local stringCount = readVarInt()
	local stringList = table_create(stringCount)

	for i = 1, stringCount do
		stringList[i] = readString()
	end

	local function readInstruction(codeList)
		local value = readWord()
		local opcode = bit32.band(value, 0xFF)

		local opinfo = opList[opcode + 1]
		local opname = opinfo[1]
		local opmode = opinfo[2]
		local kmode = opinfo[3]
		local usesAux = opinfo[4]

		local inst = {
			opcode = opcode;
			name = opname;
			opmode = opmode;
			kmode = kmode;
			usesAux = usesAux;
		}

		table.insert(codeList, inst)

		if opmode == 1 then --[[ A ]]
			inst.A = bit32.band(bit32.rshift(value, 8), 0xFF)
		elseif opmode == 2 then --[[ AB ]]
			inst.A = bit32.band(bit32.rshift(value, 8), 0xFF)
			inst.B = bit32.band(bit32.rshift(value, 16), 0xFF)
		elseif opmode == 3 then --[[ ABC ]]
			inst.A = bit32.band(bit32.rshift(value, 8), 0xFF)
			inst.B = bit32.band(bit32.rshift(value, 16), 0xFF)
			inst.C = bit32.band(bit32.rshift(value, 24), 0xFF)
		elseif opmode == 4 then --[[ AD ]]
			inst.A = bit32.band(bit32.rshift(value, 8), 0xFF)
			local temp = bit32.band(bit32.rshift(value, 16), 0xFFFF)
			inst.D = if temp < 0x8000 then temp else temp - 0x10000
		elseif opmode == 5 then --[[ AE ]]
			local temp = bit32.band(bit32.rshift(value, 8), 0xFFFFFF)
			inst.E = if temp < 0x800000 then temp else temp - 0x1000000
		end

		if usesAux then 
			local aux = readWord()
			inst.aux = aux

			table.insert(codeList, {value = aux})
		end

		return usesAux
	end

	local function checkkmode(inst, k)
		local kmode = inst.kmode

		if kmode == 1 then --// AUX
			inst.K = k[inst.aux +  1]
		elseif kmode == 2 then --// C
			inst.K = k[inst.C + 1]
		elseif kmode == 3 then--// D
			inst.K = k[inst.D + 1]
		elseif kmode == 4 then --// AUX import
			local extend = inst.aux
			local count = bit32.rshift(extend, 30)
			local id0 = bit32.band(bit32.rshift(extend, 20), 0x3FF)

			inst.K0 = k[id0 + 1]
			inst.KC = count
			if count == 2 then
				local id1 = bit32.band(bit32.rshift(extend, 10), 0x3FF)

				inst.K1 = k[id1 + 1]
			elseif count == 3 then
				local id1 = bit32.band(bit32.rshift(extend, 10), 0x3FF)
				local id2 = bit32.band(bit32.rshift(extend, 0), 0x3FF)

				inst.K1 = k[id1 + 1]
				inst.K2 = k[id2 + 1]
			end
		elseif kmode == 5 then --// AUX boolean low 1 bit
			inst.K = bit32.extract(inst.aux, 0, 1) == 1
			inst.KN = bit32.extract(inst.aux, 31, 1) == 1
		elseif kmode == 6 then --// AUX number low 24 bits
			inst.K = k[bit32.extract(inst.aux, 0, 24) + 1]
			inst.KN = bit32.extract(inst.aux, 31, 1) == 1
		end
	end

	local function readProto(bytecodeid)
		local maxstacksize = readByte()
		local numparams = readByte()
		local nups = readByte()
		local isvararg = readByte() ~= 0

		if luauVersion >= 4 then
			readByte() --// flags 
		end

		local sizecode = readVarInt()
		local codelist = table_create(sizecode)

		local skipnext = false 
		for i = 1, sizecode do
			if skipnext then 
				skipnext = false
				continue 
			end

			skipnext = readInstruction(codelist)
		end

		local sizek = readVarInt()
		local klist = table_create(sizek)

		for i = 1, sizek do
			local kt = readByte()
			local k

			if kt == 0 then --// Nil
				k = nil
			elseif kt == 1 then --// Bool
				k = readByte() ~= 0
			elseif kt == 2 then --// Number
				local d = buffer_readf64(stream, position)
				position = position + 8
				k = d
			elseif kt == 3 then --// String
				k = stringList[readVarInt()]
			elseif kt == 4 then --// Import
				k = readWord()
			elseif kt == 5 then --// Table
				local dataLength = readVarInt()
				local data = table_create(dataLength)
				for i = 1, dataLength do
					data[i] = readVarInt()
				end
				k = data
			elseif kt == 6 then --// Closure
				k = readVarInt()
			elseif kt == 7 then --// Vector
				error("Fiu does not currently support vector constants!",0)
			end

			klist[i] = k
		end
		
		-- // 2nd pass to replace constant references in the instruction
		for i = 1, sizecode do
			checkkmode(codelist[i], klist)
		end

		local sizep = readVarInt()
		local protolist = table_create(sizep)

		for i = 1, sizep do
			protolist[i] = readVarInt()
		end

		local linedefined = readVarInt()
		local debugname = stringList[readVarInt()]

		-- // lineinfo
		if readByte() ~= 0 then
			local lineGap = readByte()
			for i = 1, sizecode do
				readByte()
			end
			local intervals = bit32.rshift(sizecode - 1, lineGap) + 1
			for i = 1, intervals do
				readWord()
			end
		end

		-- // debuginfo
		if readByte() ~= 0 then
			local sizel = readVarInt()
			for i = 1, sizel do
				readVarInt()
				readVarInt()
				readVarInt()
				readByte()
			end
		end

		return {
			maxstacksize = maxstacksize;
			numparams = numparams;
			nups = nups;
			isvararg = isvararg;
			linedefined = linedefined;
			debugname = debugname;

			sizecode = sizecode;
			code = codelist;

			sizek = sizek;
			k = klist;

			sizep = sizep;
			protos = protolist;

			bytecodeid = bytecodeid;
		}
	end

	local protoCount = readVarInt()
	local protoList = table_create(protoCount)

	for i = 1, protoCount do
		protoList[i] = readProto(i - 1)
	end

	local mainProto = protoList[readVarInt() + 1]

	assert(position == #bytecode, "Deserializer position mismatch")

	return {
		stringList = stringList;
		protoList = protoList;

		mainProto = mainProto;

		typesVersion = typesVersion;
	}
end

local function luau_load(module, env)
	if type(module) == "string" then
		module = luau_deserialize(module)
	end

	local protolist = module.protoList
	local mainProto = module.mainProto

	local function luau_wrapclosure(module, proto, upvals)
		local function luau_execute(debugging, stack, protos, code, varargs)
			local top, pc, open_upvalues, generalized_iterators = -1, 1, {}, {}
			local constants = proto.k

			while true do
				local inst = code[pc]
				local op = inst.opcode
				debugging.pc = pc
				debugging.name = inst.opname

				pc += 1

				if op == 2 then --[[ LOADNIL ]]
					stack[inst.A] = nil
				elseif op == 3 then --[[ LOADB ]]
					stack[inst.A] = inst.B ~= 0
					pc += inst.C
				elseif op == 4 then --[[ LOADN ]]
					stack[inst.A] = inst.D
				elseif op == 5 then --[[ LOADK ]]
					stack[inst.A] = inst.K
				elseif op == 6 then --[[ MOVE ]]
					stack[inst.A] = stack[inst.B]
				elseif op == 7 then --[[ GETGLOBAL ]]
					pc += 1

					local kv = inst.K
					stack[inst.A] = env[kv]
				elseif op == 8 then --[[ SETGLOBAL ]]
					pc += 1 --// adjust for aux 

					local kv = inst.K
					env[kv] = stack[inst.A]
				elseif op == 9 then --[[ GETUPVAL ]]
					local uv = upvals[inst.B + 1]
					stack[inst.A] = uv.store[uv.index]
				elseif op == 10 then --[[ SETUPVAL ]]
					local uv = upvals[inst.B + 1]
					uv.store[uv.index] = stack[inst.A]
				elseif op == 11 then --[[ CLOSEUPVALS ]]
					for i, uv in open_upvalues do
						if uv.index >= inst.A then
							uv.value = uv.store[uv.index]
							uv.store = uv
							uv.index = "value" --// self reference
							open_upvalues[i] = nil
						end
					end
				elseif op == 12 then --[[ GETIMPORT ]]
					pc += 1 --// adjust for aux 

					local count = inst.KC
					if count == 1 then
						stack[inst.A] = env[inst.K0]
					elseif count == 2 then
						stack[inst.A] = env[inst.K0][inst.K1]
					elseif count == 3 then
						stack[inst.A] = env[inst.K0][inst.K1][inst.K2]
					end
				elseif op == 13 then --[[ GETTABLE ]]
					stack[inst.A] = stack[inst.B][stack[inst.C]]
				elseif op == 14 then --[[ SETTABLE ]]
					stack[inst.B][stack[inst.C]] = stack[inst.A]
				elseif op == 15 then --[[ GETTABLEKS ]]
					pc += 1 --// adjust for aux 

					local index = inst.K
					stack[inst.A] = stack[inst.B][index]
				elseif op == 16 then --[[ SETTABLEKS ]]
					pc += 1 --// adjust for aux

					local index = inst.K
					stack[inst.B][index] = stack[inst.A]
				elseif op == 17 then --[[ GETTABLEN ]]
					stack[inst.A] = stack[inst.B][inst.C + 1]
				elseif op == 18 then --[[ SETTABLEN ]]
					stack[inst.B][inst.C + 1] = stack[inst.A]
				elseif op == 19 then --[[ NEWCLOSURE ]]
					local newPrototype = protolist[inst.D + 1]

					local upvalues = {}

					for i = 1, newPrototype.nups do
						local pseudo = code[pc]

						pc += 1

						local type = pseudo.A

						if type == 0 then --// value
							local upvalue = {
								value = stack[pseudo.B],
								index = "value",--// self reference
							}
							upvalue.store = upvalue

							upvalues[i] = upvalue
						elseif type == 1 then --// reference
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
						elseif type == 2 then --// upvalue
							upvalues[i] = upvals[pseudo.B]
						end
					end

					stack[inst.A] = luau_wrapclosure(module, newPrototype, upvalues)
				elseif op == 20 then --[[ NAMECALL ]]
					pc += 1 --// adjust for aux 

					local A = inst.A
					local B = inst.B

					local kv = inst.K
					local sb = stack[B]

					stack[A + 1] = sb
					stack[A] = sb[kv]
				elseif op == 21 then --[[ CALL ]]
					local A, B, C = inst.A, inst.B, inst.C

					local params = if B == 0 then top - A else B - 1
					local func = stack[A]
					local ret_list = table_pack(
						func(table.unpack(stack, A + 1, A + params))
					)

					local ret_num = ret_list.n

					if C == 0 then
						top = A + ret_num - 1
					else
						ret_num = C - 1
					end

					table_move(ret_list, 1, ret_num, A, stack)
				elseif op == 22 then --[[ RETURN ]]
					local A = inst.A
					local B = inst.B 
					local b = B - 1
					local nresults

					if b == LUA_MULTRET then
						nresults = top - A + 1
					else
						nresults = B - 1
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
					if stack[inst.A] == stack[inst.aux] then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 28 then --[[ JUMPIFLE ]]
					if stack[inst.A] <= stack[inst.aux] then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 29 then --[[ JUMPIFLT ]]
					if stack[inst.A] < stack[inst.aux] then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 30 then --[[ JUMPIFNOTEQ ]]
					if stack[inst.A] == stack[inst.aux] then
						pc += 1
					else
						pc += inst.D
					end
				elseif op == 31 then --[[ JUMPIFNOTLE ]]
					if stack[inst.A] <= stack[inst.aux] then
						pc += 1
					else
						pc += inst.D
					end
				elseif op == 32 then --[[ JUMPIFNOTLT ]]
					if stack[inst.A] < stack[inst.aux] then
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
					stack[inst.A] = stack[inst.B] + inst.K
				elseif op == 40 then --[[ SUBK ]]
					stack[inst.A] = stack[inst.B] - inst.K
				elseif op == 41 then --[[ MULK ]]
					stack[inst.A] = stack[inst.B] * inst.K
				elseif op == 42 then --[[ DIVK ]]
					stack[inst.A] = stack[inst.B] / inst.K
				elseif op == 43 then --[[ MODK ]]
					stack[inst.A] = stack[inst.B] % inst.K
				elseif op == 44 then --[[ POWK ]]
					stack[inst.A] = stack[inst.B] ^ inst.K
				elseif op == 45 then --[[ AND ]]
					local value = stack[inst.B]
					if (not not value) == false then
						stack[inst.A] = value
					else
						stack[inst.A] = stack[inst.C] or false
					end
				elseif op == 46 then --[[ OR ]]
					local value = stack[inst.B]
					if (not not value) == true then
						stack[inst.A] = value
					else
						stack[inst.A] = stack[inst.C] or false
					end
				elseif op == 47 then --[[ ANDK ]]
					local value = stack[inst.B]
					if (not not value) == false then
						stack[inst.A] = value
					else
						stack[inst.A] = inst.K or false
					end
				elseif op == 48 then --[[ ORK ]]
					local value = stack[inst.B]
					if (not not value) == true then
						stack[inst.A] = value
					else
						stack[inst.A] = inst.K or false
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
					pc += 1 --// adjust for aux 

					stack[inst.A] = table_create(inst.aux)
				elseif op == 54 then --[[ DUPTABLE ]]
					local template = inst.K
					local serialized = {}
					for _, id in template do
						serialized[constants[id + 1]] = nil
					end
					stack[inst.A] = serialized
				elseif op == 55 then --[[ SETLIST ]]
					pc += 1 --// adjust for aux 

					local A = inst.A
					local B = inst.B
					local c = inst.C - 1

					if c == LUA_MULTRET then
						c = top - B
					end

					table_move(stack, B, B + c - 1, inst.aux, stack[A])
				elseif op == 56 then --[[ FORNPREP ]]
					local A = inst.A
					local limit = stack[A]
					if type(limit) ~= "number" then
						local number = tonumber(limit)

						if number == nil then
							error("invalid 'for' limit (number expected)")
						end

						stack[A] = number
						limit = number
					end
					local step = stack[A + 1]
					if type(step) ~= "number" then
						local number = tonumber(step)

						if number == nil then
							error("invalid 'for' step (number expected)")
						end

						stack[A + 1] = number
						step = number
					end
					local index = stack[A + 2]
					if type(index) ~= "number" then
						local number = tonumber(index)

						if number == nil then
							error("invalid 'for' index (number expected)")
						end

						stack[A + 2] = number
						index = number
					end

					if step > 0 then 
						if index > limit then 
							pc += inst.D 
						end 
					else 
						if limit > index then 
							pc += inst.D
						end 
					end 
				elseif op == 57 then --[[ FORNLOOP ]]
					local A = inst.A
					local limit = stack[A]
					local step = stack[A + 1]
					local index = stack[A + 2] + step

					stack[A + 2] = index

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
					local aux = inst.aux

					top = A + 6

					local it = stack[A]

					if type(it) == "function" then 
						local vals = { stack[A](stack[A + 1], stack[A + 2]) }

						table_move(vals, 1, aux, A + 3, stack)

						if stack[A + 3] ~= nil then
							stack[A + 2] = stack[A + 3]
							pc += inst.D
						else
							pc += 1
						end
					else 
						local _, vals = coroutine_resume(generalized_iterators[inst])

						if vals == LUA_GENERALIZED_TERMINATOR then 
							pc += 1
						else 
							table_move(vals, 1, aux, A + 3, stack)

							stack[A + 2] = stack[A + 3]
							pc += inst.D
						end
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

					table_move(varargs.list, 1, b, A, stack)
				elseif op == 64 then --[[ DUPCLOSURE ]]
					local newPrototype = protolist[inst.K + 1] --// correct behavior would be to reuse the prototype if possible but it would not be useful here

					local upvalues = {}

					for i = 1, newPrototype.nups do
						local pseudo = code[pc]
						pc += 1

						local type = pseudo.A

						if type == 0 then --// value
							local upvalue = {
								value = stack[pseudo.B],
								index = "value",--// self reference
							}
							upvalue.store = upvalue

							upvalues[i] = upvalue
						--// references dont get handled by DUPCLOSURE
						elseif type == 2 then --// upvalue
							upvalues[i] = upvals[pseudo.B]
						end
					end

					stack[inst.A] = luau_wrapclosure(module, newPrototype, upvalues)
				elseif op == 65 then --[[ PREPVARARGS ]]
					--[[ Handled by wrapper ]]
				elseif op == 66 then --[[ LOADKX ]]
					pc += 1 --// adjust for aux 

					local kv = inst.K
					stack[inst.A] = kv
				elseif op == 67 then --[[ JUMPX ]]
					pc += inst.E
				elseif op == 68 then --[[ FASTCALL ]]
					--[[ Skipped ]]
				elseif op == 70 then --[[ CAPTURE ]]
					--[[ Handled by CLOSURE ]]
					error("Unhandled CAPTURE")
				elseif op == 71 then --[[ SUBRK ]]
					stack[inst.A] = inst.K - stack[inst.B]  
				elseif op == 72 then --[[ DIVRK ]]
					stack[inst.A] = inst.K / stack[inst.B]  
				elseif op == 73 then --[[ FASTCALL1 ]]
					--[[ Skipped ]]
				elseif op == 74 then --[[ FASTCALL2 ]]
					pc += 1 --// Skipped and skips aux instruction
				elseif op == 75 then --[[ FASTCALL2K ]]
					pc += 1 --// Skipped and skips aux instruction
				elseif op == 76 then --[[ FORGPREP ]]
					local iterator = stack[inst.A]

					if type(iterator) ~= "function" then 
						local loopInstruction = code[pc + inst.D]
						if generalized_iterators[loopInstruction] == nil then 
							--// Thanks @bmcq-0 and @memcorrupt for the spoonfeed
							local function gen_iterator()
								for r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200 in iterator do 
									coroutine_yield({r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200})
								end

								coroutine_yield(LUA_GENERALIZED_TERMINATOR)
							end

							generalized_iterators[loopInstruction] = coroutine_create(gen_iterator)
						end
					end

					pc += inst.D
				elseif op == 77 then --[[ JUMPXEQKNIL ]]
					local kn = inst.KN

					if (stack[inst.A] == nil) ~= kn then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 78 then --[[ JUMPXEQKB ]]
					local kv = inst.K
					local kn = inst.KN

					if ((stack[inst.A] and true or false) == (kv and true or false)) ~= kn then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 79 then --[[ JUMPXEQKN ]]
					local kv = inst.K
					local kn = inst.KN

					if (stack[inst.A] == kv) ~= kn then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 80 then --[[ JUMPXEQKS ]]
					local kv = inst.K
					local kn = inst.KN

					if (stack[inst.A] == kv) ~= kn then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 81 then --[[ IDIV ]]
					stack[inst.A] = stack[inst.B] // stack[inst.C]
				elseif op == 82 then --[[ IDIVK ]]
					stack[inst.A] = stack[inst.B] // inst.K
				else
					error("Unsupported Opcode: " .. inst.opname .. " op: " .. op)
				end
			end
		end

		local function wrapped(...)
			local passed = table_pack(...)
			local stack = table_create(proto.maxstacksize)
			local varargs = {
				len = 0,
				list = {},
			}

			table_move(passed, 1, proto.numparams, 0, stack)

			if proto.numparams < passed.n then
				local start = proto.numparams + 1
				local len = passed.n - proto.numparams
				varargs.len = len
				table_move(passed, start, start + len - 1, 1, varargs.list)
			end

			local debugging = {pc = 0, name = "NONE"}
			local result
			if not FIU_DEBUGGING then --// for debugging issues
				result = table_pack(pcall(luau_execute, debugging, stack, proto.protos, proto.code, varargs))
			else
				result = table_pack(true, luau_execute(debugging, stack, proto.protos, proto.code, varargs))
			end

			if result[1] then
				return table.unpack(result, 2, result.n)
			else
				error(string.format("Fiu VM Error PC: %s Opcode: %s: \n%s",debugging.pc, debugging.name, result[2]), 0)
			end
		end
		return wrapped
	end
	
	return luau_wrapclosure(module, mainProto)
end

return {
	luau_load = luau_load,
	luau_deserialize = luau_deserialize,
}
