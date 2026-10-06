--!ctx Luau

local ok, bytecode = Luau.compile([[
return function()
    return 1
end
]], {
    optimizationLevel = 2,
    debugLevel = 2,
    coverageLevel = 0,
})

if not ok then
    error(bytecode)
end

local settings = Fiu.luau_newsettings()
settings.reuseClosures = true

local module = Fiu.luau_deserialize(bytecode, settings)
local hasDupClosure = false
for _, proto in module.protoList do
    for _, instruction in proto.code do
        if instruction.opcode == 64 then
            hasDupClosure = true
            assert(type(instruction.K) == "number")
        end
    end
end
assert(hasDupClosure, "test case did not compile a DUPCLOSURE instruction")

local run = Fiu.luau_load(module, {}, settings)
local first, same = run(), run()
assert(first == same, "repeated DUPCLOSURE should reuse a closure")
assert(first() == 1 and same() == 1)

local otherRun = Fiu.luau_load(module, {}, settings)
assert(first ~= otherRun(), "separate loaded modules should not share closures")

local defaultRun = Fiu.luau_load(module, {}, Fiu.luau_newsettings())
assert(defaultRun() ~= defaultRun(), "closure reuse should be disabled by default")

OK()
