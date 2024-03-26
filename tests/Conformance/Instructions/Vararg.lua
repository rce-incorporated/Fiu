-- tests: LOP_GETVARARGS, LOP_PREPVARARGS, LOP_CALL, LOP_RETURN

local function f(...)
	return {...}
end

local t = f(1, 2, 3)
assert(t[1] == 1 and t[2] == 2 and t[3] == 3, "Test 1 failed")

local function g(...)
	return ...
end

local a, b, c = g(1, 2, 3)
assert(a == 1 and b == 2 and c == 3, "Test 2 failed")

local function h(a, ...)
	return {
		a = a,
		...
	}
end

local t = h(1, 2, 3)
assert(t.a == 1 and t[1] == 2 and t[2] == 3, "Test 3 failed")

OK()