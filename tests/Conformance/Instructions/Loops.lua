-- tests: LOP_FORGPREP, LOP_FORGLOOP, LOP_FORNPREP, LOP_FORNLOOP, LOP_FORGPREP_INEXT, LOP_FORGPREP_NEXT

-- FORGLOOP
-- FORGPREP
local t = {1,2,3,4,5,6,7,8,9,10}
local c = 0

assert(#t == 10, "Table was not created correctly")

-- : Function #1
do
	-- LOP_FORGPREP_INEXT
	for i, v in ipairs(t) do
		c += v
	end
end
assert(c == 55, "FORGLOOP did not loop correctly #1")

-- : Function #2
c = 0
do
	-- LOP_FORGPREP_NEXT
	for i, v in pairs(t) do
		c += v * 2
	end
end
assert(c == 110, "FORGLOOP did not loop correctly #2")

-- : Generalized Iteration #1
c = 0
do
	for i, v in t do
		c += v * 3
	end
end
assert(c == 165, "FORGLOOP did not loop correctly #3")

-- : Generalized Iteration #2
c = 0
do
	for i, v in {a = 1, b = 2, c = 3} do
		c += v + 4
	end
end
assert(c == 18, "FORGLOOP did not loop correctly #4")

-- : Generalized Iteration #3
local x = ''
do
	for i, v in {1, 2, 3, nil, 5} do
		x ..= tostring(v)
	end
end
assert(x == "1235", "FORGLOOP did not loop correctly #5")

-- : Table Metatable Call
c = 0
do
	local m1 = setmetatable({}, {
		__call = function(_, _, i)
			if i >= 10 then
				return
			end
			return i + 1
		end
	})
	for i in m1, nil, 0 do
		c += t[i] * 4
	end
end
assert(c == 220, "FORGLOOP did not loop correctly #6")

-- : Userdata Metatable Call
c = 0
do
	local p = newproxy(true)
	local m = getmetatable(p)
	m.__call = function(_, _, i)
		if i >= 10 then
			return
		end
		return i + 1
	end
	for i in p, nil, 0 do
		c += t[i] * 5
	end
end
assert(c == 275, "FORGLOOP did not loop correctly #7")

-- : Table Metatable Iteration
c = 0
do
	local m = setmetatable({}, {
		__iter = function(self, i, v)
			return next, t
		end
	})
	for i, v in m do
		c += v * 6
	end
end
assert(c == 330, "FORGLOOP did not loop correctly #8")

-- : Userdata Metatable Iteration
c = 0
do
	local p = newproxy(true)
	local m = getmetatable(p)
	m.__iter = function(self, i, v)
		return next, t
	end
	for i, v in p do
		c += v * 7
	end
end
assert(c == 385, "FORGLOOP did not loop correctly #9")

-- FORNLOOP
-- FORNPREP
c = 0
for i = 1, 10 do
	c += t[i] * 8
end
assert(c == 440, "FORNLOOP did not loop correctly #1")

c = 0
for i = 5, 1, -1 do
	c -= i
end
assert(c == -15, "FORNLOOP did not loop correctly #2")

OK();