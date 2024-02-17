local TEST_ALL = false;
local TEST_CONFORMANCE = false;
local TEST_STAGING = false;
local TEST_SPECIFIC = true;

local TEST_IF_OK = false;

local OUTPUT_DEBUG = false;

local fiu = require("../Source");

local conformanceTests = {
	"attrib",
	"basic",
	"bitwise",
	"calls",
	"clear",
	"constructs",
	"coroutine",
	"datetime",
	"ifelseexpr",
	"iter",
	"literals",
	"locals",
	"math",
	"move",
	"pm",
	"sort",
	"strconv",
	"strings",
	"tables",
	"tpack",
	"utf8",
	"vararg"
};

local stagingTests = {
	"AndOr",
	"AndOrK",
	"Arit",
	"AritK",
	"Booleans",
	"Concat",
	"DupTableSetList",
	-- "GetImportSpecial",
	"Globals",
	"HelloWorld",
	"LOADN",
	"LOADNIL",
	"Tables",
	"Unary",
	"Conditions",
	"WhileRepeat",
	"BasicJump",
	"Closure",
	"Namecall",
	"Varargs",
	"GenericFor",
	"ForLoops",
	"Returns",
	"BasicReturn",

	--// Bug reports
	"Issue4",
	"Issue5",
};

local specificTests = {
	{
		false,
		"BasicReturn"
	}
};

local function TestIfOk()
	--// TODO: Proper CI tests
end

local function TestOutput(directory, testNames)
	for i, v in testNames do
		print(string.format(">>>>>>>> RUNNING TEST: %s <<<<<<<<", v));
		if OUTPUT_DEBUG then
			print("--------->> BYTECODE LISTING <<---------");
			print((require(string.format("%s/Listings/%s", directory, v)))());
		end
		print("--------->> SOURCE OUTPUT <<---------");
		print("SOURCE PCALL: ", pcall(function()
			(require(string.format("%s/SourceTests/%s", directory, v)))();
		end));
		print("--------->> VM OUTPUT <<---------");
		local s, e = pcall(function()
			local m = (require(string.format("%s/Tests/%s", directory, v)))();
			(fiu.luau_load(m, getfenv()))();
		end);
		if not s then
			print(">>>>>>>>>>>>>>>>>>>>>>>>>>>> Broken: " .. e);
		end;
		print("VM PCALL: ", s);
		print(string.format(">>>>>>>> FINISHED RUNNING TEST: %s <<<<<<<<", v));
	end;
end

local function Test(directory, testNames)
	if TEST_IF_OK then 
		TestIfOk(directory, testNames)
	else  
		TestOutput(directory, testNames)
	end
end;

if TEST_ALL then
	Test("ConformanceTests", conformanceTests)
	Test("StagingTests", stagingTests)

	return;
end;

if TEST_CONFORMANCE then 
	Test("ConformanceTests", conformanceTests)

	return;
end 

if TEST_STAGING then 
	Test("StagingTests", stagingTests)

	return;
end 

if TEST_SPECIFIC then 
	local specificConformanceTests = {}
	local specificStagingTests = {
		"FunctionIssue"
	}

	for i,v in specificTests do 
		if v[1] then 
			table.insert(specificConformanceTests, v[2])
		else 
			table.insert(specificStagingTests, v[2])
		end 
	end

	Test("ConformanceTests", specificConformanceTests)
	Test("StagingTests", specificStagingTests)
end 

print("FINISHED.");
