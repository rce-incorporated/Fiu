-- file was auto-generated by `fiu-tests`
--!ctx Luau

local ok, compileResult = Luau.compile([[
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
3; 2; 0 1 1 0 0 3 1 1 0 0 [] 1 [4,] {
	22 2 0 ? 0 2 ? ? ? ? ? ? ? ? ? ?
}
1 9 0 0 1 1 ? 360 48 1 [1,] 1 [1,3,10,13,13,13,13,266,269,269,269,269,522,525,525,525,525,529,530,530,530,531,786,789,789,789,789,789,789,789,789,789,789,792,1028,1028,1050,1050,1050,1050,1050,1052,1054,1054,1054,1054,1054,1054,1054,1054,1054,1054,1057,1284,1284,1315,1315,1315,1315,1315,1317,1319,1319,1319,1319,1319,1319,1319,1319,1319,1319,1322,1540,1540,1540,1540,1580,1580,1580,1580,1580,1582,1584,1584,1584,1584,1584,1584,1584,1584,1584,1584,1796,1796,1796,1796,1796,1796,1796,1796,1796,1796,1796,1796,1796,1841,1841,1841,1844,2052,2052,2052,2052,2102,2102,2102,2102,2102,2104,2106,2106,2106,2106,2106,2106,2106,2106,2106,2106,2308,2308,2308,2308,2308,2308,2308,2308,2308,2308,2308,2308,2308,2363,2363,2363,2366,2564,2564,2564,2564,2624,2624,2624,2624,2624,2626,2628,2628,2628,2628,2628,2628,2628,2628,2628,2628,2631,2820,2820,2820,2820,2889,2889,2889,2889,2889,2891,2893,2893,2893,2893,2893,2893,2893,2893,2893,2893,2896,3076,3076,3076,3076,3154,3154,3154,3154,3154,3156,3158,3158,3158,3158,3158,3158,3158,3158,3158,3158,3161,3332,3332,3332,3332,3419,3419,3419,3419,3419,3421,3423,3423,3423,3423,3423,3423,3423,3423,3423,3423,3426,3431,3431,3431,3431,3431,3431,3431,3431,3431,3684,3687,3687,3689,3689,3689,3689,3689,3689,3689,3689,3689,3689,3692,3697,3697,3697,3697,3697,3697,3697,3697,3697,3697,3950,3953,3955,3955,3955,3955,3955,3955,3955,3955,3955,3955,4100,4100,4100,4100,4100,4100,4100,4100,4212,4212,4212,4356,4356,4356,4356,4356,4356,4356,4356,4356,4356,4356,4356,4469,4469,4469,4472,4473,4474,4474,4474,4474,4475,4475,4478,4478,4478,4479,4730,4737,4737,4737,4737,4737,4737,4737,4737,4737,4737,4738,4738,4738,4738,4738,4738,4738,4738,4738,4738,4868,4868,4868,4868,4868,4868,4868,4868,4995,4995,4995,5124,5124,5124,5124,5124,5124,5124,5124,5252,5252,5252,5254,5254,5254,5255,] {
	65 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 64 4 3 ? 0 ? ? 0 ? 1 ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 14 ? ? ? ? ? ? ? ?; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 5 4 3 ? 2 ? ? 3 ? 4 ? ? ? ? ? ?; 21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 9 ? ? ? ? ? ? ? ?
	12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 2 ? ? 3 ? 4 ? ? ? ? ? ?; 21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?
	23 4 0 ? 0 ? ? 4 ? ? ? ? ? ? ? ?; 12 4 4 1074790400 1 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 2 ? ? 3 ? 4 ? ? ? ? ? ?
	21 3 0 ? 1 2 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 1 ? ? 0 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 10 ? ? ? ? ? ? ? ?; 32 4 0 2 1 ? ? 3 ? ? ? ? ? ? ? 1
	~ 2; 39 3 2 ? 1 1 4 ? ? 5 ? ? ? ? ? ?; 24 4 0 ? 0 ? ? -5 ? ? ? ? ? ? ? ?; 79 4 6 5 1 ? ? 2 ? 6 ? ? ? 0 ? 1
	~ 5; 3 3 0 ? 3 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 3 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 6 1 3 4 ? ? 7 ? ? ? ? ? 1
	~ 6; 5 4 3 ? 4 ? ? 6 ? 7 ? ? ? ? ? ?; 12 4 4 1081081856 2 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856
	21 3 0 ? 2 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 3 3 0 ? 3 1 0 ? ? ? ? ? ? ? ? ?; 25 4 0 ? 3 ? ? 5 ? ? ? ? ? ? ? ?
	12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 4 ? ? 9 ? 10 ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?
	23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 1 ? ? ? ? ? ? ? ?; 79 4 6 4 2 ? ? 2 ? 5 ? ? ? 0 ? 1; ~ 4
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 10 1 4 4 ? ? 11 ? ? ? ? ? 1; ~ 10
	5 4 3 ? 5 ? ? 10 ? 11 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 3 3 0 ? 3 0 0 ? ? ? ? ? ? ? ? ?; 26 4 0 ? 3 ? ? 5 ? ? ? ? ? ? ? ?; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 5 4 3 ? 4 ? ? 11 ? 12 ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 2 ? ? ? ? ? ? ? ?; 79 4 6 12 2 ? ? 2 ? 13 ? ? ? 0 ? 1; ~ 12; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 13 1 4 4 ? ? 14 ? ? ? ? ? 1; ~ 13; 5 4 3 ? 5 ? ? 13 ? 14 ? ? ? ? ? ?
	12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?
	4 4 0 ? 3 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 1 ? ? ? ? ? ? ? ?; 27 4 0 4 3 ? ? 6 ? ? ? ? ? ? ? 1; ~ 4
	12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 4 ? ? 14 ? 15 ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?
	23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 3 ? ? ? ? ? ? ? ?; 79 4 6 15 2 ? ? 2 ? 16 ? ? ? 0 ? 1; ~ 15
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 16 1 4 4 ? ? 17 ? ? ? ? ? 1; ~ 16
	5 4 3 ? 5 ? ? 16 ? 17 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	2 1 0 ? 6 ? ? ? ? ? ? ? ? ? ? ?; 3 3 0 ? 7 0 0 ? ? ? ? ? ? ? ? ?; 27 4 0 7 6 ? ? 2 ? ? ? ? ? ? ? 1; ~ 7
	3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 78 4 5 0 5 ? ? 2 ? 0 ? ? ? 0 ? 1; ~ 0
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 17 1 4 4 ? ? 18 ? ? ? ? ? 1; ~ 17
	5 4 3 ? 5 ? ? 17 ? 18 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 4 4 0 ? 3 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 2 ? ? ? ? ? ? ? ?; 30 4 0 4 3 ? ? 6 ? ? ? ? ? ? ? 1
	~ 4; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 4 ? ? 18 ? 19 ? ? ? ? ? ?
	21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 4 ? ? ? ? ? ? ? ?; 79 4 6 19 2 ? ? 2 ? 20 ? ? ? 0 ? 1
	~ 19; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 20 1 4 4 ? ? 21 ? ? ? ? ? 1
	~ 20; 5 4 3 ? 5 ? ? 20 ? 21 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 6 ? ? ? ? ? ? ? ? ? ? ?; 3 3 0 ? 7 0 0 ? ? ? ? ? ? ? ? ?; 30 4 0 7 6 ? ? 2 ? ? ? ? ? ? ? 1
	~ 7; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 78 4 5 1 5 ? ? 2 ? 1 ? ? ? 0 ? 1
	~ 1; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 21 1 4 4 ? ? 22 ? ? ? ? ? 1
	~ 21; 5 4 3 ? 5 ? ? 21 ? 22 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 4 4 0 ? 3 ? ? 30 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 20 ? ? ? ? ? ? ? ?
	29 4 0 3 4 ? ? 6 ? ? ? ? ? ? ? 1; ~ 3; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400
	5 4 3 ? 4 ? ? 22 ? 23 ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 5 ? ? ? ? ? ? ? ?
	79 4 6 23 2 ? ? 2 ? 24 ? ? ? 0 ? 1; ~ 23; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 24 1 4 4 ? ? 25 ? ? ? ? ? 1; ~ 24; 5 4 3 ? 5 ? ? 24 ? 25 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1
	~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 4 4 0 ? 3 ? ? 30 ? ? ? ? ? ? ? ?
	4 4 0 ? 4 ? ? 20 ? ? ? ? ? ? ? ?; 32 4 0 4 3 ? ? 6 ? ? ? ? ? ? ? 1; ~ 4; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1
	~ 1074790400; 5 4 3 ? 4 ? ? 25 ? 26 ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 6 ? ? ? ? ? ? ? ?; 79 4 6 26 2 ? ? 2 ? 27 ? ? ? 0 ? 1; ~ 26; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 27 1 4 4 ? ? 28 ? ? ? ? ? 1; ~ 27; 5 4 3 ? 5 ? ? 27 ? 28 ? ? ? ? ? ?
	12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?
	4 4 0 ? 3 ? ? 20 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 20 ? ? ? ? ? ? ? ?; 28 4 0 3 4 ? ? 6 ? ? ? ? ? ? ? 1; ~ 3
	12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 4 ? ? 22 ? 23 ? ? ? ? ? ?; 21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?
	23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 7 ? ? ? ? ? ? ? ?; 79 4 6 28 2 ? ? 2 ? 29 ? ? ? 0 ? 1; ~ 28
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 24 1 4 4 ? ? 25 ? ? ? ? ? 1; ~ 24
	5 4 3 ? 5 ? ? 24 ? 25 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 4 4 0 ? 3 ? ? 20 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 10 ? ? ? ? ? ? ? ?; 31 4 0 4 3 ? ? 6 ? ? ? ? ? ? ? 1
	~ 4; 12 4 4 1074790400 3 ? ? 2 ? ? 2 ? ? ? 1 1; ~ 1074790400; 5 4 3 ? 4 ? ? 29 ? 30 ? ? ? ? ? ?
	21 3 0 ? 3 2 1 ? ? ? ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 8 ? ? ? ? ? ? ? ?; 79 4 6 30 2 ? ? 2 ? 31 ? ? ? 0 ? 1
	~ 30; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 31 1 4 4 ? ? 32 ? ? ? ? ? 1
	~ 31; 5 4 3 ? 5 ? ? 31 ? 32 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 2 ? ? ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 79 4 6 32 2 ? ? 2 ? 33 ? ? ? 0 ? 1; ~ 32
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 33 1 4 4 ? ? 34 ? ? ? ? ? 1; ~ 33
	5 4 3 ? 5 ? ? 33 ? 34 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 23 4 0 ? 0 ? ? 1 ? ? ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 79 4 6 5 2 ? ? 2 ? 6 ? ? ? 0 ? 1; ~ 5; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 34 1 4 4 ? ? 35 ? ? ? ? ? 1; ~ 34; 5 4 3 ? 5 ? ? 34 ? 35 ? ? ? ? ? ?
	12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 5 ? ? ? ? ? ? ? ? ? ? ?
	78 4 5 2147483648 5 ? ? 2 ? 0 ? ? ? 1 ? 1; ~ 2147483648; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 35 1 4 4 ? ? 36 ? ? ? ? ? 1; ~ 35; 5 4 3 ? 5 ? ? 35 ? 36 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1
	~ 1081081856; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 2 1 0 ? 6 ? ? ? ? ? ? ? ? ? ? ?; 78 4 5 0 6 ? ? 2 ? 0 ? ? ? 0 ? 1
	~ 0; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 78 4 5 0 5 ? ? 2 ? 0 ? ? ? 0 ? 1
	~ 0; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 36 1 4 4 ? ? 37 ? ? ? ? ? 1
	~ 36; 5 4 3 ? 5 ? ? 36 ? 37 ? ? ? ? ? ?; 12 4 4 1081081856 3 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 0 ? ? ? ? ? ? ? ?; 5 4 3 ? 3 ? ? 37 ? 38 ? ? ? ? ? ?; 4 4 0 ? 6 ? ? 1 ? ? ? ? ? ? ? ?
	4 4 0 ? 4 ? ? 11 ? ? ? ? ? ? ? ?; 4 4 0 ? 5 ? ? 1 ? ? ? ? ? ? ? ?; 56 4 0 ? 4 ? ? 7 ? ? ? ? ? ? ? ?; 80 4 6 38 3 ? ? 6 ? 39 ? ? ? 0 ? 1
	~ 38; 6 2 0 ? 7 3 ? ? ? ? ? ? ? ? ? ?; 6 2 0 ? 8 6 ? ? ? ? ? ? ? ? ? ?; 49 3 0 ? 3 7 8 ? ? ? ? ? ? ? ? ?
	39 3 2 ? 2 2 4 ? ? 5 ? ? ? ? ? ?; 57 4 0 ? 4 ? ? -7 ? ? ? ? ? ? ? ?; 79 4 6 39 2 ? ? 2 ? 40 ? ? ? 0 ? 1; ~ 39
	3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 40 1 5 4 ? ? 41 ? ? ? ? ? 1; ~ 40
	5 4 3 ? 6 ? ? 40 ? 41 ? ? ? ? ? ?; 12 4 4 1081081856 4 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?
	80 4 6 38 3 ? ? 2 ? 39 ? ? ? 0 ? 1; ~ 38; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 41 1 5 4 ? ? 42 ? ? ? ? ? 1; ~ 41; 5 4 3 ? 6 ? ? 41 ? 42 ? ? ? ? ? ?; 12 4 4 1081081856 4 ? ? 8 ? ? 8 ? ? ? 1 1
	~ 1081081856; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 5 4 3 ? 6 ? ? 42 ? 43 ? ? ? ? ? ?; 80 4 6 2147483691 6 ? ? 2 ? 44 ? ? ? 1 ? 1
	~ 2147483691; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 44 1 5 4 ? ? 45 ? ? ? ? ? 1
	~ 44; 5 4 3 ? 6 ? ? 44 ? 45 ? ? ? ? ? ?; 12 4 4 1081081856 4 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856
	21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 5 4 3 ? 6 ? ? 42 ? 43 ? ? ? ? ? ?; 80 4 6 42 6 ? ? 2 ? 43 ? ? ? 0 ? 1; ~ 42
	3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 45 1 5 4 ? ? 46 ? ? ? ? ? 1; ~ 45
	5 4 3 ? 6 ? ? 45 ? 46 ? ? ? ? ? ?; 12 4 4 1081081856 4 ? ? 8 ? ? 8 ? ? ? 1 1; ~ 1081081856; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?
	12 4 4 1121976320 4 ? ? 47 ? ? 47 ? ? ? 1 1; ~ 1121976320; 21 3 0 ? 4 1 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}]], {
	{ },{ 0,"3",1074790400,"4",1,10,"5","6",1081081856,"7","8","9",2,"10","11",
		3,"12","13","14",4,"15","16","17",5,"18","19",6,"20",7,"21",8,"22",9,"23","24","25",
		"26","27","28",11,"30","31","32","33","34","35","36",1121976320,
	},
}, {
	"\109","\97","\101\114\114\111\114","\76\111\111\112\32\100\105\100\32\110\111\116\32\74\85\77\80",
	"\76\111\111\112\32\100\105\100\32\110\111\116\32\74\85\77\80\66\65\67\75\32\111\114\32\101\120\99\101\101\100\101\100\32\105\110\115\116\114\117\99\116\105\111\110\115",
	"\97\115\115\101\114\116","\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\69\81\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\69\81\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\74\85\77\80\73\70\69\81\32\105\110\99\111\114\114\101\99\116\32\114\101\115\117\108\116",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\69\81\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\69\81\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\74\85\77\80\73\70\78\79\84\69\81\32\105\110\99\111\114\114\101\99\116\32\114\101\115\117\108\116",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\76\69\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\76\69\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\76\84\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\76\84\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\76\69\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\73\70\78\79\84\76\69\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\88\69\81\75\78\32\99\111\114\114\101\99\116\108\121",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\88\69\81\75\66\32\99\111\114\114\101\99\116\108\121",
	"\74\85\77\80\88\69\81\75\66\32\105\110\99\111\114\114\101\99\116\32\114\101\115\117\108\116\32\35\49",
	"\74\85\77\80\88\69\81\75\66\32\105\110\99\111\114\114\101\99\116\32\114\101\115\117\108\116\32\35\50",
	"","\49\50\51\52\53\54\55\56\57\49\48\49\49","\105","\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\88\69\81\75\83\32\99\111\114\114\101\99\116\108\121\32\35\49",
	"\83\116\97\116\101\109\101\110\116\32\100\105\100\32\110\111\116\32\74\85\77\80\88\69\81\75\83\32\99\111\114\114\101\99\116\108\121\32\35\50",
	"\83\65\77\80\76\69","\83\65\77\80\76\69\49","\74\85\77\80\88\69\81\75\83\32\105\110\99\111\114\114\101\99\116\32\114\101\115\117\108\116\32\35\49",
	"\74\85\77\80\88\69\81\75\83\32\105\110\99\111\114\114\101\99\116\32\114\101\115\117\108\116\32\35\50",
	"\79\75","\98","\99","\115",
}

assert(MATCH(
	Fiu.luau_deserialize(compileResult),
	FiuUtils.decodeModule(encodedModule, constantList, stringList)
))

OK()
