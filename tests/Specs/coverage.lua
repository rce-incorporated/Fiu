--!ctx Luau

--[[Api check]] do
	local ok, compileResult = Luau.compile([[
	print("Hello world!")
	]], {
		optimizationLevel = 1,
		debugLevel = 0,
		coverageLevel = 2,
		vectorLib = nil,
		vectorCtor = nil,
		vectorType = nil
	})
	
	if not ok then
		error(`Failed to compile, error: {compileResult}`)
	end
	
	local module = Fiu.luau_deserialize(compileResult)
	
	local success, err = pcall(Fiu.luau_getcoverage, module, nil, function() end)
	assert(not success, "Must fail")
	assert(err == "proto must have debug enabled", "Error does not match")

	success, err = pcall(Fiu.luau_getcoverage, module, "string", function() end)
	assert(not success, "Must fail")
	assert(err == "protoid must be a number or nil", "Error does not match")

	success, err = pcall(Fiu.luau_getcoverage, module, 1, "")
	assert(not success, "Must fail")
	assert(err == "callback must be a function", "Error does not match")
end

--[[Full coverage: Level 2]] do
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
	funcB(2)
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
			size = 11,
			depth = 0,
			linedefined = 1,
			hits = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
				[4] = 1,
				[7] = 1,
				[10] = 1,
				[11] = 1,
			}
		}
	))
	
	assert(MATCH(
		coverage["funcA"],
		{
			size = 11,
			depth = 1,
			linedefined = 4,
			hits = { [5] = 1 }
		}
	))
	
	assert(MATCH(
		coverage["funcB"],
		{
			size = 11,
			depth = 1,
			linedefined = 7,
			hits = { [8] = 1 }
		}
	))
	
	assert(hits == 9, "Coverage must have 9 hits")
end


--[[Full coverage: Level 1]] do
local ok, compileResult = Luau.compile([[
	local a = 1
	local b = 2
	local c = 3
	function funcA()
		funcB(2)
		return a + b + c
	end
	function funcB(a)
		return a + b + c
	end
	return funcA()
	]], {
		optimizationLevel = 1,
		debugLevel = 2,
		coverageLevel = 1,
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
			size = 11,
			depth = 0,
			linedefined = 1,
			hits = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
				[4] = 1,
				[8] = 1,
				[11] = 1,
			}
		}
	))

	assert(MATCH(
		coverage["funcA"],
		{
			size = 11,
			depth = 1,
			linedefined = 4,
			hits = {
				[5] = 1,
				[6] = 1
			}
		}
	))
	
	assert(MATCH(
		coverage["funcB"],
		{
			size = 11,
			depth = 1,
			linedefined = 8,
			hits = { [9] = 1 }
		}
	))
	
	assert(hits == 9, "Coverage must have 9 hits")
end

--[[Semi Coverage: Unused function]] do
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
	
	assert(hits == 7, "Coverage must have 7 hits")
end

--[[Full Coverage: Deep]] do
local ok, compileResult = Luau.compile([[
	local a = 1
	local b = 2
	local c = 3
	function funcA()
		local function foo()
			local function bar()
				print("bar")
			end
			bar()
		end
		foo()
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
			size = 15,
			depth = 0,
			linedefined = 1,
			hits = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
				[4] = 1,
				[15] = 1,
			}
		}
	))
	
	assert(MATCH(
		coverage["funcA"],
		{
			size = 15,
			depth = 1,
			linedefined = 4,
			hits = {
				[5] = 1,
				[11] = 1,
				[12] = 1,
			}
		}
	))
	
	assert(MATCH(
		coverage["foo"],
		{
			size = 15,
			depth = 2,
			linedefined = 5,
			hits = {
				[6] = 1,
				[9] = 1,
			}
		}
	))

	assert(MATCH(
		coverage["bar"],
		{
			size = 15,
			depth = 3,
			linedefined = 6,
			hits = { [7] = 1 }
		}
	))
	
	assert(hits == 11, "Coverage must have 11 hits")
end

--[[Semi Coverage: Deep, Unused function]] do
local ok, compileResult = Luau.compile([[
	local a = 1
	local b = 2
	local c = 3
	function funcA()
		local function foo()
			local function bar()
				print("bar")
			end
		end
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
			size = 13,
			depth = 0,
			linedefined = 1,
			hits = {
				[1] = 1,
				[2] = 1,
				[3] = 1,
				[4] = 1,
				[13] = 1,
			}
		}
	))
	
	assert(MATCH(
		coverage["funcA"],
		{
			size = 13,
			depth = 1,
			linedefined = 4,
			hits = {
				[5] = 1,
				[10] = 1,
			}
		}
	))
	
	assert(MATCH(
		coverage["foo"],
		{
			size = 13,
			depth = 2,
			linedefined = 5,
			hits = { [6] = 0 } -- Should not have any hits
		}
	))

	assert(MATCH(
		coverage["bar"],
		{
			size = 13,
			depth = 3,
			linedefined = 6,
			hits = { [7] = 0 } -- Should not have any hits
		}
	))
	
	assert(hits == 7, "Coverage must have 7 hits")
end

OK()
