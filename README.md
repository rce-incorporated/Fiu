# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This software aims to provide a decently fast and reliable way of executing Luau bytecode under other Lua environments without the use of `loadstring`. For the purpose of anything from sandboxing to reimplementing arbitrary execution, this should serve your needs.

Note that only an interpreter is provided, and compiled code must be obtained from some external source.

Fiu is in a working state but bugs and side effects can be encountered! Open an [issue](https://github.com/TheGreatSageEqualToHeaven/Fiu/issues) if you encounter any breaking issues.

# Usage
If you are going to use `Source.lua` on the repository instead of the [releases](https://github.com/TheGreatSageEqualToHeaven/Fiu/releases) you will need to set `FIU_DEBUGGING` to false at the top of the file

`luau_load` <div>can be used to deserialise and interpret code at the same time, bytecode that has already been deserialised can also be passed.</div>
`luau_deserialize` <div>can be used to deserialise bytecode.</div>

`luau_newproto` <div>can be used to build your own prototype.</div>
`luau_newmodule` <div>can be used to build your own module.</div>

# Contributing

- Tests can be added and compiled using CreateTests.lua, Lua with the `io` and `os` library is needed.
- Tests must be ran with Luau using `RunTests.lua`, you can use `allTests` or `specificTests`.
- Contributed code should be consistent with the source.

<div>Luau updates often and Fiu will need to be updated and have working releases added for every new version.</div>
