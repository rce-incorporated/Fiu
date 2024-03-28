local a = table.isfrozen({}) -- no propagate pls >:c
local b = math.floor(15)
local c = math.floor(25)
assert(not (a and b))
assert(a or c == 25)

OK()
