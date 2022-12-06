local a = 1
while a ~= 5 do
	if a == 3 then
		a += 2
		print("breaking down")
		break
	end
	a = a + 1
end
print("jumped")
