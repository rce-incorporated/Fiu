--!ctx Luau

local ok, compileResult = Luau.compile([[
error("Hello, World!")
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

local panicCalled = false
settings.callHooks.panicHook = function(message, stack, debugging, proto, module, upvals)
	assert(message:find("Hello, World!$"), "Message does not end with 'Hello, World!'")
	assert(type(stack) == "table", "Stack is not a table")
	assert(type(debugging) == "table", "Debugging is not a table")
	assert(type(proto) == "table", "Proto is not a table")
	assert(type(module) == "table", "Module is not a table")
	assert(type(upvals) == "nil", "Upvals is not nil")
	panicCalled = true
end

local module = Fiu.luau_deserialize(compileResult)

local func, _ = Fiu.luau_load(module, {error = error}, settings)

assert(panicCalled == false, "Panic hook was called before function was executed")

local runOk, runRes = pcall(func)

assert(runOk == false, "Function did not panic")
assert(runRes:find("Hello, World!$"), "Function did not panic with 'Hello, World!'")

assert(panicCalled, "Panic hook was not called")

OK()