--[[ Source: while true do task.wait() print'hi' end ]]

local luau_execute, luau_close = Fiu.luau_load("\5\1\4\4\116\97\115\107\4\119\97\105\116\5\112\114\105\110\116\2\104\105\1\2\0\0\1\0\0\10\65\0\0\0\12\0\2\0\0\4\0\128\21\0\1\1\12\0\4\0\0\0\48\64\5\1\5\0\21\0\2\1\24\0\248\255\22\0\1\0\6\3\1\3\2\4\0\4\0\128\3\3\4\0\0\48\64\3\4\0\1\0\1\24\0\0\0\0\0\0\0\0\0\1\1\0\0\0\0\0", getfenv())
task.delay(5, luau_close)
luau_execute()
