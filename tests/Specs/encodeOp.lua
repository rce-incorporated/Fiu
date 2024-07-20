--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = {0};
a[1]= 1
spark(a)
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = nil,
	vectorCtor = nil,
	vectorType = nil
})

if not ok then
	error(compileResult)
end

local settings = Fiu.luau_newsettings()

local sparkCalled = false
settings.extensions["spark"] = function(t)
	if t[1] == 1 then
        sparkCalled = true;
		return
	end
	error(`failed`)
end

local decodeCalled = false
settings.decodeOp = function(op)
    decodeCalled = true;
    return op - 2;
end

local function encodeOp(op)
    return op + 2;
end

local aux = {8,9,13,16,17,21,28,29,30,31,32,33,54,56,59,61,67,75,76,78,79,80,81}
local function encodeLuau(bc : string)
	local stream, cursor = buffer.fromstring(bc), 0

	local function readByte()
		local byte = buffer.readu8(stream, cursor); cursor += 1
		return byte
	end
	local function readWord()
		local word = buffer.readu32(stream, cursor); cursor += 4
		return word
	end
    local function writeWord(v)
		buffer.writeu32(stream, cursor, v); cursor += 4
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
			local str = buffer.readstring(stream, cursor, size)
			cursor += size
			return str
		end
	end
	local luauVersion = readByte(); assert(luauVersion ~= 0)
	local typesVersion = if luauVersion >= 4 then readByte() else 0
	for i = 1, readVarInt() do
		readString()
	end
	local function readInstruction()
		local value = readWord(); cursor -= 4
        writeWord(encodeOp(value))
		if table.find(aux, bit32.band(value, 0xFF) + 1) then
			cursor += 4; return true
		end
        return
	end
	local function readProto()
        cursor += 4
		if luauVersion >= 4 then
			cursor += 1
            local sz = readVarInt();
            cursor += sz;
		end
        local sizecode = readVarInt();
		local skipnext = false 
		for i = 1, sizecode do
			if skipnext then 
				skipnext = false
				continue 
			end
			skipnext = readInstruction()
		end
		for i = 1, readVarInt() do
			local kt = readByte()
			if kt == 1 then
				cursor += 1
			elseif kt == 2 then
				cursor += 8
			elseif kt == 3 then
                readVarInt()
			elseif kt == 4 then
				cursor += 4
			elseif kt == 5 then
				for i = 1, readVarInt() do
					readVarInt()
				end
			elseif kt == 6 then
				readVarInt()
			elseif kt == 7 then
                cursor += 16
			end
		end
		for i = 1, readVarInt() do
			readVarInt()
		end
		readVarInt()
		readVarInt()
		if readByte() ~= 0 then
			local i = bit32.rshift((sizecode - 1), readByte()) + 1
			cursor += sizecode
            cursor += i * 4
		end
		if readByte() ~= 0 then
			for i = 1, readVarInt() do
				readVarInt(); readVarInt(); readVarInt(); cursor += 1
			end
			for i = 1, readVarInt() do
				readVarInt()
			end
		end
	end
	if typesVersion == 3 then
		local index = readByte()
		while index ~= 0 do
			readVarInt()
			index = readByte()
		end
	end
	for i = 1, readVarInt() do
		readProto()
	end
	readVarInt()
	assert(cursor == buffer.len(stream), "deserializer cursor position mismatch")
	return buffer.tostring(stream)
end

compileResult = encodeLuau(compileResult);

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult, settings), {assert = assert}, settings)

func()

assert(decodeCalled, "extension `decodeOp` was not called")
assert(sparkCalled, "extension `spark` was not called")

OK()