local function foo(...)
	return {...}
end

local list = foo("1", 2, true)

assert(#list == 3)
assert(list[1] == "1")
assert(list[2] == 2)
assert(list[3] == true)

OK()