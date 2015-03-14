----------------------------------
-- ETK 4.0                      --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------

etk = {}

do
	local etk = etk
	
	--include "helpers.lua"
	--include "graphics.lua"
	--include "screenmanager.lua"
	--include "viewmanager.lua"
	--include "eventmanager.lua"
	--include "widgetmanager.lua"
	--include "dialog.lua"
end

do
	local Button = etk.Widgets.Button
	local Input = etk.Widgets.Input
	local Label = etk.Widgets.Label
	local myView = etk.View()
	
	--[[
	local box1 = Box(
					Position {
                        top  = "50px",
                        left   = "100px"
                    },
                    Dimension ("100px", "10%"),
				   "Hello world")
	
	local box2 = Box(
                   	Position {
						top  = "50px",
						left   = "2px",
						alignment = {
						  {ref=box1, side=Position.Sides.Right}
						}
                    },
                    Dimension ("50px", "10%"),
					"Hello!")
	
	local box3 = Box(
				Position {
					top  = "2px",
					left = "0",
					alignment = {
					  {ref=box2, side=Position.Sides.Bottom},
					  {ref=box2, side=Position.Sides.Left}
					}
				},
				Dimension ("50px", "20%"),
				"Yolo")
				--]]
	
	local button1 = Button {
		position = Position { bottom  = "2px", right = "2px" },
		text = "OK"
	}
	
	local button2 = Button {
		position = Position { bottom  = "2px", right = "2px", alignment = {{ref=button1, side=Position.Sides.Left}}},
		text = "Number+1"
	}
	
	local input1 = Input {
		position = Position { top  = "2px", right = "2px" },
		value = 1337
	}
	input1.number = true
	input1.dimension.width = Input.defaultStyle.defaultWidth * 2


	local input2 = Input {
		position = Position { top  = "4px", left = "0px", alignment = {{ref=input1, side=Position.Sides.Bottom},{ref=input1, side=Position.Sides.Left}}},
		value = "this is an input"
	}	
	
	local label1 = Label {
		position = Position { top  = "2px", right = "10px", alignment = {{ref=input1, side=Position.Sides.Left}}},
		text = "This is a label"
	}
	
	local label2 = Label {
		position = Position { top  = "0px", right = "10px", alignment = {{ref=input2, side=Position.Sides.Top},{ref=input2, side=Position.Sides.Left}}},
		text = "This is a label"
	}
	label2.limit = true
	label2.dimension = Dimension("30px","20px")
	
	myView:addChildren(button1, button2, input1, input2, label1, label2)
    	
	
	function button2:charIn(char)
		self.text = self.text .. char
		
		self.parent:invalidate()
	end
	
	button2.onAction = λ -> input1.value++;
	
	function myView:draw(gc, x, y, width, height)
		Logger.Log("in myView draw")
	end
	
	button1.onAction = function ()
		local dialog = etk.Dialog("Test Dialog", Position {top="40px", left="20px"}, Dimension("-40px", "-80px"))
		
		local nameLabel = Label {position = Position { top  = "30px", left = "4px"}, text="Name: "}
		local nameInput = Input {position = Position { top  = "30px", left = "50px"}}
		nameInput.dimension.width = "-54px"
			
		local closeButton = Button {
			position = Position { bottom  = "4px", right = "4px" },
			text = "Close"
		}
		closeButton.onAction = function()
			input2.value = "Hi " .. nameInput.value
			etk.RootScreen:popScreen();
		end
		
		dialog:addChildren(nameLabel, nameInput, closeButton)
		
		etk.RootScreen:pushScreen(dialog)
	end
	
	function myView:enterKey()
		print("Enterkey myView")
	end
	
	function input1:enterKey()
		print("Enterkey input1")
	end
	
	etk.RootScreen:pushScreen(myView)
end