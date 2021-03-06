local ROOT = (...):gsub('[^.]*.[^.]*.[^.]*$', '')

local Layout, Event

local show

local function deactivateSiblings (target)
    local sibling = target.parent and target.parent[1]
    local wasSiblingOpen

    if not sibling then
        return
    end

    while sibling do

        sibling.active = nil

        local layout = sibling.menuLayout

        if layout and layout.isShown then
            wasSiblingOpen = true
            layout:hide()
        end

        if sibling.items and sibling.items[1] then
            deactivateSiblings(sibling.items[1])
        end

        sibling = sibling:getNextSibling()
    end

    return wasSiblingOpen
end

local function activate (event, ignoreIfNoneOpen)
    local target = event.target

    while target.parent
    and target.parent.type ~= 'menu' and target.parent.type ~= 'submenu' do
        target = target.parent
        if not target then
            return
        end
    end

    local wasSiblingOpen = deactivateSiblings(target)
    local ignore = ignoreIfNoneOpen and not wasSiblingOpen

    if not ignore then
        show(target)
        target.active = true
    end
end

local function registerLayoutEvents (self)
    local menuLayout = self.menuLayout

    menuLayout:onReshape(function (event)
        menuLayout:hide()
        deactivateSiblings(self.rootMenu[1])
    end)

    menuLayout:onPressStart(function (event)
        if not event.hit then
            menuLayout:hide()
            if self.parentMenu == self.rootMenu then
                deactivateSiblings(self.rootMenu[1])
            end
        else
            activate(event)
        end
    end)

    menuLayout:onEnter(activate)
    menuLayout:onPressEnter(activate)
end

local function addLayoutChildren (self)
    local root = self.menuLayout.root
    local textWidth = 0
    local keyWidth = 0
    local height = 0

    while #root > 0 do rawset(root, #root, nil) end

    root.height = 0
    root.width = 0

    for index, child in ipairs(self.items) do
        child.type = child.type or 'menu.item'
        root:addChild(child)
        local childHeight = child:getHeight()
        height = height + childHeight
        if child.type == 'menu.item' then
            local pad = child.padding or 0
            local tw = child.fontData:getAdvance(child[2].text)
                + pad * 2 + childHeight
            local kw = child.fontData:getAdvance(child[3].text)
                + pad * 2 + childHeight
            textWidth = math.max(textWidth, tw)
            keyWidth = math.max(keyWidth, kw)
        end
    end

    local isSubmenu = self.parentMenu and self.parentMenu.parentMenu
    local x = isSubmenu and self:getWidth() or 0
    local y = isSubmenu and 0 or self:getHeight()

    root.left = self:getX() + x
    root.top = self:getY() + y
    root.height = height
    root.width = textWidth + keyWidth + (root.padding or 0)
end

local function createLayout (self)
    Layout = Layout or require(ROOT .. 'layout')

    self.menuLayout = Layout { type = 'submenu' }
end

show = function (self)
    if not self.items or #self.items < 1 then return end

    addLayoutChildren(self)
    self.menuLayout:show()
end

local function initialize (self)
    local pad = self.padding or 0
    local isSubmenu = self.parentMenu and self.parentMenu.parentMenu
    local text, key, icon = self.text or '', self.key or '', self.icon
    local textWidth = self.fontData:getAdvance(text) + pad * 2

    if isSubmenu then
        local tc = self.textColor or { 0, 0, 0 }
        local keyColor = { tc[1], tc[2], tc[3], 0x90 }
        local edgeType
        if #self.items > 0 then
            key = ' '
            edgeType = 'menu.expander'
        else
            key = key:gsub('%f[%w].', string.upper)
        end
        self.height = self.fontData:getLineHeight() + pad * 2
        self.flow = 'x'
        self:addChild({ icon = icon, width = self.height })
        self:addChild({ text = text, width = textWidth })
        self:addChild({ text = key, align = 'middle right',
            minwidth = self.height,
            textColor = keyColor, type = edgeType })

        self.icon = nil
        self.text = nil
    else
        self.width = textWidth
    end
end

local function extractChildren (self)
    self.items = {}
    for index, child in ipairs(self) do
        self[index] = nil
        self.items[#self.items + 1] = child
        child.parentMenu = self
        child.rootMenu = self.rootMenu
        child.type = child.type or 'menu.item'
    end
end

local function registerEvents (self)
    self:onPressStart(activate)

    self:onEnter(function (event)
        activate(event, true)
    end)

    self:onPressEnter(function (event)
        activate(event, true)
    end)
end

return function (self)
    extractChildren(self)
    initialize(self)
    registerEvents(self)

    self.rootMenu.layout:addWidget(self)

    if not self.items or #self.items < 1 then return end
    createLayout(self)
    registerLayoutEvents(self)
    addLayoutChildren(self)
end
