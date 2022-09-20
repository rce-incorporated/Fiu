--[[
local success = nil

local trueVal  = true
local falseVal = false
local nilVal   = nil

if trueVal then success = true end
if not trueVal then success = false end
assert(success, "Testing `true` value failed!")

success = nil
if not falseVal then success = true end
if falseVal then success = false end
assert(success, "Testing `false` value failed!")

success = nil
if not nilVal then success = true end
if nilVal then success = false end
assert(success, "Testing `nil` value failed!")

success = nil
if trueVal == true  then success = true  end
if trueVal == false then success = false end
if trueVal == nil   then success = false end
assert(success, "Comparing `true` value failed!")

success = nil
if falseVal == false then success = true  end
if falseVal == true  then success = false end
if falseVal == nil   then success = false end
assert(success, "Comparing `false` value failed!")

success = nil
if nilVal == nil   then success = true  end
if nilVal == true  then success = false end
if nilVal == false then success = false end
assert(success, "Comparing `nil` value failed!")

success = (trueVal and "a") == "a"
assert(success, "Testsetting `true` value failed!")

success = (falseVal and "a") == false
assert(success, "Testsetting `false` value failed!")

success = (nilVal and "a") == nil
assert(success, "Testsetting `nil` value failed!")

success = (trueVal or "a") == true
assert(success, "Testsetting `true` value failed!")

success = (falseVal or "a") == "a"
assert(success, "Testsetting `false` value failed!")

success = (nilVal or "a") == "a"
assert(success, "Testsetting `nil` value failed!")

print("Tests passed.")
]]

return function()
	return "\3\12\28\84\101\115\116\105\110\103\32\96\116\114\117\101\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\6\97\115\115\101\114\116\29\84\101\115\116\105\110\103\32\96\102\97\108\115\101\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\27\84\101\115\116\105\110\103\32\96\110\105\108\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\30\67\111\109\112\97\114\105\110\103\32\96\116\114\117\101\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\31\67\111\109\112\97\114\105\110\103\32\96\102\97\108\115\101\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\29\67\111\109\112\97\114\105\110\103\32\96\110\105\108\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\32\84\101\115\116\115\101\116\116\105\110\103\32\96\116\114\117\101\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\33\84\101\115\116\115\101\116\116\105\110\103\32\96\102\97\108\115\101\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\31\84\101\115\116\115\101\116\116\105\110\103\32\96\110\105\108\96\32\118\97\108\117\101\32\102\97\105\108\101\100\33\5\112\114\105\110\116\13\84\101\115\116\115\32\112\97\115\115\101\100\46\1\4\0\0\1\108\65\0\0\0\2\0\0\0\3\0\1\0\75\1\0\5\0\0\0\0\6\2\0\0\5\3\0\0\12\1\2\0\0\0\16\64\21\1\3\1\2\0\0\0\3\0\1\0\75\1\0\5\3\0\0\0\6\2\0\0\5\3\3\0\12\1\2\0\0\0\16\64\21\1\3\1\2\0\0\0\3\0\1\0\75\1\0\5\4\0\0\0\6\2\0\0\5\3\4\0\12\1\2\0\0\0\16\64\21\1\3\1\2\0\0\0\3\0\1\0\75\1\0\5\5\0\0\0\6\2\0\0\5\3\5\0\12\1\2\0\0\0\16\64\21\1\3\1\2\0\0\0\3\0\1\0\75\1\0\5\6\0\0\0\6\2\0\0\5\3\6\0\12\1\2\0\0\0\16\64\21\1\3\1\2\0\0\0\3\0\1\0\75\1\0\5\7\0\0\0\6\2\0\0\5\3\7\0\12\1\2\0\0\0\16\64\21\1\3\1\3\0\1\0\75\1\0\5\8\0\0\0\6\2\0\0\5\3\8\0\12\1\2\0\0\0\16\64\21\1\3\1\3\0\1\0\75\1\0\5\9\0\0\0\6\2\0\0\5\3\9\0\12\1\2\0\0\0\16\64\21\1\3\1\3\0\1\0\75\1\0\5\10\0\0\0\6\2\0\0\5\3\10\0\12\1\2\0\0\0\16\64\21\1\3\1\3\0\1\0\75\1\0\5\8\0\0\0\6\2\0\0\5\3\8\0\12\1\2\0\0\0\16\64\21\1\3\1\3\0\1\0\75\1\0\5\9\0\0\0\6\2\0\0\5\3\9\0\12\1\2\0\0\0\16\64\21\1\3\1\3\0\1\0\75\1\0\5\10\0\0\0\6\2\0\0\5\3\10\0\12\1\2\0\0\0\16\64\21\1\3\1\12\1\12\0\0\0\176\64\5\2\13\0\21\1\2\1\22\0\1\0\14\3\1\3\2\4\0\0\16\64\3\3\3\4\3\5\3\6\3\7\3\8\3\9\3\10\3\11\4\0\0\176\64\3\12\0\1\0\1\24\0\0\7\2\0\0\0\0\0\0\2\1\2\0\0\0\0\0\0\2\1\2\0\0\0\0\0\0\2\1\3\0\0\0\0\0\0\2\1\3\0\0\0\0\0\0\2\1\3\0\0\0\0\0\0\2\1\0\0\0\0\0\0\2\1\0\0\0\0\0\0\2\1\0\0\0\0\0\0\2\1\0\0\0\0\0\0\2\1\0\0\0\0\0\0\2\1\0\0\0\0\0\0\2\0\0\0\1\1\0\0\0\0\0"
end
