-- The following defines/macros are supposed to be used for simple cases only 
-- (within simple syntax constructs that wouldn't confuse the "parser". See examples.)

--Lua variable pattern
--define "__LuaVar__" "[%w%._%[%]]+"

--Lambda style!
--define "λ(.-)->(.-);" "(function (%1) %2 end)"
--define "λ(.-)=>(.-);" "(function (%1) return %2 end)"


--Indexing of strings, string[~index]
--define "(%w+)%[%~(%w+)%]" "%1:sub(%2, %2)"

--Increment/Decrement (Note: just use that in a "standalone way", not like: print(a++) etc.)
--define "(__LuaVar__)%+%+" "%1 = %1 + 1"
--define "(__LuaVar__)%-%-" "%1 = %1 - 1"

--Compound assignment operators
--define "(__LuaVar__)%+=(__LuaVar__)" "%1 = %1 + %2"
--define "(__LuaVar__)%-=(__LuaVar__)" "%1 = %1 - %2"