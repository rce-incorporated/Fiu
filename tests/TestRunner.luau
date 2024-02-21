local fs = require("@lune/fs")
local luau = require("@lune/luau")
local task = require("@lune/task")
local stdio = require("@lune/stdio")
local process = require("@lune/process")

local Files = require("Utils/Files")
local Enviroment = require("Utils/Enviroment")

-- Fiu
local fiu = require("../Source")

local CONFIGURATION = require("Config")

local STATUS_SYMBOLS = {
	`{stdio.color("red")}X{stdio.color("reset")}`,
	`{stdio.color("green")}✔{stdio.color("reset")}`
}

local PROCESS_OPTIONS = {} do
	for _, arg in process.args do
		local name, value = arg:match("^(%w+)=(.+)$")
		if name then
			PROCESS_OPTIONS[name] = value
		end
	end
end

CONFIGURATION.DEBUGGING = PROCESS_OPTIONS.debug and tonumber(PROCESS_OPTIONS.debug) or CONFIGURATION.DEBUGGING
CONFIGURATION.DEBUGGING_LEVEL = PROCESS_OPTIONS.debuglevel and tonumber(PROCESS_OPTIONS.debuglevel) or CONFIGURATION.DEBUGGING_LEVEL
local RELATIVE_SINGLE_RUN = PROCESS_OPTIONS.test;

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

for i, v in CONFIGURATION.TESTS do
	assert(fs.isDir(v), `{i}: [{v}] directory not found`)
end

local RUNTIME_ENV = getfenv();

local function tableCopyMerge(target, source)
	local copy = table.clone(target);
	for i, v in source do
		copy[i] = v
	end
	return copy;
end

local function canDebug(executor : number)
	return CONFIGURATION.DEBUGGING == 3 or CONFIGURATION.DEBUGGING == executor
end

local function tassert(cond, msg, stack, test_info, thread)
	if not cond then
		test_info.passed = false
		test_info.result = msg
		for i, v in stack do
			table.insert(test_info.resstack, v)
		end
		coroutine.resume(thread)
		coroutine.yield()
	end
end

local gen_temp_env = {
	task = task,
	print = function() end,
}

local fiu_env
local luau_env

fiu_env = Enviroment.new(tableCopyMerge(gen_temp_env, {
	loadstring = function(str : string)
		local ok, bytecode = pcall(luau.compile, str, bytecode_compilation_options)
		if not ok then
			error(tostring(bytecode))
		end
		local env = getfenv(2);
		return setfenv(fiu.luau_load(bytecode, env), env)
	end
}), RUNTIME_ENV)

luau_env = Enviroment.new(tableCopyMerge(gen_temp_env, {
	loadstring = function(str : string)
		local ok, bytecode = pcall(luau.compile, str, bytecode_compilation_options)
		if not ok then
			error(tostring(bytecode))
		end
		local env = getfenv(2);
		return setfenv(luau.load(bytecode, { debugName = "loadstring" }), env)
	end
}), RUNTIME_ENV)

local function filterErrorMessage(msg : string)
	local str, _ = msg:gsub(".+:%d+:(.+)", "%1");
	return str
end

