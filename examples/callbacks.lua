local luau_settings = luau_newsettings()

luau_settings.callHooks.interruptHook = function(stack, debugging, proto, module, upvals)
	print("Interrupted: ", debugging.name)
	print("Previous Instruction: ", proto.code[debugging.pc-2].opname)
	print("Next Instruction: ", proto.code[debugging.pc+1].opname)
	
	stack[proto.code[debugging.pc+1].A] = function() error("This function was placed by the interrupt hook!") end
end

luau_settings.callHooks.stepHook = function(stack, debugging, proto, module, upvals)
	print("Step occured!", debugging.name, debugging.pc)
end

luau_settings.callHooks.panicHook = function(message, stack, debugging, proto, module, upvals)
	print("VM Panic: ", message)
end

local luau_execute = luau_load("\5\1\1\5\109\97\99\114\111\1\1\0\0\1\2\0\5\65\0\0\0\12\0\1\0\0\0\0\64\21\0\1\1\22\0\1\0\2\3\1\4\0\0\0\64\0\1\0\1\24\0\0\0\0\1\1\0\0\0\0\0", {}, luau_settings)
luau_execute()
