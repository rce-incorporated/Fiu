--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = {0}
a[1] = 1
spark(a)
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = nil,
	vectorCtor = nil,
	vectorType = nil
}, 2)

if not ok then
	error(compileResult)
end

local settings = Fiu.luau_newsettings()

local sparkCalled = false
settings.extensions["spark"] = function(t)
	if t[1] == 1 then
        sparkCalled = true
		return
	end
	error(`failed`)
end

local decodeCalled = false
settings.decodeOp = function(op)
    decodeCalled = true
    return op - 2
end

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult, settings), {}, settings)

func()

assert(decodeCalled, "extension `decodeOp` was not called")
assert(sparkCalled, "extension `spark` was not called")

OK()