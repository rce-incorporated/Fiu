// local DEBUG_OPTIONS = { OFF = 0, Fiu = 1, LUAU = 2, ALL = 3 }
// local DEBUG_LEVEL = { PRINT = 1, WARN = 2, ALL = 3, IO_STREAM = 4}

// local TEST_DIR = "tests"

// return {
// 	TEST_DIR = TEST_DIR,
// 	TESTS = {
// 		Conformance = `{TEST_DIR}/Conformance`,
// 		Staging = `{TEST_DIR}/Staging`,
// 	},
// 	DEBUGGING = DEBUG_OPTIONS.ALL,
// 	DEBUGGING_LEVEL = DEBUG_LEVEL.WARN,
// }
#include <string>
#include <vector>
#include <map>

#define COLOR_RED "\033[1;31m"    // ANSI escape code for red
#define COLOR_GREEN "\033[1;32m"  // ANSI escape code for green
#define COLOR_YELLOW "\033[1;33m" // ANSI escape code for yellow
#define COLOR_RESET "\033[1;0m"   // ANSI escape code to reset the color

#define ERROR_SYMBOL (COLOR_RED "X" COLOR_RESET)
#define SUCCESS_SYMBOL (COLOR_GREEN "+" COLOR_RESET)

#define FIU_TESTCASES std::map<std::string, std::vector<std::string>> TestCases =

#define FIU_EXPORT std::map<std::string, std::string> FiuExport =

#define DEBUG_LUAU_ENABLE_PRINT 0
bool FIU_DEBUG_LUAU_ENABLE_PRINT = DEBUG_LUAU_ENABLE_PRINT;
#define DEBUG_LUAU_ENABLE_WARN 0
bool FIU_DEBUG_LUAU_ENABLE_WARN = DEBUG_LUAU_ENABLE_WARN;

FIU_TESTCASES {
	{"Conformance", {
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

		// Original FIU tests
		"Conformance/attrib",
		"Conformance/basic",
		"Conformance/bitwise",
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
		"Conformance/typed",
		"Conformance/utf8",
		"Conformance/vararg"
	}},
	{"Staging", {
		// Fiu Repository Issue Tests
		"Staging/Issues/4",
		"Staging/Issues/5",
		"Staging/Issues/14",
		"Staging/Issues/16",

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
		"Staging/GetImportSpecial",
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
	}}
};

FIU_EXPORT {
	{"luau_load", "function"},
	{"luau_deserialize", "function"}
};