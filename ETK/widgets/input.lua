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
            cursorColor     = {{000,000,020},{000,000,020}},
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
            self.cursorPos = tostring(self.value):ulen()
            self.cursorX = 0
            self.cursorDirty = true

            local style = arg.style or Input.defaultStyle
            self.style = style

            local dimension = Dimension(style.defaultWidth, style.defaultHeight)
            Widget.init(self, arg.position, dimension)
        end

        function Input:setValue(val)
            if val then
                if self.number then
                    self.value = type(val) == "number" and val or 0
                else
                    self.value = tostring(val)
                end
            else
                self.value = self.number and 0 or ""
            end
            self:doValueChange()
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

            if strWidth < width - 3 or not self.hasFocus then
                gc:drawString(text, x + 2, y, "top")
            else
                -- TODO: FIX POSITION WHERE strWidth>width AND self.cursorPos ISN'T AT THE END
                gc:drawString(text, x - 3 + width - strWidth, y, "top")
            end
            if self.hasFocus then
                if self.cursorDirty then
                    self.cursorX = gc:getStringWidth(value:usub(1, self.cursorPos)) + 2
                    self.cursorDirty = false
                end
                gc:setColorRGB(unpackColor(style.cursorColor[color]))
                if strWidth < width - 3 then
                    gc:drawLine(x + self.cursorX, y+2, x + self.cursorX, y+height-2)
                else
                    local xx = x + self.cursorX - (strWidth - width) - 4
                    gc:drawLine(xx, y+2, xx, y+height-2)
                end
            end

            gc:smartClipRect("restore")
        end

        ------------------------
        -- Handle input event --
        ------------------------

        function Input:doValueChange()
            self.cursorDirty = true
            CallEvent(self, "onValueChange", self.value)
        end

        function Input:charIn(char)
            if self.disabled then
                return
            end

            local newValue = tostring(self.value)

            if self.cursorPos >= 0 and self.cursorPos < newValue:ulen() then
                newValue = newValue:usub(1, self.cursorPos) .. char .. newValue:usub(self.cursorPos+1)
            else
                newValue = newValue .. char
            end

            if self.number then
                newValue = tonumber(newValue)
            end

            if not newValue then
                return
            end

            self.value = newValue
            self.cursorPos++

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:clearKey()
            if self.disabled then
                return
            end

            self.value = self.number and 0 or ""
            self.cursorPos = self.number and 1 or 0

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:backspaceKey()
            if self.disabled then
                return
            end

            local newValue = tostring(self.value)

            if self.cursorPos == 0 then
                return
            elseif self.cursorPos > 0 and self.cursorPos < newValue:ulen() then
                newValue = newValue:usub(1, self.cursorPos-1) .. newValue:usub(self.cursorPos+1)
            else
                newValue = tostring(self.value):usub(1,-2)
            end

            if self.number then
                newValue = tonumber(newValue)
            end

            if newValue and tostring(newValue):ulen() > 0 then
                self.value = newValue
                self.cursorPos--
            else
                if self.number then
                    self.value = 0
                    self.cursorPos = 1
                else
                    self.value = ""
                    self.cursorPos = 0
                end
            end

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:deleteKey()
            if self.disabled then
                return
            end

            local newValue = tostring(self.value)

            if self.cursorPos == newValue:ulen() then
                return
            elseif self.cursorPos >= 0 then
                newValue = newValue:usub(1, self.cursorPos) .. newValue:usub(self.cursorPos+2)
            end

            if self.number then
                newValue = tonumber(newValue)
            end

            if newValue and tostring(newValue):ulen() > 0 then
                self.value = newValue
            else
                if self.number then
                    self.value = 0
                    self.cursorPos = 1
                else
                    self.value = ""
                    self.cursorPos = 0
                end
            end

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:arrowUp()
            if not self.disabled and self.number then
                self.value++
                self:doValueChange()
                self.parent:invalidate()
            end
        end

        function Input:arrowDown()
            if not self.disabled and self.number then
                self.value--
                self:doValueChange()
                self.parent:invalidate()
            end
        end

        function Input:arrowLeft()
            if self.disabled then
                return
            end
            if self.cursorPos > 0 then
                self.cursorPos--
                self.cursorDirty = true
                self.parent:invalidate()
            end
        end

        function Input:arrowRight()
            if self.disabled then
                return
            end
            if self.cursorPos < tostring(self.value):ulen() then
                self.cursorPos++
                self.cursorDirty = true
                self.parent:invalidate()
            end
        end

    end

end
