local fiu = require("../Source")
local tests = {
	"Conditions"	
}

for i,v in tests do 
	local m = require("Tests/"..v)()
	fiu.luau_load(m, getfenv())()
end
