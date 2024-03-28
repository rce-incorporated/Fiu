# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This interpreter aims to provide a decently fast and reliable way of executing Luau bytecode without the use of `loadstring`. 

Fiu does not taint the environment if you pass a table of functions or a wrapper around `getfenv` that does not taint Fiu's thread. Note that only an interpreter is provided, and compiled code must be obtained from an external source. While Fiu is in a working state, bugs and side effects can be encountered! Open an [issue](https://github.com/TheGreatSageEqualToHeaven/Fiu/issues) if you encounter any issues.

# Usage
Fiu can be downloaded from the [releases page](https://github.com/rce-incorporated/Fiu/releases) and the experimental version from [here](https://github.com/rce-incorporated/Fiu/tree/experimental).

- `luau_load(module | bytecode, env, settings?)` <div>Accepts a luau module or bytecode. Returns the main prototype wrapped and a `luau_close` function to kill the interpreter if needed.</div>
- `luau_deserialize(bytecode, settings?)` <div>Used to deserialise bytecode.</div>
- `luau_newsettings()` <div>Used to create a table of default settings.</div>
- `luau_validatesettings(settings)` <div>Used to validate the passed settings.</div>

## Settings

`vectorCtor` - Vector constructor function  
`vectorSize` - Vector size  
`useNativeNamecall` - Boolean to indicate if `namecallHandler` should be used  
`namecallHandler` - Function handler for native namecalling  
`extensions` - Table of injectable globals
`callHooks` - VM callback behaviour emulators  
`errorHandling` - Error handling by the VM for line information and opcode information  
`generalizedIteration` - Use generalized iteration in the VM  

### Vector constant support

Vector constants can be supported by setting `vectorCtor` and `vectorSize`. `vectorSize` can be 3 or 4, `vectorCtor` on Roblox would be `Vector3.new`.

### Native namecall support

Namecalling is impossible to support dynamically so in environments where only `__namecall` is implemented without `__index` you can define a `namecallHandler` and set `useNativeNamecall` to true. In the namecall handler you must return a boolean as the first return value. 

Example: 

```lua
luau_settings.namecallHandler = function(namecallMethod, self, ...)
    if namecallMethod == "FindFirstChild" then
        return true, self:FindFirstChild(...)
    end 

    return false
end
```

### Stack frame, running thread and errors

The interpreter can be accurate 1:1 to existing stack frames if `errorHandling` is disabled. 

Generalized iteration can also cause issues because it requires a new thread to be created so anything that gets iterated will go deeper in the C stack depth limit and `__iter` and `__call` will have a different thread when `coroutine.running` is called. If generialized iteration is disabled with `generializedIteration` `__call` will still function but `__iter` and iterating over tables without an iterator will no longer work.

Fiu cannot provide perfect errors, if `errorHandling` is enabled all errors are processed by Fiu and will be turned into strings if they are not. If you want to be able to error a table and then grab the table enable `allowProxyErrors` which will error the errored object again. Note that when `errorHandling` is disabled this behaviour is done by default because Fiu will not interfere with errors. 

### Injectable globals

The vm allows globals to be injected into the VM with `extensions`, these injected globals can never be deleted by the interpreter and any attempts will just result in environment globals being set to `nil`. 

Example:

```lua
luau_settings.extensions["foo"] = function()
    print('hello world!')
end
```

### VM callback behaviour

The Luau VM provides simple hooks to see into the VM at certain points, the Fiu VM emulates 4 of these callbacks. 

`breakHook(stack, debugging, proto, module, upvals)` - When a `LOP_BREAK`/breakpoint is encountered `breakHook` will be called  
`interruptHook(stack, debugging, proto, module, upvals)` - When a vm interrupt occurs the `interruptHook` will be called  
`panicHook(message, stack, debugging, proto, module, upvals)` - When an unprotected error occurs within the VM the `panicHook` will be called if `errorHandling` is enabled  
`stepHook(stack, debugging, proto, module, upvals)` - When a VM step (In Fiu, when the PC increases) occurs `stepHook` will be called  

Example:

```lua
settings.callHooks.stepHook = function(stack, debugging)
	print('step occured', debugging.name, debugging.pc)	
end
settings.callHooks.panicHook = function(message, stack, debugging)
	print(debugging.name, message)
	for i,v in stack do 
		print(i,v)
	end
end
settings.callHooks.interruptHook = function(stack, debugging)
	print(debugging.name, "interrupted!")
end
```
 
# Contributing

- Testing using GitHub Actions
  - Fork this repository, and commit your changes.
  - Commiting changes should automatically run tests with `GitHub Actions`.
  - Results would show for the commit.
- Testing locally(optional)
  - `fiu-tests` must be compiled using CMake, this is needed to run and debug tests.
    - Setup cmake tree with `cmake ./tests` or `cmake -DCMAKE_BUILD_TYPE=Release ./tests` for release tree.
    - Compile cmake tree with `cmake --build . --target=fiu-tests`.
  - Tests must be ran with `fiu-tests` executable compiled from cmake.
    - For specific test use `-t <file path>` or test the whole directory with `-tf <directory path>`, the paths are relative to `(workspaceRoot)/tests/`.

<div>Luau updates often and Fiu will need to be updated and have working releases added for every new bytecode version.</div>  
  
### Contributors
  
[TheGreatSageEqualToHeaven](https://github.com/TheGreatSageEqualToHeaven/)  
[Rerumu](https://github.com/Rerumu/)  
[Green](https://github.com/green-real/)  
[SnorlaxAssist](https://github.com/Snorlaxassist)  
