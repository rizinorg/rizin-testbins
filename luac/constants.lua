local a = true
local b = false
local c = nil

local testTable = {
    [true] = "is_true",
    [false] = "is_false",
    field1 = true,
    field2 = false,
    field3 = nil
}

local logic = (true or false) and (not nil)
local comparison = (nil == nil) and (true ~= false)

if true then
    local x = false
elseif nil then
    local y = true
else
    local z = nil
end

while false do 
   print(false)
end

repeat
    local stop = true
until true

local function getConstants()
    return true, false, nil
end

local r1, r2, r3 = getConstants()

print(type(true), type(false), type(nil))
