local t = {}
t[1] = 1
local v = t[1]
t["hash"] = 5
local k = t["hash"]
t[t] = {}
local n = t[t]
assert(t[1] == 1)
assert(t[1] == v)
assert(t["hash"] == 5)
assert(t["hash"] == k)
assert(t[t] == n)

OK()
