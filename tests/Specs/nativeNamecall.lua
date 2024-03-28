--!ctx Luau

local ok, compileResult = Luau.compile([[
assert(someObj:Test(1) == "Correct")
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

settings.useNativeNamecall = true
settings.namecallHandler = function(method, self, ...)
	called = true
	if method == "Test" then
		return true, self:Test(...)
	end
	return false
end

-- Test Object
local someObj = newproxy(true);

local objMeta = getmetatable(someObj)
local someObjCalled = false
objMeta.__namecall = function(self, ...)
	local method = getNamecall()
	if method == "Test" then
		local num = ...
		assert(self == someObj)
		assert(num == 1)
		someObjCalled = true
		return "Correct"
	end
	return
end

objMeta.__index = function()
	error("namecall should not be indexing")
end

settings.extensions["someObj"] = someObj

local func, _ = Fiu.luau_load(Fiu.luau_deserialize(compileResult), {assert = assert}, settings)

func()

assert(called, "nativecallHandler was not called")
assert(someObjCalled, "someObj:Test was not called")

OK()