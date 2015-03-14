-- Needs the lua_additions to also be included at some point (for the LuaVar pattern)

-- The following defines/macros are supposed to be used for simple cases only 
-- (within simple syntax constructs that wouldn't confuse the "parser". See examples.)

--Bitwise operators
--define "(__LuaVar__)<<(__LuaVar__)" "_bitop._shiftLeft(%1, %2)"
--define "(__LuaVar__)<<(%d+)" "_bitop._shiftLeft(%1, %2)"
--define "(__LuaVar__)>>(__LuaVar__)" "_bitop._shiftRight(%1, %2)"
--define "(__LuaVar__)>>(%d+)" "_bitop._shiftRight(%1, %2)"

--Compound assignment operators
--define "(__LuaVar__)<<=(__LuaVar__)" "%1 = _bitop._shiftLeft(%1, %2)"
--define "(__LuaVar__)<<=(%d+)" "%1 = _bitop._shiftLeft(%1, %2)"
--define "(__LuaVar__)>>=(__LuaVar__)" "%1 = _bitop._shiftRight(%1, %2)"
--define "(__LuaVar__)>>=(%d+)" "%1 = _bitop._shiftRight(%1, %2)"
--define "(__LuaVar__)%^=(__LuaVar__)" "%1 = _bitop._xor(%1, %2)"
--define "(__LuaVar__)%^=(%d+)" "%1 = _bitop._xor(%1, %2)"
--define "(__LuaVar__)&=(__LuaVar__)" "%1 = _bitop._and(%1, %2)"
--define "(__LuaVar__)&=(%d+)" "%1 = _bitop._and(%1, %2)"
--define "(__LuaVar__)|=(__LuaVar__)" "%1 = _bitop._or(%1, %2)"
--define "(__LuaVar__)|=(%d+)" "%1 = _bitop._or(%1, %2)"


--------------------------------------------------------------------------------------------------------
-- Bit operations
-- Adapted from Jim's Chip-8 emulator ( https://github.com/jimbauwens/chip-8/blob/master/main.lua )
--------------------------------------------------------------------------------------------------------

-- TODO : well, maybe change that 2^32 limit. It's a time/perf trade-off, though.
--define "MAX_INT" "2^32"

local _bitop = {
    _and = function(a, b)
        local result = 0
        local d = MAX_INT
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
        local d = MAX_INT
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
        local d = MAX_INT
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
