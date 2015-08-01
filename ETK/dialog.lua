-----------------
-- Dialog view --
-----------------

do
    local View = etk.View
    
    do etk.Dialog = class(View)
        local Dialog = etk.Dialog
        
        function Dialog:invalidate()
            self.parent:invalidate()
        end
        
        function Dialog:init(title, position, dimension)
            self.title = title
            View.init(self, {position=position, dimension=dimension})
        end
        
        function Dialog:draw(gc,x, y, width, height)
            gc:setFont("sansserif", "r", 10)
            gc:setColorRGB(224, 224, 224)
            
            gc:fillRect(x, y, width, height)
        
            for i=1, 14, 2 do
                gc:setColorRGB(32+i*3, 32+i*4, 32+i*3)
                gc:fillRect(x, y + i, width, 2)
            end
            
            gc:setColorRGB(32+16*3, 32+16*4, 32+16*3)
            gc:fillRect(x, y+15, width, 10)
            
            gc:setColorRGB(128,128,128)
            gc:drawRect(x, y, width, height)
            gc:drawRect(x-1, y-1, width+2, height+2)
            
            gc:setColorRGB(96, 100, 96)
            gc:fillRect(x+width+1, y, 1, height+2)
            gc:fillRect(x, y+height+2, width+3, 1)
            
            gc:setColorRGB(104, 108, 104)
            gc:fillRect(x+width+2, y+1, 1, height+2)
            gc:fillRect(x+1, y+height+3, width+3, 1)
            gc:fillRect(x+width+3, y+2, 1, height+2)
            gc:fillRect(x+2, y+height+4, width+2, 1)
                    
            gc:setColorRGB(255, 255, 255)
            gc:drawString(self.title, x+4, y+2, "top")
        end
    end

end
