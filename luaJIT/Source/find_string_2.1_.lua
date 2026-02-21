local start, finish = string.find(text, "%d+")
print("Digit sequence:", string.sub(text, start, finish)) -- prints Digit sequence: 1234

-- Search a pattern in the beginning of the string
local start, finish = string.find(text, "^Hello")
if start then
  print("Sentence starts with 'Hello'") -- prints Sentence starts with 'Hello'
end

-- Search a pattern at the end of the string
local start, finish = string.find(text, "%d+%$")
if not start then
  print("Sentence does not end with digits.") -- prints Sentence does not end with digits.
end