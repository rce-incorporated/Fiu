# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This software aims to provide a decently fast and reliable way of executing Luau bytecode under other Lua environments without the use of `loadstring`. For the purpose of anything from sandboxing to reimplementing arbitrary execution, this should serve your needs.

Note that only an interpreter is provided, and compiled code must be obtained from some external source.

### Unfinished

What's missing/not working?
- [ ] Some `for` loop operations
- [ ] Vararg operations
- [ ] For loop table structure is incorrect
- [ ] Namecall table argument does not get passed
