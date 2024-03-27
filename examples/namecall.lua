local Bytecode = "\5\1\4\5\112\114\105\110\116\4\103\97\109\101\9\87\111\114\107\115\112\97\99\101\14\70\105\110\100\70\105\114\115\116\67\104\105\108\100\1\4\0\0\1\2\0\11\65\0\0\0\12\0\1\0\0\0\0\64\12\1\3\0\0\0\32\64\5\3\4\0\20\1\1\3\5\0\0\0\21\1\3\0\21\0\0\1\22\0\1\0\6\3\1\4\0\0\0\64\3\2\4\0\0\32\64\3\3\3\4\0\1\0\1\24\0\0\0\0\0\0\0\0\0\0\1\1\0\0\0\0\0"

local luau_settings = Fiu.luau_newsettings()
luau_settings.useNativeNamecall = true
luau_settings.namecallHandler = function(namecallMethod, self, ...)
    if namecallMethod == "FindFirstChild" then
        print("Calling native __namecall FindFirstChild")
        return true, self:FindFirstChild(...)
    end 

    return false
end

local luau_execute = Fiu.luau_load(Bytecode, { print = print, game = game }, luau_settings)
luau_execute()
