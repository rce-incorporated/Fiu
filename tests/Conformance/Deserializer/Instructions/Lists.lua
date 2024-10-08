-- file was auto-generated by `fiu-tests`
--!ctx Luau

local ok, compileResult = Luau.compile([[
-- tests: LOP_NEWTABLE, LOP_DUPTABLE, LOP_SETLIST, LOP_MOVE, LOP_LENGTH

-- NEWTABLE
-- SETLIST
local t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}

-- LENGTH
assert(#t == 10, "Length does not match")
assert(table.concat(t, ",") == "1,2,3,4,5,6,7,8,9,10", "Concat does not match")

-- DUPTABLE
local t3 = {A=2}
local t4 = t3

assert(#t3 == 0, "Length does not match")
assert(t3.A == 2, "t3.A does not match")

-- MOVE
t4 = t
assert(t4 == t, "Move failed")

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
3; 1; 0 11 0 0 1 1 ? 84 18 0 [] 1 [1,5,5,5,5,5,5,5,5,5,5,5,5,5,5,8,8,8,8,8,8,8,8,8,8,8,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,12,12,12,12,13,15,15,15,15,15,15,15,15,15,15,15,16,16,16,16,16,16,16,16,16,16,16,16,19,20,20,20,20,20,20,20,20,20,20,22,22,22,23,] {
	65 1 0 ? 0 ? ? ? ? ? ? ? ? ? ? ?; 53 2 0 10 0 0 ? ? ? ? ? ? ? ? ? 1; ~ 10; 4 4 0 ? 1 ? ? 1 ? ? ? ? ? ? ? ?
	4 4 0 ? 2 ? ? 2 ? ? ? ? ? ? ? ?; 4 4 0 ? 3 ? ? 3 ? ? ? ? ? ? ? ?; 4 4 0 ? 4 ? ? 4 ? ? ? ? ? ? ? ?; 4 4 0 ? 5 ? ? 5 ? ? ? ? ? ? ? ?
	4 4 0 ? 6 ? ? 6 ? ? ? ? ? ? ? ?; 4 4 0 ? 7 ? ? 7 ? ? ? ? ? ? ? ?; 4 4 0 ? 8 ? ? 8 ? ? ? ? ? ? ? ?; 4 4 0 ? 9 ? ? 9 ? ? ? ? ? ? ? ?
	4 4 0 ? 10 ? ? 10 ? ? ? ? ? ? ? ?; 55 3 0 1 0 1 11 ? ? ? ? ? ? ? ? 1; ~ 1; 52 2 0 ? 3 0 ? ? ? ? ? ? ? ? ? ?
	79 4 6 0 3 ? ? 2 ? 1 ? ? ? 0 ? 1; ~ 0; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?
	75 3 1 1 1 2 4 ? ? 2 ? ? ? ? ? 1; ~ 1; 5 4 3 ? 3 ? ? 1 ? 2 ? ? ? ? ? ?; 12 4 4 1075838976 1 ? ? 3 ? ? 3 ? ? ? 1 1
	~ 1075838976; 21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 12 4 4 2151683072 3 ? ? 6 ? ? 5 6 ? ? 2 1; ~ 2151683072
	6 2 0 ? 4 0 ? ? ? ? ? ? ? ? ? ?; 5 4 3 ? 5 ? ? 7 ? 8 ? ? ? ? ? ?; 21 3 0 ? 3 3 2 ? ? ? ? ? ? ? ? ?; 80 4 6 8 3 ? ? 2 ? 9 ? ? ? 0 ? 1
	~ 8; 3 3 0 ? 2 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 2 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 9 1 2 4 ? ? 10 ? ? ? ? ? 1
	~ 9; 5 4 3 ? 3 ? ? 9 ? 10 ? ? ? ? ? ?; 12 4 4 1075838976 1 ? ? 3 ? ? 3 ? ? ? 1 1; ~ 1075838976
	21 3 0 ? 1 3 1 ? ? ? ? ? ? ? ? ?; 54 4 3 ? 1 ? ? 11 ? 12 ? ? ? ? ? ?; 4 4 0 ? 2 ? ? 2 ? ? ? ? ? ? ? ?; 16 3 1 10 2 1 96 ? ? 11 ? ? ? ? ? 1
	~ 10; 6 2 0 ? 2 1 ? ? ? ? ? ? ? ? ? ?; 52 2 0 ? 5 1 ? ? ? ? ? ? ? ? ? ?; 79 4 6 12 5 ? ? 2 ? 13 ? ? ? 0 ? 1
	~ 12; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 1 1 4 4 ? ? 2 ? ? ? ? ? 1
	~ 1; 5 4 3 ? 5 ? ? 1 ? 2 ? ? ? ? ? ?; 12 4 4 1075838976 3 ? ? 3 ? ? 3 ? ? ? 1 1; ~ 1075838976
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 15 3 1 10 5 1 96 ? ? 11 ? ? ? ? ? 1; ~ 10; 79 4 6 13 5 ? ? 2 ? 14 ? ? ? 0 ? 1
	~ 13; 3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 14 1 4 4 ? ? 15 ? ? ? ? ? 1
	~ 14; 5 4 3 ? 5 ? ? 14 ? 15 ? ? ? ? ? ?; 12 4 4 1075838976 3 ? ? 3 ? ? 3 ? ? ? 1 1; ~ 1075838976
	21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?; 6 2 0 ? 2 0 ? ? ? ? ? ? ? ? ? ?; 27 4 0 0 2 ? ? 2 ? ? ? ? ? ? ? 1; ~ 0
	3 3 0 ? 4 0 1 ? ? ? ? ? ? ? ? ?; 3 3 0 ? 4 1 0 ? ? ? ? ? ? ? ? ?; 75 3 1 15 1 4 4 ? ? 16 ? ? ? ? ? 1; ~ 15
	5 4 3 ? 5 ? ? 15 ? 16 ? ? ? ? ? ?; 12 4 4 1075838976 3 ? ? 3 ? ? 3 ? ? ? 1 1; ~ 1075838976; 21 3 0 ? 3 3 1 ? ? ? ? ? ? ? ? ?
	12 4 4 1090519040 3 ? ? 17 ? ? 17 ? ? ? 1 1; ~ 1090519040; 21 3 0 ? 3 1 1 ? ? ? ? ? ? ? ? ?; 22 2 0 ? 0 1 ? ? ? ? ? ? ? ? ? ?
}]], {
	{ 10,"1","2",1075838976,"3","4",2151683072,"5","6","7","8",{ 10,},0,2,"9","10",
		"11",1090519040,
	},
}, {
	"\76\101\110\103\116\104\32\100\111\101\115\32\110\111\116\32\109\97\116\99\104","\97\115\115\101\114\116",
	"\116\97\98\108\101","\99\111\110\99\97\116","\44","\49\44\50\44\51\44\52\44\53\44\54\44\55\44\56\44\57\44\49\48",
	"\67\111\110\99\97\116\32\100\111\101\115\32\110\111\116\32\109\97\116\99\104","\65","\116\51\46\65\32\100\111\101\115\32\110\111\116\32\109\97\116\99\104",
	"\77\111\118\101\32\102\97\105\108\101\100","\79\75","\116","\116\51","\116\52",
}

assert(MATCH(
	Fiu.luau_deserialize(compileResult),
	FiuUtils.decodeModule(encodedModule, constantList, stringList)
))

OK()
