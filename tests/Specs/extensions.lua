--!ctx Luau

local ok, compileResult = Luau.compile([[
sideload("Test")();
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

local called = false
settings.extensions["sideload"] = function(name)
	if name == "Test" then
		return function()
			called = true
		end
	end
	error(`Parameter not expected: {name}`)
end

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult), {assert = assert}, settings)

func()

assert(called, "extension `sideload` 'Test' was not called")

OK()