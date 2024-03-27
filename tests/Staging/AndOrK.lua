local a = table.isfrozen({}) -- no propagate pls >:c

assert(not (a and "Hello World"))
assert((a or "Goodbye World") == "Goodbye World")

OK()
