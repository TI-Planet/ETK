-------------------
-- Button widget --
-------------------

do
    local Widget  = etk.Widget
    local Widgets = etk.Widgets
    
    do Widgets.Button = class(Widget)
        local Widget = etk.Widget
        local Button = Widgets.Button
        
        Button.defaultStyle = {
            textColor       = {{000,000,000},{000,000,000}},
            backgroundColor = {{248,252,248},{248,252,248}},
            borderColor     = {{136,136,136},{160,160,160}},
            focusColor      = {{040,148,184},{000,000,000}},
            
            defaultWidth  = 48,
            defaultHeight = 27,
            font = {
                    serif="sansserif",
                    style="r",
                    size=10
                }
        }
    
        function Button:init(arg)   
            self.text = arg.text or "Button"
            
            local style = arg.style or Button.defaultStyle
            self.style = style
            
            local dimension = Dimension(style.defaultWidth, style.defaultHeight)
            
            Widget.init(self, arg.position, dimension)
        end
        
        function Button:prepare(gc)
            local font = self.style.font
            
            gc:setFont(font.serif, font.style, font.size)
            self.dimension.width = gc:getStringWidth(self.text) + 10
            self.dimension:invalidate()
            self.position:invalidate()
        end
        
        function Button:draw(gc, x, y, width, height, isColor)
            if self.meDown then
                y = y + 1
            end
            
            local color = isColor and 1 or 2
            local style = self.style
            
            gc:setColorRGB(unpackColor(style.backgroundColor[color]))
            gc:fillRect(x + 2, y + 2, width - 4, height - 4)
            
            gc:setColorRGB(unpackColor(style.textColor[color]))
            gc:drawString(self.text, x + 5, y + 3, "top")
            
            if self.hasFocus then
                gc:setColorRGB(unpackColor(style.focusColor[color]))
                gc:setPen("medium", "smooth")
            else
                gc:setColorRGB(unpackColor(style.borderColor[color]))
                gc:setPen("thin", "smooth")
            end
            
            gc:fillRect(x + 2, y, width - 4, 2)
            gc:fillRect(x + 2, y + height - 2, width - 4, 2)
            gc:fillRect(x, y + 2, 1, height - 4)
            gc:fillRect(x + 1, y + 1, 1, height - 2)
            gc:fillRect(x + width - 1, y + 2, 1, height - 4)
            gc:fillRect(x + width - 2, y + 1, 1, height - 2)
            
            if self.hasFocus then
                gc:setColorRGB(unpackColor(style.focusColor[color]))
            end
            
            gc:setPen("thin", "smooth")
        end
    
    
        function Button:doAction()
            self.parent:invalidate()
            CallEvent(self, "onAction")
        end
        
        function Button:onMouseDown()
            self.meDown = true
        end
        
        function Button:onMouseUp(x, y, onMe)
            self.meDown = false
            
            if onMe then
                self:doAction()
            end
        end
        
        function Button:enterKey()
            self:doAction()
        end
    end

end
