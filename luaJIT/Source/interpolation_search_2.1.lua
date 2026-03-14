-- function to search an item in the list
function interpolation_search(list, item)
   local low = 1
   local high = #list

   -- loop until item is in between low and high indices
   while low <= high and item >= list[low] and item <= list[high] do
      -- if item is found, return the index
      if low == high then
         if list[low] == item then 
            return low 
         else 
            return nil 
         end
      end

      -- Estimate the position by interpolation
      local pos = low + math.floor(((high - low) / (list[high] - list[low])) * (item - list[low]))

      -- if item is found else update low and high accordingly
      if list[pos] == item then
         return pos
      elseif list[pos] < item then
         low = pos + 1
      else
         high = pos - 1
      end
   end
   return nil
end

-- Example Usage
local numbers = {1, 2, 4, 5, 8, 9}
local item = 8
local index = interpolation_search(numbers, item)
if index then
   print("Item", item, "found, index:", index) -- Output: Item 8 found at index: 3
else
   print("Item", item, "not found in the list.")
end

item = 3
index = interpolation_search(numbers, item)
if index then
   print("Item", item, "found at index:", index)
else
   print("Item", item, "not present.") -- Output: Item 3 not found in the list.
end