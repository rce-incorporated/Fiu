local t = {}

for i,v in {1,2,3} do 
	t[i] = v
end 

assert(t[1] == 1)
assert(t[2] == 2)
assert(t[3] == 3)

print("GENERALIZED DONE")

local t2 = {}
for i,v in pairs({6,7,8,9}) do 
 	t2[i] = v
end

assert(t2[1] == 6)
assert(t2[2] == 7)
assert(t2[3] == 8)
assert(t2[4] == 9)

OK()
