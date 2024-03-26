-- tests: LOP_JUMP, LOP_JUMPBACK, LOP_JUMPIF, LOP_JUMPIFNOT, LOP_JUMPIFEQ, LOP_JUMPIFLE, LOP_JUMPIFLT, LOP_JUMPIFNOTEQ, LOP_JUMPIFNOTLE, LOP_JUMPIFNOTLT, LOP_JUMPXEQKN, LOP_JUMPXEQKB, LOP_JUMPXEQKS

local function m(a)
	return a
end

-- JUMP
for i = 0, 2 do
	-- lint: suppress warning
	if true then
		continue
	end
	error("Loop did not JUMP")
end

-- JUMPBACK
local b = 0
while b < 10 do
	b += 1
end
assert(b == 10, "Loop did not JUMPBACK or exceeded instructions")

-- JUMPIF
local c = 0
if not m(true) then
	error("Statement did not JUMPIF correctly #1")
else
	c = 1
end
assert(c == 1, "Statement did not JUMPIF correctly #2")

-- JUMPIFNOT
c = 0
if m(false) then
	error("Statement did not JUMPIFNOT correctly #1")
else
	c = 2
end
assert(c == 2, "Statement did not JUMPIFNOT correctly #2")

-- JUMPIFEQ
c = 0
if m(1) ~= m(1) then
	error("Statement did not JUMPIFEQ correctly #1")
else
	c = 3
end
assert(c == 3, "Statement did not JUMPIFEQ correctly #2")
assert((m(nil) == m(false)) == false, "JUMPIFEQ incorrect result")

-- JUMPIFNOTEQ
c = 0
if m(1) == m(2) then
	error("Statement did not JUMPIFNOTEQ correctly #1")
else
	c = 4
end
assert(c == 4, "Statement did not JUMPIFNOTEQ correctly #2")
assert((m(nil) ~= m(false)) == true, "JUMPIFNOTEQ incorrect result")

-- JUMPIFLT
c = 0
if not (m(30) > m(20)) then
	error("Statement did not JUMPIFLE correctly #1")
else
	c = 5
end
assert(c == 5, "Statement did not JUMPIFLE correctly #2")

-- JUMPIFNOTLT
c = 0
if m(30) < m(20) then
	error("Statement did not JUMPIFNOTLT correctly #1")
else
	c = 6
end
assert(c == 6, "Statement did not JUMPIFNOTLT correctly #2")

-- JUMPIFLE
c = 0
if not (m(20) >= m(20)) then
	error("Statement did not JUMPIFLE correctly #1")
else
	c = 7
end
assert(c == 7, "Statement did not JUMPIFLE correctly #2")

-- JUMPIFNOTLE
c = 0
if m(20) <= m(10) then
	error("Statement did not JUMPIFNOTLE correctly #1")
else
	c = 8
end
assert(c == 8, "Statement did not JUMPIFNOTLE correctly #2")

-- JUMPXEQKN
c = 0
for i = 0, 10 do
	if i == 9 then
		break
	end
	c += 1
end
assert(c == 9, "Statement did not JUMPXEQKN correctly")

-- JUMPXEQKB
c = 0
for i = 0, 10 do
	if (i == 10) == true then
		break
	end
	c += 1
end
assert(c == 10, "Statement did not JUMPXEQKB correctly")
assert(m(nil) ~= false, "JUMPXEQKB incorrect result #1")
assert((m(nil) == false) == false, "JUMPXEQKB incorrect result #2")

-- JUMPXEQKS
c = 0
local s = ""
for i = 1, 11 do
	if s == "1234567891011" then
		break
	end
	s ..= i
	c += 1
end
assert(c == 11, "Statement did not JUMPXEQKS correctly #1")
assert(s == "1234567891011", "Statement did not JUMPXEQKS correctly #2")
assert(m("SAMPLE") ~= "SAMPLE1", "JUMPXEQKS incorrect result #1")
assert(m("SAMPLE") == "SAMPLE", "JUMPXEQKS incorrect result #2")

OK()