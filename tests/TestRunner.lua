local fs = require("@lune/fs")
local luau = require("@lune/luau")
local task = require("@lune/task")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

local Files = require("Utils/Files")
local Formatter = require("Utils/Formatter")
local Enviroment = require("Utils/Enviroment")
local Translation = require("Utils/Translation")

local CONFIGURATION = require("Config")

local STATUS_SYMBOLS = {
	`{stdio.color("red")}X{stdio.color("reset")}`,
	`{stdio.color("green")}✔{stdio.color("reset")}`
}

local STAGES = {
	[0] = "Compiling",
	"Deserializing Fiu",
	"Deserializing Luau",
	"Executing Fiu",
	"Executing Luau",
	"Comparing results"
}

local VM_NAMES = {
	"Fiu",
	"Luau",
	Fiu = 1,
	Luau = 2,
}

local bytecode_compilation_options = {
	optimizationLevel = 1,
	debugLevel = 1,
}

-- Fiu
local fiuOk, fiuLoad = pcall(luau.load, fs.readFile("Source.lua"), { debugName = "Fiu" })
assert(fiuOk, `[{STATUS_SYMBOLS[1]}] Failed to Compile 'Fiu': {fiuLoad}`)

print(`[{STATUS_SYMBOLS[2]}] Fiu: Compiled`)

local fiu : typeof(require("../Source"))
fiuOk, fiu = pcall(fiuLoad)
assert(fiuOk, `[{STATUS_SYMBOLS[1]}] Failed to Load 'Fiu': {fiu}`)

print(`[{STATUS_SYMBOLS[2]}] Fiu: Loaded`)

local PROCESS_OPTIONS = {} do
	for _, arg in process.args do
		local name, value = arg:match("^(%w+)=(.+)$")
		if name then
			PROCESS_OPTIONS[name] = value
		end
	end
end

print = Formatter.print
warn = function(...)
	print(`{Formatter.applyStyle(stdio.style("dim"), "[")}{Formatter.applyColor(stdio.color("yellow"), "WARN")}{Formatter.applyStyle(stdio.style("dim"), "]")}`)
	print(...)
end

CONFIGURATION.DEBUGGING = PROCESS_OPTIONS.debug and tonumber(PROCESS_OPTIONS.debug) or CONFIGURATION.DEBUGGING
CONFIGURATION.DEBUGGING_LEVEL = PROCESS_OPTIONS.debuglevel and tonumber(PROCESS_OPTIONS.debuglevel) or CONFIGURATION.DEBUGGING_LEVEL
local RELATIVE_SINGLE_RUN = PROCESS_OPTIONS.test
local COLLECT_LOGS = if (PROCESS_OPTIONS.collectlogs ~= nil) then PROCESS_OPTIONS.collectlogs:lower() == "true" else true

for i, v in CONFIGURATION.TESTS do
	assert(fs.isDir(v), `{i}: [{v}] directory not found`)
end

local RUNTIME_ENV = getfenv()

setmetatable(RUNTIME_ENV, {
	__newindex = function(_, k, v)
		error(`Cannot modify the runtime environment, {debug.traceback()}`)
	end
})

local function tableCopyMerge(target, source)
	local copy = table.clone(target)
	for i, v in source do
		copy[i] = v
	end
	return copy
end

local function mathFloorPrecision(num, precision)
	return math.floor(num * precision) / precision
end

local function canDebug(executor : number)
	return CONFIGURATION.DEBUGGING == 3 or CONFIGURATION.DEBUGGING == executor
end

local function canDebugByLevel(level : number)
	return CONFIGURATION.DEBUGGING_LEVEL == level or CONFIGURATION.DEBUGGING_LEVEL == 3 or CONFIGURATION.DEBUGGING_LEVEL == 4
end

local function tassert(cond, msg, stack, testInfo, thread)
	if not cond then
		testInfo.passed = false
		testInfo.result = msg
		for i, v in stack do
			table.insert(testInfo.resstack, v)
		end
		coroutine.resume(thread)
		coroutine.yield()
	end
