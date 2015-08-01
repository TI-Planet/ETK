#!/usr/bin/env lua

BUILDERV = 0.6
MAX_FILES = 100

print("----------------------------------------")
print(" TI-Nspire Lua Project Builder v" .. BUILDERV .. "a")
print(" (C) 2015 - The ETK team,")
print(" Jim Bauwens, Adrien 'Adriweb' Bertrand")
print("----------------------------------------\r\n")

-- TODO : support optional outfile explicit support (-> same name as infile, but .tns),
--        as well as options (could be used to say to do some post-processing, like calling LuaSrcDiet)

if #arg<2 then
    print"Usage: ./build.lua infile outfile.tns"
    os.exit(0)
else
    buildfilename = assert(arg[1], "You need to specify an input file name !")
    outfilename = assert(arg[2], "You need to specify an output file name !")
end

print("Project main file: " .. buildfilename .. "\r\n")

debug.traceback=nil

local luaout = ""
local luafiles = 0


function assert(bool, errormsg)
    if not bool then
        error(errormsg or "", 0)
    end
    return bool
end

function getPath(filename)
    local a, b, path = filename:find("(.*%/).*%..*")
    return path or ""
end

function processFile(filename, path)
    luafiles = luafiles + 1
    assert(luafiles <= MAX_FILES, "Too many files to include! Are you sure you don't have an include loop?")

    local out = ""

    local file = assert(io.open(filename, "r"), filename .. " could not be read! Aborting.")
    print("Processing " .. filename)

    --assert(os.execute("luac -p " .. filename) == 0, filename .. " contains a syntax error! Aborting.")

    local filecontent = file:read("*a")
    file:close()

    if filename ~= buildfilename then
        local fileheader = "-- Start of " .. filename     .. " --\r\n"
        local hbar       = string.rep("-", #fileheader-2) .. "\r\n"
        local fileend    = "-- End of " .. filename       .. " --\r\n"
        local ebar       = string.rep("-", #fileend-2)    .. "\r\n"

        filecontent = hbar .. fileheader .. hbar .. "\r\n" .. filecontent .. "\r\n" .. ebar .. fileend .. ebar
    end

    out = filecontent:gsub("%-%-include \"([^\"]*)\"", function (f) local f = path .. f return processFile(f, getPath(f)) end)

    return out
end

local macroTable = {}
function addMacro(pattern,content)
    --print("adding", pattern, content)
    macroTable[#macroTable+1] = {pattern, content}
    return ""
end

-- helper function to replace without patterns
function string.replace(str, search, replace)
    search = search:gsub("(%W)","%%%1") -- escape patterns
    replace = replace:gsub("%%", "%%%1")
    return str:gsub(search, replace)
end

-- TODO : Handle spaces in the middle of patterns... Not sure how though.
-- TODO : Maybe try to find a way to not replace stuff within strings and comments
--        The programmer could indicate a line that would have to be ignored by the project builder by making
--        it start with '@' for example, so that the builder ignores the lines (and just removes the '@' on the output file)
-- TODO : Have some kind of "include guard" mechanism for the included files to prevent them from being included several times ?
--        It could be easily done by adding the path of the included file in a table, and checking that it's not in the table before.
function processMacros(luacode)
    luacode = luacode:gsub("%-%-define \"([^\"]*)\" \"([^\"]*)\"", addMacro)

    print("Pre-processing macros...")
    for i, v in ipairs(macroTable) do
        local pattern, content = v[1], v[2]
        local toDelete = false
        for ii, vv in ipairs(macroTable) do
            local valPattern = vv[1]
            if i ~= ii and valPattern:match(pattern) then
                macroTable[ii][1] = valPattern:replace(pattern, content)
                toDelete = true
            end
        end
        if toDelete then table.remove(macroTable, i) end
    end

    print("Processing macros...")
    for i, v in ipairs(macroTable) do
        -- print(i, v[1], v[2])
        luacode = luacode:gsub(v[1], v[2])
    end

    return luacode
end

luaout = processFile(buildfilename, getPath(buildfilename))
print("\r\nSuccesully loaded " .. luafiles .. " lua files!\r\n")
luaout = processMacros(luaout)
print("")

local tmpname = "big." .. buildfilename
print("Creating temp output file "..tmpname)

local tmpfile = assert(io.open(tmpname, "w"), "Failed to create temp file. Are you sure you have permissions to the current directory ?")
tmpfile:write(luaout)
tmpfile:close()

print("Trying to build project with Luna...")
assert(os.execute("cat " .. tmpname .. " | luna - " .. outfilename), "Building with Luna failed! You can try to build " .. tmpname .. " manually")

print("\r\nBuilding successful!")
