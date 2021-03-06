return function (self)

    self.index = 1
    self.flow = 'x' -- TODO: support vertical stepper

    local decrement = self:addChild {
        type = 'stepper.left',
    }

    local view = self:addChild {
        type = 'text',
        align = 'middle center',
        margin = 0,
        canFocus = false,
    }

    local increment = self:addChild {
        type = 'stepper.right',
    }

    self:onReshape(function (event)
        decrement.width = decrement:getHeight()
        increment.width = increment:getHeight()
    end)

    local function updateValue ()
        if not self.options then return end
        local option = self.options[self.index]
        self:setValue(option.value)
        view.text = option.text
    end

    decrement:onPress(function (event)
        if not self.options then return end
        self.index = self.index - 1
        if self.index < 1 then
            self.index = #self.options
        end
        updateValue()
    end)

    increment:onPress(function (event)
        if not self.options then return end
        self.index = self.index + 1
        if self.index > #self.options then
            self.index = 1
        end
        updateValue()
    end)

    updateValue()

end
