function jump_search(list, item)
   local n = #list  -- size of the list
   local step = math.floor(math.sqrt(n)) -- steps to skip
   local prev = 1

   -- Find the block where the item can be found
   while prev < n and list[math.min(step, n)] < item do
      prev = step
      step = step + math.floor(math.sqrt(n))
   end

   -- Perform linear search in the block
   while prev <= math.min(step, n) do
      if list[prev] == item then
         return prev
      end
      prev = prev + 1
   end
   return nil -- Return nil if the item is not found
end

-- Example Usage
local numbers = {1, 2, 4, 5, 8, 9}
local item = 8
local index = jump_search(numbers, item)
if index then
   print("Item", item, "found, index:", index) -- Output: Item 8 found at index: 3
else
   print("Item", item, "not found in the list.")
end

item = 3
index = jump_search(numbers, item)
if index then
   print("Item", item, "found at index:", index)
else
   print("Item", item, "not present.") -- Output: Item 3 not found in the list.
end