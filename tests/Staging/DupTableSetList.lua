local a = {
  a = 1,
  b = 2,
  c = 3,
}

local c = {
	a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a, a
}

assert(a.a == 1)
assert(a.b == 2)
assert(a.c == 3)
assert(#a == 0)
assert(#c == 44)

OK()
