getfenv().a = { b = { c = "HELLO" } }

print(a.b)
print(a.b.c)

--[[
WARNING: Requires a small edit where you add a.b.c to the environment
env.a = {b = {c="HELLOAHHHHHHHHH"}}
]]
