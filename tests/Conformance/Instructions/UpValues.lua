-- tests: LOP_GETUPVAL, LOP_SETUPVAL

-- test for upvalues
local a = 1
local function f()
	return a
end
assert(f() == 1)

local function g()
	local a = 2
	return f()
end
assert(g() == 1)

local function h()
	local a = 3
	local function f()
		return a
	end
	return f()
end
assert(h() == 3)

local function i()
	local a = 4
	local function f()
		return a
	end
	a = 5
	return f()
end
assert(i() == 5)

local function j()
	local a = 6
	local function f()
		return a
	end
	local a = 7
	return f()
end
assert(j() == 6)

local function k()
	local a = 8
	local function f()
		return a
	end
	do
		local a = 9
		return f()
	end
end
assert(k() == 8)

local a = 10
do
	local a = 11
	local function f()
		return a
	end
	assert(f() == 11)
end

local function l()
	local a = 12
	local function f()
		return a
	end
	do
		a = 13
		return f()
	end
end
assert(l() == 13)

OK()