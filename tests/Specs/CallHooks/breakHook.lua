--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = 1

step()
done()
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

local programKill = false
local breakCalled = false
local doneCalled = false
local stepCalled = false
settings.extensions = {
	done = function()
		doneCalled = true;
	end,
	step = function()
		stepCalled = true;
	end
};
settings.callHooks.breakHook = function(stack, debugging, proto, module, upvals)
	assert(type(stack) == "table", "Stack is not a table")
	assert(type(debugging) == "table", "Debugging is not a table")
	assert(type(proto) == "table", "Proto is not a table")
	assert(type(module) == "table", "Module is not a table")
	assert(type(upvals) == "nil", "Upvals is not nil")
	if (not breakCalled) then
		assert(stack[0] == nil, "Stack must be empty")
		breakCalled = true;
		return false
	else
		assert(stack[0] ~= nil, "Stack must not be empty")
		programKill = true;
		return true, "dead" -- kill vm function
	end
end

local module = Fiu.luau_deserialize(compileResult)

-- Add Breakpoint
module.mainProto.code[1].opcode = 1

-- Add Breakpoint right after step is called
module.mainProto.code[6].opcode = 1

local func, _ = Fiu.luau_load(module, {}, settings)

assert(breakCalled == false, "Break hook was called before function was executed")

local a = {func()}

assert(breakCalled, "Break hook was not called.")
assert(programKill, "Break hook was not called again, was meant to kill")
assert(#a == 1, "Break hook suppoose to kill with 1 param")
assert(a[1] == "dead", "Break hook mismatched value")
assert(stepCalled, "Break was never suppose to stop the program before step is called.")
assert(not doneCalled, "Break was never suppose to complete.")

OK()