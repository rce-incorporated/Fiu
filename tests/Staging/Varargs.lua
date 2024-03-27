local function foo(...)
	assert(select(1,...) == 5)
	assert(select(2,...) == 3)
	assert(select(3,...) == 4)
	assert(select(4,...) == 2)
	assert(... :: any == 5)
end

foo(5,3,4,2)
