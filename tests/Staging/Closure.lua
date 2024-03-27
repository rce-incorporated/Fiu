assert((function() return 5 end)() == 5)

local upvalue = math.floor(1)

assert((function() assert(upvalue == 1) upvalue = math.floor(5) assert(upvalue == 5) return upvalue end)() == 5)
assert(upvalue == 5)

OK()