local function displayMessage(msg : string, stack : {string}, status : number)
	local stack_size = #stack;
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
	local file_name = file.relativeName;
	local test_info = {
		stage = 0,
		passed = false,
		result = nil,
		resstack = {},
		file = file,
	};
	
	local thread = coroutine.running()
	local timeout
	timeout = task.delay(7, function()
		timeout = nil
		test_info.passed = false
		test_info.result = `Test [{file_name}]: Failed (Timed out) at stage {STAGES[test_info.stage]}`
		coroutine.resume(thread)
	end)

	local info_print = function(vm : number, ...)
		if not canDebug(vm) then
			return
		end
		local args = {...}
		for i, v in args do
			args[i] = tostring(v)
		end
		table.insert(test_info.resstack, `+ [{stdio.color("blue")}PRINT{stdio.color("reset")}] {table.concat(args, "\t")}`)
	end

	local info_warn = function(vm : number, ...)
		if not canDebug(vm) then
			return
		end
		local args = {...}
		for i, v in args do
			args[i] = tostring(v)
		end
		table.insert(test_info.resstack, `+ [{stdio.color("yellow")}WARN{stdio.color("reset")}] {table.concat(args, "\t")}`)
	end

	local context_screening = {}
	local info_create = function(vm : number, debugid : number, info_writer : (vm : number, ...any) -> ()) : (...any) -> ()
		return function(...)
			if not canDebug(vm) or (CONFIGURATION.DEBUGGING_LEVEL ~= debugid and CONFIGURATION.DEBUGGING_LEVEL ~= 3) then
				return
			end
			if (not context_screening[vm]) then
				table.insert(test_info.resstack, `[{VM_NAMES[vm]}]`)
				context_screening[vm] = true
			end
			info_writer(vm, ...)
		end
	end

	local TEMP_FIU_ENV = fiu_env:construct();
	local TEMP_LUAU_ENV = luau_env:construct();

	TEMP_FIU_ENV.print = info_create(VM_NAMES.Fiu, 1, info_print)
	TEMP_LUAU_ENV.print = info_create(VM_NAMES.Luau, 1, info_print)
	
	TEMP_FIU_ENV.warn = info_create(VM_NAMES.Fiu, 2, info_warn)
	TEMP_LUAU_ENV.warn = info_create(VM_NAMES.Luau, 2, info_warn)

	task.spawn(function()
		local source = fs.readFile(file.path)
		local bytecode = luau.compile(source, bytecode_compilation_options)
		
		test_info.stage = 1
		local fiu_deserialize_suc, fiu_deserialize_ret = pcall(fiu.luau_load, bytecode, TEMP_FIU_ENV)

		test_info.stage = 2
		local luau_deserialize_suc, luau_deserialize_ret = pcall(luau.load, bytecode, { debugName = file.relativePath, environment = TEMP_LUAU_ENV })

		tassert(
			luau_deserialize_suc,
			`Test [{file_name}]: Luau failed to deserialize`, {
				`Luau: {luau_deserialize_ret}`
			},
			test_info, thread
		)

		tassert(
			fiu_deserialize_suc,
			`Test [{file_name}]: Fiu failed to deserialize`, {
				`Fiu: {fiu_deserialize_ret}`
			},
			test_info, thread
		)

		test_info.stage = 3
		setfenv(fiu_deserialize_ret, TEMP_FIU_ENV)
		local fiu_suc, fiu_ret = pcall(fiu_deserialize_ret)

		test_info.stage = 4
		setfenv(luau_deserialize_ret, TEMP_LUAU_ENV)
		local luau_suc, luau_ret = pcall(luau_deserialize_ret)

		test_info.stage = 5
		tassert(
			fiu_suc and luau_suc,
			`Test [{file_name}]: Failed to execute`, {
				not luau_suc and `Luau: {luau_ret}` or nil,
				not fiu_suc and `Fiu: {fiu_ret}` or nil
			},
			test_info, thread
		)

		test_info.passed = true
		test_info.result = `Test [{file_name}]: Passed`

		coroutine.resume(thread)
	end)

	coroutine.yield()

	if timeout then
		task.cancel(timeout)
	end

	table.freeze(test_info);

	return test_info;
end

local tests_failed = {};

for i, v in CONFIGURATION.TESTS do
	local failed = false
	local results = {}
	local test_files = Files.getFiles(v, "^[%w%-+_]+%.luau?$", `{CONFIGURATION.TEST_DIR}`)
	for i, v in test_files do
		if (RELATIVE_SINGLE_RUN and v.relativeName ~= RELATIVE_SINGLE_RUN) then
			continue
		end
		local test_info = RunTestFile(v)
		
		table.insert(results, test_info)

		if not test_info.passed then
			failed = true
			table.insert(tests_failed, test_info)
		end
	end

	if not failed then
		print(`[{STATUS_SYMBOLS[2]}] {i}: {stdio.color("green")}All tests passed{stdio.color("reset")}`)
	else
		print(`[{STATUS_SYMBOLS[1]}] {i}: {stdio.color("red")}Some tests failed{stdio.color("reset")}`)
	end

	for _, test_info in results do
		print(displayMessage(test_info.result, test_info.resstack, test_info.passed and 2 or 1))
	end

	print()
	print()
	
end

if #tests_failed > 0 then
	print("Failed tests:");
	for i, v in tests_failed do
		print(displayMessage(v.file.relativePath, {}, 1))
	end
	process.exit(1);
end

print("All tests passed")
process.exit(0);