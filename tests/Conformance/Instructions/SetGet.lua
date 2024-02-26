-- tests: LOP_SETTABLEKS, LOP_GETTABLEKS, LOP_SETTABLEN, LOP_GETTABLEN, LOP_SETTABLE, LOP_GETTABLE, LOP_SETGLOBAL, LOP_GETGLOBAL, LOP_GETIMPORT

local t = {}

-- SETTABLEKS
t.Foo = 123
-- GETTABLEKS
assert(t.Foo == 123, "GETTABLEKS Failed")

-- SETTABLEN
t[1] = 456
-- GETTABLEN
assert(t[1] == 456, "GETTABLEN Failed")

-- SETTABLE
local k = {}
t[k] = 789
-- GETTABLE
assert(t[k] == 789, "GETTABLE Failed")

-- SETGLOBAL
global_t = {a = 1, b = 2}
-- GETGLOBAL
assert(global_t and type(global_t) == "table" and #global_t == 0 and global_t.a == 1 and global_t.b == 2, "GETGLOBAL Failed")

-- GETIMPORT
assert(math, "Math is missing")
assert(math.min and type(math.min) == "function", "GETIMPORT Failed")

OK()