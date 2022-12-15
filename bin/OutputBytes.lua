local f1 = io.open("bytecode.luac", "rb");
local bytecode = f1:read("*all");
f1:close();

print(bytecode:gsub(".", function(b) return b:byte() end))
