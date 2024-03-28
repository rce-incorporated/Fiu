getfenv()

local a = 5
if a then 
	string.sub("valid", 1,2)
end 
if not a then 
	error('invalid')
end
if a == math.floor(1) then 
	error('invalid')
else 
end
if a ~= math.floor(1) then 
	string.sub("valid", 1,2)
end
if a >= math.floor(1) then
	string.sub("valid", 1,2)
 end
if a > math.floor(1) then 
	string.sub("valid", 1,2)
end
if a < math.floor(1) then 
	error('invalid')
end
if a <= math.floor(1) then 
	error('invalid')
end

OK()
