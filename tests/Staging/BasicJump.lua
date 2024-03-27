local a = 1
while a ~= 5 do
	if a == 3 then
		a += 20
		break
	end
	a = a + 1
end
assert(a == 23)

OK()