end

local genTempEnv = {
	task = task,
	print = function() end,
}

local fiuEnv
local luauEnv

local fiuMaskEnv

fiuEnv = Enviroment.new(tableCopyMerge(genTempEnv, {
	loadstring = function(str : string)
		local ok, bytecode = pcall(luau.compile, str, bytecode_compilation_options)
		if not ok then
			error(tostring(bytecode))
		end
		-- FIU Wraps the Luau execute function, setting the context function of a closure
		-- when FIU Debugging is enabled: this(1) -> luau_execute(2) -> wrapped(3)
		-- Otherwise: this(1) -> luau_execute(2) -> pcall(3) -> wrapped(4)
		local env = getfenv(3)
		if env == RUNTIME_ENV then
			env = fiuMaskEnv;
		end
		return setfenv(fiu.luau_load(bytecode, env), env)
	end
}), RUNTIME_ENV)

luauEnv = Enviroment.new(tableCopyMerge(genTempEnv, {
	loadstring = function(str : string)
		local ok, bytecode = pcall(luau.compile, str, bytecode_compilation_options)
		if not ok then
			error(tostring(bytecode))
		end
		-- this(1) -> @luau(2)
		local env = getfenv(2)
		return setfenv(luau.load(bytecode, { debugName = "loadstring" }), env)
	end
}), RUNTIME_ENV)

local function displayMessage(msg : string, stack : {string}, status : number)
	local stack_size = #stack
	return `  [{STATUS_SYMBOLS[status]}] {msg}{
		if stack_size > 0
		then if stack_size > 1
			then "\n    | "
			else "\n    └ "
		else ""
	}{
		if stack_size > 1
		then `{table.concat(stack, "\n    | ", 1, stack_size - 1)}\n    └ {table.concat(stack, stack_size, stack_size)}`
		else table.concat(stack)
	}`
end

