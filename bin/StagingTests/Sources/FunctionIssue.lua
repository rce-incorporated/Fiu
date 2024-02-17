local function Stack()
	if not Stack then
		error("Function upvalue was not captured properly")
	end
end

Stack()