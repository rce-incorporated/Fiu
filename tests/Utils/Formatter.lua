local stdio = require("@lune/stdio")

local iowrite = print;

local Formatter = {}

local MAX_FORMAT_DEPTH = 4
local INDENT = "    "

local COLOR_CYAN = stdio.color("cyan")
local COLOR_BLUE = stdio.color("blue")
local COLOR_YELLOW = stdio.color("yellow")
local COLOR_GREEN = stdio.color("green")
local COLOR_PURPLE = stdio.color("purple")
local COLOR_RESET = stdio.color("reset")

local STYLE_DIM = stdio.style("dim")
local STYLE_RESET = stdio.style("reset")

local function applyStyle(style : string, str : string)
	return `{style}{str}{STYLE_RESET}`
end

local function applyColor(color : string, str : string)
	return `{color}{str}{COLOR_RESET}`
end

function Formatter.formatValue(value : any, depth : number, asKey : boolean?)
	depth = depth or 0

	if depth >= MAX_FORMAT_DEPTH  then
		return applyStyle(STYLE_DIM, "{ ... }")
	end

	if value == nil then
		return "nil"
	elseif type(value) == "boolean" then
		return applyColor(COLOR_YELLOW, tostring(value))
	elseif type(value) == "number" then
		return applyColor(COLOR_CYAN, tostring(value))
	elseif type(value) == "string" then
		return `"{applyColor(COLOR_GREEN, (value:gsub(`[%z\128-\255]`, ""):gsub('"', '\\"'):gsub('\n', '\\n')))}"`
	elseif type(value) == "function" then
		return applyColor(COLOR_PURPLE,`<{tostring(value)}>`)
	elseif type(value) == "table" then
		if asKey then
			return applyColor(COLOR_BLUE, `<{tostring(value)}>`)
		end
		local result = {}
		for k, v in value do
			if type(k) == "string" then
				table.insert(result, `\n{string.rep(INDENT, depth + 1)}{k} {applyStyle(STYLE_DIM, '=')} {Formatter.formatValue(v, depth + 1)}`)
			else
				table.insert(result, `\n{string.rep(INDENT, depth + 1)}[{Formatter.formatValue(k, depth, true)}] {applyStyle(STYLE_DIM, '=')} {Formatter.formatValue(v, depth + 1)}`)
			end
		end
		if #result == 0 then
			return applyStyle(STYLE_DIM, "{}")
		end
		table.insert(result, `\n{string.rep(INDENT, depth)}{applyStyle(STYLE_DIM, '}')}`)
		return `{applyStyle(STYLE_DIM, '{')}{table.concat(result, `{applyStyle(STYLE_DIM, ',')}`)}`
	else
		return `<{tostring(value)}>`
	end
end

function Formatter.print(... : any)
	local args = {...}
	local formattedArgs = {}
	for i = 1, #args, 1 do
		local v = args[i]
		if type(v) == "string" then
			table.insert(formattedArgs, v)
		elseif type(v) == "nil" then
			table.insert(formattedArgs, `nil`)
		else
			table.insert(formattedArgs, Formatter.formatValue(v, 0))
		end
	end
	iowrite(table.concat(formattedArgs, "  "))
end

Formatter.applyColor = applyColor
Formatter.applyStyle = applyStyle

return Formatter