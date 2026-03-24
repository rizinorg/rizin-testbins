local author = "Parser_Test"
local version = 42
local pi = 3.14159265

local max_users_64 = 9007199254740992LL 
local complex_val = 2.5 + 3i

local config = {
    "array_item_1",
    "array_item_2",
    debug_mode = true,
    max_users = 100,
    [999] = "secret",
    
    -- Added to the table to ensure the compiler stores them as constants
    large_limit = max_users_64,
    vector = complex_val
}

local function make_multiplier(multiplier)
    return function(value)
        return value * multiplier 
    end
end

local doubler = make_multiplier(2)
local result = doubler(config.max_users)

print("Author:", author)
print("Result:", result)

-- Printing them ensures the compiler doesn't optimize them away as unused variables
print("Large Limit:", config.large_limit)
print("Complex Vector:", config.vector)