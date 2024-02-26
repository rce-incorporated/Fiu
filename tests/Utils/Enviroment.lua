local Enviroment = {}

Enviroment.__index = Enviroment

function Enviroment.new(env : any, baseEnv : any?)
	return setmetatable({
		env = env,
		baseEnv = baseEnv,
	}, Enviroment)
end

function Enviroment.valueExists(k, ...) : any?
	local values = {...};
	for _, registry in values do
		local value = rawget(registry, k)
		if value ~= nil then
			return value
		end
	end
	return
end

function Enviroment:copy()
	return Enviroment.new(table.clone(self.env), self.baseEnv)
end

function Enviroment:construct(staticContext : boolean)
	local env = self.env
	local baseEnv = self.baseEnv
	local constructed;
	local localGlobal = {}
	local virtualEnv = {}
	constructed = setmetatable({}, {
		__index = function(self, k)
			if staticContext then
				--// custom handled getfenv
				local env = rawget(virtualEnv, "getfenv")
				if env then
					local penv = env(2);
					if penv ~= constructed then
						return penv[k]
					end
				end
			end
			return Enviroment.valueExists(k, localGlobal, virtualEnv, env, baseEnv and baseEnv or nil)
		end,
		__newindex = function(self, k, v)
			if staticContext then
				--// custom handled getfenv
				local env = rawget(virtualEnv, "getfenv")
				if env then
					local penv = env(2);
					if penv ~= constructed then
						penv[k] = v
						return
					end
				end
			end
			rawset(localGlobal, k, v)
		end,
		__iter = function(self)
			return pairs(localGlobal)
		end
	})
	return constructed, virtualEnv
end

return Enviroment