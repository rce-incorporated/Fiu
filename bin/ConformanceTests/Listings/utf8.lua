--[====[Generated by CreateTests.lua]====]
return function()
	return [[Function 0 (checkerror):
    6:   local s, err = pcall(f, ...)
GETIMPORT R2 1 [pcall]
MOVE R3 R1
GETVARARGS R4 -1
CALL R2 -1 2
REMARK builtin assert/1
    7:   assert(not s and string.find(err, msg))
NOT R5 R2
JUMPIFNOT R5 L0
GETIMPORT R5 4 [string.find]
MOVE R6 R3
MOVE R7 R0
CALL R5 2 1
L0: FASTCALL1 1 R5 L1
GETIMPORT R4 6 [assert]
CALL R4 1 0
    8: end
L1: RETURN R0 0

Function 1 (len):
   12:   return #string.gsub(s, "[\x80-\xBF]", "")
GETIMPORT R2 2 [string.gsub]
MOVE R3 R0
LOADK R4 K3 ['[�-�]']
LOADK R5 K4 ['']
CALL R2 3 1
LENGTH R1 R2
RETURN R1 1

Function 2 (check):
   24:   local l = utf8.len(s, 1, -1, nonstrict)
GETIMPORT R3 2 [utf8.len]
MOVE R4 R0
LOADN R5 1
LOADN R6 -1
MOVE R7 R2
CALL R3 4 1
REMARK builtin assert/1
   25:   assert(#t == l and len(s) == l)
LOADB R5 0
LENGTH R6 R1
JUMPIFNOTEQ R6 R3 L1
GETUPVAL R6 0
MOVE R7 R0
CALL R6 1 1
JUMPIFEQ R6 R3 L0
LOADB R5 0 +1
L0: LOADB R5 1
L1: FASTCALL1 1 R5 L2
GETIMPORT R4 4 [assert]
CALL R4 1 0
REMARK builtin assert/1
   26:   assert(utf8.char(table.unpack(t)) == s)   -- 't' and 's' are equivalent
L2: GETIMPORT R6 6 [utf8.char]
REMARK builtin table.unpack/1
FASTCALL1 53 R1 L3
MOVE R8 R1
GETIMPORT R7 9 [table.unpack]
CALL R7 1 -1
L3: CALL R6 -1 1
JUMPIFEQ R6 R0 L4
LOADB R5 0 +1
L4: LOADB R5 1
L5: FASTCALL1 1 R5 L6
GETIMPORT R4 4 [assert]
CALL R4 1 0
REMARK builtin assert/1
   28:   assert(utf8.offset(s, 0) == 1)
L6: GETIMPORT R6 11 [utf8.offset]
MOVE R7 R0
LOADN R8 0
CALL R6 2 1
JUMPXEQKN R6 K12 L7 [1]
LOADB R5 0 +1
L7: LOADB R5 1
L8: FASTCALL1 1 R5 L9
GETIMPORT R4 4 [assert]
CALL R4 1 0
REMARK allocation: table array 1
   31:   local t1 = {utf8.codepoint(s, 1, -1, nonstrict)}
L9: NEWTABLE R4 0 1
GETIMPORT R5 14 [utf8.codepoint]
MOVE R6 R0
LOADN R7 1
LOADN R8 -1
MOVE R9 R2
CALL R5 4 -1
SETLIST R4 R5 -1 [1]
REMARK builtin assert/1
   32:   assert(#t == #t1)
LENGTH R7 R1
LENGTH R8 R4
JUMPIFEQ R7 R8 L10
LOADB R6 0 +1
L10: LOADB R6 1
L11: FASTCALL1 1 R6 L12
GETIMPORT R5 4 [assert]
CALL R5 1 0
   33:   for i = 1, #t do assert(t[i] == t1[i]) end   -- 't' is equal to 't1'
L12: LOADN R7 1
LENGTH R5 R1
LOADN R6 1
FORNPREP R5 L17
REMARK builtin assert/1
L13: GETTABLE R10 R1 R7
GETTABLE R11 R4 R7
JUMPIFEQ R10 R11 L14
LOADB R9 0 +1
L14: LOADB R9 1
L15: FASTCALL1 1 R9 L16
GETIMPORT R8 4 [assert]
CALL R8 1 0
L16: FORNLOOP R5 L13
   35:   for i = 1, l do   -- for all codepoints
L17: LOADN R7 1
MOVE R5 R3
LOADN R6 1
FORNPREP R5 L53
   36:     local pi = utf8.offset(s, i)        -- position of i-th char
L18: GETIMPORT R8 11 [utf8.offset]
MOVE R9 R0
MOVE R10 R7
CALL R8 2 1
   37:     local pi1 = utf8.offset(s, 2, pi)   -- position of next char
GETIMPORT R9 11 [utf8.offset]
MOVE R10 R0
LOADN R11 2
MOVE R12 R8
CALL R9 3 1
REMARK builtin assert/1+
   38:     assert(string.find(string.sub(s, pi, pi1 - 1), justone))
GETIMPORT R11 17 [string.find]
REMARK builtin string.sub/3
MOVE R13 R0
MOVE R14 R8
SUBK R15 R9 K12 [1]
FASTCALL 45 L19
GETIMPORT R12 19 [string.sub]
CALL R12 3 1
L19: GETUPVAL R13 1
CALL R11 2 -1
FASTCALL 1 L20
GETIMPORT R10 4 [assert]
CALL R10 -1 0
REMARK builtin assert/1
   39:     assert(utf8.offset(s, -1, pi1) == pi)
L20: GETIMPORT R12 11 [utf8.offset]
MOVE R13 R0
LOADN R14 -1
MOVE R15 R9
CALL R12 3 1
JUMPIFEQ R12 R8 L21
LOADB R11 0 +1
L21: LOADB R11 1
L22: FASTCALL1 1 R11 L23
GETIMPORT R10 4 [assert]
CALL R10 1 0
REMARK builtin assert/1
   40:     assert(utf8.offset(s, i - l - 1) == pi)
L23: GETIMPORT R12 11 [utf8.offset]
MOVE R13 R0
SUB R15 R7 R3
SUBK R14 R15 K12 [1]
CALL R12 2 1
JUMPIFEQ R12 R8 L24
LOADB R11 0 +1
L24: LOADB R11 1
L25: FASTCALL1 1 R11 L26
GETIMPORT R10 4 [assert]
CALL R10 1 0
REMARK builtin assert/1
   41:     assert(pi1 - pi == #utf8.char(utf8.codepoint(s, pi, pi, nonstrict)))
L26: SUB R12 R9 R8
GETIMPORT R14 6 [utf8.char]
GETIMPORT R15 14 [utf8.codepoint]
MOVE R16 R0
MOVE R17 R8
MOVE R18 R8
MOVE R19 R2
CALL R15 4 -1
CALL R14 -1 1
LENGTH R13 R14
JUMPIFEQ R12 R13 L27
LOADB R11 0 +1
L27: LOADB R11 1
L28: FASTCALL1 1 R11 L29
GETIMPORT R10 4 [assert]
CALL R10 1 0
   42:     for j = pi, pi1 - 1 do
L29: MOVE R12 R8
SUBK R10 R9 K12 [1]
LOADN R11 1
FORNPREP R10 L34
REMARK builtin assert/1
   43:       assert(utf8.offset(s, 0, j) == pi)
L30: GETIMPORT R15 11 [utf8.offset]
MOVE R16 R0
LOADN R17 0
MOVE R18 R12
CALL R15 3 1
JUMPIFEQ R15 R8 L31
LOADB R14 0 +1
L31: LOADB R14 1
L32: FASTCALL1 1 R14 L33
GETIMPORT R13 4 [assert]
CALL R13 1 0
   42:     for j = pi, pi1 - 1 do
L33: FORNLOOP R10 L30
   45:     for j = pi + 1, pi1 - 1 do
L34: ADDK R12 R8 K12 [1]
SUBK R10 R9 K12 [1]
LOADN R11 1
FORNPREP R10 L37
REMARK builtin assert/1
   46:       assert(not utf8.len(s, j))
L35: GETIMPORT R15 2 [utf8.len]
MOVE R16 R0
MOVE R17 R12
CALL R15 2 1
NOT R14 R15
FASTCALL1 1 R14 L36
GETIMPORT R13 4 [assert]
CALL R13 1 0
   45:     for j = pi + 1, pi1 - 1 do
L36: FORNLOOP R10 L35
REMARK builtin assert/1
   48:    assert(utf8.len(s, pi, pi, nonstrict) == 1)
L37: GETIMPORT R12 2 [utf8.len]
MOVE R13 R0
MOVE R14 R8
MOVE R15 R8
MOVE R16 R2
CALL R12 4 1
JUMPXEQKN R12 K12 L38 [1]
LOADB R11 0 +1
L38: LOADB R11 1
L39: FASTCALL1 1 R11 L40
GETIMPORT R10 4 [assert]
CALL R10 1 0
REMARK builtin assert/1
   49:    assert(utf8.len(s, pi, pi1 - 1, nonstrict) == 1)
L40: GETIMPORT R12 2 [utf8.len]
MOVE R13 R0
MOVE R14 R8
SUBK R15 R9 K12 [1]
MOVE R16 R2
CALL R12 4 1
JUMPXEQKN R12 K12 L41 [1]
LOADB R11 0 +1
L41: LOADB R11 1
L42: FASTCALL1 1 R11 L43
GETIMPORT R10 4 [assert]
CALL R10 1 0
REMARK builtin assert/1
   50:    assert(utf8.len(s, pi, -1, nonstrict) == l - i + 1)
L43: GETIMPORT R12 2 [utf8.len]
MOVE R13 R0
MOVE R14 R8
LOADN R15 -1
MOVE R16 R2
CALL R12 4 1
SUB R14 R3 R7
ADDK R13 R14 K12 [1]
JUMPIFEQ R12 R13 L44
LOADB R11 0 +1
L44: LOADB R11 1
L45: FASTCALL1 1 R11 L46
GETIMPORT R10 4 [assert]
CALL R10 1 0
REMARK builtin assert/1
   51:    assert(utf8.len(s, pi1, -1, nonstrict) == l - i)
L46: GETIMPORT R12 2 [utf8.len]
MOVE R13 R0
MOVE R14 R9
LOADN R15 -1
MOVE R16 R2
CALL R12 4 1
SUB R13 R3 R7
JUMPIFEQ R12 R13 L47
LOADB R11 0 +1
L47: LOADB R11 1
L48: FASTCALL1 1 R11 L49
GETIMPORT R10 4 [assert]
CALL R10 1 0
REMARK builtin assert/1
   52:    assert(utf8.len(s, 1, pi, nonstrict) == i)
L49: GETIMPORT R12 2 [utf8.len]
MOVE R13 R0
LOADN R14 1
MOVE R15 R8
MOVE R16 R2
CALL R12 4 1
JUMPIFEQ R12 R7 L50
LOADB R11 0 +1
L50: LOADB R11 1
L51: FASTCALL1 1 R11 L52
GETIMPORT R10 4 [assert]
CALL R10 1 0
   35:   for i = 1, l do   -- for all codepoints
L52: FORNLOOP R5 L18
   55:   local i = 0
L53: LOADN R5 0
   56:   for p, c in utf8.codes(s, nonstrict) do
GETIMPORT R6 21 [utf8.codes]
MOVE R7 R0
MOVE R8 R2
CALL R6 2 3
FORGPREP R6 L60
   57:     i = i + 1
L54: ADDK R5 R5 K12 [1]
REMARK builtin assert/1
   58:     assert(c == t[i] and p == utf8.offset(s, i))
LOADB R12 0
GETTABLE R13 R1 R5
JUMPIFNOTEQ R10 R13 L56
GETIMPORT R13 11 [utf8.offset]
MOVE R14 R0
MOVE R15 R5
CALL R13 2 1
JUMPIFEQ R9 R13 L55
LOADB R12 0 +1
L55: LOADB R12 1
L56: FASTCALL1 1 R12 L57
GETIMPORT R11 4 [assert]
CALL R11 1 0
REMARK builtin assert/1
   59:     assert(utf8.codepoint(s, p, p, nonstrict) == c)
L57: GETIMPORT R13 14 [utf8.codepoint]
MOVE R14 R0
MOVE R15 R9
MOVE R16 R9
MOVE R17 R2
CALL R13 4 1
JUMPIFEQ R13 R10 L58
LOADB R12 0 +1
L58: LOADB R12 1
L59: FASTCALL1 1 R12 L60
GETIMPORT R11 4 [assert]
CALL R11 1 0
   56:   for p, c in utf8.codes(s, nonstrict) do
L60: FORGLOOP R6 L54 2
REMARK builtin assert/1
   61:   assert(i == #t)
LENGTH R8 R1
JUMPIFEQ R5 R8 L61
LOADB R7 0 +1
L61: LOADB R7 1
L62: FASTCALL1 1 R7 L63
GETIMPORT R6 4 [assert]
CALL R6 1 0
   63:   i = 0
L63: LOADN R5 0
   64:   for c in string.gmatch(s, utf8.charpattern) do
GETIMPORT R6 23 [string.gmatch]
MOVE R7 R0
GETIMPORT R8 25 [utf8.charpattern]
CALL R6 2 3
FORGPREP R6 L67
   65:     i = i + 1
L64: ADDK R5 R5 K12 [1]
REMARK builtin assert/1
   66:     assert(c == utf8.char(t[i]))
GETIMPORT R13 6 [utf8.char]
GETTABLE R14 R1 R5
CALL R13 1 1
JUMPIFEQ R9 R13 L65
LOADB R12 0 +1
L65: LOADB R12 1
L66: FASTCALL1 1 R12 L67
GETIMPORT R11 4 [assert]
CALL R11 1 0
   64:   for c in string.gmatch(s, utf8.charpattern) do
L67: FORGLOOP R6 L64 1
REMARK builtin assert/1
   68:   assert(i == #t)
LENGTH R8 R1
JUMPIFEQ R5 R8 L68
LOADB R7 0 +1
L68: LOADB R7 1
L69: FASTCALL1 1 R7 L70
GETIMPORT R6 4 [assert]
CALL R6 1 0
   70:   for i = 1, l do
L70: LOADN R8 1
MOVE R6 R3
LOADN R7 1
FORNPREP R6 L75
REMARK builtin assert/1
   71:     assert(utf8.offset(s, i) == utf8.offset(s, i - l - 1, #s + 1))
L71: GETIMPORT R11 11 [utf8.offset]
MOVE R12 R0
MOVE R13 R8
CALL R11 2 1
GETIMPORT R12 11 [utf8.offset]
MOVE R13 R0
SUB R15 R8 R3
SUBK R14 R15 K12 [1]
LENGTH R16 R0
ADDK R15 R16 K12 [1]
CALL R12 3 1
JUMPIFEQ R11 R12 L72
LOADB R10 0 +1
L72: LOADB R10 1
L73: FASTCALL1 1 R10 L74
GETIMPORT R9 4 [assert]
CALL R9 1 0
   70:   for i = 1, l do
L74: FORNLOOP R6 L71
   74: end
L75: RETURN R0 0

Function 3 (check):
   79:     local a, b = utf8.len(s)
GETIMPORT R2 2 [utf8.len]
MOVE R3 R0
CALL R2 1 2
REMARK builtin assert/1
   80:     assert(not a and b == p)
NOT R5 R2
JUMPIFNOT R5 L1
JUMPIFEQ R3 R1 L0
LOADB R5 0 +1
L0: LOADB R5 1
L1: FASTCALL1 1 R5 L2
GETIMPORT R4 4 [assert]
CALL R4 1 0
   81:   end
L2: RETURN R0 0

Function 4 (??):
   93:         for c in utf8.codes(s) do assert(c) end
GETIMPORT R0 2 [utf8.codes]
GETUPVAL R1 0
CALL R0 1 3
FORGPREP R0 L1
REMARK builtin assert/1
L0: FASTCALL1 1 R3 L1
MOVE R6 R3
GETIMPORT R5 4 [assert]
CALL R5 1 0
L1: FORGLOOP R0 L0 1
   94:       end)
RETURN R0 0

Function 5 (errorcodes):
   91:     checkerror("invalid UTF%-8 code",
GETUPVAL R1 0
LOADK R2 K0 ['invalid UTF%-8 code']
REMARK allocation: closure with 1 upvalues
   92:       function ()
NEWCLOSURE R3 P0
CAPTURE VAL R0
   91:     checkerror("invalid UTF%-8 code",
CALL R1 2 0
   95:   end
RETURN R0 0

Function 6 (invalid):
  149:   checkerror("invalid UTF%-8 code", utf8.codepoint, s)
GETUPVAL R1 0
LOADK R2 K0 ['invalid UTF%-8 code']
GETIMPORT R3 3 [utf8.codepoint]
MOVE R4 R0
CALL R1 3 0
REMARK builtin assert/1
  150:   assert(not utf8.len(s))
GETIMPORT R3 5 [utf8.len]
MOVE R4 R0
CALL R3 1 1
NOT R2 R3
FASTCALL1 1 R2 L0
GETIMPORT R1 7 [assert]
CALL R1 1 0
  151: end
L0: RETURN R0 0

Function 7 (??):
    3: print "testing UTF-8 library"
GETIMPORT R0 1 [print]
LOADK R1 K2 ['testing UTF-8 library']
CALL R0 1 0
    5: local function checkerror (msg, f, ...)
DUPCLOSURE R0 K3 ['checkerror']
   11: local function len (s)
DUPCLOSURE R1 K4 ['len']
   16: local justone = "^" .. utf8.charpattern .. "$"
LOADK R3 K5 ['^']
GETIMPORT R4 8 [utf8.charpattern]
LOADK R5 K9 ['$']
CONCAT R2 R3 R5
REMARK builtin assert/1
   18: assert(not utf8.offset("alo", 5))
GETIMPORT R5 11 [utf8.offset]
LOADK R6 K12 ['alo']
LOADN R7 5
CALL R5 2 1
NOT R4 R5
FASTCALL1 1 R4 L0
GETIMPORT R3 14 [assert]
CALL R3 1 0
REMARK builtin assert/1
   19: assert(not utf8.offset("alo", -4))
L0: GETIMPORT R5 11 [utf8.offset]
LOADK R6 K12 ['alo']
LOADN R7 -4
CALL R5 2 1
NOT R4 R5
FASTCALL1 1 R4 L1
GETIMPORT R3 14 [assert]
CALL R3 1 0
   23: local function check (s, t, nonstrict)
L1: DUPCLOSURE R3 K15 ['check']
CAPTURE VAL R1
CAPTURE VAL R2
   78:   local function check (s, p)
DUPCLOSURE R4 K16 ['check']
   82:   check("abc\xE3def", 4)
MOVE R5 R4
LOADK R6 K17 ['abc�def']
LOADN R7 4
CALL R5 2 0
   83:   check("汉字\x80", #("汉字") + 1)
MOVE R5 R4
LOADK R6 K18 ['汉字�']
LOADN R7 7
CALL R5 2 0
   84:   check("\xF4\x9F\xBF", 1)
MOVE R5 R4
LOADK R6 K19 ['���']
LOADN R7 1
CALL R5 2 0
   85:   check("\xF4\x9F\xBF\xBF", 1)
MOVE R5 R4
LOADK R6 K20 ['����']
LOADN R7 1
CALL R5 2 0
   90:   local function errorcodes (s)
DUPCLOSURE R4 K21 ['errorcodes']
CAPTURE VAL R0
   96:   errorcodes("ab\xff")
MOVE R5 R4
LOADK R6 K22 ['ab�']
CALL R5 1 0
  101: checkerror("position out of range", utf8.offset, "abc", 1, 5)
MOVE R4 R0
LOADK R5 K23 ['position out of range']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K24 ['abc']
LOADN R8 1
LOADN R9 5
CALL R4 5 0
  102: checkerror("position out of range", utf8.offset, "abc", 1, -4)
MOVE R4 R0
LOADK R5 K23 ['position out of range']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K24 ['abc']
LOADN R8 1
LOADN R9 -4
CALL R4 5 0
  103: checkerror("position out of range", utf8.offset, "", 1, 2)
MOVE R4 R0
LOADK R5 K23 ['position out of range']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K25 ['']
LOADN R8 1
LOADN R9 2
CALL R4 5 0
  104: checkerror("position out of range", utf8.offset, "", 1, -1)
MOVE R4 R0
LOADK R5 K23 ['position out of range']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K25 ['']
LOADN R8 1
LOADN R9 -1
CALL R4 5 0
  105: checkerror("continuation byte", utf8.offset, "𦧺", 1, 2)
MOVE R4 R0
LOADK R5 K26 ['continuation byte']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K27 ['𦧺']
LOADN R8 1
LOADN R9 2
CALL R4 5 0
  106: checkerror("continuation byte", utf8.offset, "𦧺", 1, 2)
MOVE R4 R0
LOADK R5 K26 ['continuation byte']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K27 ['𦧺']
LOADN R8 1
LOADN R9 2
CALL R4 5 0
  107: checkerror("continuation byte", utf8.offset, "\x80", 1)
MOVE R4 R0
LOADK R5 K26 ['continuation byte']
GETIMPORT R6 11 [utf8.offset]
LOADK R7 K28 ['�']
LOADN R8 1
CALL R4 4 0
  110: checkerror("out of string", utf8.len, "abc", 0, 2)
MOVE R4 R0
LOADK R5 K29 ['out of string']
GETIMPORT R6 31 [utf8.len]
LOADK R7 K24 ['abc']
LOADN R8 0
LOADN R9 2
CALL R4 5 0
  111: checkerror("out of string", utf8.len, "abc", 1, 4)
MOVE R4 R0
LOADK R5 K29 ['out of string']
GETIMPORT R6 31 [utf8.len]
LOADK R7 K24 ['abc']
LOADN R8 1
LOADN R9 4
CALL R4 5 0
  114: local s = "hello World"
LOADK R4 K32 ['hello World']
REMARK allocation: table array 1
  115: local t = {string.byte(s, 1, -1)}
NEWTABLE R5 0 1
REMARK builtin string.byte/3
MOVE R7 R4
LOADN R8 1
LOADN R9 -1
FASTCALL 41 L2
GETIMPORT R6 35 [string.byte]
CALL R6 3 -1
L2: SETLIST R5 R6 -1 [1]
  116: for i = 1, utf8.len(s) do assert(t[i] == string.byte(s, i)) end
LOADN R8 1
GETIMPORT R9 31 [utf8.len]
MOVE R10 R4
CALL R9 1 1
MOVE R6 R9
LOADN R7 1
FORNPREP R6 L8
REMARK builtin assert/1
L3: GETTABLE R11 R5 R8
REMARK builtin string.byte/2
FASTCALL2 41 R4 R8 L4
MOVE R13 R4
MOVE R14 R8
GETIMPORT R12 35 [string.byte]
CALL R12 2 1
L4: JUMPIFEQ R11 R12 L5
LOADB R10 0 +1
L5: LOADB R10 1
L6: FASTCALL1 1 R10 L7
GETIMPORT R9 14 [assert]
CALL R9 1 0
L7: FORNLOOP R6 L3
  117: check(s, t)
L8: MOVE R6 R3
MOVE R7 R4
MOVE R8 R5
CALL R6 2 0
  119: check("汉字/漢字", {27721, 23383, 47, 28450, 23383,})
MOVE R6 R3
LOADK R7 K36 ['汉字/漢字']
REMARK allocation: table array 5
NEWTABLE R8 0 5
LOADN R9 27721
LOADN R10 23383
LOADN R11 47
LOADN R12 28450
LOADN R13 23383
SETLIST R8 R9 5 [1]
CALL R6 2 0
REMARK allocation: table array 1
  123:   local t = {utf8.codepoint(s,1,#s - 1)}
NEWTABLE R6 0 1
GETIMPORT R7 38 [utf8.codepoint]
LOADK R8 K39 ['áéí�']
LOADN R9 1
LOADN R10 6
CALL R7 3 -1
SETLIST R6 R7 -1 [1]
REMARK builtin assert/1
  124:   assert(#t == 3 and t[1] == 225 and t[2] == 233 and t[3] == 237)
LOADB R8 0
LENGTH R9 R6
JUMPXEQKN R9 K40 L10 NOT [3]
LOADB R8 0
GETTABLEN R9 R6 1
JUMPXEQKN R9 K41 L10 NOT [225]
LOADB R8 0
GETTABLEN R9 R6 2
JUMPXEQKN R9 K42 L10 NOT [233]
GETTABLEN R9 R6 3
JUMPXEQKN R9 K43 L9 [237]
LOADB R8 0 +1
L9: LOADB R8 1
L10: FASTCALL1 1 R8 L11
GETIMPORT R7 14 [assert]
CALL R7 1 0
  125:   checkerror("invalid UTF%-8 code", utf8.codepoint, s, 1, #s)
L11: MOVE R7 R0
LOADK R8 K44 ['invalid UTF%-8 code']
GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K39 ['áéí�']
LOADN R11 1
LOADN R12 7
CALL R7 5 0
  126:   checkerror("out of range", utf8.codepoint, s, #s + 1)
MOVE R7 R0
LOADK R8 K45 ['out of range']
GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K39 ['áéí�']
LOADN R11 8
CALL R7 4 0
REMARK allocation: table array 1
  127:   t = {utf8.codepoint(s, 4, 3)}
NEWTABLE R7 0 1
GETIMPORT R8 38 [utf8.codepoint]
LOADK R9 K39 ['áéí�']
LOADN R10 4
LOADN R11 3
CALL R8 3 -1
SETLIST R7 R8 -1 [1]
MOVE R6 R7
REMARK builtin assert/1
  128:   assert(#t == 0)
LENGTH R9 R6
JUMPXEQKN R9 K46 L12 [0]
LOADB R8 0 +1
L12: LOADB R8 1
L13: FASTCALL1 1 R8 L14
GETIMPORT R7 14 [assert]
CALL R7 1 0
  129:   checkerror("out of range", utf8.codepoint, s, -(#s + 1), 1)
L14: MOVE R7 R0
LOADK R8 K45 ['out of range']
GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K39 ['áéí�']
LOADN R11 -8
LOADN R12 1
CALL R7 5 0
  130:   checkerror("out of range", utf8.codepoint, s, 1, #s + 1)
MOVE R7 R0
LOADK R8 K45 ['out of range']
GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K39 ['áéí�']
LOADN R11 1
LOADN R12 8
CALL R7 5 0
REMARK builtin assert/1
  132:   assert(utf8.codepoint("\u{D7FF}") == 0xD800 - 1)
GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K47 ['퟿']
CALL R9 1 1
JUMPXEQKN R9 K48 L15 [55295]
LOADB R8 0 +1
L15: LOADB R8 1
L16: FASTCALL1 1 R8 L17
GETIMPORT R7 14 [assert]
CALL R7 1 0
REMARK builtin assert/1
  133:   assert(utf8.codepoint("\u{E000}") == 0xDFFF + 1)
L17: GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K49 ['']
CALL R9 1 1
JUMPXEQKN R9 K50 L18 [57344]
LOADB R8 0 +1
L18: LOADB R8 1
L19: FASTCALL1 1 R8 L20
GETIMPORT R7 14 [assert]
CALL R7 1 0
REMARK builtin assert/1
  134:   assert(utf8.codepoint("\u{D800}", 1, 1, true) == 0xD800)
L20: GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K51 ['���']
LOADN R11 1
LOADN R12 1
LOADB R13 1
CALL R9 4 1
JUMPXEQKN R9 K52 L21 [55296]
LOADB R8 0 +1
L21: LOADB R8 1
L22: FASTCALL1 1 R8 L23
GETIMPORT R7 14 [assert]
CALL R7 1 0
REMARK builtin assert/1
  135:   assert(utf8.codepoint("\u{DFFF}", 1, 1, true) == 0xDFFF)
L23: GETIMPORT R9 38 [utf8.codepoint]
LOADK R10 K53 ['���']
LOADN R11 1
LOADN R12 1
LOADB R13 1
CALL R9 4 1
JUMPXEQKN R9 K54 L24 [57343]
LOADB R8 0 +1
L24: LOADB R8 1
L25: FASTCALL1 1 R8 L26
GETIMPORT R7 14 [assert]
CALL R7 1 0
REMARK builtin assert/1
  139: assert(utf8.char() == "")
L26: GETIMPORT R8 56 [utf8.char]
CALL R8 0 1
JUMPXEQKS R8 K25 L27 ['']
LOADB R7 0 +1
L27: LOADB R7 1
L28: FASTCALL1 1 R7 L29
GETIMPORT R6 14 [assert]
CALL R6 1 0
REMARK builtin assert/1
  140: assert(utf8.char(0, 97, 98, 99, 1) == "\0abc\1")
L29: GETIMPORT R8 56 [utf8.char]
LOADN R9 0
LOADN R10 97
LOADN R11 98
LOADN R12 99
LOADN R13 1
CALL R8 5 1
JUMPXEQKS R8 K57 L30 []
LOADB R7 0 +1
L30: LOADB R7 1
L31: FASTCALL1 1 R7 L32
GETIMPORT R6 14 [assert]
CALL R6 1 0
REMARK builtin assert/1
  142: assert(utf8.codepoint(utf8.char(0x10FFFF)) == 0x10FFFF)
L32: GETIMPORT R8 38 [utf8.codepoint]
GETIMPORT R9 56 [utf8.char]
LOADK R10 K58 [1114111]
CALL R9 1 -1
CALL R8 -1 1
JUMPXEQKN R8 K58 L33 [1114111]
LOADB R7 0 +1
L33: LOADB R7 1
L34: FASTCALL1 1 R7 L35
GETIMPORT R6 14 [assert]
CALL R6 1 0
  145: checkerror("value out of range", utf8.char, 0x7FFFFFFF + 1)
L35: MOVE R6 R0
LOADK R7 K59 ['value out of range']
GETIMPORT R8 56 [utf8.char]
LOADK R9 K60 [2147483648]
CALL R6 3 0
  146: checkerror("value out of range", utf8.char, -1)
MOVE R6 R0
LOADK R7 K59 ['value out of range']
GETIMPORT R8 56 [utf8.char]
LOADN R9 -1
CALL R6 3 0
  148: local function invalid (s)
DUPCLOSURE R6 K61 ['invalid']
CAPTURE VAL R0
  154: invalid("\xF4\x9F\xBF\xBF")
MOVE R7 R6
LOADK R8 K20 ['����']
CALL R7 1 0
  161: invalid("\xC0\x80")          -- zero
MOVE R7 R6
LOADK R8 K62 ['��']
CALL R7 1 0
  162: invalid("\xC1\xBF")          -- 0x7F (should be coded in 1 byte)
MOVE R7 R6
LOADK R8 K63 ['��']
CALL R7 1 0
  163: invalid("\xE0\x9F\xBF")      -- 0x7FF (should be coded in 2 bytes)
MOVE R7 R6
LOADK R8 K64 ['���']
CALL R7 1 0
  164: invalid("\xF0\x8F\xBF\xBF")  -- 0xFFFF (should be coded in 3 bytes)
MOVE R7 R6
LOADK R8 K65 ['����']
CALL R7 1 0
  168: invalid("\x80")  -- continuation byte
MOVE R7 R6
LOADK R8 K28 ['�']
CALL R7 1 0
  169: invalid("\xBF")  -- continuation byte
MOVE R7 R6
LOADK R8 K66 ['�']
CALL R7 1 0
  170: invalid("\xFE")  -- invalid byte
MOVE R7 R6
LOADK R8 K67 ['�']
CALL R7 1 0
  171: invalid("\xFF")  -- invalid byte
MOVE R7 R6
LOADK R8 K68 ['�']
CALL R7 1 0
  175: check("", {})
MOVE R7 R3
LOADK R8 K25 ['']
REMARK allocation: table hash 0
NEWTABLE R9 0 0
CALL R7 2 0
  178: s = "\0 \x7F\z
LOADK R4 K69 []
  182: s = string.gsub(s, " ", "")
GETIMPORT R7 71 [string.gsub]
MOVE R8 R4
LOADK R9 K72 [' ']
LOADK R10 K25 ['']
CALL R7 3 1
MOVE R4 R7
  183: check(s, {0,0x7F, 0x80,0x7FF, 0x800,0xFFFF, 0x10000,0x10FFFF})
MOVE R7 R3
MOVE R8 R4
REMARK allocation: table array 8
NEWTABLE R9 0 8
LOADN R10 0
LOADN R11 127
LOADN R12 128
LOADN R13 2047
LOADN R14 2048
LOADK R15 K73 [65535]
LOADK R16 K74 [65536]
LOADK R17 K58 [1114111]
SETLIST R9 R10 8 [1]
CALL R7 2 0
  185: x = "日本語a-4\0éó"
LOADK R7 K75 []
SETGLOBAL R7 K76 ['x']
  186: check(x, {26085, 26412, 35486, 97, 45, 52, 0, 233, 243})
MOVE R7 R3
GETGLOBAL R8 K76 ['x']
REMARK allocation: table array 9
NEWTABLE R9 0 9
LOADN R10 26085
LOADN R11 26412
LOADK R12 K77 [35486]
LOADN R13 97
LOADN R14 45
LOADN R15 52
LOADN R16 0
LOADN R17 233
LOADN R18 243
SETLIST R9 R10 9 [1]
CALL R7 2 0
  190: check("𣲷𠜎𠱓𡁻𠵼ab𠺢",
MOVE R7 R3
LOADK R8 K78 ['𣲷𠜎𠱓𡁻𠵼ab𠺢']
REMARK allocation: table array 8
  191:       {0x23CB7, 0x2070E, 0x20C53, 0x2107B, 0x20D7C, 0x61, 0x62, 0x20EA2,})
NEWTABLE R9 0 8
LOADK R10 K79 [146615]
LOADK R11 K80 [132878]
LOADK R12 K81 [134227]
LOADK R13 K82 [135291]
LOADK R14 K83 [134524]
LOADN R15 97
LOADN R16 98
LOADK R17 K84 [134818]
SETLIST R9 R10 8 [1]
  190: check("𣲷𠜎𠱓𡁻𠵼ab𠺢",
CALL R7 2 0
  193: check("𨳊𩶘𦧺𨳒𥄫𤓓\xF4\x8F\xBF\xBF",
MOVE R7 R3
LOADK R8 K85 ['𨳊𩶘𦧺𨳒𥄫𤓓􏿿']
REMARK allocation: table array 7
  194:       {0x28CCA, 0x29D98, 0x269FA, 0x28CD2, 0x2512B, 0x244D3, 0x10ffff})
NEWTABLE R9 0 7
LOADK R10 K86 [167114]
LOADK R11 K87 [171416]
LOADK R12 K88 [158202]
LOADK R13 K89 [167122]
LOADK R14 K90 [151851]
LOADK R15 K91 [148691]
LOADK R16 K58 [1114111]
SETLIST R9 R10 7 [1]
  193: check("𨳊𩶘𦧺𨳒𥄫𤓓\xF4\x8F\xBF\xBF",
CALL R7 2 0
  197: local i = 0
LOADN R7 0
  198: for p, c in string.gmatch(x, "()(" .. utf8.charpattern .. ")") do
GETIMPORT R8 93 [string.gmatch]
GETGLOBAL R9 K76 ['x']
LOADK R11 K94 ['()(']
GETIMPORT R12 8 [utf8.charpattern]
LOADK R13 K95 [')']
CONCAT R10 R11 R13
CALL R8 2 3
FORGPREP R8 L50
  199:   i = i + 1
L36: ADDK R7 R7 K96 [1]
REMARK builtin assert/1
  200:   assert(utf8.offset(x, i) == p)
GETIMPORT R15 11 [utf8.offset]
GETGLOBAL R16 K76 ['x']
MOVE R17 R7
CALL R15 2 1
JUMPIFEQ R15 R11 L37
LOADB R14 0 +1
L37: LOADB R14 1
L38: FASTCALL1 1 R14 L39
GETIMPORT R13 14 [assert]
CALL R13 1 0
REMARK builtin assert/1
  201:   assert(utf8.len(x, p) == utf8.len(x) - i + 1)
L39: GETIMPORT R15 31 [utf8.len]
GETGLOBAL R16 K76 ['x']
MOVE R17 R11
CALL R15 2 1
GETIMPORT R18 31 [utf8.len]
GETGLOBAL R19 K76 ['x']
CALL R18 1 1
SUB R17 R18 R7
ADDK R16 R17 K96 [1]
JUMPIFEQ R15 R16 L40
LOADB R14 0 +1
L40: LOADB R14 1
L41: FASTCALL1 1 R14 L42
GETIMPORT R13 14 [assert]
CALL R13 1 0
REMARK builtin assert/1
  202:   assert(utf8.len(c) == 1)
L42: GETIMPORT R15 31 [utf8.len]
MOVE R16 R12
CALL R15 1 1
JUMPXEQKN R15 K96 L43 [1]
LOADB R14 0 +1
L43: LOADB R14 1
L44: FASTCALL1 1 R14 L45
GETIMPORT R13 14 [assert]
CALL R13 1 0
  203:   for j = 1, #c - 1 do
L45: LOADN R15 1
LENGTH R16 R12
SUBK R13 R16 K96 [1]
LOADN R14 1
FORNPREP R13 L50
REMARK builtin assert/1
  204:     assert(utf8.offset(x, 0, p + j - 1) == p)
L46: GETIMPORT R18 11 [utf8.offset]
GETGLOBAL R19 K76 ['x']
LOADN R20 0
ADD R22 R11 R15
SUBK R21 R22 K96 [1]
CALL R18 3 1
JUMPIFEQ R18 R11 L47
LOADB R17 0 +1
L47: LOADB R17 1
L48: FASTCALL1 1 R17 L49
GETIMPORT R16 14 [assert]
CALL R16 1 0
  203:   for j = 1, #c - 1 do
L49: FORNLOOP R13 L46
  198: for p, c in string.gmatch(x, "()(" .. utf8.charpattern .. ")") do
L50: FORGLOOP R8 L36 2
  208: print 'OK'
GETIMPORT R8 1 [print]
LOADK R9 K97 ['OK']
CALL R8 1 0
  209: 
RETURN R0 0

]]
end