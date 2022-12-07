local fiu = require("../Source")
local allTests = {
	"AndOr", "AndOrK", "Arit", "AritK", "Booleans", "Concat", "DupTableSetList", "GetImportSpecial", "Globals", "HelloWorld",
	"LOADN", "LOADNIL", "Tables", "Unary", "Conditions", "WhileRepeat", "BasicJump", "Closure"

	-- Not fully working tests: "ForLoops", "Namecall"
	--[[
	ForLoops: generalised iteration is not supported, table structure was incorrect
	Namecall: table argument pass is missing
	]]
	-- Optional Tests: "GetImportSpecial", "WhileTrueDo"
}

local specificTests = {
	"Conditions"
}

for i,v in specificTests do
	print(string.format(">>>>>>>> RUNNING TEST: %s <<<<<<<<", v))
	print("--------->> BYTECODE LISTING <<---------")
	print(require("Listings/"..v)())
	print("--------->> VM OUTPUT <<---------") 
	print("VM PCALL: ", pcall(function()
		local m = require("Tests/"..v)()
		fiu.luau_load(m, getfenv())()
	end))
	print("--------->> SOURCE OUTPUT <<---------") 
	print("SOURCE PCALL: ", pcall(function()
		require("SourceTests/"..v)()
	end))
	print(string.format(">>>>>>>> FINISHED RUNNING TEST: %s <<<<<<<<", v))
end
