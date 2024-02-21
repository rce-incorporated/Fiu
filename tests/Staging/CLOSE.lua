local functions = {}
for i = 1, 10 do
    functions[i] = function()
        print(i)
    end
end
functions[2]()
functions[9]()

OK()
