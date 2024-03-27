local a = math.floor(12)
local b = math.floor(15)
local c = 1 + b
assert(c == 16)
local c = 1 - b
assert(c == -14)
local c = 1 / b
assert(c == 0.06666666666666667)
local c = 1 * b
assert(c == 15)
local c = 1 % b
assert(c == 1)
local c = 1 ^ b
assert(c == 1)
local c = a + b
assert(c == 27)
local c = a - b
assert(c == -3)
local c = a / b
assert(c == 0.8)
local c = a * b
assert(c == 180)
local c = a % b
assert(c == 12)
local c = a ^ b
assert(c == 15407021574586368)

OK()
