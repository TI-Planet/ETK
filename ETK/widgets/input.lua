------------------
-- Input widget --
------------------

do
	local Widget  = etk.Widget
	local Widgets = etk.Widgets
	
	do Widgets.Input = class(Widget)
		local Widget = etk.Widget
		local Input = Widgets.Input
		
		Input.defaultStyle = {
			textColor       = {{000,000,000},{000,000,000}},
			backgroundColor = {{255,255,255},{255,255,255}},
			borderColor     = {{136,136,136},{160,160,160}},
			focusColor      = {{040,148,184},{000,000,000}},
			disabledColor   = {{128,128,128},{128,128,128}},
			
			defaultWidth  = 100,
			defaultHeight = 20,
			
			font = {
					serif="sansserif",
					style="r",
					size=10
				}
		}
		
		function Input:init(arg)	
			self.value = arg.value or ""
			self.disabled = arg.disabled
			
			local style = arg.style or Input.defaultStyle
			self.style = style
			
			local dimension = Dimension(style.defaultWidth, style.defaultHeight)
			
			Widget.init(self, arg.position, dimension)
		end
		
		function Input:draw(gc, x, y, width, height, isColor)
			local color = isColor and 1 or 2
			local style = self.style
			local font = style.font
			
			gc:setFont(font.serif, font.style, font.size)
			
			gc:setColorRGB(unpackColor(style.backgroundColor[color]))
			gc:fillRect(x, y, width, height)
		
			gc:setColorRGB(unpackColor(style.borderColor[color]))
			gc:drawRect(x, y, width, height)
			
			if self.hasFocus then
				gc:setColorRGB(unpackColor(style.focusColor[color]))
				gc:drawRect(x - 1, y - 1, width + 2, height + 2)
				gc:setColorRGB(0, 0, 0)
			end
			
			gc:smartClipRect("subset", x, y, width, height)
			
			if self.disabled or self.value == "" then
				gc:setColorRGB(unpackColor(style.focusColor[color]))
			end
			
			local value = tostring(self.value)
			local text = value
			
			if value == "" then
				text = self.placeholder or value
			end
			
			local strWidth = gc:getStringWidth(text)
			
			if strWidth < width - 4 or not self.hasFocus then
				gc:drawString(text, x + 2, y + 1, "top")
			else
				gc:drawString(text, x - 4 + width - strWidth, y + 1, "top")
			end
			
			if self.hasFocus and value ~= "" then
				gc:fillRect(x + (text == value and strWidth + 2 or width - 4), y+2, 1, height-3)
			end
			
			gc:smartClipRect("restore")
		end
	
		------------------------
		-- Handle input event --
		------------------------
		
		function Input:doValueChange()
			CallEvent(self, "onValueChange", self.value)
		end
	
		function Input:charIn(char)
			if self.disabled then
				return
			end

			local newValue = self.value .. char
			
			if self.number then
				newValue = tonumber(newValue)
			end
			
			if not newValue then
				return
			end
			
			self.value = newValue

			self:doValueChange()
			self.parent:invalidate()
		end
		
		function Input:clearKey()
			if self.disabled then
				return
			end

			self.value = self.number and 0 or ""
			self:doValueChange()
			self.parent:invalidate()
		end
		
		function Input:backspaceKey()
			if self.disabled then
				return
			end

			local newValue = tostring(self.value):usub(1,-2)
			
			if self.number then
				newValue = tonumber(newValue)
			end
			
			if newValue then
				self.value = newValue
			else
				self.value = self.number and 0 or ""
			end

			self:doValueChange()
			self.parent:invalidate()
		end
	
	end

end
