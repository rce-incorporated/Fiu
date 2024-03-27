# [Fiu](https://github.com/TheGreatSageEqualToHeaven/Fiu/blob/main/Source.lua)

Pronounced like "Phew". This software aims to provide a decently fast and reliable way of executing Luau bytecode under other Lua environments without the use of `loadstring`. For the purpose of anything from sandboxing to reimplementing arbitrary execution, this should serve your needs.

Fiu does not taint the environment if you pass it a table of functions or a wrapper around `getfenv` using `__index` so it should not deoptimise the environment.

Note that only an interpreter is provided, and compiled code must be obtained from some external source.

Fiu is in a working state but bugs and side effects can be encountered! Open an [issue](https://github.com/TheGreatSageEqualToHeaven/Fiu/issues) if you encounter any breaking issues.

**Vector constants are currently not supported!**

# Usage
Use `Source.lua` from the repository and set `FIU_DEBUGGING` to false at the top of the file.

- `luau_load(bytecode | chunk, env)` <div>Used to deserialise and interpret code at the same time, bytecode that has already been deserialised can also be passed.</div>
- `luau_deserialize(bytecode)` <div>Used to deserialise bytecode.</div>

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
- Contributed code should be consistent with the source.

<div>Luau updates often and Fiu will need to be updated and have working releases added for every new version.</div>  
  
### **Contributors**
  
[TheGreatSageEqualToHeaven](https://github.com/TheGreatSageEqualToHeaven/)  
[Rerumu](https://github.com/Rerumu/)  
[Green](https://github.com/green-real/)  
[SnorlaxAssist](https://github.com/Snorlaxassist)  
