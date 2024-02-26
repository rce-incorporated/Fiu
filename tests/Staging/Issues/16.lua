-- to bypass the table constant
local function a(b)
	return b
end

local t = {
	a("1"),
	a("2"),
	a("3")
}

assert(#t == 3)
assert(t[1] == "1")
assert(t[2] == "2")
assert(t[3] == "3")

local t2 = {
	a("1"),
	a("2"),
	a("3"),
	name = a("SETLIST")
}

assert(#t2 == 3)
assert(t2[1] == "1")
assert(t2[2] == "2")
assert(t2[3] == "3")
assert(t2.name == "SETLIST")

OK()