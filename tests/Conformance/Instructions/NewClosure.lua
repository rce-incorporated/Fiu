-- tests: LOP_NEWCLOSURE

-- void Luau optimization via `setfenv`
local _ref = setfenv

-- test upvalues
local a = 1
local b = 2
local c = 3
function newClosure()
	assert(a == 1, b == 2, c == 3)
	return a + b + c
end
assert(newClosure() == 6)

-- test function given proto
function newClosure2(a)
	local function nestClosure(a, b, c)
		return {a, b, c}
	end
	
	return "NEWCLOSURE", nestClosure(21, 22, 23)
end

local closure, result = newClosure2(20)
assert(closure == "NEWCLOSURE")
assert(result[1] == 21 and result[2] == 22 and result[3] == 23)

OK()