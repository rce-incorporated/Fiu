cmake_minimum_required(VERSION 3.20)
project(fiu-tests LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 14)

option(LUAU_BUILD_CLI "Build CLI" OFF)
option(LUAU_BUILD_TESTS "Build tests" OFF)
option(LUAU_BUILD_WEB "Build Web module" OFF)
option(LUAU_WERROR "Warnings as errors" OFF)
option(LUAU_STATIC_CRT "Link with the static CRT (/MT)" OFF)
add_subdirectory(luau)

add_library(Luau.Fiu.CLI STATIC
  luau/CLI/Coverage.h
  luau/CLI/Coverage.cpp
  luau/CLI/FileUtils.h
  luau/CLI/FileUtils.cpp
  luau/CLI/Flags.h
  luau/CLI/Flags.cpp
  luau/CLI/Profiler.h
  luau/CLI/Profiler.cpp
  luau/CLI/Require.h
  luau/CLI/Require.cpp
)
target_link_libraries(Luau.Fiu.CLI Luau.VM)
target_link_libraries(Luau.Fiu.CLI Luau.Common)
target_link_libraries(Luau.Fiu.CLI Luau.Config)

add_executable(fiu-tests
  Utils/uformat.h

  Config.h

  main.cpp
)

target_link_libraries(fiu-tests Luau.Fiu.CLI)

# Luau Core Components
target_link_libraries(fiu-tests Luau.Compiler)
target_link_libraries(fiu-tests Luau.CodeGen)
target_link_libraries(fiu-tests isocline)