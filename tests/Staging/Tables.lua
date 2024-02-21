local t = {}
t[1] = 1
local v = t[1]
t["hash"] = 1
local k = t["hash"]
t[t] = {}
local n = t[t]
print(t,v,k,n)

OK()
