local t = {}
local a = 1 
while a ~= 10 do 
    a = a + 1
    table.insert(t, a)
end

assert(t[2] == 3)
assert(t[3] == 4)
assert(t[4] == 5)
assert(t[5] == 6)
assert(t[6] == 7)
assert(t[7] == 8)
assert(t[8] == 9)
assert(t[9] == 10)

local t = {}
local a = 1
repeat	
    a = a + 1
    table.insert(t, a)
until a == 10

assert(t[2] == 3)
assert(t[3] == 4)
assert(t[4] == 5)
assert(t[5] == 6)
assert(t[6] == 7)
assert(t[7] == 8)
assert(t[8] == 9)
assert(t[9] == 10)

OK()
