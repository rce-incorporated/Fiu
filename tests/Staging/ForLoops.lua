local t = {}

for i = 1, 10 do 
 	if i == 5 then 
 		continue
 	end
 	t[i] = true
 	if i == 8 then 
 		break
 	end
end

assert(t[1])
assert(t[2])
assert(t[3])
assert(t[4])
assert(t[5] == nil)
assert(t[6])
assert(t[7])
assert(t[8])
assert(t[9] == nil)
assert(t[10] == nil)

OK()
