--!ctx Luau

local source = [=[
local iterations = 100000
local f; f = function() end
for _ = 1, iterations do
	f()
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
if FiuCodeGen.__codegenReady then
	fiuCodeGenExecute()
end
fiuCodeGenTime = os.clock() - start

local totalTime = os.clock() - testStart

local results = `Closure Speed: [Luau: {math.round(luauTime * 1000000)}us] [Fiu: {math.round(fiuTime * 1000000)}us]`;
if FiuCodeGen.__codegenReady then
	results ..= ` [Fiu (CodeGen): {math.round(fiuCodeGenTime * 1000000)}]`;
else
	results ..= ` [Fiu (CodeGen): None]`;
end

results ..= ` Total Time: {math.round(totalTime * 1000000)}us`;

OK(results)