----------------------------------
-- ETK Screenmanager            --
-- stuff and stuff I guess      --
-- cookies                      --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------

do etk.RootScreen = {}
    local RootScreen = etk.RootScreen
    local eg = etk.graphics

    local x, y = 0, 0

    ---------------------
    -- Screen handling --
    ---------------------

    RootScreen.screens = {}
    local screens = RootScreen.screens

    function RootScreen:pushScreen(screen, args)
        screen:onPushed(args)

        table.insert(screens, screen)
        screen.parent = self
    end

    function RootScreen:popScreen(args)
        local index = #screens
        screens[index]:onPopped(args)

        return table.remove(screens, index)
    end

    function RootScreen:peekScreen()
        return screens[#screens] or RootScreen
    end

    ----------------------------
    -- Dimension and position --
    ----------------------------

    function RootScreen:getDimension()
        return eg.viewPortWidth, eg.viewPortHeight
    end

    function RootScreen:getPosition()
        return x, y
    end

    -------------------
    -- Draw children --
    -------------------

    function RootScreen:paint(gc)
        for k, screen in ipairs(self.screens) do
            screen:paint(gc)
        end
    end

    ----------------
    -- Invalidate --
    ----------------

    function RootScreen:invalidate()
        eg.invalidate()
    end
end

------------------
-- Screen class --
------------------

do etk.Screen = class()
    local Screen = etk.Screen
    local eg = etk.graphics

    function Screen:init(position, dimension)
        self.parent = parent
        self.position = position
        self.dimension = dimension

        self.children = {}
    end

    --------------------------------
    -- Dimension helper functions --
    --------------------------------

    function Screen:getDimension()
        local parentWidth, parentHeight = self.parent:getDimension()

        return self.dimension:get(parentWidth, parentHeight, eg.dimensionsChanged)
    end

    function Screen:getPosition()
        local parentX, parentY = self.parent:getPosition()
        local parentWidth, parentHeight = self.parent:getDimension()
        local width, height = self:getDimension()

        return self.position:get(parentX, parentY, parentWidth, parentHeight, width, height, eg.dimensionsChanged)
    end

    function Screen:containsPosition(x, y)
        local cachedX, cachedY = self.position:getCachedPosition()
        local cachedWidth, cachedHeight = self.dimension:getCachedDimension()

        return x >= cachedX and y >= cachedY and x < cachedX + cachedWidth and y < cachedY + cachedHeight
    end

    ---------------------
    -- Manage children --
    ---------------------

    function Screen:addChild(child)
        table.insert(self.children, child)
        child.parent = self
    end

    function Screen:addChildren(...)
        for k, child in ipairs{...} do
            self:addChild(child)
        end
    end

    ----------------
    -- Invalidate --
    ----------------

    function Screen:invalidate()
        local cachedX, cachedY = self.position:getCachedPosition()
        local cachedWidth, cachedHeight = self.dimension:getCachedDimension()

        eg.invalidate(cachedX, cachedY, cachedWidth, cachedHeight)
    end

    -------------------
    -- Screen events --
    -------------------

    function Screen:onPushed(args)
        -- when pushed
    end

    function Screen:onPopped(args)
        -- when popped
    end

    --------------------
    -- Drawing events --
    --------------------

    function Screen:paint(gc)
        self:prepare(gc)

        local width, height = self:getDimension()
        local x, y = self:getPosition()

        --debug draw bouding boxes
        --gc:drawRect(x, y, width, height)

        self:draw(gc, x, y, width, height, eg.isColor)

        for k, screen in ipairs(self.children) do
            screen:paint(gc)

            -- Reset color to default
            -- Possibly this should also be done with the pen and the font
            gc:setColorRGB(0,0,0)
        end

        self:postDraw(gc, x, y, width, height, eg.isColor)
    end

    function Screen:prepare(gc)
        -- use this callback to calculate dimensions
    end

    function Screen:draw(gc, x, y, width, height, isColor)
        -- all drawing should happen here

        -- called before drawing children
    end

    function Screen:postDraw(gc, x, y, width, height, isColor)
        -- all drawing should happen here

        -- called after drawing children
    end
end
