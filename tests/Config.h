#pragma once

#include <string>
#include <vector>
#include <map>

using namespace std;

#define STYLE_DIM "\x1b[2m"       // Dim the text
#define STYLE_BOLD "\x1b[1m"      // Bold/brighten the text
#define STYLE_RESET "\x1b[0m"     // Reset all styles to default

#define COLOR_BLACK "\x1b[30m"    // ANSI escape code for black
#define COLOR_RED "\033[1;31m"    // ANSI escape code for red
#define COLOR_GREEN "\033[1;32m"  // ANSI escape code for green
#define COLOR_YELLOW "\033[1;33m" // ANSI escape code for yellow
#define COLOR_BLUE "\x1b[34m"     // ANSI escape code for blue
#define COLOR_MAGENTA "\x1b[95m"  // ANSI escape code for bright magenta
#define COLOR_CYAN "\x1b[96m"     // ANSI escape code for bright cyan
#define COLOR_WHITE "\x1b[37m"    // ANSI escape code for white
#define COLOR_RESET "\033[1;0m"   // ANSI escape code to reset the color

#define ERROR_SYMBOL (COLOR_RED "X" COLOR_RESET)
#define WARN_SYMBOL (COLOR_YELLOW "-" COLOR_RESET)
#define SUCCESS_SYMBOL (COLOR_GREEN "+" COLOR_RESET)

#define FIU_TESTCASES map<string, vector<string>> TestCases =

#define FIU_EXPORT map<string, string> FiuExport =

// Enable/Disable Debugging Lua Context
bool DEBUG_LUAU_ENABLE_PRINT = false;
bool DEBUG_LUAU_ENABLE_WARN = false;

FIU_EXPORT {
	{"luau_newsettings", "function"},
	{"luau_validatesettings", "function"},
	{"luau_deserialize", "function"},
	{"luau_load", "function"}
};

FIU_TESTCASES {
	{"Conformance", {
		// Main FIU/Luau tests
		"Conformance/assert",
		"Conformance/attrib",
		"Conformance/basic",
		"Conformance/bitwise",
		"Conformance/buffers",
		"Conformance/calls",
		"Conformance/clear",
		"Conformance/constructs",
		"Conformance/coroutine",
		"Conformance/datetime",
		"Conformance/ifelseexpr",
		"Conformance/iter",
		"Conformance/literals",
		"Conformance/locals",
		"Conformance/math",
		"Conformance/move",
		"Conformance/pm",
		"Conformance/sort",
		"Conformance/strconv",
		"Conformance/stringinterp",
		"Conformance/strings",
		"Conformance/tables",
		"Conformance/tpack",
		"Conformance/utf8",
		"Conformance/vararg",

		// Instruction Specific Tests
		"Conformance/Instructions/Calls",
		"Conformance/Instructions/Constants",
		"Conformance/Instructions/DupClosure",
		"Conformance/Instructions/Lists",
		"Conformance/Instructions/Logic",
		"Conformance/Instructions/Loops",
		"Conformance/Instructions/Math",
		"Conformance/Instructions/NewClosure",
		"Conformance/Instructions/SetGet",
		"Conformance/Instructions/Strings",
		"Conformance/Instructions/UpValues",
		"Conformance/Instructions/Vararg",

		// Deserializer Specific Tests
		"Conformance/Deserializer/Instructions/Calls",
		"Conformance/Deserializer/Instructions/Constants",
		"Conformance/Deserializer/Instructions/DupClosure",
		"Conformance/Deserializer/Instructions/Lists",
		"Conformance/Deserializer/Instructions/Logic",
		"Conformance/Deserializer/Instructions/Loops",
		"Conformance/Deserializer/Instructions/Math",
		"Conformance/Deserializer/Instructions/NewClosure",
		"Conformance/Deserializer/Instructions/SetGet",
		"Conformance/Deserializer/Instructions/Strings",
		"Conformance/Deserializer/Instructions/UpValues",
		"Conformance/Deserializer/Instructions/Vararg",
	}},
	{"Staging", {
		// Fiu Repository Issue Tests
		"Staging/Issues/4",
		"Staging/Issues/5",
		"Staging/Issues/14",
		"Staging/Issues/16",
		"Staging/Issues/34",

		// Original FIU tests
		"Staging/AndOr",
		"Staging/AndOrK",
		"Staging/Arit",
		"Staging/AritK",
		"Staging/BasicJump",
		"Staging/Booleans",
		"Staging/BufferIssue",
		"Staging/CLOSE",
		"Staging/Closure",
		"Staging/Concat",
		"Staging/Conditions",
		"Staging/DupTableSetList",
		"Staging/ForLoops",
		"Staging/FunctionIssue",
		"Staging/GenericFor",
		"Staging/Globals",
		"Staging/HelloWorld",
		"Staging/LOADN",
		"Staging/LOADNIL",
		"Staging/Namecall",
		"Staging/Returns",
		"Staging/Tables",
		"Staging/Unary",
		"Staging/Varargs",
		"Staging/WhileRepeat",
	}},
	{"Specs", {
		// Fiu Spec Tests
		"Specs/CallHooks/breakHook",
		"Specs/CallHooks/interruptHook",
		"Specs/CallHooks/panicHook",
		"Specs/CallHooks/stepHook",
		"Specs/extensions",
		"Specs/nativeNamecall",
		"Specs/vectorLib",
		"Specs/importConstants",
		"Specs/decodeOp",
		"Specs/coverage",
	}},
	{"Benchmarks", {
		// Fiu Benchmark Tests
		"Benchmarks/Speeds/closure",
		"Benchmarks/Speeds/table",
		"Benchmarks/maxcstack",
	}}
};
