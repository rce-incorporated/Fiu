local match = {`joe: {1+5}`, `word {string.rep("meow",2)}`}

local count = 0

for i, v in {`joe: {1+5}`, `word {string.rep("meow",2)}`} do
	print(v)
	count += 1;
	assert(v == match[i])
end

assert(count == 2)

OK()
