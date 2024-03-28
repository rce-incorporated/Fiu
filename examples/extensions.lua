--[[ Source: macro() ]]

local luau_settings = Fiu.luau_newsettings()

luau_settings.extensions["macro"] = function()
    print("Hello World, from Fiu extension!")
end

local luau_execute, luau_close = Fiu.luau_load("\5\1\1\5\109\97\99\114\111\1\1\0\0\1\2\0\5\65\0\0\0\12\0\1\0\0\0\0\64\21\0\1\1\22\0\1\0\2\3\1\4\0\0\0\64\0\1\0\1\24\0\0\0\0\1\1\0\0\0\0\0", nil, luau_settings)

luau_execute()
