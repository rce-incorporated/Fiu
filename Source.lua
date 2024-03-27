-- // Environment changes in the VM are not supposed to alter the behaviour of the VM so we localise them all beforehand
local type = type
local pcall = pcall
local error = error
local tonumber = tonumber
local assert =assert

local string_format = string.format

local table_move = table.move
local table_pack = table.pack
local table_unpack = table.unpack
local table_create = table.create
local table_insert = table.insert
local table_remove = table.remove

local coroutine_create = coroutine.create
local coroutine_yield = coroutine.yield
local coroutine_resume = coroutine.resume
local coroutine_close = coroutine.close

local buffer_fromstring = buffer.fromstring
local buffer_readu8 = buffer.readu8
local buffer_readu32 = buffer.readu32
local buffer_readstring = buffer.readstring
local buffer_readf32 = buffer.readf32
local buffer_readf64 = buffer.readf64

local bit32_bor = bit32.bor
local bit32_band = bit32.band
local bit32_btest = bit32.btest
local bit32_rshift = bit32.rshift
local bit32_lshift = bit32.lshift
local bit32_extract = bit32.extract

local ttisnumber = function(v) return type(v) == "number" end
local ttisboolean = function(v) return type(v) == "boolean" end
local ttisfunction = function(v) return type(v) == "function" end

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
	{ "FORGLOOP", 4, 8, true },
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
	{ "SUBRK", 3, 7, false },
	{ "DIVRK", 3, 7, false },
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

local function luau_newsettings()
	return {
		vectorCtor = function() error("vectorCtor was not provided") end,
		vectorSize = 4,
		useNativeNamecall = false,
		namecallHandler = function() error("Native __namecall handler was not provided") end,
		extensions = {},
		callHooks = {},
		errorHandling = true,
		generalizedIteration = true
	}	
end

local function luau_validatesettings(luau_settings)
	assert(type(luau_settings) == "table", "luau_settings should be a table")
	assert(type(luau_settings.vectorCtor) == "function", "luau_settings.vectorCtor should be a function")
	assert(type(luau_settings.vectorSize) == "number", "luau_settings.vectorSize should be a number")
	assert(type(luau_settings.useNativeNamecall) == "boolean", "luau_settings.useNativeNamecall should be a boolean")
	assert(type(luau_settings.namecallHandler) == "function", "luau_settings.namecallHandler should be a function")
	assert(type(luau_settings.extensions) == "table", "luau_settings.extensions should be a table of functions")
	assert(type(luau_settings.callHooks) == "table", "luau_settings.callHooks should be a table of functions")
	assert(type(luau_settings.errorHandling) == "boolean", "luau_settings.errorHandling should be a boolean")
end

