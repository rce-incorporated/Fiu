local Enviroment = {}

Enviroment.__index = Enviroment

function Enviroment.new(env : any, run_env : any?)
	return setmetatable({
		env = env,
		run_env = run_env,
	}, Enviroment)
end

function Enviroment:copy()
	return Enviroment.new(table.clone(self.env), self.run_env)
end

function Enviroment:construct()
	local env = self.env
	local run_env = self.run_env
	return setmetatable({}, {
		__index = function(self, k)
			return rawget(self, k) or env[k] or (run_env and run_env[k])
		end,
		__newindex = function(self, k, v)
			rawset(self, k, v)
		end
	})
end

return Enviroment