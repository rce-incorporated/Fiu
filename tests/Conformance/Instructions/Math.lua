-- tests: LOP_ADD, LOP_SUB, LOP_MUL, LOP_DIV, LOP_MOD, LOP_POW, LOP_ADDK, LOP_SUBK, LOP_MULK, LOP_DIVK, LOP_MODK, LOP_POWK, LOP_SUBRK, LOP_DIVRK, LOP_IDIV, LOP_IDIVK, LOP_MINUS

local t = {}

t.a = 1
t.b = 2

-- ADD
assert(t.a + t.b == 3, "Failed ADD")
-- SUB
assert(t.a - t.b == -1, "Failed SUB")
-- MUL
assert(t.a * t.b == 2, "Failed MUL")
-- DIV
assert(t.a / t.b == 0.5, "Failed DIV")
-- MOD
assert(t.a % t.b == 1, "Failed MOD")
-- POW
assert(t.a ^ t.b == 1, "Failed POW")

-- ADDK
assert(t.a + 2 == 3, "Failed ADDK")
-- SUBK
assert(t.a - 2 == -1, "Failed SUBK")
-- MULK
assert(t.a * 2 == 2, "Failed MULK")
-- DIVK
assert(t.a / 2 == 0.5, "Failed DIVK")
-- MODK
assert(t.a % 2 == 1, "Failed MODK")
-- POWK
assert(t.a ^ 2 == 1, "Failed POWK")

-- SUBRK
assert(2 - t.a == 1, "Failed SUBRK")
-- DIVRK
assert(2 / t.a == 2, "Failed DIVRK")

-- IDIV
assert(t.a // t.b == 0, "Failed IDIV")
-- IDIVK
assert(t.a // 2 == 0, "Failed IDIVK")

-- MINUS
assert(-t.a == -1, "Failed MINUS")

OK()