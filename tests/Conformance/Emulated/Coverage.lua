--!ctx Luau

local ok, compileResult = Luau.compile([[
print("Hello World!")
]])

if not ok then
	error(`Failed to compile, error: {compileResult}`)
end

local module = Fiu.luau_deserialize(compileResult)

table.insert(module.mainProto.code, 1, {
	opcode = 69,
	opname = "COVERAGE",
	E = 0,
})

local func, _ = Fiu.luau_load(module, {print = print})

func()

OK()
