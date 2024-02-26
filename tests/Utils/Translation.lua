local Translation = {}

function Translation.toString(o) : string
	local kind = type(o)
	if kind == "string" then
		return `"{o}"`
	end
	return tostring(o)
end

function Translation.toStringTable(t) : string
	local strlist = {}
	for k, v in t do
		table.insert(strlist, `[{Translation.toString(k)}] = {Translation.toString(v)}`)
	end
	return `\{{table.concat(strlist, ', ')}\}`
end

return Translation