local fs = require("@lune/fs");

local Files = {};

export type FileItem = {
	path : string,
	name : string,
	relativePath : string,
	relativeName : string,
}

function Files.getFiles(path : string, filter : string, parentPath : string?): {FileItem}
	assert(fs.isDir(path), `Path is not a directory: {path}`)
	local files = fs.readDir(path)
	local result = {}
	for _, file in files do
		local filePath = `{path}/{file}`
		local fileName = file:match("^(.+)%.(.+)$")
		if fs.isDir(filePath) then
			local subFiles = Files.getFiles(filePath, filter, parentPath or path)
			for _, subFile in subFiles do
				table.insert(result, subFile)
			end
			continue;
		end
		if file:match(filter) then
			table.insert(result, {
				path = filePath,
				name = fileName,
				relativePath = parentPath and filePath:sub(#parentPath + 2) or filePath:sub(#path + 2),
				relativeName = `{parentPath and `{path:sub(#parentPath + 2)}/` or ''}{fileName}`,
			})
		end
	end
	return result;
end

return Files;