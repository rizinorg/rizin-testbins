-- Cheking Upvalues and CLOSUREs
local function create_account(initial_balance)
    local balance = initial_balance -- This will be Upvalue for nested functions
    
    -- Table with metamethods for check OP_MMBIN и OP_SELF
    local Account = {
        owner = "Admin",
        -- Cheking numeric cycles (FORLOOP)
        calculate_interest = function(self, years, rate)
            local total = self.balance
            for i = 1, years do
                total = total + (total * rate)
            end
            return total
        end
    }

    Account.__index = Account

    -- Creating objects (NEWTABLE, SETTABLE)
    local self = setmetatable({ balance = balance }, Account)

    -- Checking logical branches (EQ, JMP, TEST)
    function self:withdraw(amount)
        if amount > 0 and self.balance >= amount then
            self.balance = self.balance - amount
            return true
        else
            return false
        end
    end

    -- Checking iterators (TFORLOOP)
    function self:batch_deposit(...)
        local args = {...} -- VARARG
        for _, val in ipairs(args) do
            self.balance = self.balance + val
        end
    end

    return self
end

-- Main block for testing CALL and constants
local my_acc = create_account(1000)
my_acc:batch_deposit(100, 200, 300)

if my_acc:withdraw(500) then
    print("New balance: " .. my_acc.balance)
end
