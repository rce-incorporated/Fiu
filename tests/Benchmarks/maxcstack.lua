--!ctx Luau

local ok, compileResult = Luau.compile([[
	local function stack()
		count()
		stack()
	end
	stack()
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
settings.errorHandling = true
local debugCount = 0
settings.extensions.count = function()
	debugCount += 1
end
local debugResult = Fiu.luau_load(compileResult, {}, settings)
local debugOk, _ = pcall(debugResult)
assert(not debugOk, "Something went wrong in debug, expected an error")

settings.errorHandling = false
local releaseCount = 0
settings.extensions.count = function()
	releaseCount += 1
end
local releaseResult = Fiu.luau_load(compileResult, {}, settings)
local releaseOk, _ = pcall(releaseResult)
assert(not releaseOk, "Something went wrong in release, expected an error")

OK(`Max stack depth: [DEBUG: {debugCount}] [RELEASE: {releaseCount}]`)