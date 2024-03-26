-- tests: LOP_CONCAT, LOP_LOADK, LOP_LENGTH

local a = "a"
local b = "b"

-- CONCAT
local c = a..b

assert(c == "ab" and #c == 2, "Concat does not match #1")

local d = c

-- CONCAT
d ..= "cd"

assert(d == "abcd" and #d == 4, "Concat does not match #2")

OK()