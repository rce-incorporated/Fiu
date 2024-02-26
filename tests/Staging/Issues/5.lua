local a = "a"
local v = "klfanj"

assert(not (string.sub(v, 1, #a) == a))

OK()
