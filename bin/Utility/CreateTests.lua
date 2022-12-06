--// Run on Lua 5.3

local f = io.popen("dir ..\\Sources")

for name in f:lines() do 
	local s = name:gmatch("(%w+%.lua)")() 
	if type(s) == "string" and #s ~= 0 and s:find("lua") then 
		local f0 = io.open("..\\Sources\\"..s, "r")
		local source = f0:read("*all")
		f0:close()

		os.execute(string.format("luau --compile=binary ..\\Sources\\%s > bytecode", s))

		local f1 = io.open("bytecode", "rb")
		local bytecode = f1:read("*all")
		f1:close()

		local f2 = io.open("..\\Tests\\"..s, "w+")
		f2:write(string.format(
[[return function()
	return '%s'
end]], bytecode:gsub(".", function(b) return "\\" .. b:byte() end)))
		f2:close()

		local f3 = io.open("..\\SourceTests\\"..s, "w+")
		f3:write(string.format(
[[return function()
	%s
end]], source))
		f3:close()
	end
end

