--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = 0
assert(a == 3)
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

-- Interrupt hook
-- where `assert(res)` res is false, but hook changes it to true.

local interruptCalled = false
settings.callHooks.interruptHook = function(stack, debugging, proto, module, upvals)
	assert(type(stack) == "table", "Stack is not a table")
	assert(type(debugging) == "table", "Debugging is not a table")
	assert(type(proto) == "table", "Proto is not a table")
	assert(type(module) == "table", "Module is not a table")
	assert(type(upvals) == "nil", "Upvals is not nil")
	interruptCalled = true
	stack[proto.code[debugging.pc].B] = true
end

local module = Fiu.luau_deserialize(compileResult)

local func, _ = Fiu.luau_load(module, {assert = assert}, settings)

assert(interruptCalled == false, "Interrupt hook was called before function was executed")

func()

assert(interruptCalled, "Interrupt hook was not called")

OK()