----------------------------------
-- ETK Graphics                 --
-- Some flags and functions     --
-- for painting and more        --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------

do
    etk.graphics = {}
    local eg = etk.graphics
    
    eg.needsFullRedraw = true
    eg.dimensionsChanged = true
    
    eg.isColor = platform.isColorDisplay()
    
    eg.viewPortWidth  = 318
    eg.viewPortHeight = 212
    
    eg.areaToRedraw = {0, 0, 0, 0}
    
    
    ------------------------------------------------
    -- Replacement for platform.window:invalidate --
    ------------------------------------------------
    
    eg.invalidate = function (x, y, w, h)
        platform.window:invalidate(x, y, w, h)
        
        if x then
            eg.needsFullRedraw = false
            eg.areaToRedraw = {x, y, w, h}
        end
    end
    
    
    ----------------------------------------------
    -- Replacement for graphicalContex:clipRect --
    ----------------------------------------------
    
    local clipRectData  = {}
    local clipRects = 0
    
    local gc_clipRect = function (gc, what, x, y, w, h)
        if what == "set"  then
            clipRects = clipRects + 1
            clipRectData[clipRects] = {x, y, w, h}
                        
        elseif what == "subset" and clipRects > 0 then
            local old  = clipRectData[clipRects]
            
            x   = old[1] < x and x or old[1]
            y   = old[2] < y and y or old[2]
            h   = old[2] + old[4] > y + h and h or old[2] + old[4] - y
            w   = old[1] + old[3] > x + w and w or old[1] + old[3] - x
            
            what = "set"
            
            clipRects = clipRects + 1
            clipRectData[clipRects] = {x, y, w, h}
            
        elseif what == "restore" and clipRects > 0 then
            what = "set"
            
            clipRectData[clipRects] = nil
            clipRects = clipRects - 1
            
            local old  = clipRectData[clipRects]
            x, y, w, h = old[1], old[2], old[3], old[4]
            
        elseif what == "restore" then
            what = "reset"
        end
            
        gc:clipRect(what, x, y, w, h)
    end
    
    --------------------------------------
    -- platform.withGC for apiLevel < 2 --
    --------------------------------------
    
    if not platform.withGC then
        platform.withGC = function (f, ...)
            local gc = platform.gc()
            gc:begin()
            local args = {...}
            args[#args+1] = gc
            local results = { f(unpack(args)) }
            gc:finish()
            return unpack(results)
        end
    end
    
    ---------------------------------
    -- Patch the Graphical Context --
    ---------------------------------
    
    local addToGC = function (name, func)
        local gcMeta = platform.withGC(getmetatable)
        gcMeta[name] = func
    end
    
    ------------------------
    -- Apply some patches --
    ------------------------
    
    addToGC("smartClipRect", gc_clipRect)
    
end
