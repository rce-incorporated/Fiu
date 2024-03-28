-- file was auto-generated by `fiu-tests`
--!ctx Luau

local ok, compileResult = Luau.compile([[
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
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = nil,
	vectorCtor = nil,
	vectorType = nil
})

if not ok then
	error(`Failed to compile, error: {compileResult}`)
end

local encodedModule, constantList, stringList = [[
1; 24; 0 4 1 0 0 11 3 7 2 0 [] 1 [11,11,11,11,11,11,11,] {
	7 1 1 0 1 ? ? ? ? 1 ? ? ? ? ? 1; ~ 0; 6 2 0 ? 3 0 ? ? ? ? ? ? ? ? ? ?; 20 3 1 1 1 1 153 ? ? 2 ? ? ? ? ? 1
	~ 1; 21 3 0 ? 1 3 0 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 1 0 ? ? ? ? ? ? ? ? ? ?
}
1 4 1 2 0 18 4 9 2 0 [] 1 [19,19,20,20,22,22,22,22,22,] {
	79 4 6 2147483648 0 ? ? 3 ? 1 ? ? ? 1 ? 1; ~ 2147483648; 4 4 0 ? 1 ? ? 1 ? ? ? ? ? ? ? ?; 22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?
	9 2 0 ? 2 0 ? ? ? ? ? ? ? ? ? ?; 40 3 2 ? 3 0 1 ? ? 2 ? ? ? ? ? ?; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 35 3 0 ? 1 0 2 ? ? ? ? ? ? ? ? ?
	22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?
}
2 4 2 0 0 33 2 4 1 0 [] 1 [34,34,34,34,] {
	15 3 1 0 3 0 136 ? ? 1 ? ? ? ? ? 1; ~ 0; 33 3 0 ? 2 1 3 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 2 2 ? ? ? ? ? ? ? ? ? ?
}
3 3 1 0 0 36 9 4 1 0 [] 1 [37,37,37,37,] {
	7 1 1 0 2 ? ? ? ? 1 ? ? ? ? ? 1; ~ 0; 33 3 0 ? 1 0 2 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?
}
4 6 3 0 0 43 ? 5 1 0 [] 1 [44,44,44,44,44,] {
	15 3 1 0 5 0 136 ? ? 1 ? ? ? ? ? 1; ~ 0; 33 3 0 ? 4 5 1 ? ? ? ? ? ? ? ? ?; 33 3 0 ? 3 4 2 ? ? ? ? ? ? ? ? ?
	22 2 0 ? 3 2 ? ? ? ? ? ? ? ? ? ?
}
5 5 2 1 0 51 11 10 2 0 [] 1 [51,51,51,51,51,51,51,51,51,51,] {
	9 2 0 ? 2 0 ? ? ? ? ? ? ? ? ? ?; 15 3 1 0 4 0 153 ? ? 1 ? ? ? ? ? 1; ~ 0; 33 3 0 ? 3 4 1 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 4 ? ? 20 ? ? ? ? ? ? ? ?; 16 3 1 0 3 0 153 ? ? 1 ? ? ? ? ? 1; ~ 0; 16 3 1 1 4 2 152 ? ? 2 ? ? ? ? ? 1
	~ 1; 22 2 0 ? 0 2 ? ? ? ? ? ? ? ? ? ?
}
6 2 1 0 0 57 12 2 1 0 [] 1 [58,58,] {
	39 3 2 ? 1 0 0 ? ? 1 ? ? ? ? ? ?; 22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?
}
7 3 3 0 0 60 13 2 0 0 [] 1 [61,62,] {
	14 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
8 9 3 0 0 68 3 12 2 0 [] 1 [68,68,68,68,68,68,68,68,68,68,68,68,] {
	5 4 3 ? 3 ? ? 0 ? 1 ? ? ? ? ? ?; 53 2 0 4 4 0 ? ? ? ? ? ? ? ? ? 1; ~ 4; 6 2 0 ? 5 0 ? ? ? ? ? ? ? ? ? ?
	6 2 0 ? 6 1 ? ? ? ? ? ? ? ? ? ?; 6 2 0 ? 7 2 ? ? ? ? ? ? ? ? ? ?; 5 4 3 ? 8 ? ? 0 ? 1 ? ? ? ? ? ?; 55 3 0 1 4 5 5 ? ? ? ? ? ? ? ? 1
	~ 1; 8 1 1 1 4 ? ? ? ? 2 ? ? ? ? ? 1; ~ 1; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
9 7 1 0 0 77 20 15 5 0 [] 1 [78,78,78,79,79,81,81,81,81,81,81,81,81,81,81,] {
	4 4 0 ? 1 ? ? 1 ? ? ? ? ? ? ? ?; 31 4 0 1 0 ? ? 3 ? ? ? ? ? ? ? 1; ~ 1; 4 4 0 ? 1 ? ? 1 ? ? ? ? ? ? ? ?
	22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?; 12 4 4 1073741824 2 ? ? 1 ? ? 1 ? ? ? 1 1; ~ 1073741824; 5 4 3 ? 4 ? ? 2 ? 3 ? ? ? ? ? ?
	40 3 2 ? 5 0 3 ? ? 4 ? ? ? ? ? ?; 5 4 3 ? 6 ? ? 4 ? 5 ? ? ? ? ? ?; 49 3 0 ? 3 4 6 ? ? ? ? ? ? ? ? ?; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?
	21 3 0 ? 2 1 2 ? ? ? ? ? ? ? ? ?; 35 3 0 ? 1 0 2 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?
}
10 3 1 0 0 90 22 11 5 0 [] 1 [91,91,92,92,92,96,350,350,350,350,352,] {
	79 4 6 2147483648 0 ? ? 5 ? 1 ? ? ? 1 ? 1; ~ 2147483648; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400
	21 3 0 ? 1 1 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?; 7 1 1 3 1 ? ? ? ? 4 ? ? ? ? ? 1; ~ 3
	40 3 2 ? 2 0 4 ? ? 5 ? ? ? ? ? ?; 21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
11 6 1 0 0 98 25 19 7 0 [] 1 [99,99,99,100,100,100,100,100,100,100,100,100,100,100,101,101,101,101,103,] {
	4 4 0 ? 1 ? ? 0 ? ? ? ? ? ? ? ?; 32 4 0 0 1 ? ? 16 ? ? ? ? ? ? ? 1; ~ 0; 12 4 4 1073741824 3 ? ? 1 ? ? 1 ? ? ? 1 1
	~ 1073741824; 7 1 1 2 4 ? ? ? ? 3 ? ? ? ? ? 1; ~ 2; 6 2 0 ? 5 0 ? ? ? ? ? ? ? ? ? ?
	21 3 0 ? 3 3 2 ? ? ? ? ? ? ? ? ?; 50 2 0 ? 2 3 ? ? ? ? ? ? ? ? ? ?; 73 3 0 ? 1 2 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1076887552 1 ? ? 4 ? ? 4 ? ? ? 1 1
	~ 1076887552; 21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?; 7 1 1 5 1 ? ? ? ? 6 ? ? ? ? ? 1; ~ 5
	40 3 2 ? 2 0 6 ? ? 7 ? ? ? ? ? ?; 21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
12 3 1 0 0 109 26 10 2 0 [] 1 [110,110,110,111,111,111,111,111,113,113,] {
	4 4 0 ? 1 ? ? 0 ? ? ? ? ? ? ? ?; 32 4 0 0 1 ? ? 6 ? ? ? ? ? ? ? 1; ~ 0; 7 1 1 0 1 ? ? ? ? 1 ? ? ? ? ? 1
	~ 0; 40 3 2 ? 2 0 1 ? ? 2 ? ? ? ? ? ?; 21 3 0 ? 1 2 0 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 1 0 ? ? ? ? ? ? ? ? ? ?
	4 4 0 ? 1 ? ? 101 ? ? ? ? ? ? ? ?; 22 2 0 ? 1 2 ? ? ? ? ? ? ? ? ? ?
}
13 5 2 0 0 119 26 10 2 0 [] 1 [120,120,120,121,121,121,121,121,123,123,] {
	4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 32 4 0 1 2 ? ? 6 ? ? ? ? ? ? ? 1; ~ 1; 40 3 2 ? 4 1 0 ? ? 1 ? ? ? ? ? ?
	20 3 1 1 2 0 160 ? ? 2 ? ? ? ? ? 1; ~ 1; 21 3 0 ? 2 3 0 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 2 0 ? ? ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 101 ? ? ? ? ? ? ? ?; 22 2 0 ? 2 2 ? ? ? ? ? ? ? ? ? ?
}
14 3 1 1 0 129 28 5 1 0 [] 1 [130,130,130,130,131,] {
	9 2 0 ? 1 0 ? ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 1 ? ? ? ? ? ? ? ?; 16 3 1 0 2 1 151 ? ? 1 ? ? ? ? ? 1; ~ 0
	22 2 0 ? 0 2 ? ? ? ? ? ? ? ? ? ?
}
15 3 2 0 0 137 ? 5 0 0 [] 1 [137,137,137,137,137,] {
	29 4 0 1 0 ? ? 2 ? ? ? ? ? ? ? 1; ~ 1; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?
	22 2 0 ? 2 2 ? ? ? ? ? ? ? ? ? ?
}
16 1 0 0 0 140 ? 2 0 0 [] 1 [140,140,] {
	2 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 2 ? ? ? ? ? ? ? ? ? ?
}
17 1 0 0 0 141 ? 2 0 0 [] 1 [141,141,] {
	2 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 2 ? ? ? ? ? ? ? ? ? ?
}
18 1 1 0 0 142 ? 1 0 0 [] 1 [142,] {
	22 2 0 ? 0 2 ? ? ? ? ? ? ? ? ? ?
}
19 3 0 0 0 145 ? 4 0 0 [] 1 [145,145,145,145,] {
	4 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 1 ? ? 2 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 3 ? ? ? ? ? ? ? ?; 22 2 0 ? 0 4 ? ? ? ? ? ? ? ? ? ?
}
20 2 0 0 0 146 ? 5 3 0 [] 1 [146,146,146,146,146,] {
	12 4 4 1073741824 0 ? ? 1 ? ? 1 ? ? ? 1 1; ~ 1073741824; 5 4 3 ? 1 ? ? 2 ? 3 ? ? ? ? ? ?; 21 3 0 ? 0 2 1 ? ? ? ? ? ? ? ? ?
	22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
21 2 0 0 0 147 ? 5 3 0 [] 1 [147,147,147,147,147,] {
	12 4 4 1073741824 0 ? ? 1 ? ? 1 ? ? ? 1 1; ~ 1073741824; 5 4 3 ? 1 ? ? 2 ? 3 ? ? ? ? ? ?; 21 3 0 ? 0 2 1 ? ? ? ? ? ? ? ? ?
	22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
22 2 0 0 0 147 ? 5 3 1 [22,] 1 [147,147,147,147,147,] {
	12 4 4 1073741824 0 ? ? 1 ? ? 1 ? ? ? 1 1; ~ 1073741824; 64 4 3 ? 1 ? ? 2 ? 3 ? ? ? ? ? ?; 21 3 0 ? 0 2 1 ? ? ? ? ? ? ? ? ?
	22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}
23 14 0 0 1 1 ? 604 102 19 [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,20,21,23,] 1 [1,3,3,3,3,3,3,3,4,4,4,4,4,4,4,5,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,261,261,261,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,264,266,266,266,267,267,267,268,268,268,268,268,268,268,268,268,268,268,268,268,268,268,268,271,271,271,273,274,274,274,278,278,278,278,278,278,278,278,278,278,278,278,278,281,281,281,283,283,283,283,283,283,283,283,283,283,283,283,286,286,286,286,286,286,287,287,287,289,289,289,289,289,292,292,292,292,292,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,296,298,298,298,298,298,298,298,298,299,299,299,299,299,299,299,303,303,303,303,303,303,303,303,303,303,303,303,303,303,303,303,303,303,303,306,306,306,306,307,307,307,307,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,308,311,311,311,311,311,311,311,311,313,313,313,313,313,313,313,316,316,316,316,316,316,316,319,319,319,319,319,319,319,319,319,319,319,319,319,319,319,319,319,319,320,320,320,320,320,320,320,320,320,321,321,321,321,321,321,321,321,321,321,321,321,321,321,321,321,323,323,323,324,324,324,326,326,327,327,582,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,584,585,585,585,585,586,586,841,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,843,845,845,845,853,853,853,853,853,853,853,853,853,853,853,855,855,855,855,855,855,855,855,855,855,855,856,856,856,856,856,856,856,856,856,856,856,856,856,858,858,858,866,866,866,874,874,874,874,877,877,877,884,884,884,884,884,884,884,884,884,884,884,884,884,884,886,886,887,887,887,894,894,894,894,894,894,894,894,894,894,894,894,894,894,896,896,897,897,897,897,901,901,901,901,901,901,901,901,901,901,901,901,901,902,902,902,902,902,902,902,902,902,902,902,902,904,904,904,904,904,904,904,904,904,904,904,904,904,904,904,904,904,905,905,905,905,905,905,905,905,905,905,905,905,905,905,905,905,905,908,908,908,908,908,908,908,908,908,908,908,909,909,909,909,909,909,909,909,909,909,909,909,910,910,910,910,910,910,910,910,910,910,910,913,913,913,913,913,913,913,913,913,913,913,913,913,913,914,914,914,914,914,914,914,914,914,914,914,914,914,914,915,915,915,915,915,915,915,915,915,915,915,915,915,915,917,917,917,918,] {
	65 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 0 1 1 4 ? ? 1 ? ? ? ? ? 1; ~ 0
	5 4 3 ? 2 ? ? 0 ? 1 ? ? ? ? ? ?; 12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 3 1 1 4 ? ? 4 ? ? ? ? ? 1; ~ 3; 5 4 3 ? 2 ? ? 3 ? 4 ? ? ? ? ? ?
	12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 1 0 0 ? ? ? ? ? ? ? ? ?
	53 2 0 0 3 0 ? ? ? ? ? ? ? ? ? 1; ~ 0; 73 3 0 ? 40 3 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1077936128 2 ? ? 5 ? ? 5 ? ? ? 1 1
	~ 1077936128; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 80 4 6 2147483654 2 ? ? 11 ? 7 ? ? ? 1 ? 1; ~ 2147483654
	12 4 4 1077936128 3 ? ? 5 ? ? 5 ? ? ? 1 1; ~ 1077936128; 73 3 0 ? 40 3 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1077936128 2 ? ? 5 ? ? 5 ? ? ? 1 1
	~ 1077936128; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 80 4 6 7 2 ? ? 2 ? 8 ? ? ? 0 ? 1; ~ 7
	3 3 0 ? 1 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 8 1 1 4 ? ? 9 ? ? ? ? ? 1; ~ 8
	5 4 3 ? 2 ? ? 8 ? 9 ? ? ? ? ? ?; 12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?
	12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 73 3 0 ? 40 3 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1077936128 2 ? ? 5 ? ? 5 ? ? ? 1 1
	~ 1077936128; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1083179008 4 ? ? 10 ? ? 10 ? ? ? 1 1; ~ 1083179008
	73 3 0 ? 40 4 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1077936128 3 ? ? 5 ? ? 5 ? ? ? 1 1; ~ 1077936128; 21 3 0 ? 3 2 2 ? ? ? ? ? ? ? ? ?
	27 4 0 3 2 ? ? 2 ? ? ? ? ? ? ? 1; ~ 3; 3 3 0 ? 1 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 8 1 1 4 ? ? 9 ? ? ? ? ? 1; ~ 8; 5 4 3 ? 2 ? ? 8 ? 9 ? ? ? ? ? ?; 12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 8 1 1 11 0 ? ? ? ? 12 ? ? ? ? ? 1
	~ 11; 64 4 3 ? 0 ? ? 12 ? 13 ? ? ? ? ? ?; 8 1 1 11 0 ? ? ? ? 12 ? ? ? ? ? 1; ~ 11
	7 1 1 11 3 ? ? ? ? 12 ? ? ? ? ? 1; ~ 11; 73 3 0 ? 40 3 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1077936128 2 ? ? 5 ? ? 5 ? ? ? 1 1
	~ 1077936128; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 80 4 6 7 2 ? ? 2 ? 8 ? ? ? 0 ? 1; ~ 7
	3 3 0 ? 1 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 13 1 1 4 ? ? 14 ? ? ? ? ? 1; ~ 13
	5 4 3 ? 2 ? ? 13 ? 14 ? ? ? ? ? ?; 12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 0 0 0 ? ? ? ? ? ? ? ? ?; 8 1 1 14 0 ? ? ? ? 15 ? ? ? ? ? 1; ~ 14; 4 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?
	64 4 3 ? 1 ? ? 15 ? 16 ? ? ? ? ? ?; 70 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?; 70 2 0 ? 0 0 ? ? ? ? ? ? ? ? ? ?; 4 4 0 ? 5 ? ? 5 ? ? ? ? ? ? ? ?
	6 2 0 ? 6 1 ? ? ? ? ? ? ? ? ? ?; 4 4 0 ? 7 ? ? 4 ? ? ? ? ? ? ? ?; 21 3 0 ? 6 2 2 ? ? ? ? ? ? ? ? ?; 35 3 0 ? 4 5 6 ? ? ? ? ? ? ? ? ?
	23 4 0 ? 0 ? ? 0 ? ? ? ? ? ? ? ?; 79 4 6 16 4 ? ? 2 ? 17 ? ? ? 0 ? 1; ~ 16; 3 3 0 ? 3 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 3 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 17 1 3 4 ? ? 18 ? ? ? ? ? 1; ~ 17; 5 4 3 ? 4 ? ? 17 ? 18 ? ? ? ? ? ?
	12 4 4 1074790400 2 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 2 3 1 ? ? ? ? ? ? ? ? ?; 7 1 1 14 2 ? ? ? ? 15 ? ? ? ? ? 1
	~ 14; 78 4 5 0 2 ? ? 2 ? 0 ? ? ? 0 ? 1; ~ 0; 3 3 0 ? 1 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 18 1 1 4 ? ? 19 ? ? ? ? ? 1; ~ 18; 5 4 3 ? 2 ? ? 18 ? 19 ? ? ? ? ? ?
	12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?; 54 4 3 ? 0 ? ? 20 ? 21 ? ? ? ? ? ?
	4 4 0 ? 1 ? ? 10 ? ? ? ? ? ? ? ?; 16 3 1 19 1 0 136 ? ? 20 ? ? ? ? ? 1; ~ 19; 8 1 1 21 0 ? ? ? ? 22 ? ? ? ? ? 1
	~ 21; 4 4 0 ? 0 ? ? 20 ? ? ? ? ? ? ? ?; 8 1 1 22 0 ? ? ? ? 23 ? ? ? ? ? 1; ~ 22
	64 4 3 ? 0 ? ? 23 ? 24 ? ? ? ? ? ?; 7 1 1 21 1 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21; 16 3 1 24 0 1 153 ? ? 25 ? ? ? ? ? 1
	~ 24; 64 4 3 ? 0 ? ? 25 ? 26 ? ? ? ? ? ?; 7 1 1 21 1 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21
	16 3 1 26 0 1 152 ? ? 27 ? ? ? ? ? 1; ~ 26; 7 1 1 21 3 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21
	4 4 0 ? 5 ? ? 1 ? ? ? ? ? ? ? ?; 20 3 1 24 3 3 153 ? ? 25 ? ? ? ? ? 1; ~ 24; 21 3 0 ? 3 3 2 ? ? ? ? ? ? ? ? ?
	39 3 2 ? 2 3 27 ? ? 28 ? ? ? ? ? ?; 7 1 1 21 4 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21; 15 3 1 26 3 4 152 ? ? 27 ? ? ? ? ? 1
	~ 26; 4 4 0 ? 4 ? ? 1 ? ? ? ? ? ? ? ?; 21 3 0 ? 3 2 2 ? ? ? ? ? ? ? ? ?; 27 4 0 3 2 ? ? 2 ? ? ? ? ? ? ? 1
	~ 3; 3 3 0 ? 1 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 28 1 1 4 ? ? 29 ? ? ? ? ? 1
	~ 28; 5 4 3 ? 2 ? ? 28 ? 29 ? ? ? ? ? ?; 12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400
	21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?; 7 1 1 21 0 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21; 54 4 3 ? 1 ? ? 20 ? 21 ? ? ? ? ? ?
	4 4 0 ? 2 ? ? -100 ? ? ? ? ? ? ? ?; 16 3 1 19 2 1 136 ? ? 20 ? ? ? ? ? 1; ~ 19; 16 3 1 29 1 0 149 ? ? 30 ? ? ? ? ? 1
	~ 29; 7 1 1 21 1 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21; 15 3 1 29 0 1 149 ? ? 30 ? ? ? ? ? 1
	~ 29; 64 4 3 ? 1 ? ? 30 ? 31 ? ? ? ? ? ?; 16 3 1 24 1 0 153 ? ? 25 ? ? ? ? ? 1; ~ 24
	7 1 1 21 3 ? ? ? ? 22 ? ? ? ? ? 1; ~ 21; 15 3 1 29 2 3 149 ? ? 30 ? ? ? ? ? 1; ~ 29
	4 4 0 ? 4 ? ? 2 ? ? ? ? ? ? ? ?; 4 4 0 ? 5 ? ? 3 ? ? ? ? ? ? ? ?; 20 3 1 24 2 2 153 ? ? 25 ? ? ? ? ? 1; ~ 24
	21 3 0 ? 2 4 2 ? ? ? ? ? ? ? ? ?; 79 4 6 31 2 ? ? 2 ? 32 ? ? ? 0 ? 1; ~ 31; 3 3 0 ? 1 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 1 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 32 1 1 4 ? ? 33 ? ? ? ? ? 1; ~ 32; 5 4 3 ? 2 ? ? 32 ? 33 ? ? ? ? ? ?
	12 4 4 1074790400 0 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 0 3 1 ? ? ? ? ? ? ? ? ?; 54 4 3 ? 0 ? ? 33 ? 34 ? ? ? ? ? ?
	4 4 0 ? 1 ? ? 0 ? ? ? ? ? ? ? ?; 16 3 1 24 1 0 153 ? ? 25 ? ? ? ? ? 1; ~ 24; 64 4 3 ? 1 ? ? 34 ? 35 ? ? ? ? ? ?
	70 2 0 ? 0 0 ? ? ? ? ? ? ? ? ? ?; 16 3 1 35 1 0 191 ? ? 36 ? ? ? ? ? 1; ~ 35; 3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 6 ? ? 10 ? ? ? ? ? ? ? ?; 20 3 1 35 4 0 191 ? ? 36 ? ? ? ? ? 1; ~ 35; 21 3 0 ? 4 3 2 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 6 ? ? 20 ? ? ? ? ? ? ? ?; 20 3 1 35 4 4 191 ? ? 36 ? ? ? ? ? 1; ~ 35; 21 3 0 ? 4 3 2 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 6 ? ? 30 ? ? ? ? ? ? ? ?; 20 3 1 35 4 4 191 ? ? 36 ? ? ? ? ? 1; ~ 35; 21 3 0 ? 4 3 2 ? ? ? ? ? ? ? ? ?
	15 3 1 24 3 4 153 ? ? 25 ? ? ? ? ? 1; ~ 24; 79 4 6 2147483684 3 ? ? 7 ? 37 ? ? ? 1 ? 1; ~ 2147483684
	15 3 1 26 3 0 152 ? ? 27 ? ? ? ? ? 1; ~ 26; 79 4 6 37 3 ? ? 2 ? 38 ? ? ? 0 ? 1; ~ 37
	3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?; 73 3 0 ? 1 2 2 ? ? ? ? ? ? ? ? ?; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?; 54 4 3 ? 0 ? ? 39 ? 40 ? ? ? ? ? ?; 54 4 3 ? 1 ? ? 41 ? 42 ? ? ? ? ? ?
	53 2 0 0 2 0 ? ? ? ? ? ? ? ? ? 1; ~ 0; 16 3 1 40 2 1 130 ? ? 41 ? ? ? ? ? 1; ~ 40
	16 3 1 38 1 0 131 ? ? 39 ? ? ? ? ? 1; ~ 38; 64 4 3 ? 1 ? ? 42 ? 43 ? ? ? ? ? ?; 15 3 1 38 3 0 131 ? ? 39 ? ? ? ? ? 1
	~ 38; 15 3 1 40 2 3 130 ? ? 41 ? ? ? ? ? 1; ~ 40; 16 3 1 43 1 2 145 ? ? 44 ? ? ? ? ? 1
	~ 43; 64 4 3 ? 1 ? ? 44 ? 45 ? ? ? ? ? ?; 15 3 1 38 3 0 131 ? ? 39 ? ? ? ? ? 1; ~ 38
	15 3 1 40 2 3 130 ? ? 41 ? ? ? ? ? 1; ~ 40; 16 3 1 45 1 2 242 ? ? 46 ? ? ? ? ? 1; ~ 45
	15 3 1 38 5 0 131 ? ? 39 ? ? ? ? ? 1; ~ 38; 15 3 1 40 4 5 130 ? ? 41 ? ? ? ? ? 1; ~ 40
	15 3 1 43 3 4 145 ? ? 44 ? ? ? ? ? 1; ~ 43; 4 4 0 ? 4 ? ? 4 ? ? ? ? ? ? ? ?; 21 3 0 ? 3 2 2 ? ? ? ? ? ? ? ? ?
	79 4 6 46 3 ? ? 2 ? 35 ? ? ? 0 ? 1; ~ 46; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 47 1 2 4 ? ? 48 ? ? ? ? ? 1; ~ 47; 5 4 3 ? 3 ? ? 47 ? 48 ? ? ? ? ? ?; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 15 3 1 38 2 0 131 ? ? 39 ? ? ? ? ? 1; ~ 38
	15 3 1 40 1 2 130 ? ? 41 ? ? ? ? ? 1; ~ 40; 5 4 3 ? 3 ? ? 48 ? 49 ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 12 ? ? ? ? ? ? ? ?
	20 3 1 45 1 1 242 ? ? 46 ? ? ? ? ? 1; ~ 45; 21 3 0 ? 1 4 1 ? ? ? ? ? ? ? ? ?; 15 3 1 38 5 0 131 ? ? 39 ? ? ? ? ? 1
	~ 38; 15 3 1 40 4 5 130 ? ? 41 ? ? ? ? ? 1; ~ 40; 15 3 1 48 3 4 138 ? ? 49 ? ? ? ? ? 1
	~ 48; 79 4 6 49 3 ? ? 2 ? 50 ? ? ? 0 ? 1; ~ 49; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 50 1 2 4 ? ? 51 ? ? ? ? ? 1; ~ 50; 5 4 3 ? 3 ? ? 50 ? 51 ? ? ? ? ? ?
	12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 1 ? ? ? ? ? ? ? ? ? ? ?
	8 1 1 29 1 ? ? ? ? 30 ? ? ? ? ? 1; ~ 29; 64 4 3 ? 1 ? ? 51 ? 52 ? ? ? ? ? ?; 8 1 1 11 1 ? ? ? ? 12 ? ? ? ? ? 1
	~ 11; 7 1 1 11 1 ? ? ? ? 12 ? ? ? ? ? 1; ~ 11; 4 4 0 ? 2 ? ? 1 ? ? ? ? ? ? ? ?
	4 4 0 ? 3 ? ? 2 ? ? ? ? ? ? ? ?; 21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1
	~ 29; 17 3 0 ? 3 4 0 ? ? ? ? ? ? ? ? ?; 79 4 6 2147483700 3 ? ? 20 ? 16 ? ? ? 1 ? 1; ~ 2147483700
	3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1; ~ 29; 17 3 0 ? 3 4 1 ? ? ? ? ? ? ? ? ?
	79 4 6 2147483701 3 ? ? 14 ? 24 ? ? ? 1 ? 1; ~ 2147483701; 3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1
	~ 29; 17 3 0 ? 3 4 2 ? ? ? ? ? ? ? ? ?; 77 4 5 2147483648 3 ? ? 8 ? 0 ? ? ? 1 ? 1; ~ 2147483648
	7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1; ~ 29; 17 3 0 ? 3 4 3 ? ? ? ? ? ? ? ? ?; 80 4 6 21 3 ? ? 2 ? 22 ? ? ? 0 ? 1
	~ 21; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 54 1 2 4 ? ? 55 ? ? ? ? ? 1
	~ 54; 5 4 3 ? 3 ? ? 54 ? 55 ? ? ? ? ? ?; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400
	21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 7 1 1 11 1 ? ? ? ? 12 ? ? ? ? ? 1; ~ 11; 4 4 0 ? 2 ? ? 1 ? ? ? ? ? ? ? ?
	4 4 0 ? 3 ? ? 2 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 3 ? ? ? ? ? ? ? ?; 4 4 0 ? 5 ? ? 4 ? ? ? ? ? ? ? ?; 21 3 0 ? 1 5 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1; ~ 29; 17 3 0 ? 3 4 0 ? ? ? ? ? ? ? ? ?
	79 4 6 2147483700 3 ? ? 20 ? 16 ? ? ? 1 ? 1; ~ 2147483700; 3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1
	~ 29; 17 3 0 ? 3 4 1 ? ? ? ? ? ? ? ? ?; 79 4 6 2147483701 3 ? ? 14 ? 24 ? ? ? 1 ? 1; ~ 2147483701
	3 3 0 ? 2 0 0 ? ? ? ? ? ? ? ? ?; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1; ~ 29; 17 3 0 ? 3 4 2 ? ? ? ? ? ? ? ? ?
	79 4 6 2147483703 3 ? ? 8 ? 26 ? ? ? 1 ? 1; ~ 2147483703; 7 1 1 29 4 ? ? ? ? 30 ? ? ? ? ? 1; ~ 29
	17 3 0 ? 3 4 3 ? ? ? ? ? ? ? ? ?; 80 4 6 21 3 ? ? 2 ? 22 ? ? ? 0 ? 1; ~ 21; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 54 1 2 4 ? ? 55 ? ? ? ? ? 1; ~ 54; 5 4 3 ? 3 ? ? 54 ? 55 ? ? ? ? ? ?
	12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 64 4 3 ? 1 ? ? 56 ? 57 ? ? ? ? ? ?
	8 1 1 57 1 ? ? ? ? 58 ? ? ? ? ? 1; ~ 57; 12 4 4 1134559232 2 ? ? 59 ? ? 59 ? ? ? 1 1; ~ 1134559232
	5 4 3 ? 3 ? ? 60 ? 61 ? ? ? ? ? ?; 21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 75 3 1 61 1 2 4 ? ? 62 ? ? ? ? ? 1; ~ 61
	5 4 3 ? 3 ? ? 61 ? 62 ? ? ? ? ? ?; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 1 3 2 ? ? ? ? ? ? ? ? ?
	21 3 0 ? 1 1 1 ? ? ? ? ? ? ? ? ?; 12 4 4 1134559232 2 ? ? 59 ? ? 59 ? ? ? 1 1; ~ 1134559232; 5 4 3 ? 3 ? ? 62 ? 63 ? ? ? ? ? ?
	21 3 0 ? 2 2 2 ? ? ? ? ? ? ? ? ?; 75 3 1 63 1 2 4 ? ? 64 ? ? ? ? ? 1; ~ 63; 5 4 3 ? 3 ? ? 63 ? 64 ? ? ? ? ? ?
	12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 1 3 2 ? ? ? ? ? ? ? ? ?; 21 3 0 ? 1 1 3 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 4 0 0 ? ? ? ? ? ? ? ? ?; 79 4 6 2147483700 1 ? ? 5 ? 16 ? ? ? 1 ? 1; ~ 2147483700; 79 4 6 55 2 ? ? 2 ? 26 ? ? ? 0 ? 1
	~ 55; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 64 1 4 4 ? ? 65 ? ? ? ? ? 1
	~ 64; 5 4 3 ? 5 ? ? 64 ? 65 ? ? ? ? ? ?; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 64 4 3 ? 3 ? ? 65 ? 28 ? ? ? ? ? ?; 8 1 1 66 3 ? ? ? ? 67 ? ? ? ? ? 1; ~ 66
	64 4 3 ? 3 ? ? 67 ? 68 ? ? ? ? ? ?; 8 1 1 68 3 ? ? ? ? 69 ? ? ? ? ? 1; ~ 68; 7 1 1 68 3 ? ? ? ? 69 ? ? ? ? ? 1
	~ 68; 4 4 0 ? 4 ? ? 1 ? ? ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?; 64 4 3 ? 3 ? ? 69 ? 50 ? ? ? ? ? ?
	8 1 1 70 3 ? ? ? ? 71 ? ? ? ? ? 1; ~ 70; 7 1 1 70 5 ? ? ? ? 71 ? ? ? ? ? 1; ~ 70
	4 4 0 ? 6 ? ? 100 ? ? ? ? ? ? ? ?; 21 3 0 ? 5 2 2 ? ? ? ? ? ? ? ? ?; 79 4 6 71 5 ? ? 2 ? 72 ? ? ? 0 ? 1; ~ 71
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 72 1 4 4 ? ? 73 ? ? ? ? ? 1; ~ 72
	5 4 3 ? 5 ? ? 72 ? 73 ? ? ? ? ? ?; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	53 2 0 0 1 0 ? ? ? ? ? ? ? ? ? 1; ~ 0; 64 4 3 ? 3 ? ? 73 ? 74 ? ? ? ? ? ?; 16 3 1 70 3 1 160 ? ? 71 ? ? ? ? ? 1
	~ 70; 4 4 0 ? 7 ? ? 100 ? ? ? ? ? ? ? ?; 20 3 1 70 5 1 160 ? ? 71 ? ? ? ? ? 1; ~ 70
	21 3 0 ? 5 3 2 ? ? ? ? ? ? ? ? ?; 79 4 6 71 5 ? ? 2 ? 72 ? ? ? 0 ? 1; ~ 71; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 74 1 4 4 ? ? 75 ? ? ? ? ? 1; ~ 74; 5 4 3 ? 5 ? ? 74 ? 75 ? ? ? ? ? ?
	12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 53 2 0 0 3 2 ? ? ? ? ? ? ? ? ? 1
	~ 0; 64 4 3 ? 4 ? ? 75 ? 76 ? ? ? ? ? ?; 70 2 0 ? 0 3 ? ? ? ? ? ? ? ? ? ?; 16 3 1 76 4 3 156 ? ? 77 ? ? ? ? ? 1
	~ 76; 20 3 1 76 6 3 156 ? ? 77 ? ? ? ? ? 1; ~ 76; 21 3 0 ? 6 2 2 ? ? ? ? ? ? ? ? ?
	27 4 0 3 6 ? ? 2 ? ? ? ? ? ? ? 1; ~ 3; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 77 1 5 4 ? ? 78 ? ? ? ? ? 1; ~ 77; 5 4 3 ? 6 ? ? 77 ? 78 ? ? ? ? ? ?; 12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 15 3 1 78 6 3 151 ? ? 79 ? ? ? ? ? 1; ~ 78
	79 4 6 52 6 ? ? 2 ? 16 ? ? ? 0 ? 1; ~ 52; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 79 1 5 4 ? ? 80 ? ? ? ? ? 1; ~ 79; 5 4 3 ? 6 ? ? 79 ? 80 ? ? ? ? ? ?; 12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 7 ? ? 1 ? ? ? ? ? ? ? ?; 75 3 1 53 24 7 4 ? ? 24 ? ? ? ? ? 1
	~ 53; 5 4 3 ? 8 ? ? 53 ? 24 ? ? ? ? ? ?; 12 4 4 2231452672 6 ? ? 82 ? ? 81 82 ? ? 2 1; ~ 2231452672
	21 3 0 ? 6 3 2 ? ? ? ? ? ? ? ? ?; 79 4 6 83 6 ? ? 2 ? 84 ? ? ? 0 ? 1; ~ 83; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 84 1 5 4 ? ? 85 ? ? ? ? ? 1; ~ 84; 5 4 3 ? 6 ? ? 84 ? 85 ? ? ? ? ? ?
	12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 12 4 4 2153862144 4 ? ? 86 ? ? 7 86 ? ? 2 1
	~ 2153862144; 53 2 0 8 5 0 ? ? ? ? ? ? ? ? ? 1; ~ 8; 4 4 0 ? 6 ? ? 10 ? ? ? ? ? ? ? ?
	4 4 0 ? 7 ? ? 9 ? ? ? ? ? ? ? ?; 4 4 0 ? 8 ? ? 8 ? ? ? ? ? ? ? ?; 4 4 0 ? 9 ? ? 4 ? ? ? ? ? ? ? ?; 4 4 0 ? 10 ? ? 19 ? ? ? ? ? ? ? ?
	4 4 0 ? 11 ? ? 23 ? ? ? ? ? ? ? ?; 4 4 0 ? 12 ? ? 0 ? ? ? ? ? ? ? ?; 4 4 0 ? 13 ? ? 0 ? ? ? ? ? ? ? ?; 55 3 0 1 5 6 9 ? ? ? ? ? ? ? ? 1
	~ 1; 64 4 3 ? 6 ? ? 87 ? 88 ? ? ? ? ? ?; 5 4 3 ? 7 ? ? 88 ? 89 ? ? ? ? ? ?; 21 3 0 ? 4 4 1 ? ? ? ? ? ? ? ? ?
	2 1 0 ? 6 ? ? ? ? ? ? ? ? ? ? ?; 77 4 5 0 6 ? ? 2 ? 0 ? ? ? 0 ? 1; ~ 0; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 89 1 5 4 ? ? 90 ? ? ? ? ? 1; ~ 89; 5 4 3 ? 6 ? ? 89 ? 90 ? ? ? ? ? ?
	12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 7 ? ? ? ? ? ? ? ? ? ? ?
	2 1 0 ? 6 ? ? ? ? ? ? ? ? ? ? ?; 77 4 5 0 6 ? ? 2 ? 0 ? ? ? 0 ? 1; ~ 0; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 90 1 5 4 ? ? 91 ? ? ? ? ? 1; ~ 90; 5 4 3 ? 6 ? ? 90 ? 91 ? ? ? ? ? ?
	12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 6 ? ? ? ? ? ? ? ? ? ? ?
	77 4 5 0 6 ? ? 2 ? 0 ? ? ? 0 ? 1; ~ 0; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 91 1 5 4 ? ? 92 ? ? ? ? ? 1; ~ 91; 5 4 3 ? 6 ? ? 91 ? 92 ? ? ? ? ? ?; 12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 12 4 4 1170210816 6 ? ? 93 ? ? 93 ? ? ? 1 1; ~ 1170210816
	64 4 3 ? 7 ? ? 94 ? 95 ? ? ? ? ? ?; 21 3 0 ? 6 2 2 ? ? ? ? ? ? ? ? ?; 78 4 5 1 6 ? ? 2 ? 1 ? ? ? 0 ? 1; ~ 1
	3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 95 1 5 4 ? ? 96 ? ? ? ? ? 1; ~ 95
	5 4 3 ? 6 ? ? 95 ? 96 ? ? ? ? ? ?; 12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?
	12 4 4 1170210816 6 ? ? 93 ? ? 93 ? ? ? 1 1; ~ 1170210816; 64 4 3 ? 7 ? ? 96 ? 38 ? ? ? ? ? ?; 21 3 0 ? 6 2 2 ? ? ? ? ? ? ? ? ?
	78 4 5 0 6 ? ? 2 ? 0 ? ? ? 0 ? 1; ~ 0; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 97 1 5 4 ? ? 98 ? ? ? ? ? 1; ~ 97; 5 4 3 ? 6 ? ? 97 ? 98 ? ? ? ? ? ?; 12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 12 4 4 1170210816 6 ? ? 93 ? ? 93 ? ? ? 1 1; ~ 1170210816
	64 4 3 ? 7 ? ? 98 ? 99 ? ? ? ? ? ?; 21 3 0 ? 6 2 2 ? ? ? ? ? ? ? ? ?; 78 4 5 1 6 ? ? 2 ? 1 ? ? ? 0 ? 1; ~ 1
	3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 99 1 5 4 ? ? 100 ? ? ? ? ? 1; ~ 99
	5 4 3 ? 6 ? ? 99 ? 100 ? ? ? ? ? ?; 12 4 4 1074790400 4 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?
	12 4 4 1178599424 4 ? ? 101 ? ? 101 ? ? ? 1 1; ~ 1178599424; 21 3 0 ? 4 1 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}]], {
	{ "1","2",},{ 0,1,},{ "7",},{ "8",},{ "7",},{ "2","9",},{ 1,},{ },{ "1","14",},{ "17",1073741824,"18",1,"19",},
	{ 0,"21",1074790400,"22",1,},{ "23",1073741824,"22","24",1076887552,"25",1,},
	{ "26",1,},{ 1,"26",},{ "27",},{ },{ },{ },{ },{ },{ "21",1073741824,"29",},{ "21",1073741824,"29",},
	{ "23",1073741824,21,},{ "30","24",1074790400,"31","32",1077936128,"33","34","35","36",
		1083179008,"3",0,"37","4",1,120,"38","39","7",{ 19,},"1","8",2,"2",3,"9",10,"40",
		"14",4,-95,"41",{ 24,},5,"11",60,20,"10",{ 38,},"15",{ 40,},6,"12",7,"13",5,"42","43",
		12,"44",8,1,2,"45",3,9,"20","17",1134559232,"46","47","48","49","50",
		10,"22",11,"25",12,"26",101,"51",13,"52",14,"28","53","27","54","55","56",
		2231452672,0.8414709848078965,"57","58",2153862144,
		15,"59","60","61","62","23",1170210816,19,"63",20,"64",22,"65","66",
		1178599424,
	},
}, {
	"\97","\120","\102","\102\97\99\116","\114\101\115","\110","\105","\115\101\108\102","\121","\98","\97\100\100","\102\49","\102\50",
	"\116","\99","\100","\108\111\97\100\115\116\114\105\110\103","\114\101\116\117\114\110\32\102\97\116\40",
	"\41","\102\97\116","\101\114\114\111\114","\101\114\114\95\111\110\95\110","\112\99\97\108\108","\97\115\115\101\114\116",
	"\100\117\109\109\121","\100\101\101\112","\118","\116\101\115\116","\120\117\120\117","\82\101\108\97\116\105\111\110\97\108\32\111\112\101\114\97\116\111\114\115\32\109\117\115\116\32\114\101\116\117\114\110\32\98\111\111\108\101\97\110\115",
	"\84\114\117\101\32\97\110\100\32\70\97\108\115\101\32\109\117\115\116\32\98\101\32\98\111\111\108\101\97\110\115",
	"\116\121\112\101","\116\97\98\108\101","\102\117\110\99\116\105\111\110","\84\121\112\101\32\109\117\115\116\32\114\101\116\117\114\110\32\116\104\101\32\116\121\112\101\32\111\102\32\105\116\115\32\97\114\103\117\109\101\110\116",
	"\112\114\105\110\116","\73\110\118\97\108\105\100\32\116\121\112\101\32\102\111\114\32\102","\73\110\118\97\108\105\100\32\118\97\108\117\101\32\102\111\114\32\102\97\99\116\40\53\41",
	"\76\111\99\97\108\32\102\117\110\99\116\105\111\110\32\109\117\115\116\32\98\101\32\108\111\99\97\108",
	"\73\110\118\97\108\105\100\32\97\115\115\101\115\115\109\101\110\116\32\102\111\114\32\97\58\120\40\49\41\43\49\48\32\61\61\32\97\46\121\40\49\41",
	"\73\110\118\97\108\105\100\32\118\97\108\117\101\32\102\111\114\32\97\46\116\58\120\40\50\44\51\41",
	"\73\110\118\97\108\105\100\32\118\97\108\117\101\32\102\111\114\32\97\46\98\46\99\46\102\49",
	"\107","\73\110\118\97\108\105\100\32\118\97\108\117\101\32\102\111\114\32\97\46\98\46\99\46\107",
	"\73\110\118\97\108\105\100\32\118\97\108\117\101\32\102\111\114\32\116\91\49\93\44\32\116\91\50\93\44\32\116\91\51\93\44\32\116\91\52\93",
	"\108\111\97\100\115\116\114\105\110\103\32\34\97\115\115\101\114\116\40\102\97\116\40\54\41\61\61\55\50\48\44\32\39\85\110\109\97\116\99\104\105\110\103\32\118\97\108\117\101\115\39\41\34\32\40\41",
	"\70\97\105\108\101\100\32\116\111\32\99\111\109\112\105\108\101\32\116\101\115\116\32\99\97\115\101\32\35\49",
	"\114\101\116\117\114\110\32\102\97\116\40\49\41\44\32\51","\70\97\105\108\101\100\32\116\111\32\99\111\109\112\105\108\101\32\116\101\115\116\32\99\97\115\101\32\35\50",
	"\85\110\109\97\116\99\104\105\110\103\32\118\97\108\117\101\115","\84\97\105\108\32\99\97\108\108\32\35\49",
	"\84\97\105\108\32\99\97\108\108\32\35\50","\78\97\109\101\99\97\108\108\32\35\49","\78\97\109\101\99\97\108\108\32\99\97\108\108\32\35\50",
	"\109\97\116\104","\115\105\110","\69\120\116\114\97\32\97\114\103\117\109\101\110\116\115\32\35\49",
	"\115\111\114\116","\101\120\116\114\97\32\97\114\103\117\109\101\110\116","\66\117\103\32\105\110\32\112\97\114\97\109\101\116\101\114\32\97\100\106\117\115\116\109\101\110\116\32\35\49",
	"\66\117\103\32\105\110\32\112\97\114\97\109\101\116\101\114\32\97\100\106\117\115\116\109\101\110\116\32\35\50",
	"\66\117\103\32\105\110\32\112\97\114\97\109\101\116\101\114\32\97\100\106\117\115\116\109\101\110\116\32\35\51",
	"\69\114\114\111\114\32\35\49","\69\114\114\111\114\32\35\50","\69\114\114\111\114\32\35\51",
	"\79\75",
}

assert(MATCH(
	Fiu.luau_deserialize(compileResult),
	FiuUtils.decodeModule(encodedModule, constantList, stringList)
))

OK()
