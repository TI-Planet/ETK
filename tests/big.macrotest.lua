-----------------------------------------
-- Start of ../extra/lua_additions.lua --
-----------------------------------------

-- The following defines/macros are supposed to be used for simple cases only 
-- (within simple syntax constructs that wouldn't confuse the "parser". See examples.)

--Lua variable pattern


--Lambda style!


--Indexing of strings, string:sub(index, index)


--Increment/Decrement (Note: just use that in a "standalone way", not like: print(a = a + 1) etc.)



--Compound assignment operators


---------------------------------------
-- End of ../extra/lua_additions.lua --
---------------------------------------

---------------------------------
-- Start of ../extra/bitop.lua --
---------------------------------

-- Needs the lua_additions to also be included at some point (for the LuaVar pattern)

-- The following defines/macros are supposed to be used for simple cases only 
-- (within simple syntax constructs that wouldn't confuse the "parser". See examples.)

--Bitwise operators





--Compound assignment operators












--------------------------------------------------------------------------------------------------------
-- Bit operations
-- Adapted from Jim's Chip-8 emulator ( https://github.com/jimbauwens/chip-8/blob/master/main.lua )
--------------------------------------------------------------------------------------------------------

-- TODO : well, maybe change that 2^32 limit. It's a time/perf trade-off, though.


local _bitop = {
    _and = function(a, b)
        local result = 0
        local d = 2^32
        while d >= 1 do
            d = d/2
            local aa,bb = a-d, b-d
            local aaa,bbb = aa>=0, bb>=0
            if aaa and bbb then result = result + d end
            if aaa then a = aa end
            if bbb then b = bb end
        end
        return result
    end,

    _or = function(a, b)
        local result = 0
        local d = 2^32
        while d >= 1 do
            d = d/2
            local aa,bb = a-d, b-d
            local aaa,bbb = aa>=0, bb>=0
            if aaa or bbb then result = result + d end
            if aaa then a = aa end
            if bbb then b = bb end
        end
        return result
    end,

    _xor = function(a, b)
        local result = 0
        local d = 2^32
        while d >= 1 do
            d = d/2
            local aa,bb = a-d, b-d
            local aaa,bbb = aa>=0, bb>=0
            if aaa ~= bbb then result = result + d end
            if aaa then a = aa end
            if bbb then b = bb end
        end
        return result
    end,

    _shiftLeft = function(int, n)
        return int*2^n
    end,

    _shiftRight = function(int, n)
        return math.floor(int/2^n)
    end
}

-------------------------------
-- End of ../extra/bitop.lua --
-------------------------------





local myString = [[
	this is a pretty multi-line string
	abc
	test
]]

local a = 0
a = a + 1
print(a)
a = a - 2
print(a)

local b = {[42]=9000}
print(b[42])
b[42] = b[42] + 1
print(b[42])

local c = 84
c = _bitop._shiftRight(c, 1)
print(_bitop._shiftLeft(21, 1), c)

newStringA = myString:gsub("(.)", (function ( x ) return  x..x end))
print(newStringA)

newStringB = myString:gsub("()", (function ( x ) return  myString:sub(x, x) end)) 
print(newStringB)

print("ETK Version 4.0")
print("Why would I help you")

local myString = "ETK Version 4.0"

for i=1, #myString do
	print(myString:sub(i, i))
end
