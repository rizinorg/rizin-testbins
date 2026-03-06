_G.GAME_VERSION = 2.1
_G.DEBUG_MODE = true

local dummy1, dummy2, dummy3, dummy4 = nil, nil, nil, nil
local base_stats = {
    hp = 1000,
    mp = 500.5,
    name = "Hero",
    is_alive = true,
    status = nil
}

local function make_damage_calculator(base_multiplier)
    local combo_count = 0
    
    return function(weapon_damage, is_crit)
        combo_count = combo_count + 1
        local final_damage = weapon_damage * base_multiplier

        if is_crit then
            final_damage = final_damage * 2.5
        end
        return final_damage, combo_count
    end
end

local calc_dmg = make_damage_calculator(1.2)

local hit1, hits_total = calc_dmg(45, false)
local hit2, hits_total2 = calc_dmg(50, true)

local function math_torture(x, y)
    local a = x + y
    local b = x - 10
    local c = 100 * y
    local d = x / 2.5
    local e = y % 3
    local f = x ^ 2
    local g = "Str" .. "ing"
    local h = g .. x
    local i = -(a)
    local j = not (b > 0)
    local k = #g
    return a, b, c, d, e, f, g, i, j, k
end

local function inventory_system()
    local inv = {}
    
    inv.sword = "Iron Sword"
    inv.shield = "Wooden Shield"

    inv[1] = "Potion"
    inv[2] = "Elixir"
    
    local weapon = inv.sword
    local item = inv[1]

    local key = "shield"
    local defense = inv[key]
    inv[key] = "Steel Shield"
    
    return inv
end

local function loop_torture()
    local sum = 0
 
    for i = 1, 100, 2 do
        sum = sum + i
    end

    local test_table = {a=1, b=2, c=3}
    local concat_str = ""
    for k, v in pairs(test_table) do
        concat_str = concat_str .. k
        sum = sum + v
    end
    
    local counter = 10
    while counter > 0 do
        counter = counter - 1
    end
    
    repeat
        counter = counter + 1
    until counter >= 10
    
    return sum
end

local function comparison_torture(val)
    if val < 10 then
        return -1
    elseif val >= 100 then 
        return 1
    elseif val == "admin" then
        return 999
    elseif val ~= true then 
        return 0
    end
    return 42
end

local function tail_call_target(a, b, c)
    return a + b + c
end

local function vararg_and_tailcall(prefix, ...)
    local args = {...}
    
    if #args < 3 then
        return prefix
    end
    
    -- Tail Call (CALLT)
    return tail_call_target(args[1], args[2], args[3])
end

-- MAIN EXECUTION
local function main()
    local m1, m2, m3 = math_torture(15, 7)
    local inv = inventory_system()
    local loop_res = loop_torture()
    local comp_res = comparison_torture(50)
    
    local final_val = vararg_and_tailcall("Result", 10, 20, 30)
    
    _G.DEBUG_OUTPUT = final_val
end

main()