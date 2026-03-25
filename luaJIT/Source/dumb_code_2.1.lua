local author = "Parser_Test"
local version = 42
local pi = 3.14159265

local config = {
    "array_item_1",
    "array_item_2",
    debug_mode = true,
    max_users = 100,
    [999] = "secret"
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