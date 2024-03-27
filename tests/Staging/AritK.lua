local a = math.floor(12)
local b = math.floor(15)
local c = b + 1
assert(c == 16)
local c = b - 1
assert(c == 14)
local c = b / 1
assert(c == 15)
local c = b * 1
assert(c == 15)
local c = b % 1
assert(c == 0)
local c = b ^ 1
assert(c == 15)

OK()