local function luau_deserialize(bytecode, luau_settings)
	if luau_settings == nil then
		luau_settings = luau_newsettings()
	else 
		luau_validatesettings(luau_settings)
	end

	local stream = buffer_fromstring(bytecode)
	local cursor = 0

	local function readByte()
		local byte = buffer_readu8(stream, cursor)
		cursor = cursor + 1
		return byte
	end

	local function readWord()
		local word = buffer_readu32(stream, cursor)
		cursor = cursor + 4
		return word
	end

	local function readFloat()
		local float = buffer_readf32(stream, cursor)
		cursor = cursor + 4
		return float
	end

	local function readDouble()
		local double = buffer_readf64(stream, cursor)
		cursor = cursor + 8
		return double
	end

	local function readVarInt()
		local result = 0

		for i = 0, 4 do
			local value = readByte()
			result = bit32_bor(result, bit32_lshift(bit32_band(value, 0x7F), i * 7))
			if not bit32_btest(value, 0x80) then
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
			local str = buffer_readstring(stream, cursor, size)
			cursor = cursor + size

			return str
		end
	end

	local luauVersion = readByte()
	local typesVersion = 0
	if luauVersion == 0 then
		error("the provided bytecode is an error message",0)
	elseif luauVersion < 3 or luauVersion > 5 then
		error("the version of the provided bytecode is unsupported",0)
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
		local opcode = bit32_band(value, 0xFF)

		local opinfo = opList[opcode + 1]
		local opname = opinfo[1]
		local opmode = opinfo[2]
		local kmode = opinfo[3]
		local usesAux = opinfo[4]

		local inst = {
			opcode = opcode;
			opname = opname;
			opmode = opmode;
			kmode = kmode;
			usesAux = usesAux;
		}

		table_insert(codeList, inst)

		if opmode == 1 then --[[ A ]]
			inst.A = bit32_band(bit32_rshift(value, 8), 0xFF)
		elseif opmode == 2 then --[[ AB ]]
			inst.A = bit32_band(bit32_rshift(value, 8), 0xFF)
			inst.B = bit32_band(bit32_rshift(value, 16), 0xFF)
		elseif opmode == 3 then --[[ ABC ]]
			inst.A = bit32_band(bit32_rshift(value, 8), 0xFF)
			inst.B = bit32_band(bit32_rshift(value, 16), 0xFF)
			inst.C = bit32_band(bit32_rshift(value, 24), 0xFF)
		elseif opmode == 4 then --[[ AD ]]
			inst.A = bit32_band(bit32_rshift(value, 8), 0xFF)
			local temp = bit32_band(bit32_rshift(value, 16), 0xFFFF)
			inst.D = if temp < 0x8000 then temp else temp - 0x10000
		elseif opmode == 5 then --[[ AE ]]
			local temp = bit32_band(bit32_rshift(value, 8), 0xFFFFFF)
			inst.E = if temp < 0x800000 then temp else temp - 0x1000000
		end

		if usesAux then 
			local aux = readWord()
			inst.aux = aux

			table_insert(codeList, {value = aux, opname = "auxvalue" })
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
			local count = bit32_rshift(extend, 30)
			local id0 = bit32_band(bit32_rshift(extend, 20), 0x3FF)

			inst.K0 = k[id0 + 1]
			inst.KC = count
			if count == 2 then
				local id1 = bit32_band(bit32_rshift(extend, 10), 0x3FF)

				inst.K1 = k[id1 + 1]
			elseif count == 3 then
				local id1 = bit32_band(bit32_rshift(extend, 10), 0x3FF)
				local id2 = bit32_band(bit32_rshift(extend, 0), 0x3FF)

				inst.K1 = k[id1 + 1]
				inst.K2 = k[id2 + 1]
			end
		elseif kmode == 5 then --// AUX boolean low 1 bit
			inst.K = bit32_extract(inst.aux, 0, 1) == 1
			inst.KN = bit32_extract(inst.aux, 31, 1) == 1
		elseif kmode == 6 then --// AUX number low 24 bits
			inst.K = k[bit32_extract(inst.aux, 0, 24) + 1]
			inst.KN = bit32_extract(inst.aux, 31, 1) == 1
		elseif kmode == 7 then --// B
			inst.K = k[inst.B + 1]
		elseif kmode == 8 then --// AUX number low 16 bits
			inst.K = bit32_band(inst.aux, 0xf)
		end
	end

	local function readProto(bytecodeid)
		local maxstacksize = readByte()
		local numparams = readByte()
		local nups = readByte()
		local isvararg = readByte() ~= 0

		if luauVersion >= 4 then
			readByte() --// flags 
			local typesize = readVarInt();
			cursor = cursor + typesize;
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
				k = readDouble()
			elseif kt == 3 then --// String
				k = stringList[readVarInt()]
			elseif kt == 4 then --// Import
				k = readWord()
			elseif kt == 5 then --// Table
				local dataLength = readVarInt()
				k = table_create(dataLength)

				for i = 1, dataLength do
					k[i] = readVarInt()
				end
			elseif kt == 6 then --// Closure
				k = readVarInt()
			elseif kt == 7 then --// Vector
				local x,y,z,w = readFloat(), readFloat(), readFloat(), readFloat()

				if luau_settings.vectorSize == 4 then
					k = luau_settings.vectorCtor(x,y,z,w)
				else 
					k = luau_settings.vectorCtor(x,y,z)
				end
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
			protolist[i] = readVarInt() + 1
		end

		local linedefined = readVarInt()
		local debugname = stringList[readVarInt()]

		-- // lineinfo
		if readByte() ~= 0 then
			local lineGap = readByte()
			for i = 1, sizecode do
				readByte()
			end
			local intervals = bit32_rshift(sizecode - 1, lineGap) + 1
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
			local sizeupvalues = readVarInt()
			for i = 1, sizeupvalues do
				readVarInt()
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

	assert(cursor == #bytecode, "deserializer cursor position mismatch")

	return {
		stringList = stringList;
		protoList = protoList;

		mainProto = mainProto;

		typesVersion = typesVersion;
	}
end

local function luau_load(module, env, luau_settings)
	if luau_settings == nil then
		luau_settings = luau_newsettings()
	else 
		luau_validatesettings(luau_settings)
	end

	if type(module) == "string" then
		module = luau_deserialize(module, luau_settings)
	end

	local protolist = module.protoList
	local mainProto = module.mainProto
	
	local breakHook = luau_settings.callHooks.breakHook
	local stepHook = luau_settings.callHooks.stepHook
	local interruptHook = luau_settings.callHooks.interruptHook
	local panicHook = luau_settings.callHooks.panicHook
	
	local alive = true 
	
	local function luau_close()
		alive = false
	end
	
	local function luau_wrapclosure(module, proto, upvals)
		local function luau_execute(debugging, stack, protos, code, varargs)
			local top, pc, open_upvalues, generalized_iterators = -1, 1, {}, {}
			local constants = proto.k
			local extensions = luau_settings.extensions

			while alive do
				local inst = code[pc]
				local op = inst.opcode
				
				debugging.pc = pc
				debugging.top = top
				debugging.name = inst.opname

				pc += 1
				
				if stepHook then
					stepHook(stack, debugging, proto, module, upvals)
				end
				
				if op == 0 then --[[ NOP ]]
					--// Do nothing
				elseif op == 1 then --[[ BREAK ]]
					if breakHook then
						breakHook(stack, debugging, proto, module, upvals)
					else
						error("Breakpoint encountered without a break hook")
					end
				elseif op == 2 then --[[ LOADNIL ]]
					stack[inst.A] = nil
				elseif op == 3 then --[[ LOADB ]]
					stack[inst.A] = inst.B == 1
					pc += inst.C
				elseif op == 4 then --[[ LOADN ]]
					stack[inst.A] = inst.D
				elseif op == 5 then --[[ LOADK ]]
					stack[inst.A] = inst.K
				elseif op == 6 then --[[ MOVE ]]
					stack[inst.A] = stack[inst.B]
				elseif op == 7 then --[[ GETGLOBAL ]]
					local kv = inst.K

					stack[inst.A] = extensions[kv] or env[kv]

					pc += 1 --// adjust for aux
				elseif op == 8 then --[[ SETGLOBAL ]]
					local kv = inst.K
					env[kv] = stack[inst.A]

					pc += 1 --// adjust for aux
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
					local count = inst.KC
					local k0 = inst.K0
					local import = extensions[k0] or env[k0]

					if count == 1 then
						stack[inst.A] = import
					elseif count == 2 then
						stack[inst.A] = import[inst.K1]
					elseif count == 3 then
						stack[inst.A] = import[inst.K1][inst.K2]
					end

					pc += 1 --// adjust for aux 
				elseif op == 13 then --[[ GETTABLE ]]
					stack[inst.A] = stack[inst.B][stack[inst.C]]
				elseif op == 14 then --[[ SETTABLE ]]
					stack[inst.B][stack[inst.C]] = stack[inst.A]
				elseif op == 15 then --[[ GETTABLEKS ]]
					local index = inst.K
					stack[inst.A] = stack[inst.B][index]

					pc += 1 --// adjust for aux 
				elseif op == 16 then --[[ SETTABLEKS ]]
					local index = inst.K
					stack[inst.B][index] = stack[inst.A]

					pc += 1 --// adjust for aux
				elseif op == 17 then --[[ GETTABLEN ]]
					stack[inst.A] = stack[inst.B][inst.C + 1]
				elseif op == 18 then --[[ SETTABLEN ]]
					stack[inst.B][inst.C + 1] = stack[inst.A]
				elseif op == 19 then --[[ NEWCLOSURE ]]
					local newPrototype = protolist[protos[inst.D + 1]]

					local nups = newPrototype.nups
					local upvalues = table_create(nups)
					stack[inst.A] = luau_wrapclosure(module, newPrototype, upvalues)

					for i = 1, nups do
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
							upvalues[i] = upvals[pseudo.B + 1]
						end
					end
				elseif op == 20 then --[[ NAMECALL ]]
					local A = inst.A
					local B = inst.B

					local kv = inst.K
					local sb = stack[B]

					stack[A + 1] = sb
					stack[A] = sb[kv]

					pc += 1 --// adjust for aux 

					--// Special handling for native namecall behaviour
					local useNativeHandler = luau_settings.useNativeNamecall

					if useNativeHandler then
						local nativeNamecall = luau_settings.namecallHandler

						local callInst = code[pc]
						local callOp = callInst.opcode

						--// Copied from the CALL handler under
						local callA, callB, callC = callInst.A, callInst.B, callInst.C

						local params = if callB == 0 then top - callA else callB - 1
						local ret_list = table_pack(
							nativeNamecall(kv, table_unpack(stack, callA + 1, callA + params))
						)

						if ret_list[1] == true then
							if interruptHook then
								interruptHook(stack, debugging, proto, module, upvals)	
							end
							
							pc += 1 --// Skip next CALL instruction

							inst = callInst
							op = callOp
							debugging.pc = pc
							debugging.name = inst.opname
							
							if stepHook then
								stepHook(stack, debugging, proto, module, upvals)
							end

							table_remove(ret_list, 1)

							local ret_num = ret_list.n - 1

							if callC == 0 then
								top = callA + ret_num - 1
							else
								ret_num = callC - 1
							end

							table_move(ret_list, 1, ret_num, callA, stack)
						end
					end
				elseif op == 21 then --[[ CALL ]]
					if interruptHook then
						interruptHook(stack, debugging, proto, module, upvals)	
					end
					
					local A, B, C = inst.A, inst.B, inst.C

					local params = if B == 0 then top - A else B - 1
					local func = stack[A]
					local ret_list = table_pack(
						func(table_unpack(stack, A + 1, A + params))
					)

					local ret_num = ret_list.n

					if C == 0 then
						top = A + ret_num - 1
					else
						ret_num = C - 1
					end

					table_move(ret_list, 1, ret_num, A, stack)
				elseif op == 22 then --[[ RETURN ]]
					if interruptHook then
						interruptHook(stack, debugging, proto, module, upvals)	
					end
					
					local A = inst.A
					local B = inst.B 
					local b = B - 1
					local nresults

					if b == LUA_MULTRET then
						nresults = top - A + 1
					else
						nresults = B - 1
					end

					return table_unpack(stack, A, A + nresults - 1)
				elseif op == 23 then --[[ JUMP ]]
					pc += inst.D
				elseif op == 24 then --[[ JUMPBACK ]]
					if interruptHook then
						interruptHook(stack, debugging, proto, module, upvals)	
					end
					
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
					stack[inst.A] = table_create(inst.aux)

					pc += 1 --// adjust for aux 
				elseif op == 54 then --[[ DUPTABLE ]]
					local template = inst.K
					local serialized = {}
					for _, id in template do
						serialized[constants[id + 1]] = nil
					end
					stack[inst.A] = serialized
				elseif op == 55 then --[[ SETLIST ]]
					local A = inst.A
					local B = inst.B
					local c = inst.C - 1

					if c == LUA_MULTRET then
						c = top - B + 1
					end

					table_move(stack, B, B + c - 1, inst.aux, stack[A])

					pc += 1 --// adjust for aux 
				elseif op == 56 then --[[ FORNPREP ]]
					local A = inst.A

					local limit = stack[A]
					if not ttisnumber(limit) then
						local number = tonumber(limit)

						if number == nil then
							error("invalid 'for' limit (number expected)")
						end

						stack[A] = number
						limit = number
					end

					local step = stack[A + 1]
					if not ttisnumber(step) then
						local number = tonumber(step)

						if number == nil then
							error("invalid 'for' step (number expected)")
						end

						stack[A + 1] = number
						step = number
					end

					local index = stack[A + 2]
					if not ttisnumber(index) then
						local number = tonumber(index)

						if number == nil then
							error("invalid 'for' index (number expected)")
						end

						stack[A + 2] = number
						index = number
					end

					if step > 0 then
						if not (index <= limit) then
							pc += inst.D
						end
					else
						if not (limit <= index) then
							pc += inst.D
						end
					end
				elseif op == 57 then --[[ FORNLOOP ]]
					if interruptHook then
						interruptHook(stack, debugging, proto, module, upvals)	
					end
					
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
					if interruptHook then
						interruptHook(stack, debugging, proto, module, upvals)	
					end
					
					local A = inst.A
					local res = inst.K

					top = A + 6

					local it = stack[A]

					if (luau_settings.generalizedIteration == false) or ttisfunction(it) then 
						local vals = { it(stack[A + 1], stack[A + 2]) }
						table_move(vals, 1, res, A + 3, stack)

						if stack[A + 3] ~= nil then
							stack[A + 2] = stack[A + 3]
							pc += inst.D
						else
							pc += 1
						end
					else
						local ok, vals = coroutine_resume(generalized_iterators[inst], it, stack[A + 1], stack[A + 2])
						if not ok then
							error(vals)
						end
						if vals == LUA_GENERALIZED_TERMINATOR then 
							generalized_iterators[inst] = nil
							pc += 1
						else
							table_move(vals, 1, res, A + 3, stack)

							stack[A + 2] = stack[A + 3]
							pc += inst.D
						end
					end
				elseif op == 59 then --[[ FORGPREP_INEXT ]]
					if not ttisfunction(stack[inst.A]) then
						error(string_format("attempt to iterate over a %s value", type(stack[inst.A]))) -- FORGPREP_INEXT encountered non-function value
					end

					pc += inst.D
				elseif op == 61 then --[[ FORGPREP_NEXT ]]
					if not ttisfunction(stack[inst.A]) then
						error(string_format("attempt to iterate over a %s value", type(stack[inst.A]))) -- FORGPREP_NEXT encountered non-function value
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

					local nups = newPrototype.nups
					local upvalues = table_create(nups)
					stack[inst.A] = luau_wrapclosure(module, newPrototype, upvalues)

					for i = 1, nups do
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
							upvalues[i] = upvals[pseudo.B + 1]
						end
					end
				elseif op == 65 then --[[ PREPVARARGS ]]
					--[[ Handled by wrapper ]]
				elseif op == 66 then --[[ LOADKX ]]
					local kv = inst.K
					stack[inst.A] = kv

					pc += 1 --// adjust for aux 
				elseif op == 67 then --[[ JUMPX ]]
					if interruptHook then
						interruptHook(stack, debugging, proto, module, upvals)	
					end
					
					pc += inst.E
				elseif op == 68 then --[[ FASTCALL ]]
					--[[ Skipped ]]
				elseif op == 70 then --[[ CAPTURE ]]
					--[[ Handled by CLOSURE ]]
					error("encountered unhandled CAPTURE")
				elseif op == 71 then --[[ SUBRK ]]
					stack[inst.A] = inst.K - stack[inst.C]
				elseif op == 72 then --[[ DIVRK ]]
					stack[inst.A] = inst.K / stack[inst.C]
				elseif op == 73 then --[[ FASTCALL1 ]]
					--[[ Skipped ]]
				elseif op == 74 then --[[ FASTCALL2 ]]
					--[[ Skipped ]]
					pc += 1 --// adjust for aux
				elseif op == 75 then --[[ FASTCALL2K ]]
					--[[ Skipped ]]
					pc += 1 --// adjust for aux
				elseif op == 76 then --[[ FORGPREP ]]
					local iterator = stack[inst.A]

					if luau_settings.generalizedIteration and not ttisfunction(iterator) then
						local loopInstruction = code[pc + inst.D]
						if generalized_iterators[loopInstruction] == nil then 
							local function gen_iterator(...)
								for r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16, r17, r18, r19, r20, r21, r22, r23, r24, r25, r26, r27, r28, r29, r30, r31, r32, r33, r34, r35, r36, r37, r38, r39, r40, r41, r42, r43, r44, r45, r46, r47, r48, r49, r50, r51, r52, r53, r54, r55, r56, r57, r58, r59, r60, r61, r62, r63, r64, r65, r66, r67, r68, r69, r70, r71, r72, r73, r74, r75, r76, r77, r78, r79, r80, r81, r82, r83, r84, r85, r86, r87, r88, r89, r90, r91, r92, r93, r94, r95, r96, r97, r98, r99, r100, r101, r102, r103, r104, r105, r106, r107, r108, r109, r110, r111, r112, r113, r114, r115, r116, r117, r118, r119, r120, r121, r122, r123, r124, r125, r126, r127, r128, r129, r130, r131, r132, r133, r134, r135, r136, r137, r138, r139, r140, r141, r142, r143, r144, r145, r146, r147, r148, r149, r150, r151, r152, r153, r154, r155, r156, r157, r158, r159, r160, r161, r162, r163, r164, r165, r166, r167, r168, r169, r170, r171, r172, r173, r174, r175, r176, r177, r178, r179, r180, r181, r182, r183, r184, r185, r186, r187, r188, r189, r190, r191, r192, r193, r194, r195, r196, r197, r198, r199, r200 in ... do 
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
					local ra = stack[inst.A]

					if (ttisboolean(ra) and (ra == kv)) ~= kn then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 79 then --[[ JUMPXEQKN ]]
					local kv = inst.K
					local kn = inst.KN
					local ra = stack[inst.A]

					if (ra == kv) ~= kn then
						pc += inst.D
					else
						pc += 1
					end
				elseif op == 80 then --[[ JUMPXEQKS ]]
					local kv = inst.K
					local kn = inst.KN
					local ra = stack[inst.A]

					if (ra == kv) ~= kn then
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
			
			for i, uv in open_upvalues do
				uv.value = uv.store[uv.index]
				uv.store = uv
				uv.index = "value" --// self reference
				open_upvalues[i] = nil
			end
			
			for i, iter in generalized_iterators do 
				coroutine_close(iter)
				generalized_iterators[i] = nil
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
			if luau_settings.errorHandling then 
				result = table_pack(pcall(luau_execute, debugging, stack, proto.protos, proto.code, varargs))
			else
				result = table_pack(true, luau_execute(debugging, stack, proto.protos, proto.code, varargs))
			end

			if result[1] then
				return table_unpack(result, 2, result.n)
			else
				if panicHook then
					panicHook(result[2], stack, debugging, proto, module, upvals)
				end
				
				return error(string_format("Fiu VM Error PC: %s Opcode: %s: \n%s", debugging.pc, debugging.name, result[2]), 0)
			end
		end

		return wrapped
	end

	return luau_wrapclosure(module, mainProto),  luau_close
end

return {
	luau_newsettings = luau_newsettings,
	luau_validatesettings = luau_validatesettings,
	luau_deserialize = luau_deserialize,
	luau_load = luau_load,
}
