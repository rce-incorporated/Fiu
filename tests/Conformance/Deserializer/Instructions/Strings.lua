-- file was auto-generated by `fiu-tests`
--!ctx Luau

local ok, compileResult = Luau.compile([[
-- tests: LOP_CONCAT, LOP_LOADK, LOP_LENGTH

local a = "a"
local b = "b"

-- CONCAT
local c = a..b

assert(c == "ab" and #c == 2, "Concat does not match #1")

local d = c

-- CONCAT
d ..= "cd"

assert(d == "abcd" and #d == 4, "Concat does not match #2")

OK()
]], {
	optimizationLevel = 2,
	debugLevel = 2,
	coverageLevel = 0,
	vectorLib = nil,
	vectorCtor = nil,
	vectorType = nil
})

if not ok then
	error(`Failed to compile, error: {compileResult}`)
end

local encodedModule, constantList, stringList = [[
3; 1; 0 7 0 0 1 1 ? 42 13 0 [] 1 [1,3,4,7,7,7,9,9,9,9,9,9,9,9,9,9,9,9,9,9,11,14,14,14,16,16,16,16,16,16,16,16,16,16,16,16,16,16,18,18,18,19,] {
	65 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 5 4 3 ? 0 ? ? 0 ? 1 ? ? ? ? ? ?; 5 4 3 ? 1 ? ? 1 ? 2 ? ? ? ? ? ?; 5 4 3 ? 3 ? ? 0 ? 1 ? ? ? ? ? ?
	5 4 3 ? 4 ? ? 1 ? 2 ? ? ? ? ? ?; 49 3 0 ? 2 3 4 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 0 0 ? ? ? ? ? ? ? ? ?; 80 4 6 2147483650 2 ? ? 6 ? 3 ? ? ? 1 ? 1
	~ 2147483650; 52 2 0 ? 5 2 ? ? ? ? ? ? ? ? ? ?; 79 4 6 3 5 ? ? 2 ? 4 ? ? ? 0 ? 1; ~ 3
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 4 1 4 4 ? ? 5 ? ? ? ? ? 1; ~ 4
	5 4 3 ? 5 ? ? 4 ? 5 ? ? ? ? ? ?; 12 4 4 1078984704 3 ? ? 6 ? ? 6 ? ? ? 1 1; ~ 1078984704; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	6 2 0 ? 3 2 ? ? ? ? ? ? ? ? ? ?; 6 2 0 ? 4 3 ? ? ? ? ? ? ? ? ? ?; 5 4 3 ? 5 ? ? 7 ? 8 ? ? ? ? ? ?; 49 3 0 ? 3 4 5 ? ? ? ? ? ? ? ? ?
	3 3 0 ? 5 0 0 ? ? ? ? ? ? ? ? ?; 80 4 6 2147483656 3 ? ? 6 ? 9 ? ? ? 1 ? 1; ~ 2147483656; 52 2 0 ? 6 3 ? ? ? ? ? ? ? ? ? ?
	79 4 6 9 6 ? ? 2 ? 10 ? ? ? 0 ? 1; ~ 9; 3 3 0 ? 5 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 5 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 10 1 5 4 ? ? 11 ? ? ? ? ? 1; ~ 10; 5 4 3 ? 6 ? ? 10 ? 11 ? ? ? ? ? ?; 12 4 4 1078984704 4 ? ? 6 ? ? 6 ? ? ? 1 1
	~ 1078984704; 21 3 0 ? 4 3 1 ? ? ? ? ? ? ? ? ?; 12 4 4 1085276160 4 ? ? 12 ? ? 12 ? ? ? 1 1; ~ 1085276160
	21 3 0 ? 4 1 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}]], {
	{ "1","2","3",2,"4","5",1078984704,"6","7",4,"8","9",1085276160,},
}, {
	"\97","\98","\97\98","\67\111\110\99\97\116\32\100\111\101\115\32\110\111\116\32\109\97\116\99\104\32\35\49",
	"\97\115\115\101\114\116","\99\100","\97\98\99\100","\67\111\110\99\97\116\32\100\111\101\115\32\110\111\116\32\109\97\116\99\104\32\35\50",
	"\79\75","\99","\100",
}

assert(MATCH(
	Fiu.luau_deserialize(compileResult),
	FiuUtils.decodeModule(encodedModule, constantList, stringList)
))

OK()
