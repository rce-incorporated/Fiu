return function()
	local a = table.isfrozen({}) -- no propagate pls >:c
local b = math.floor(15)
local c = math.floor(25)
print(a and b)
print(a or c)

end