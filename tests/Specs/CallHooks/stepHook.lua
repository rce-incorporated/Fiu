--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = 1
local b = 2
local c = 3
local d = 4
local e = 5
local f = 6

local function test()
	return a, b, c, d, e, f
end

for i = 1, 100 do
	f += 1
	break
end

local comp = {test()}

assert(#comp == 6, `Expected 6 elements in the table, got {#comp}`)
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

local stepCalled = false
settings.callHooks.stepHook = function(stack, debugging, proto, module, upvals)
	assert(type(stack) == "table", `Expected stack to be a table, got {type(stack)}`)
	assert(type(debugging) == "table", `Expected debugging to be a table, got {type(debugging)}`)
	assert(type(proto) == "table", `Expected proto to be a table, got {type(proto)}`)
	assert(type(module) == "table", `Expected module to be a table, got {type(module)}`)
	if upvals then
		assert(type(upvals) == "table", `Expected upvals to be a table, got {type(upvals)}`)
	end
	stepCalled = true;
end

settings.callHooks.breakHook = function(stack, debugging, proto, module, upvals)
	error("Unexpected break");
end

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult), {assert = assert}, settings)

assert(stepCalled == false, "Step hook was called before the function was executed")

func()

assert(stepCalled, "Step hook was not called")

OK()