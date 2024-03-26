-- tests: LOP_LOADNIL, LOP_LOADK, LOP_LOADN, LOP_LOADB, LOP_NEWTABLE, LOP_NEWCLOSURE/LOP_DUPCLOSURE

-- LOADNIL
local n = nil
-- LOADK
local string = "STRING"
-- LOADN
local number = 123
-- LOADB
local boolean = true
-- NEWTABLE
local table = {1, 2, 3}
-- NEWCLOSURE/DUPCLOSURE
local function func() end
-- extra uncontrolled datatypes
local userdata = newproxy(true)
local thread = coroutine.create(func)

-- assert types
assert(type(n) == "nil")
assert(type(string) == "string" and string == "STRING")
assert(type(number) == "number" and number == 123)
assert(type(boolean) == "boolean" and boolean == true)
assert(type(table) == "table" and #table == 3 and table[1] == 1 and table[2] == 2 and table[3] == 3)
assert(type(func) == "function")
assert(type(userdata) == "userdata")
assert(type(thread) == "thread")

OK()