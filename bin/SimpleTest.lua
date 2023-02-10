local ByteString = "Bytestring"

local fiu = require("../Source")
fiu.luau_load(ByteString, getfenv())()
