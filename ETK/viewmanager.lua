----------------
-- View class --
----------------

do etk.View = class(etk.Screen)
	local View   = etk.View
	local Screen = etk.Screen
	local eg     = etk.graphics
	
	function View:init(args)
		args = args or {}
		
		local dimension = args.dimension or Dimension()
		local position  = args.position  or Position()
		
		Screen.init(self, position, dimension)
		
		self.focusIndex = 0
	end
	
	-----------------
	-- Focus logic --
	-----------------
	
	function View:switchFocus(direction, isChildView, counter)		
		local children = self.children
		
		local focusIndex = self.focusIndex
		
		local currentChild = children[focusIndex]
		local continue = true
		
		if currentChild and currentChild.focusIndex then
			continue = not currentChild:switchFocus(direction, true, 0) -- do we need to handle the focus change
		end
		
		if continue then
			
			if counter > #children then
				return
			else
				counter = counter + 1
			end
				
			self:removeFocusFromChild(currentChild)
			
			local nextFocusIndex = focusIndex + direction
			local childrenCount = #self.children
			local wrapped = false
			
			if nextFocusIndex > childrenCount then
				nextFocusIndex = 1
				wrapped = true
			elseif nextFocusIndex <= 0 then
				nextFocusIndex = childrenCount
				wrapped = true
			end
			
			if wrapped and isChildView then
				return false -- we are not handling the focus change due to wrapping, the parent focus manager needs to handle it
			else
				return self:giveFocusToChildAtIndex(nextFocusIndex, direction, isChildView, counter)
			end
		end
	end
	
	function View:removeFocusFromChild(child)
		if child then
			self.focusIndex = 0
			child.hasFocus = false
			CallEvent(child, "onBlur")
		end
	end
	
	function View:removeFocusFromChildAtIndex(index)
		self:removeFocusFromChild(self:getFocusedChild())
	end
	
	function View:giveFocusToChildAtIndex(index, direction, isChildView, counter)
		local nextChild = self.children[index]
		self.focusIndex = index
		
		if nextChild then
			if nextChild.ignoreFocus and direction and counter then
				self:switchFocus(direction, false, counter)
			else
				nextChild.hasFocus = true
				CallEvent(nextChild, "onFocus")
			end
		end
	end
	
	function View:getFocusedChild()
		return self.children[self.focusIndex]
	end
	
	-------------------------------------
	-- Link tab events to focus change --
	-------------------------------------
	
	function View:tabKey()
		self:switchFocus(1, false, 0)
		
		eg.invalidate()
	end
	
	function View:backtabKey()
		self:switchFocus(-1, false, 0)
		eg.invalidate()
	end
	
	-----------------------------------
	-- Link touch event focus change --
	-- and propagete the event       --
	-----------------------------------
	
	View.lastChildMouseDown = nil
	View.lastChildMouseOver = nil
	
	
	function View:getChildIn(x, y)
		local lastChildIndex = View.lastChildMouseDown
		
		if lastChildIndex then
			local lastChild = self.children[lastChildIndex]
			if lastChild and lastChild:containsPosition(x, y) then
				return lastChildIndex, lastChild
			end
		end
		
		for index, child in pairs(self.children) do
			if child:containsPosition(x, y) then
				return index, child
			end
		end 
	end
	
	function View:mouseDown(x, y) 
		local index, child = self:getChildIn(x, y)
		
		local lastChild = self:getFocusedChild()
		if child ~= lastChild then
			self:removeFocusFromChild(lastChild)
			
			if index then
				self:giveFocusToChildAtIndex(index)
			end
		end
		
		View.lastChildMouseDown = index
		
		if child then
			CallEvent(child, "onMouseDown", x, y)
		end
		
		self:invalidate()
	end
	
	function View:mouseUp(x, y)
		local lastChildIndex = View.lastChildMouseDown
		
		if lastChildIndex then
			local lastChild = self.children[lastChildIndex]
			CallEvent(lastChild, "onMouseUp", x, y, lastChild:containsPosition(x, y))
		end
		
		self:invalidate()
	end
	
	---------------------------------------------
	-- Propagate other events to focused child --
	---------------------------------------------
	
	function View:onEvent(event, eventHandler, ...)
		Logger.Log("View %q - event %q - eventHandler %q", tostring(self), tostring(event), tostring(eventHandler))
		
		local child = self:getFocusedChild()
		
		--if not eventHandler and child then -- TODO: ADD event propogation block support
		if child then
			CallEvent(child, "onEvent", event, child[event], ...)
			CallEvent(child, event, ...)
		end
	end
end