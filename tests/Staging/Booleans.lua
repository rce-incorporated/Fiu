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

OK()
