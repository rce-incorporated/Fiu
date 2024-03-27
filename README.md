# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This interpreter aims to provide a decently fast and reliable way of executing Luau bytecode without the use of `loadstring`. 

Fiu does not taint the environment if you pass a table of functions or a wrapper around `getfenv` that does not taint Fiu's thread. Note that only an interpreter is provided, and compiled code must be obtained from an external source. While Fiu is in a working state but bugs and side effects can be encountered! Open an [issue](https://github.com/TheGreatSageEqualToHeaven/Fiu/issues) if you encounter any breaking issues.

# Usage
Use `Source.lua` from the repository and set `FIU_DEBUGGING` to false at the top of the file.

- `luau_load(bytecode | chunk, env)` <div>Used to deserialise and interpret code at the same time, bytecode that has already been deserialised can also be passed.</div>
- `luau_deserialize(bytecode)` <div>Used to deserialise bytecode.</div>

# Contributing

- Tests can be added and compiled using CreateTests.lua, Lua with the `io` and `os` library is needed.
- Tests must be ran with Luau using `RunTests.lua`, you can use `allTests` or `specificTests`.
- Contributed code should be consistent with the source.

<div>Luau updates often and Fiu will need to be updated and have working releases added for every new bytecode version.</div>  
  
### **Contributors**
  
[TheGreatSageEqualToHeaven](https://github.com/TheGreatSageEqualToHeaven/)  
[Rerumu](https://github.com/Rerumu/)  
[Green](https://github.com/green-real/)  
[SnorlaxAssist](https://github.com/Snorlaxassist)  