local function RunTestFile(file : Files.FileItem)
	local fileName = file.relativeName
	local testInfo = {
		stage = 0,
		passed = false,
		result = nil,
		resstack = {},
		file = file,
	}
	
	local thread = coroutine.running()
	local timeout
	timeout = task.delay(7, function()
		timeout = nil
		testInfo.passed = false
		testInfo.result = `Test [{fileName}]: Failed (Timed out) at stage {STAGES[testInfo.stage]}`
		coroutine.resume(thread)
	end)

	local function infoPrint(vm : number, ...)
		if not canDebug(vm) then
			return
		end
		if CONFIGURATION.DEBUGGING_LEVEL == 4 then
			print(...)
		end
		if not COLLECT_LOGS then
			return
		end
		local args = {...}
		for i = 1, #args do
			local v = args[i]
			if type(v) == "table" then
				args[i] = Translation.toStringTable(v)
				continue
			end
			args[i] = tostring(v)
		end
		table.insert(testInfo.resstack, `+ [{Formatter.applyColor(stdio.color("blue"), "PRINT")}] {table.concat(args, "\t")}`)
	end

	local function infoWarn(vm : number, ...)
		if not canDebug(vm) then
			return
		end
		if CONFIGURATION.DEBUGGING_LEVEL == 4 then
			warn(...)
		end
		if not COLLECT_LOGS then
			return
		end
		local args = {...}
		for i = 1, #args do
			local v = args[i]
			if type(v) == "table" then
				args[i] = Translation.toStringTable(v)
				continue
			end
			args[i] = tostring(v)
		end
		table.insert(testInfo.resstack, `+ [{stdio.color("yellow")}WARN{stdio.color("reset")}] {table.concat(args, "\t")}`)
	end

	local contextScreening = {}
	local function infoCreate(vm : number, debugid : number, info_writer : (vm : number, ...any) -> ()) : (...any) -> ()
		return function(...)
			if not canDebug(vm) or not canDebugByLevel(debugid) then
				return
			end
			if not contextScreening[vm] then
				table.insert(testInfo.resstack, `[{VM_NAMES[vm]}]`)
				contextScreening[vm] = true
			end
			info_writer(vm, ...)
		end
	end

	local TEMP_FIU_ENV, VIRTUAL_FIU_ENV = fiuEnv:construct(true)
	local TEMP_LUAU_ENV, VIRTUAL_LUAU_ENV = luauEnv:construct()

	VIRTUAL_FIU_ENV.print = infoCreate(VM_NAMES.Fiu, 1, infoPrint)
	VIRTUAL_LUAU_ENV.print = infoCreate(VM_NAMES.Luau, 1, infoPrint)
	
	VIRTUAL_FIU_ENV.warn = infoCreate(VM_NAMES.Fiu, 2, infoWarn)
	VIRTUAL_LUAU_ENV.warn = infoCreate(VM_NAMES.Luau, 2, infoWarn)

	VIRTUAL_FIU_ENV.OK = function()
		testInfo.passed = true
	end
	VIRTUAL_LUAU_ENV.OK = VIRTUAL_FIU_ENV.OK

	local assignedEnv = {}
	local function isolatedGetFenv(sandbox_env : any)
		return function(target : any?)
			if target == 0 then
				-- `sandbox global` environment
				return sandbox_env
			end
			if target == nil then
				target = 1
			end
			local f
			if type(target) == "number" and target > 0 then
				target += 1
				-- FIU Wraps the Luau execute function, setting the context function of a closure
				-- would only affect `wrapped` and not luau_execute, we want to skip luau_execute and straight to wrapped
				target += if (sandbox_env == TEMP_FIU_ENV) then target//2 else 0
				f = debug.info(target, "f")
			elseif type(target) == "function" then
				f = target
			end
			local assigned = f and assignedEnv[f]
			if assigned then
				return assigned
			end
			local env = getfenv(target)
			if RUNTIME_ENV == env then
				return sandbox_env
			end
			return env
		end
	end

	VIRTUAL_FIU_ENV.getfenv = isolatedGetFenv(TEMP_FIU_ENV)
	VIRTUAL_LUAU_ENV.getfenv = isolatedGetFenv(TEMP_LUAU_ENV)

	local function isolatedSetFenv(sandbox_env : any)
		return function(target : any, new_env : any)
			assert(type(target) == "function" or type(target) == "number", "(function or number expected)")
			assert(type(new_env) == "table", "(table expected)")

			if target == 0 then
				-- `sandbox global` environment
				error(`Cannot change the luau sandbox environment`)
			end
			if type(target) == "number" then
				target += 1
				-- FIU Wraps the Luau execute function, setting the context function of a closure
				-- would only affect `wrapped` and not luau_execute, we want to skip luau_execute and straight to wrapped
				target += if (sandbox_env == TEMP_FIU_ENV) then (target - 1)//2 * 2 else 0
			end
			local env = sandbox_env.getfenv(target)
			if RUNTIME_ENV == env then
				error(`Cannot change a function environment of which is not a sandboxed environment`)
			end

			if sandbox_env == TEMP_FIU_ENV then
				local f
				if type(target) == "function" then
					assignedEnv[target] = new_env
					setfenv(target, new_env)
					f = target
				else
					f = debug.info(target, "f")
					assignedEnv[f] = new_env
					setfenv(f, new_env)
				end
				return f or target
			end
			return setfenv(target, new_env)
		end
	end

	VIRTUAL_FIU_ENV.setfenv = isolatedSetFenv(TEMP_FIU_ENV)
	VIRTUAL_LUAU_ENV.setfenv = isolatedSetFenv(TEMP_LUAU_ENV)

	fiuMaskEnv = TEMP_FIU_ENV

	task.defer(function()
		local source = fs.readFile(file.path)
		local compileOk, bytecode = pcall(luau.compile, source, bytecode_compilation_options)
		
		tassert(compileOk, `Test [{fileName}]: Failed to compile test.`, {}, testInfo, thread)

		testInfo.stage = 1
		local fiuDeserializeOk, fiuDeserializeRet = pcall(fiu.luau_load, bytecode, TEMP_FIU_ENV)

		testInfo.stage = 2
		local luauDeserializeOk, luauDeserializeRet = pcall(luau.load, bytecode, { debugName = file.relativePath })

		tassert(
			luauDeserializeOk and fiuDeserializeOk,
			`Test [{fileName}]: Failed to deserialize`, {
				not luauDeserializeOk and `Luau: {luauDeserializeRet}` or nil,
				not fiuDeserializeOk and `Fiu: {fiuDeserializeRet}` or nil
			},
			testInfo, thread
		)

		testInfo.stage = 3
		setfenv(fiuDeserializeRet, TEMP_FIU_ENV)
		if canDebug(1) and CONFIGURATION.DEBUGGING_LEVEL == 4 then
			print("[FIU CONSOLE LOG]", testInfo.file.relativeName)
		end
		local fiuExecutionTimeStart = os.clock()
		local fiuOk, fiuRet = pcall(fiuDeserializeRet)
		local fiuExecutionTimeEnd = os.clock()

		testInfo.stage = 4
		setfenv(luauDeserializeRet, TEMP_LUAU_ENV)
		if canDebug(2) and CONFIGURATION.DEBUGGING_LEVEL == 4 then
			print("[LUAU CONSOLE LOG]", testInfo.file.relativeName)
		end
		local luauExecutionTimeStart = os.clock()
		local luauOk, luauRet = pcall(luauDeserializeRet)
		local luauExecutionTimeEnd = os.clock()

		testInfo.stage = 5
		tassert(
			fiuOk and luauOk,
			`Test [{fileName}]: Failed test`, {
				not luauOk and `Luau: {luauRet}` or nil,
				not fiuOk and `Fiu: {fiuRet}` or nil
			},
			testInfo, thread
		)

		if testInfo.passed then
			testInfo.result = `Test [{fileName}]: Passed (Fiu: {
				mathFloorPrecision(fiuExecutionTimeEnd - fiuExecutionTimeStart, 1000)
			}ms, Luau: {
				mathFloorPrecision(luauExecutionTimeEnd - luauExecutionTimeStart, 1000)
			}ms)`
		else
			testInfo.result = `Test [{fileName}]: No valid confirmation (not OK)`
		end

		coroutine.resume(thread)
	end)

	coroutine.yield()

	if timeout then
		task.cancel(timeout)
	end

	table.freeze(testInfo)

	return testInfo
