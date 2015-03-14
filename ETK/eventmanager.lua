----------------------------------
-- ETK Event Manager            --
-- Handle the events!           --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------

do
	etk.eventmanager = {}
	etk.eventhandlers = {}

	local em = etk.eventmanager
	local eh = etk.eventhandlers
	local eg = etk.graphics
	local rs = etk.RootScreen
	
	-----------
	-- TOOLS --
	-----------
		
	-- We will use this function when calling events
	local callEventHandler = function (func, ...)
		if func then
			func(...)
		end
	end
	
	
	-------------------
	-- EVENT LINKING --
	-------------------
	
	local eventLinker = {}
	local triggeredEvent
	
	local eventDistributer = function (...)
		local currentScreen = rs:peekScreen()
		local eventHandler = currentScreen[triggeredEvent]
		
		local genericEventHandler = currentScreen.onEvent
		if genericEventHandler then
			genericEventHandler(currentScreen, triggeredEvent, eventHandler, ...)
		end
		
		if eventHandler then
			eventHandler(currentScreen, ...)
		end
	end
	
	eventLinker.__index = function (on, event)
		triggeredEvent = event	
		return eventDistributer
	end
	
	setmetatable(on, eventLinker)
	
	on.activate = function () 
		eg.needsFullRedraw = true
	end
	
	on.getFocus = function ()
		eg.needsFullRedraw = true
	end
	
	on.resize = function (width, height)
		Logger.Log("Viewport dimensions changed to %dx%d", width, height)
	
		eg.dimensionsChanged = true
		eg.needsFullRedraw = true
		
		eg.viewPortWidth  = width
		eg.viewPortHeight = height
	end
	
	on.paint = function(gc)
		gc:smartClipRect("set", 0, 0, eg.viewPortWidth, eg.viewPortHeight)

		--eventLinker.__index(on, "paint")(gc)
		rs:paint(gc, 0, 0, eg.viewPortWidth, eg.viewPortHeight)
		
		eg.dimensionsChanged = false
	end
	
end
