--!ctx Luau

local ok, bytecode = Luau.compile([[
return 9223372036854775807i, -9223372036854775807i
]], {
    optimizationLevel = 2,
    debugLevel = 2,
    coverageLevel = 0,
})

if not ok then
    error(bytecode)
end

local run = Fiu.luau_load(bytecode, getfenv())
local maximum, minimum = run()
assert(maximum == integer.fromstring("9223372036854775807"))
assert(minimum == integer.fromstring("-9223372036854775807"))

OK()
