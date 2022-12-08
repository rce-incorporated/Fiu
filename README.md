# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This software aims to provide a decently fast and reliable way of executing Luau bytecode under other Lua environments without the use of `loadstring`. For the purpose of anything from sandboxing to reimplementing arbitrary execution, this should serve your needs.

Note that only an interpreter is provided, and compiled code must be obtained from some external source.

Fiu is in a working state but bugs and side effects can be encountered! Open an [issue](https://github.com/TheGreatSageEqualToHeaven/Fiu/issues) if you encounter any breaking issues.

# Contributing

- Tests can be added and compiled using CreateTests.lua, Lua with the `io` and `os` library is needed.
- Tests must be ran with Luau using `RunTests.lua`, you can use `allTests` or `specificTests`.
- Contributed code should be consistent with the source.

<div>Luau updates often and Fiu will need to be updated and have working releases added for every new version.</div>
