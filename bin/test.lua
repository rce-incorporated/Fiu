local function __PRIVATE__IB__CRASH_PREVENTION__()
end
local function __PRIVATE__IB__RETURN_VARARGS__(...)
    __PRIVATE__IB__CRASH_PREVENTION__()
    return ...
end
local __PRIVATE__IB__RAWSET__ = rawset
local __PRIVATE__IB__SETMETATABLE__ = setmetatable
local __PRIVATE__IB__SETFENV__ = setfenv
local __PRIVATE__IB__VARARG_EXPR_WRAPPER__ = __PRIVATE__IB__SETMETATABLE__({}, { __index = __PRIVATE__IB__RETURN_VARARGS__, __newindex = __PRIVATE__IB__RETURN_VARARGS__, __add = __PRIVATE__IB__RETURN_VARARGS__, __sub = __PRIVATE__IB__RETURN_VARARGS__, __mul = __PRIVATE__IB__RETURN_VARARGS__, __div = __PRIVATE__IB__RETURN_VARARGS__, __mod = __PRIVATE__IB__RETURN_VARARGS__, __unm = __PRIVATE__IB__RETURN_VARARGS__, __concat = __PRIVATE__IB__RETURN_VARARGS__, __eq = __PRIVATE__IB__RETURN_VARARGS__, __lt = __PRIVATE__IB__RETURN_VARARGS__, __le = __PRIVATE__IB__RETURN_VARARGS__, __len = __PRIVATE__IB__RETURN_VARARGS__ })
local __PRIVATE__IB__STRING_CHAR__ = string.char
local __PRIVATE__IB__CHARACTER_SET__ = {}
for i = 0, 255 do
    __PRIVATE__IB__CHARACTER_SET__[i] = __PRIVATE__IB__STRING_CHAR__(i)
end
return (function()
end)()
