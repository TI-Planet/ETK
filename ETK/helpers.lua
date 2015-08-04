----------------------------------
-- ETK Helpers / Utilities      --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------

------------------
-- Enumerations --
------------------

Enum = function(enumTable)
    for k,v in ipairs(enumTable) do
        enumTable[v] = k
    end

    return enumTable
end


-------------
-- Logging --
-------------

do Logger = {}
    Logger.Log = function (message, ...)
        print(message:format(...))
    end

    Logger.Warn = function (message, ...)
        Logger.Log("Warning: " .. message, ...)
    end
end


-----------------------------------------------
-- Handle different types of user unit input --
-----------------------------------------------

do UnitCalculator = {}
    UnitCalculator.GetAbsoluteValue = function (value, referenceValue)
        local numberValue, unit = string.match(tostring(value), "([-%d.]+)(.*)")

        local number = tonumber(numberValue)

        if not number then
             Logger.Warn("UnitCalculator.GetAbsoluteValue - Invalid number value, returning 0")
             return 0
        end

        local isPercent = unit == "%"

        if number < 0 then
            print(number, "from")
            number = (isPercent and 100 or referenceValue) + number
            print(number, "to")
        end

        if isPercent then
            return referenceValue / 100 * number
        else
           return number
        end
    end
end


-------------------------------------------------
-- Keep dimensions in a nice to handle wrapper --
-------------------------------------------------

do Dimension = class()
    function Dimension:init(width, height)
        self.width = width
        self.height = height
    end

    function Dimension:get(parentWidth, parentHeight, dirty)
        if self.width then
            if dirty or not self.cachedWidth then
                self.cachedWidth  = UnitCalculator.GetAbsoluteValue(self.width, parentWidth)
                self.cachedHeight = UnitCalculator.GetAbsoluteValue(self.height, parentHeight)
            end

            return self.cachedWidth, self.cachedHeight
        else
            self.cachedWidth = parentWidth
            self.cachedHeight = parentHeight

            return parentWidth, parentHeight
        end
    end

    function Dimension:getCachedDimension()
        return self.cachedWidth or 0, self.cachedHeight or 0
    end

    function Dimension:invalidate()
        self.cachedWidth = nil
        self.cachedHeight = nil
    end
end

do Position = class()
    Position.Type  = Enum { "Absolute", "Relative" }
    Position.Sides = Enum { "Left", "Right", "Top", "Bottom" }

    function Position:init(arg)
        arg = arg or {}

        self.left   = arg.left
        self.top    = arg.top
        self.bottom = arg.bottom
        self.right  = arg.right

        self.alignment = arg.alignment or {}

        if not (self.left or self.right) then
            self.left = 0
        end

        if not (self.top or self.bottom) then
            self.top = 0
        end
    end

    function Position:get(parentX, parentY, parentWidth, parentHeight, width, height, dirty)
        if dirty or not self.cachedX then
            local x, y
            local originX = parentX
            local originY = parentY

            if self.right then
                originX = originX + parentWidth
            end

            if self.bottom then
                originY = originY + parentHeight
            end

            for _, alignment in ipairs(self.alignment) do
                local side = alignment.side
                local ref = alignment.ref
                local refWidth, refHeight = ref:getDimension()
                local refX, refY = ref:getPosition()

                if side == Position.Sides.Left then
                    originX = refX
                elseif side == Position.Sides.Right then
                    originX = refX + refWidth
                elseif side == Position.Sides.Top then
                    originY = refY
                elseif side == Position.Sides.Bottom then
                    originY = refY + refHeight
                else
                    Logger.Warn("Invalid side specified")
                end
            end

            if self.left then
                x = originX + UnitCalculator.GetAbsoluteValue(self.left, parentWidth)
            elseif self.right then
                x = originX - UnitCalculator.GetAbsoluteValue(self.right, parentWidth) - width
            end

            if self.top then
                y = originY + UnitCalculator.GetAbsoluteValue(self.top, parentHeight)
            elseif self.bottom then
                y = originY - UnitCalculator.GetAbsoluteValue(self.bottom, parentHeight) - height
            end

            self.cachedX = x
            self.cachedY = y
        end

        return self.cachedX, self.cachedY
    end

    function Position:invalidate()
        self.cachedX = nil
        self.cachedY = nil
    end

    function Position:getCachedPosition()
        return self.cachedX or 0, self.cachedY or 0
    end

end


-----------
-- Color --
-----------

local function unpackColor(col)
    return col[1] or 0, col[2] or 0, col[3] or 0
end


-------------
-- Unicode --
-------------

function string.ulen(str)
    return select(2, str:gsub("[^\128-\193]", "")) -- count the number of non-continuing bytes
end


-------------------
-- Event calling --
-------------------

local CallEvent = function(object, event, ...)
    local handler = object[event]

    if handler then
        return handler, handler(object, ...)
    end
end
