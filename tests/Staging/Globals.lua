local a = UnknownGlobal
assert(UnknownGlobal == nil)
UnknownGlobal = 15

assert(UnknownGlobal == 15, "UnknownGlobal should be 15")

OK()
