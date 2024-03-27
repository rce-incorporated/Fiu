local functions = {}
for i = 1, 10 do
    functions[i] = function()
        return i
    end
end
assert(functions[2]() == 2)
assert(functions[9]() == 9)

OK()
