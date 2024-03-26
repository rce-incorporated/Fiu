-- tests: LOP_DUPCLOSURE

-- test upvalues
local a = 1
local b = 2
local c = 3
function dupClosure()
	assert(a == 1, b == 2, c == 3)
	return a + b + c
end
assert(dupClosure() == 6)

-- test function given proto
function dupClosure2(a)
	local function nestClosure(a, b, c)
		return {a, b, c}
	end
	
	return "DUPCLOSURE", nestClosure(21, 22, 23)
end

local closure, result = dupClosure2(20)
assert(closure == "DUPCLOSURE")
assert(#result == 3 and result[1] == 21 and result[2] == 22 and result[3] == 23)

OK()