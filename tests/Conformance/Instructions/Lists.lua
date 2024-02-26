-- tests: LOP_NEWTABLE, LOP_DUPTABLE, LOP_SETLIST, LOP_MOVE, LOP_LENGTH

-- NEWTABLE
-- SETLIST
local t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

-- LENGTH
assert(#t == 10, "Length does not match")
assert(table.concat(t, ",") == "1,2,3,4,5,6,7,8,9,10", "Concat does not match")

-- DUPTABLE
local t3 = {A=2}
local t4 = t3

assert(#t3 == 0, "Length does not match")
assert(t3.A == 2, "t3.A does not match")

-- MOVE
t4 = t
assert(t4 == t, "Move failed")

OK()