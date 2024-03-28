--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = 1
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

local breakCalled = false
settings.callHooks.breakHook = function(stack, debugging, proto, module, upvals)
	assert(stack[0] == nil, "Stack must be empty")
	assert(type(stack) == "table", "Stack is not a table")
	assert(type(debugging) == "table", "Debugging is not a table")
	assert(type(proto) == "table", "Proto is not a table")
	assert(type(module) == "table", "Module is not a table")
	assert(type(upvals) == "nil", "Upvals is not nil")
	breakCalled = true
end

local module = Fiu.luau_deserialize(compileResult)

-- Add Breakpoint
table.insert(module.mainProto.code, 1, {
	opcode = 1,
	opname = "BREAK",
})

local func, _ = Fiu.luau_load(module, {}, settings)

assert(breakCalled == false, "Break hook was called before function was executed")

func()

assert(breakCalled, "Break hook was not called")

OK()