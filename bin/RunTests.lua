local fiu = require("../Source")
local tests = {
	"DupTableSetList", "Globals", "Unary", "Tables", "LOADNIL", "LOADN", "HelloWorld", "Concat", "Arit", "AritK", "AndOr", "AndOrK"
}

for i,v in tests do 
	local m = require("Tests/"..v)()
	fiu.luau_load(m, getfenv())()
end
