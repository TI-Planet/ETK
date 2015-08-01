-------------------
-- Widget things --
-------------------

etk.Widgets = {}

do etk.Widget = class(etk.Screen)
    local Widget = etk.Widget
    local Screen = etk.Screen

    function Widget:init(position, dimension)
        Screen.init(self, position, dimension)

        self.hasFocus = false;
    end

end


do Box = class(etk.Widget)
    local Widget = etk.Widget

    function Box:init(position, dimension, text)
        Widget.init(self, position, dimension)

        self.text = text
    end

    function Box:draw(gc, x, y, width, height, isColor)
        Logger.Log("In Box:draw %d, %d, %d, %d", x, y, width, height)

        gc:setColorRGB(0, 0, 0)

        if self.hasFocus then
            gc:fillRect(x, y, width, height)
        else
            -- No, draw only the outline
            gc:drawRect(x, y, width, height)
        end

        gc:setColorRGB(128, 128, 128)
        gc:setFont("sansserif", "r", 7)

        if self.text then
            gc:drawString(self.text, x+2, y, "top")
            gc:drawString(width .. "," .. height, x+2, y+9, "top")
        end
    end

end

--include "widgets/button.lua"
--include "widgets/input.lua"
--include "widgets/label.lua"
