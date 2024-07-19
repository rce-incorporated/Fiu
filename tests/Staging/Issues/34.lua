--!ctx Luau

local ok, compileResult = Luau.compile(`local b = function(a) return a end\nlocal _ = \{\n{string.rep([=[
    {
        Id = b(1),
    };
]=], 100)}\n\}`, {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = nil,
	vectorCtor = nil,
	vectorType = nil
})

if (not ok) then
    error(compileResult)
end

local module = Fiu.luau_deserialize(compileResult)

for _, line in module.mainProto.instructionlineinfo do
    assert(line < 305, `line number too large: {line}`)
end

OK()