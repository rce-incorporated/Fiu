--!ctx Luau

local source = [=[
local iterations = 100000

local T = {}
for Idx = 1, iterations do
	T[tostring(Idx)] = 'Id: ' .. tostring(Idx)
end

for Idx = 1, iterations do
	T[1] = T[tostring(Idx)]
end
]=]
local ok, compileResult = Luau.compile(source)

if not ok then
	error(compileResult)
end

local settings = Fiu.luau_newsettings()

settings.errorHandling = false

local fiuEnv = {tostring = tostring}
local fiuExecute = Fiu.luau_load(compileResult, fiuEnv, settings)
local fiuCodeGenExecute = FiuCodeGen.luau_load(compileResult, fiuEnv, settings)

local nativeExecute = loadstring(source)

local fiuTime = 0
local luauTime = 0
local fiuCodeGenTime = 0

local start = os.clock()
local testStart = start
nativeExecute()
luauTime = os.clock() - start

start = os.clock()
fiuExecute()
fiuTime = os.clock() - start

start = os.clock()
fiuCodeGenExecute()
fiuCodeGenTime = os.clock() - start

local totalTime = os.clock() - testStart

local results = `Set/Get Table Speed: [Luau: {math.round(luauTime * 1000000)}us] [Fiu: {math.round(fiuTime * 1000000)}us]`;
if FiuCodeGen.__codegenReady then
	results ..= ` [Fiu (CodeGen): {math.round(fiuCodeGenTime * 1000000)}]`;
else
	results ..= ` [Fiu (CodeGen): None]`;
end

results ..= ` Total Time: {math.round(totalTime * 1000000)}us`;

OK(results)