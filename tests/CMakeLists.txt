cmake_minimum_required(VERSION 3.20)
project(fiu-tests LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 14)

option(LUAU_BUILD_CLI "Build CLI" OFF)
option(LUAU_BUILD_TESTS "Build tests" OFF)
option(LUAU_BUILD_WEB "Build Web module" OFF)
option(LUAU_WERROR "Warnings as errors" OFF)
option(LUAU_STATIC_CRT "Link with the static CRT (/MT)" OFF)
add_subdirectory(luau)

add_executable(fiu-tests
  luau/CLI/src/Coverage.cpp
  Utils/Formatter.h
  Utils/Context.h
  Utils/Fiu.h

  Config.h

  main.cpp
)

target_link_libraries(fiu-tests Luau.CLI.lib)
target_link_libraries(fiu-tests Luau.VM)

# Luau Core Components
target_link_libraries(fiu-tests Luau.Compiler)
target_link_libraries(fiu-tests Luau.CodeGen)
target_link_libraries(fiu-tests isocline)
