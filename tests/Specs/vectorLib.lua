--!ctx Luau

local ok, compileResult = Luau.compile([[
	local t = vector.new(1, 2, 3)
	assert(gettype(t) == "vector")
	assert(t.x == 1)
	assert(t.y == 2)
	assert(t.z == 3)
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = "vector",
	vectorCtor = "new",
	vectorType = "vector"
})

if not ok then
	error(compileResult)
end

local settings = Fiu.luau_newsettings()

local called = false

settings.vectorCtor = function(x, y, z)
	called = true
	return VECTOR(x, y, z)
end
settings.vectorSize = 3

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult, settings), {assert = assert, gettype = type}, settings)

func()

assert(called, "vectorCtor was not called")

OK()