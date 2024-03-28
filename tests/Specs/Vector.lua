--!ctx Luau

local ok, compileResult = Luau.compile([[
local vec = vector.new(1,2,3,4)

assert(type(vec) == "vector")
assert(vec.x == 1)
assert(vec.y == 2)
assert(vec.z == 3)
assert(vec.w == 4)
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = "vector",
	vectorCtor = "new",
	vectorType = nil
})

if not ok then
	error(compileResult)
end

local settings = Fiu.luau_newsettings()

local called = false

settings.vectorCtor = function(x, y, z, w)
	called = true
	return {
		x = x,
		y = y,
		z = z,
		w = w
	}
end
settings.vectorSize = 4

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult, settings), {assert = assert, type = type, print = print}, settings)

func()

assert(called, "vectorCtor was not called")

OK()