end

local testsFailed = {}
local testResults = {}

for i, v in CONFIGURATION.TESTS do
	local failed = false
	local results = {}
	local testFiles = Files.getFiles(v, "^[%w%-+_]+%.luau?$", `{CONFIGURATION.TEST_DIR}`)
	for i, v in testFiles do
		if RELATIVE_SINGLE_RUN and v.relativeName ~= RELATIVE_SINGLE_RUN then
			continue
		end
		local testInfo = RunTestFile(v)
		
		table.insert(results, testInfo)

		if not testInfo.passed then
			failed = true
			table.insert(testsFailed, testInfo)
		end
	end

	if #results > 0 then
		if not failed then
			print(`[{STATUS_SYMBOLS[2]}] {i}: {stdio.color("green")}All tests passed{stdio.color("reset")}`)
		else
			print(`[{STATUS_SYMBOLS[1]}] {i}: {stdio.color("red")}Some tests failed{stdio.color("reset")}`)
		end

		for _, testInfo in results do
			print(displayMessage(testInfo.result, testInfo.resstack, testInfo.passed and 2 or 1))
		end

		print('\n')
	end
end

if #testsFailed > 0 then
	print("Failed tests:")
	for i, v in testsFailed do
		print(displayMessage(v.file.relativePath, {}, 1))
	end
	process.exit(1)
end

print("All tests passed")
process.exit(0)