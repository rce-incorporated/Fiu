-- tests: LOP_CALL, LOP_NAMECALL, LOP_FASTCALL1, LOP_FASTCALL2K, LOP_RETURN

assert(type(1<2) == 'boolean', "Relational operators must return booleans")
assert(type(true) == 'boolean' and type(false) == 'boolean', "True and False must be booleans")
assert(type(nil) == 'nil' and type(-3) == 'number' and type'x' == 'string' and
	type{} == 'table' and type(type) == 'function', "Type must return the type of its argument")

assert(type(assert) == type(print), "Type must return the type of its argument")

f = nil
function f (x) return a:x (x) end
assert(type(f) == 'function', "Invalid type for f")

-- testing local-function recursion
fact = false
do
	local res = 1
	local function fact(n)
		if n==0 then
			return res
		else
			return n*fact(n-1)
		end
	end
	assert(fact(5) == 120, "Invalid value for fact(5)")
end
assert(fact == false, "Local function must be local")

-- testing declarations
a = {i = 10}
self = 20

function a:x (x)
	return x+self.i
end
function a.y (x)
	return x+self
end

assert(a:x(1)+10 == a.y(1), "Invalid assessment for a:x(1)+10 == a.y(1)")

a.t = {i=-100}
a["t"].x = function(self, a,b)
	return self.i+a+b
end

assert(a.t:x(2,3) == -95, "Invalid value for a.t:x(2,3)")

do
	local a = {x=0}
	function a:add (x) self.x, a.y = self.x+x, 20; return self end
	assert(a:add(10):add(20):add(30).x == 60 and a.y == 20)
end

local a = {b={c={}}}

function a.b.c.f1 (x)
	return x+1
end
function a.b.c:f2 (x,y)
	self[x] = y
end
assert(a.b.c.f1(4) == 5, "Invalid value for a.b.c.f1")
a.b.c:f2('k', 12);
assert(a.b.c.k == 12, "Invalid value for a.b.c.k")

t = nil   -- 'declare' t
function f(a,b,c) local d = 'a'; t={a,b,c,d} end

f(      -- this line change must be valid
	1,2)
assert(t[1] == 1 and t[2] == 2 and t[3] == nil and t[4] == 'a', "Invalid value for t[1], t[2], t[3], t[4]")
f(1,2,   -- this one too
	3,4)
assert(t[1] == 1 and t[2] == 2 and t[3] == 3 and t[4] == 'a', "Invalid value for t[1], t[2], t[3], t[4]")

function fat(x)
	if x <= 1 then
		return 1
	else
		return x * loadstring("return fat(" .. x-1 .. ")")()
	end
end

assert(loadstring(`loadstring "assert(fat(6)==720, 'Unmatching values')" ()`), "Failed to compile test case #1")()

local a, b = assert(loadstring('return fat(1), 3'), "Failed to compile test case #2")()
assert(a == 1 and b == 3, "Unmatching values")

function err_on_n(n)
	if n == 0 then
		error();
	else
		err_on_n(n-1);
	end
end
do
	function dummy (n)
		if n > 0 then
			assert(not pcall(err_on_n, n))
			dummy(n-1)
		end
	end
end

dummy(1)

-- testing tail call
function deep(n)
	if n>0 then
		return deep(n-1)
	else
		return 101
	end
end
assert(deep(100) == 101, "Tail call #1")

a = {}
function a:deep(n)
	if n>0 then
		return self:deep(n-1)
	else
		return 101
	end
end
assert(a:deep(100) == 101, "Tail call #2")

local t = {}
function t:test()
	t.v = 1
	return self
end
assert(t:test() == t, "Namecall #1")
assert(t.v == 1, "Namecall call #2")

assert(math.sin(1,2) == math.sin(1), "Extra arguments #1")
table.sort({10,9,8,4,19,23,0,0}, function (a,b) return a<b end, "extra argument")

-- test for bug in parameter adjustment
assert((function() return nil end)(4) == nil, "Bug in parameter adjustment #1")
assert((function() local a; return a end)(4) == nil, "Bug in parameter adjustment #2")
assert((function(a) return a end)() == nil, "Bug in parameter adjustment #3")

-- test for error
assert(pcall(function() return 1,2,3 end) == true, "Error #1")
assert(pcall(function() error("xuxu") end) == false, "Error #2")
assert(pcall(function() pcall(function() error("xuxu") end) end) == true, "Error #3")

OK()