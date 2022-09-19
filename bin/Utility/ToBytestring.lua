local f = io.open("bytecode", "rb")
local s = f:read('*all')

print(s:gsub(".", function(b) return "\\" .. b:byte() end))
