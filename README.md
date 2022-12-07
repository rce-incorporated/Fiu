# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This software aims to provide a decently fast and reliable way of executing Luau bytecode under other Lua environments without the use of `loadstring`. For the purpose of anything from sandboxing to reimplementing arbitrary execution, this should serve your needs.

Note that only an interpreter is provided, and compiled code must be obtained from some external source.

### Unfinished

What's missing/not working?
- [ ] Some `for` loop operations
- [ ] Vararg operations
- [ ] Some missing operations (LOADKX, FORGLOOP_INEXT, etc)

**BUGS**
- [ ] generic `for` loop table structure is incorrect | See "ForLoops" test
- [ ] Namecall table argument does not get passed | See "Namecall" test

# Contributing

- Tests can be added and compiled using CreateTests.lua, Lua with the `io` and `os` library is needed.
- Tests must be ran with Luau using `RunTests.lua`, you can use `allTests` or `specificTests`.
- Contributed code should be consistent with the source.

<div>Luau updates often and Fiu will need to be updated and have working releases added for every new version.</div>
