--!ctx Luau

local ok, compileResult = Luau.compile([[
local a = A
local b = Lib.B
local c = Lib.List.C

assert(a() == "A")
assert(b() == "Lib.B")
assert(c() == "Lib.List.C")
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

local calledConstants = {}

settings.useImportConstants = true
settings.staticEnvironment = {
	assert = assert,
	A = function()
		calledConstants.A = true
		return "A"
	end,
	Lib = {
		B = function()
			calledConstants.B = true
			return "Lib.B"
		end,
		List = {
			C = function()
				calledConstants.C = true
				return "Lib.List.C"
			end
		}
	}
}

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult, settings), {}, settings)

func()

assert(calledConstants.A, "A was not called")
assert(calledConstants.B, "B was not called")
assert(calledConstants.C, "C was not called")

settings.staticEnvironment = {}

local success, message = pcall(Fiu.luau_deserialize, compileResult, settings)

assert(success == false, "luau_deserialize should have errored")
assert(MATCH(message, "Could not resolve import constant: A\nMake sure the import is defined in staticEnvironment."))

OK()