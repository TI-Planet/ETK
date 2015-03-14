--include "../extra/lua_additions.lua"
--include "../extra/bitop.lua"

--define "ETK" "ETK Version 4.0"
--define "HELP" "Why would I help you"

local myString = [[
	this is a pretty multi-line string
	abc
	test
]]

local a = 0
a++
print(a)
a-=2
print(a)

local b = {[42]=9000}
print(b[42])
b[42]++
print(b[42])

local c = 84
c>>=1
print(21<<1, c)

newStringA = myString:gsub("(.)", λ x => x..x;)
print(newStringA)

newStringB = myString:gsub("()", λ x => myString[~x];) 
print(newStringB)

print("ETK")
print("HELP")

local myString = "ETK"

for i=1, #myString do
	print(myString[~i])
end
