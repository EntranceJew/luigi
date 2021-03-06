local Layout = require 'luigi.layout'

local style = {
    short = {
        height = 48,
    },
    toolbar = {
        style = { 'short' },
    },
    toolButton = {
        align = 'center middle',
        width = 48,
    },
    toolButton_focused = {
        slices = 'defer',
    },
    toolButton_not_hovered = {
        slices = false,
    },
    statusbar = {
        style = 'panel',
        align = 'left middle',
    },
    listThing = {
        style = { 'short', 'panel' },
        align = 'left middle',
        outline = { 200, 200, 200 },
        height = 120,
        padding = 8,
        background = { 255, 255, 255 },
        icon = 'icon/32px/Box.png',
    },
}

local mainForm = { id = 'mainWindow', type = 'panel',
    { type = 'menu', id = 'menubar', flow = 'x',
        { text = 'File',
            { text = 'Save', id = 'menuSave', key = 'ctrl-s' },
            { text = 'Quit', id = 'menuQuit', key = 'escape' },
        },
        { text = 'Edit',
            { text = 'Cut', key = 'ctrl-c' },
            { text = 'Copy', key = 'ctrl-x' },
            { text = 'Paste', key = 'ctrl-v' },
            { type = 'slider' },
        },
        { text = 'View',
            { text = 'Theme',
                { text = 'Light', key = 'ctrl-l' },
                { text = 'Dark', key = 'ctrl-d' },
            },
            { text = 'Style',
                { text = 'Default' },
            },
        },
        { text = 'Help',
            { text = 'About Luigi', icon = 'icon/16px/Book.png', key = 'f1', },
            { text = 'About Luigi Demo', icon = 'icon/16px/Book Red.png', key = 'f2' },
            { text = 'Licenses', key = 'f3'  },
        },
    },
    { type = 'panel', id = 'toolbar', flow = 'x',
        { type = 'button', id = 'newButton', style = 'toolButton', key = 'z',
            icon = 'icon/32px/Blueprint.png' },
        { type = 'button', id = 'loadButton', style = 'toolButton',
            icon = 'icon/32px/Calendar.png' },
        { type = 'button', id = 'saveButton', style = 'toolButton',
            icon = 'icon/32px/Harddrive.png' },
    },
    { flow = 'x',
        { id = 'leftSideBox',    width = 200, minwidth = 64,
            { text = 'Hi, I\'m centered middle. ', style = 'listThing',
                align = 'middle center' },
            { text = 'Hi, I\'m centered bottom. ', style = 'listThing',
                align = 'bottom center' },
            { text = 'Hi, I\'m centered top. ', style = 'listThing',
                align = 'top center' },
            { text = 'A man, a plan, a canal: Panama!', style = 'listThing' },
        },
        { type = 'sash', width = 4, },
        { id = 'mainCanvas' },
        { type = 'sash', width = 4, },
        { type = 'panel', id = 'rightSideBox', width = 200, minwidth = 64,
            { type = 'panel', text = 'A slider', align = 'bottom', height = 24, padding = 4 },
            { type = 'slider', height = 32, margin = 4, id = 'slidey', value = 0 },
            { type = 'panel', text = 'A stepper', align = 'bottom', height = 24, padding = 4 },
            { type = 'stepper', height = 32, margin = 4, options = {
                { value = 1, text = 'Thing One' },
                { value = 2, text = 'Thing Two' },
                { value = 3, text = 'Thing Three' },
            } },
            { type = 'panel', text = 'A progress bar', align = 'bottom', height = 24, padding = 4 },
            { type = 'progress', height = 32, margin = 4, id = 'progressBar', },
        },
    },
    { type = 'sash', height = 4, },
    { type = 'panel', flow = 'x', height = 48, padding = 2,
        { type = 'text', id = 'aTextField', text = 'a text field' },
        { type = 'button', key='return', width = 80, id = 'aButton', text = 'Styling!',
    font = 'font/liberation/LiberationMono-Regular.ttf' },
    },
    { type = 'panel', id = 'statusbar', height = 24, padding = 4, textColor = { 255, 0, 0 } },
}

local layout = Layout(mainForm)

layout:setStyle(style)
-- layout:setTheme(require 'luigi.theme.light')

layout.leftSideBox:addChild {
    text = 'Alright man this is a great song\nwith a really long title...',
    style = 'listThing',
    align = 'middle right'
}

layout.slidey:onChange(function (event)
    layout.progressBar:setValue(event.value)
end)

layout:onMove(function (event)
    local w = event.target
    layout.statusbar.text = (w.type or '(generic) ') ..
        (w.id or '(unnamed)') .. ' ' ..
        w:getX() .. ', ' .. w:getY() .. ' | ' ..
        w:getWidth() .. 'x' .. w:getHeight()
end)

layout.newButton:onMove(function (event)
    layout.statusbar.text = 'Create a new thing'
    return false
end)

local foo = Layout { float = true, height = 100,
    text = 'hello', align = 'center middle', background = {255,0,0}
}

foo:onReshape(function (event)
    foo:hide()
end)

layout.newButton:onPress(function (event)
    print('creating a new thing!')
end)

layout.aButton:onPress(function (event)
    layout.aButton.font = nil
    layout.aButton.width = layout.aButton.width + 10
    local w = layout.aButton:getWidth()
    foo.root.width = w * 2
    foo.root.left = layout.aButton:getX() - w
    foo.root.top = layout.aButton:getY() - foo.root.height
    foo:show()
end)

layout.mainCanvas.font = 'font/liberation/LiberationMono-Regular.ttf'

layout.mainCanvas.text = [[Abedede sdfsdf asfdsdfdsfs sdfsdfsdf
sfsdfdfbv db er erg rth tryj ty j fgh dfgv
wefwef    rgh erh rth e rgs dvg eh tyj rt h erg
erge rg eg erg er ergs erg er ge rh erh rth]]

layout.mainCanvas.align = 'top'

layout.menuQuit:onPress(function (event) love.event.quit() end)



layout:show()
