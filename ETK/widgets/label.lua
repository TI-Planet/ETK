------------------
-- Label widget --
------------------

do
    local Widget  = etk.Widget
    local Widgets = etk.Widgets
    
    do Widgets.Label = class(Widget)
        local Widget = etk.Widget
        local Label = Widgets.Label
        
        Label.defaultStyle = {
            textColor       = {{000,000,000},{000,000,000}},
            --backgroundColor = {{248,252,248},{248,252,248}},
            
            defaultWidth = 20,
            defaultHeight = 30,
            
            font = {
                serif="sansserif",
                style="r",
                size=10
            }
        }
        
        function Label.TextPart(gc, text, max)
            local out = ""
            
            local width = gc:getStringWidth(text)
            
            if width < max then
                return text
            else
                for i=1, #text do
                    local part = text:usub(1, i)
                    if gc:getStringWidth(part .. "..") > max then
                        break
                    end
                    out = part
                end
                
                return out .. ".."
            end
        end
    
        function Label:init(arg)    
            self.text = arg.text or "Button"
            
            local style = arg.style or Label.defaultStyle
            self.style = style
            self.limit = false
            self.ignoreFocus = true
            
            local dimension = Dimension(style.defaultWidth, style.defaultHeight)
            
            Widget.init(self, arg.position, dimension)
        end
        
        function Label:prepare(gc)
            local font = self.style.font
            
            gc:setFont(font.serif, font.style, font.size)
            
            if not self.limit then
                self.dimension.width = gc:getStringWidth(self.text)
                self.dimension.height = gc:getStringHeight(self.text)
                
                self.dimension:invalidate()
                self.position:invalidate()
            end
        end
        
        function Label:draw(gc, x, y, width, height, isColor)
            local color = isColor and 1 or 2
            local style = self.style
                        
            gc:setColorRGB(unpackColor(style.textColor[color]))
            
            local displayText = self.limit and Label.TextPart(gc, self.text, width) or self.text
            
            gc:drawString(displayText, x, y, "top")
        end
    end

end
