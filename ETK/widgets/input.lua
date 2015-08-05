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

        local prev__index = Input.__index
        function Input:__index(idx)
            return idx == "value" and self._value or prev__index(self, idx)
        end

        function Input:__newindex(idx, val)
            if idx == "value" then
                self:setValue(val)
                self.parent:invalidate()
            else
                rawset(self, idx, val)
            end
        end

        function Input:init(arg)
            self.number = arg.number == true
            self:setValue(arg.value or "")
            self.disabled = arg.disabled
            self.cursorPos = tostring(self._value):ulen()
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
                    self._value = type(val) == "number" and val or 0
                else
                    self._value = tostring(val)
                end
            else
                self._value = self.number and 0 or ""
            end
            self.cursorPos = tostring(self._value):ulen()
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

            if self.disabled or self._value == "" then
                gc:setColorRGB(unpackColor(style.focusColor[color]))
            end

            local value = tostring(self._value)
            local text = value

            if value == "" then
                text = self.placeholder or value
            end

            if self.cursorDirty then
                self.cursorX = gc:getStringWidth(value:usub(1, self.cursorPos)) + 2
                self.cursorDirty = false
            end

            -- TODO: make 3 a constant value

            local strWidth = gc:getStringWidth(text)
            local xOffset = width - 3 - strWidth

            if not (xOffset < 0 and self.hasFocus) then
                xOffset = 0
            elseif self.cursorX < -xOffset then
                xOffset = -self.cursorX + 3
            end

            gc:drawString(text, x + xOffset + 2, y, "top")

            if self.hasFocus then
                gc:setColorRGB(unpackColor(style.cursorColor[color]))
                gc:drawLine(x + self.cursorX + xOffset, y+2, x + self.cursorX + xOffset, y+height-2)
            end

            gc:smartClipRect("restore")
        end

        ------------------------
        -- Handle input event --
        ------------------------

        function Input:doValueChange()
            self.cursorDirty = true
            CallEvent(self, "onValueChange", self._value)
        end

        function Input:charIn(char)
            if self.disabled then
                return
            end

            local newValue = tostring(self._value)

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

            self._value = newValue
            self.cursorPos++

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:clearKey()
            if self.disabled then
                return
            end

            self._value = self.number and 0 or ""
            self.cursorPos = self.number and 1 or 0

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:backspaceKey()
            if self.disabled then
                return
            end

            local newValue = tostring(self._value)

            if self.cursorPos == 0 then
                return
            elseif self.cursorPos > 0 and self.cursorPos < newValue:ulen() then
                newValue = newValue:usub(1, self.cursorPos-1) .. newValue:usub(self.cursorPos+1)
            else
                newValue = tostring(self._value):usub(1,-2)
            end

            if self.number then
                newValue = tonumber(newValue)
            end

            if newValue and tostring(newValue):ulen() > 0 then
                self._value = newValue
                self.cursorPos--
            else
                if self.number then
                    self._value = 0
                    self.cursorPos = 1
                else
                    self._value = ""
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

            local newValue = tostring(self._value)

            if self.cursorPos == newValue:ulen() then
                return
            elseif self.cursorPos >= 0 then
                newValue = newValue:usub(1, self.cursorPos) .. newValue:usub(self.cursorPos+2)
            end

            if self.number then
                newValue = tonumber(newValue)
            end

            if newValue and tostring(newValue):ulen() > 0 then
                self._value = newValue
            else
                if self.number then
                    self._value = 0
                    self.cursorPos = 1
                else
                    self._value = ""
                    self.cursorPos = 0
                end
            end

            self:doValueChange()
            self.parent:invalidate()
        end

        function Input:arrowUp()
            if not self.disabled and self.number then
                self._value++
                self:doValueChange()
                self.parent:invalidate()
            end
        end

        function Input:arrowDown()
            if not self.disabled and self.number then
                self._value--
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
            if self.cursorPos < tostring(self._value):ulen() then
                self.cursorPos++
                self.cursorDirty = true
                self.parent:invalidate()
            end
        end

    end

end
