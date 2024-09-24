--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = 1
local b = 2
local c = 3
function funcA()
	return a + b + c
end
function funcB(a)
	return a + b + c
end
return funcA()
]], {
	optimizationLevel = 1,
	debugLevel = 2,
	coverageLevel = 2,
	vectorLib = nil,
	vectorCtor = nil,
	vectorType = nil
})

if not ok then
	error(`Failed to compile, error: {compileResult}`)
end

local module = Fiu.luau_deserialize(compileResult)

local hits = 0
Fiu.luau_getcoverage(module, nil, function(debugname, linedefined, depth, buffer, size)
	for _, hit in buffer do
		hits += hit
	end
end)
assert(hits == 0, "Coverage must start with no hits")

local func, _ = Fiu.luau_load(module, {print = print})

local res = func()
assert(res == 6, "module must return the correct sample result")

local hits = 0
local coverage = {}
Fiu.luau_getcoverage(module, nil, function(debugname, linedefined, depth, buffer, size)
	for _, hit in buffer do
		hits += hit
	end
	coverage[debugname] = {
		depth = depth,
		hits = buffer,
		size = size,
		linedefined = linedefined,
	}
end)

assert(MATCH(
	coverage["(main)"],
	{
		size = 10,
		depth = 0,
		linedefined = 1,
		hits = {
			[1] = 1,
			[2] = 1,
			[3] = 1,
			[4] = 1,
			[7] = 1,
			[10] = 1,
		}
	}
))

assert(MATCH(
	coverage["funcA"],
	{
		size = 10,
		depth = 1,
		linedefined = 4,
		hits = { [5] = 1 }
	}
))

assert(MATCH(
	coverage["funcB"],
	{
		size = 10,
		depth = 1,
		linedefined = 7,
		hits = { [8] = 0 } -- Should not have any hits
	}
))

assert(hits == 7, "Coverage must start with no hits")

OK()
