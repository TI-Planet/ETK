----------------------------------
-- ETK 4.0 Demo project         --
--                              --
-- (C) 2015 Jim Bauwens         --
-- Licensed under the GNU GPLv3 --
----------------------------------

--include "extra/lua_additions.lua"
--include "etk/etk.lua"

do
    local Input = etk.Widgets.Input
    local Label = etk.Widgets.Label
    local Button = etk.Widgets.Button

    local myView = etk.View()

    local input1 = Input {
        position = Position { top="2px", right="2px" },
        value = 1337,
        number = true
    }
    input1.dimension.width = Input.defaultStyle.defaultWidth * 2

    local input2 = Input {
        position = Position { top="4px", left="0px", alignment={{ref=input1, side=Position.Sides.Bottom},{ref=input1, side=Position.Sides.Left}} },
        value = "this is an input"
    }

    local label1 = Label {
        position = Position { top="2px", right="10px", alignment={{ref=input1, side=Position.Sides.Left}} },
        text = "This is a label"
    }

    local label2 = Label {
        position = Position { top="0px", right="10px", alignment={{ref=input2, side=Position.Sides.Top},{ref=input2, side=Position.Sides.Left}} },
        text = "This is a label"
    }
    label2.limit = true
    label2.dimension = Dimension("30px","20px")

    local button1 = Button {
        position = Position { bottom="2px", right="2px" },
        text = "OK"
    }
    button1.onAction = function ()
        local dialog = etk.Dialog("Test Dialog", Position { top="40px", left="20px" }, Dimension("-40px", "-80px"))

        local nameLabel = Label {
            position = Position { top="30px", left="4px" },
            text = "Name: "
        }

        local nameInput = Input {
            position = Position { top="30px", left="50px" }
        }
        nameInput.dimension.width = "-54px"

        local closeButton = Button {
            position = Position { bottom="4px", right="4px" },
            text = "Close"
        }
        closeButton.onAction = function()
            input2.value = "Hi " .. nameInput.value
            etk.RootScreen:popScreen();
        end

        dialog:addChildren(nameLabel, nameInput, closeButton)

        etk.RootScreen:pushScreen(dialog)
    end

    local button2 = Button {
        position = Position { bottom="2px", right="2px", alignment={{ref=button1, side=Position.Sides.Left}} },
        text = "Number+1"
    }
    function button2:charIn(char)
        self.text = self.text .. char
        self.parent:invalidate()
    end
    button2.onAction = λ -> input1.value++;

    myView:addChildren(input1, input2, label1, label2, button1, button2)

    function myView:draw(gc, x, y, width, height)
        Logger.Log("in myView draw")
    end

    function myView:enterKey()
        print("Enterkey myView")
    end

    function input1:enterKey()
        print("Enterkey input1")
    end

    etk.RootScreen:pushScreen(myView)
end