--!ctx Luau

local ok, bytecode = Luau.compile([[
local values = {answer = 42, label = "latest"}
local function invoke(fn)
	local result = fn(42)
	return result
end
local success, result = pcall(function()
	return invoke(function(value)
		return value + values.answer - 42
	end)
end)
assert(success and result == 42)
return values.label
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
})

if not ok then
	error(bytecode)
end

local version = buffer.readu8(buffer.fromstring(bytecode), 0)
assert(version >= 9 and version <= 14, "unexpected bytecode version: " .. version)

local module = Fiu.luau_deserialize(bytecode)
local callFeedback, fastPCall = 0, 0
for _, proto in module.protoList do
	for _, instruction in proto.code do
		if instruction.opcode == 87 then
			callFeedback += 1
		elseif instruction.opcode == 89 then
			fastPCall += 1
		end
	end
end
if version == 11 then
	assert(callFeedback > 0, "version 11 test did not emit CALLFB")
elseif version == 14 then
	assert(fastPCall > 0, "version 14 test did not emit FASTPCALL")
end
local run = Fiu.luau_load(module, getfenv())
assert(run() == "latest")

if version == 9 then
	local version10 = buffer.fromstring(bytecode)
	buffer.writeu8(version10, 0, 10)
	local run10 = Fiu.luau_load(Fiu.luau_deserialize(version10), getfenv())
	assert(run10() == "latest")
end

local version100 = buffer.fromstring(bytecode)
buffer.writeu8(version100, 0, 100)
local accepted, message = pcall(Fiu.luau_deserialize, version100)
assert(not accepted and string.find(message, "bytecode version 100 is unsupported", 1, true))

OK("Bytecode version " .. version .. ", CALLFB " .. callFeedback .. ", FASTPCALL " .. fastPCall)
