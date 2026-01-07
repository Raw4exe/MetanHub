
-- Services
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')

-- Utility Functions
local function Tween(object, properties, duration, style, direction)
    duration = duration or 0.5
    style = style or Enum.EasingStyle.Quint
    direction = direction or Enum.EasingDirection.Out
    
    local tween = TweenService:Create(object, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

local function Round(number, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(number * mult + 0.5) / mult
end

-- Config System
local ConfigManager = {}
ConfigManager.__index = ConfigManager

function ConfigManager.new(gameName)
    local self = setmetatable({}, ConfigManager)
    self.gameName = gameName or tostring(game.GameId)
    self.folderName = "MarchUI"
    self.configsFolder = self.folderName .. "/Configs"
    self.currentConfig = "default"
    self.autoloadConfig = nil
    self.data = {
        flags = {},
        keybinds = {}
    }
    
    if not isfolder(self.folderName) then
        makefolder(self.folderName)
    end
    if not isfolder(self.configsFolder) then
        makefolder(self.configsFolder)
    end
    
    self:LoadAutoloadSetting()
    if self.autoloadConfig then
        self.currentConfig = self.autoloadConfig
    end
    self:Load()
    return self
end

function ConfigManager:GetConfigPath(configName)
    configName = configName or self.currentConfig
    return self.configsFolder .. "/" .. self.gameName .. "_" .. configName .. ".json"
end

function ConfigManager:GetAutoloadPath()
    return self.folderName .. "/" .. self.gameName .. "_autoload.txt"
end

function ConfigManager:Save(configName)
    configName = configName or self.currentConfig
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(self.data)
        writefile(self:GetConfigPath(configName), json)
    end)
    
    if not success then
        warn("Failed to save config:", err)
    end
end

function ConfigManager:Load(configName)
    if configName then
        self.currentConfig = configName
    end
    
    local filePath = self:GetConfigPath()
    
    if not isfile(filePath) then
        self:Save()
        return
    end
    
    local success, result = pcall(function()
        local json = readfile(filePath)
        return HttpService:JSONDecode(json)
    end)
    
    if success and result then
        if type(result.flags) == "table" then
            self.data.flags = result.flags
        end
        if type(result.keybinds) == "table" then
            self.data.keybinds = result.keybinds
        end
    else
        warn("Failed to load config, using defaults")
        self:Save()
    end
end

function ConfigManager:GetConfigList()
    local configs = {}
    local files = listfiles(self.configsFolder)
    local pattern = self.gameName .. "_(.+)%.json"
    
    for _, file in ipairs(files) do
        local fileName = file:match("([^/\\]+)$")
        local configName = fileName:match(pattern)
        if configName then
            table.insert(configs, configName)
        end
    end
    
    if #configs == 0 then
        table.insert(configs, "default")
    end
    
    return configs
end

function ConfigManager:CreateConfig(configName)
    if not configName or configName == "" then return false end
    self.currentConfig = configName
    self:Save()
    return true
end

function ConfigManager:DeleteConfig(configName)
    if not configName or configName == "" or configName == "default" then return false end
    local filePath = self:GetConfigPath(configName)
    if isfile(filePath) then
        delfile(filePath)
        if self.currentConfig == configName then
            self.currentConfig = "default"
            self:Load()
        end
        if self.autoloadConfig == configName then
            self:DeleteAutoload()
        end
        return true
    end
    return false
end

function ConfigManager:SetAutoload(configName)
    self.autoloadConfig = configName
    writefile(self:GetAutoloadPath(), configName)
end

function ConfigManager:DeleteAutoload()
    self.autoloadConfig = nil
    local path = self:GetAutoloadPath()
    if isfile(path) then
        delfile(path)
    end
end

function ConfigManager:LoadAutoloadSetting()
    local path = self:GetAutoloadPath()
    if isfile(path) then
        local success, result = pcall(function()
            return readfile(path)
        end)
        if success and result then
            self.autoloadConfig = result
        end
    end
end

function ConfigManager:GetAutoload()
    return self.autoloadConfig
end

function ConfigManager:SetFlag(flag, value)
    if not flag then return end
    self.data.flags[flag] = value
end

function ConfigManager:GetFlag(flag, default)
    if not flag then return default end
    local value = self.data.flags[flag]
    if value ~= nil then
        return value
    end
    return default
end

function ConfigManager:SetKeybind(flag, keycode)
    if not flag then return end
    self.data.keybinds[flag] = keycode and tostring(keycode) or nil
    self:Save()
end

function ConfigManager:GetKeybind(flag)
    return self.data.keybinds[flag]
end

-- Main Library
local Library = {}
Library.__index = Library

Library.Themes = {
    Default = {
        Primary = Color3.fromRGB(152, 181, 255),
        Background = Color3.fromRGB(12, 13, 15),
        Secondary = Color3.fromRGB(22, 28, 38),
        Accent = Color3.fromRGB(52, 66, 89),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Dark = {
        Primary = Color3.fromRGB(100, 100, 255),
        Background = Color3.fromRGB(10, 10, 10),
        Secondary = Color3.fromRGB(20, 20, 20),
        Accent = Color3.fromRGB(40, 40, 40),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Purple = {
        Primary = Color3.fromRGB(200, 100, 255),
        Background = Color3.fromRGB(15, 10, 20),
        Secondary = Color3.fromRGB(25, 20, 35),
        Accent = Color3.fromRGB(50, 40, 70),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Green = {
        Primary = Color3.fromRGB(100, 255, 150),
        Background = Color3.fromRGB(10, 15, 12),
        Secondary = Color3.fromRGB(20, 28, 22),
        Accent = Color3.fromRGB(40, 66, 52),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Red = {
        Primary = Color3.fromRGB(255, 100, 100),
        Background = Color3.fromRGB(15, 10, 10),
        Secondary = Color3.fromRGB(28, 20, 20),
        Accent = Color3.fromRGB(66, 40, 40),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

function Library.new()
    local self = setmetatable({}, Library)
    
    self.config = ConfigManager.new()
    self.tabs = {}
    self.currentTab = nil
    self.choosingKeybind = false
    self.connections = {}
    self.currentTheme = self.Themes.Default
    self.uiVisible = true
    self.uiKeybind = nil
    
    self:CreateUI()
    self:SetupUIKeybind()
    
    return self
end

function Library:SetupUIKeybind()
    local savedKeybind = self.config:GetKeybind("_UI_Toggle")
    if savedKeybind then
        self.uiKeybind = savedKeybind
        table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if tostring(input.KeyCode) == savedKeybind then
                self:ToggleUI()
            end
        end))
    end
end

function Library:SetUIKeybind(keycode)
    self.uiKeybind = keycode
    self.config:SetKeybind("_UI_Toggle", keycode)
    for i = #self.connections, 1, -1 do
        local conn = self.connections[i]
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
            table.remove(self.connections, i)
        end
    end
    if keycode then
        table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if tostring(input.KeyCode) == keycode then
                self:ToggleUI()
            end
        end))
    end
end

function Library:ToggleUI()
    self.uiVisible = not self.uiVisible
    if self.uiVisible then
        self.ui.Enabled = true
        Tween(self.container, {Size = UDim2.new(0, 698, 0, 479)}, 0.3)
    else
        Tween(self.container, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        self.ui.Enabled = false
    end
end

function Library:SetTheme(themeName)
    local theme = self.Themes[themeName]
    if not theme then return end
    self.currentTheme = theme
end

function Library:CreateUI()
    -- Remove old UI
    local oldUI = CoreGui:FindFirstChild("MarchUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MarchUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
    -- Main Container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 0, 0, 0)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Active = true
    container.Parent = screenGui
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container
    
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = Color3.fromRGB(52, 66, 89)
    containerStroke.Transparency = 0.5
    containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    containerStroke.Parent = container
    
    -- Handler Frame
    local handler = Instance.new("Frame")
    handler.Name = "Handler"
    handler.Size = UDim2.new(0, 698, 0, 479)
    handler.BackgroundTransparency = 1
    handler.Parent = container
    
    -- Logo/Title
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Text = "Metan"
    logo.Font = Enum.Font.GothamBold
    logo.TextSize = 16
    logo.TextColor3 = Color3.fromRGB(152, 181, 255)
    logo.TextTransparency = 0.2
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Size = UDim2.new(0, 100, 0, 16)
    logo.Position = UDim2.new(0.056, 0, 0.055, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Parent = handler
    
    local logoGradient = Instance.new("UIGradient")
    logoGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(155, 155, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
    }
    logoGradient.Parent = logo
    
    -- Logo Icon
    local logoIcon = Instance.new("ImageLabel")
    logoIcon.Name = "Icon"
    logoIcon.Image = "rbxassetid://107819132007001"
    logoIcon.Size = UDim2.new(0, 18, 0, 18)
    logoIcon.Position = UDim2.new(0.025, 0, 0.055, 0)
    logoIcon.AnchorPoint = Vector2.new(0, 0.5)
    logoIcon.BackgroundTransparency = 1
    logoIcon.ImageColor3 = Color3.fromRGB(152, 181, 255)
    logoIcon.ScaleType = Enum.ScaleType.Fit
    logoIcon.Parent = handler
    
    -- Close Button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 20, 0, 20)
    closeButton.Position = UDim2.new(0.97, 0, 0.055, 0)
    closeButton.AnchorPoint = Vector2.new(1, 0.5)
    closeButton.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    closeButton.BackgroundTransparency = 0.9
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 14
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.TextTransparency = 0.2
    closeButton.AutoButtonColor = false
    closeButton.Parent = handler
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeButton
    
    closeButton.MouseEnter:Connect(function()
        Tween(closeButton, {BackgroundTransparency = 0.7}, 0.2)
    end)
    
    closeButton.MouseLeave:Connect(function()
        Tween(closeButton, {BackgroundTransparency = 0.9}, 0.2)
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        Tween(container, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        screenGui.Enabled = false
    end)
    
    -- Tab Selection Pin
    local pin = Instance.new("Frame")
    pin.Name = "Pin"
    pin.Size = UDim2.new(0, 2, 0, 16)
    pin.Position = UDim2.new(0.026, 0, 0.136, 0)
    pin.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    pin.BorderSizePixel = 0
    pin.Parent = handler
    
    local pinCorner = Instance.new("UICorner")
    pinCorner.CornerRadius = UDim.new(1, 0)
    pinCorner.Parent = pin
    
    -- Divider
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0, 1, 0, 479)
    divider.Position = UDim2.new(0.235, 0, 0, 0)
    divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = handler
    
    -- Tabs ScrollingFrame
    local tabsFrame = Instance.new("ScrollingFrame")
    tabsFrame.Name = "Tabs"
    tabsFrame.Size = UDim2.new(0, 129, 0, 401)
    tabsFrame.Position = UDim2.new(0.026, 0, 0.111, 0)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.BorderSizePixel = 0
    tabsFrame.ScrollBarThickness = 0
    tabsFrame.ScrollBarImageTransparency = 1
    tabsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabsFrame.Parent = handler
    
    local tabsLayout = Instance.new("UIListLayout")
    tabsLayout.Padding = UDim.new(0, 4)
    tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabsLayout.Parent = tabsFrame
    
    -- Sections Folder
    local sectionsFolder = Instance.new("Folder")
    sectionsFolder.Name = "Sections"
    sectionsFolder.Parent = handler
    
    -- Store references
    self.ui = screenGui
    self.container = container
    self.handler = handler
    self.tabsFrame = tabsFrame
    self.sectionsFolder = sectionsFolder
    self.pin = pin
    
    -- Setup dragging
    self:SetupDragging()
end

function Library:SetupDragging()
    local container = self.container
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            Tween(container, {Position = newPos}, 0.2)
        end
    end)
end

function Library:Load()
    Tween(self.container, {Size = UDim2.new(0, 698, 0, 479)}, 0.5)
end

function Library:CreateTab(name, icon)
    local tab = {}
    tab.name = name
    tab.icon = icon
    tab.modules = {}
    
    -- Create tab button
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab"
    tabButton.Size = UDim2.new(0, 129, 0, 38)
    tabButton.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.LayoutOrder = #self.tabs
    tabButton.Parent = self.tabsFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 5)
    tabCorner.Parent = tabButton
    
    -- Tab Icon
    local tabIcon = Instance.new("ImageLabel")
    tabIcon.Name = "Icon"
    tabIcon.Image = icon
    tabIcon.Size = UDim2.new(0, 12, 0, 12)
    tabIcon.Position = UDim2.new(0.1, 0, 0.5, 0)
    tabIcon.AnchorPoint = Vector2.new(0, 0.5)
    tabIcon.BackgroundTransparency = 1
    tabIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    tabIcon.ImageTransparency = 0.8
    tabIcon.ScaleType = Enum.ScaleType.Fit
    tabIcon.Parent = tabButton
    
    -- Tab Label
    local tabLabel = Instance.new("TextLabel")
    tabLabel.Name = "Label"
    tabLabel.Text = name
    tabLabel.Font = Enum.Font.GothamBold
    tabLabel.TextSize = 13
    tabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabLabel.TextTransparency = 0.7
    tabLabel.TextXAlignment = Enum.TextXAlignment.Left
    tabLabel.Size = UDim2.new(0, 80, 0, 16)
    tabLabel.Position = UDim2.new(0.24, 0, 0.5, 0)
    tabLabel.AnchorPoint = Vector2.new(0, 0.5)
    tabLabel.BackgroundTransparency = 1
    tabLabel.Parent = tabButton
    
    local labelGradient = Instance.new("UIGradient")
    labelGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(155, 155, 155)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(58, 58, 58))
    }
    labelGradient.Parent = tabLabel
    
    -- Create sections
    local leftSection = Instance.new("ScrollingFrame")
    leftSection.Name = "LeftSection"
    leftSection.Size = UDim2.new(0, 243, 0, 445)
    leftSection.Position = UDim2.new(0.259, 0, 0.5, 0)
    leftSection.AnchorPoint = Vector2.new(0, 0.5)
    leftSection.BackgroundTransparency = 1
    leftSection.BorderSizePixel = 0
    leftSection.ScrollBarThickness = 0
    leftSection.ScrollBarImageTransparency = 1
    leftSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    leftSection.CanvasSize = UDim2.new(0, 0, 0, 0)
    leftSection.Visible = false
    leftSection.Parent = self.sectionsFolder
    
    local leftLayout = Instance.new("UIListLayout")
    leftLayout.Padding = UDim.new(0, 11)
    leftLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
    leftLayout.Parent = leftSection
    
    local leftPadding = Instance.new("UIPadding")
    leftPadding.PaddingTop = UDim.new(0, 1)
    leftPadding.Parent = leftSection
    
    local rightSection = Instance.new("ScrollingFrame")
    rightSection.Name = "RightSection"
    rightSection.Size = UDim2.new(0, 243, 0, 445)
    rightSection.Position = UDim2.new(0.629, 0, 0.5, 0)
    rightSection.AnchorPoint = Vector2.new(0, 0.5)
    rightSection.BackgroundTransparency = 1
    rightSection.BorderSizePixel = 0
    rightSection.ScrollBarThickness = 0
    rightSection.ScrollBarImageTransparency = 1
    rightSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
    rightSection.CanvasSize = UDim2.new(0, 0, 0, 0)
    rightSection.Visible = false
    rightSection.Parent = self.sectionsFolder
    
    local rightLayout = Instance.new("UIListLayout")
    rightLayout.Padding = UDim.new(0, 11)
    rightLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rightLayout.Parent = rightSection
    
    local rightPadding = Instance.new("UIPadding")
    rightPadding.PaddingTop = UDim.new(0, 1)
    rightPadding.Parent = rightSection
    
    tab.button = tabButton
    tab.leftSection = leftSection
    tab.rightSection = rightSection
    
    -- Tab click handler
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.tabs, tab)
    
    -- Select first tab
    if #self.tabs == 1 then
        self:SelectTab(tab)
    end
    
    -- Return tab object with methods
    return setmetatable(tab, {
        __index = {
            CreateModule = function(t, options)
                return self:CreateModule(t, options)
            end
        }
    })
end

function Library:SelectTab(tab)
    self.currentTab = tab
    
    -- Hide all sections
    for _, t in ipairs(self.tabs) do
        t.leftSection.Visible = false
        t.rightSection.Visible = false
    end
    
    -- Show selected sections
    tab.leftSection.Visible = true
    tab.rightSection.Visible = true
    
    -- Update tab buttons
    for i, t in ipairs(self.tabs) do
        local button = t.button
        local icon = button.Icon
        local label = button.Label
        
        if t == tab then
            -- Selected state
            Tween(button, {BackgroundTransparency = 0.5}, 0.5)
            Tween(icon, {ImageTransparency = 0.2, ImageColor3 = Color3.fromRGB(152, 181, 255)}, 0.5)
            Tween(label, {TextTransparency = 0.2, TextColor3 = Color3.fromRGB(152, 181, 255)}, 0.5)
            Tween(label.UIGradient, {Offset = Vector2.new(1, 0)}, 0.5)
            
            -- Move pin
            local offset = (i - 1) * (0.113 / 1.3)
            Tween(self.pin, {Position = UDim2.fromScale(0.026, 0.135 + offset)}, 0.5)
        else
            -- Unselected state
            Tween(button, {BackgroundTransparency = 1}, 0.5)
            Tween(icon, {ImageTransparency = 0.8, ImageColor3 = Color3.fromRGB(255, 255, 255)}, 0.5)
            Tween(label, {TextTransparency = 0.7, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.5)
            Tween(label.UIGradient, {Offset = Vector2.new(0, 0)}, 0.5)
        end
    end
end

function Library:CreateSettingsTab()
    local settingsTab = self:CreateTab("Settings", "rbxassetid://7733955511")
    
    local configModule = settingsTab:CreateModule({
        title = "Config Manager",
        description = "Manage your configurations",
        section = "left"
    })
    
    local configNameBox
    local configList
    local autoloadStatus
    
    local function UpdateConfigList()
        local configs = self.config:GetConfigList()
        if configList then
            configList.SetValue(configs)
        end
    end
    
    local function UpdateAutoloadStatus()
        local autoload = self.config:GetAutoload()
        if autoloadStatus then
            autoloadStatus.SetText(autoload and ("Autoload: " .. autoload) or "Autoload: None")
        end
    end
    
    configList = configModule:CreateDropdown({
        title = "Select Config",
        options = self.config:GetConfigList(),
        callback = function(value)
            if value then
                self.config:Load(value)
                print("Loaded config:", value)
            end
        end
    })
    
    autoloadStatus = configModule:CreateTextbox({
        title = "Autoload Status",
        default = self.config:GetAutoload() and ("Autoload: " .. self.config:GetAutoload()) or "Autoload: None",
        placeholder = "No autoload set"
    })
    autoloadStatus.textboxFrame.TextEditable = false
    
    configNameBox = configModule:CreateTextbox({
        title = "Config Name",
        placeholder = "Enter config name..."
    })
    
    configModule:CreateButton({
        title = "Create Config",
        callback = function()
            local name = configNameBox.text
            if name and name ~= "" then
                if self.config:CreateConfig(name) then
                    print("Created config:", name)
                    UpdateConfigList()
                else
                    warn("Failed to create config")
                end
            else
                warn("Please enter a config name")
            end
        end
    })
    
    configModule:CreateButton({
        title = "Save Config",
        callback = function()
            self.config:Save()
            print("Saved config:", self.config.currentConfig)
        end
    })
    
    configModule:CreateButton({
        title = "Delete Config",
        callback = function()
            local name = configNameBox.text
            if name and name ~= "" and name ~= "default" then
                if self.config:DeleteConfig(name) then
                    print("Deleted config:", name)
                    UpdateConfigList()
                    UpdateAutoloadStatus()
                else
                    warn("Failed to delete config")
                end
            else
                warn("Cannot delete default config or invalid name")
            end
        end
    })
    
    configModule:CreateButton({
        title = "Set as Autoload",
        callback = function()
            local name = configNameBox.text
            if name and name ~= "" then
                self.config:SetAutoload(name)
                print("Set autoload:", name)
                UpdateAutoloadStatus()
            else
                warn("Please enter a config name")
            end
        end
    })
    
    configModule:CreateButton({
        title = "Delete Autoload",
        callback = function()
            self.config:DeleteAutoload()
            print("Removed autoload")
            UpdateAutoloadStatus()
        end
    })
    
    local uiModule = settingsTab:CreateModule({
        title = "UI Settings",
        description = "Customize your UI",
        section = "right"
    })
    
    uiModule:CreateKeybind({
        title = "Toggle UI",
        default = self.config:GetKeybind("_UI_Toggle"),
        callback = function(key)
            self:SetUIKeybind(key)
            print("UI Keybind set to:", key)
        end
    })
    
    uiModule:CreateDropdown({
        title = "Theme",
        options = {"Default", "Dark", "Purple", "Green", "Red"},
        default = "Default",
        callback = function(theme)
            self:SetTheme(theme)
            print("Theme changed to:", theme)
        end
    })
    
    return settingsTab
end

function Library:CreateModule(tab, options)
    local module = {}
    module.title = options.title or "Module"
    module.description = options.description or ""
    module.flag = options.flag
    module.callback = options.callback or function() end
    module.section = options.section == "right" and tab.rightSection or tab.leftSection
    module.state = self.config:GetFlag(options.flag, false)
    module.elements = {}
    module.elementHeight = 0
    
    -- Create module frame
    local moduleFrame = Instance.new("Frame")
    moduleFrame.Name = "Module"
    moduleFrame.Size = UDim2.new(0, 241, 0, 93)
    moduleFrame.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    moduleFrame.BackgroundTransparency = 0.5
    moduleFrame.BorderSizePixel = 0
    moduleFrame.ClipsDescendants = true
    moduleFrame.Parent = module.section
    
    local moduleCorner = Instance.new("UICorner")
    moduleCorner.CornerRadius = UDim.new(0, 5)
    moduleCorner.Parent = moduleFrame
    
    local moduleStroke = Instance.new("UIStroke")
    moduleStroke.Color = Color3.fromRGB(52, 66, 89)
    moduleStroke.Transparency = 0.5
    moduleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    moduleStroke.Parent = moduleFrame
    
    local moduleLayout = Instance.new("UIListLayout")
    moduleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    moduleLayout.Parent = moduleFrame
    
    -- Header
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(0, 241, 0, 93)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.LayoutOrder = 0
    header.Parent = moduleFrame
    
    -- Module Icon
    local moduleIcon = Instance.new("ImageLabel")
    moduleIcon.Name = "Icon"
    moduleIcon.Image = "rbxassetid://79095934438045"
    moduleIcon.Size = UDim2.new(0, 15, 0, 15)
    moduleIcon.Position = UDim2.new(0.071, 0, 0.82, 0)
    moduleIcon.AnchorPoint = Vector2.new(0, 0.5)
    moduleIcon.BackgroundTransparency = 1
    moduleIcon.ImageColor3 = Color3.fromRGB(152, 181, 255)
    moduleIcon.ImageTransparency = 0.7
    moduleIcon.ScaleType = Enum.ScaleType.Fit
    moduleIcon.Parent = header
    
    -- Module Title
    local moduleTitle = Instance.new("TextLabel")
    moduleTitle.Name = "Title"
    moduleTitle.Text = module.title
    moduleTitle.Font = Enum.Font.GothamBold
    moduleTitle.TextSize = 13
    moduleTitle.TextColor3 = Color3.fromRGB(152, 181, 255)
    moduleTitle.TextTransparency = 0.2
    moduleTitle.TextXAlignment = Enum.TextXAlignment.Left
    moduleTitle.Size = UDim2.new(0, 205, 0, 13)
    moduleTitle.Position = UDim2.new(0.073, 0, 0.24, 0)
    moduleTitle.AnchorPoint = Vector2.new(0, 0.5)
    moduleTitle.BackgroundTransparency = 1
    moduleTitle.Parent = header
    
    -- Module Description
    local moduleDesc = Instance.new("TextLabel")
    moduleDesc.Name = "Description"
    moduleDesc.Text = module.description
    moduleDesc.Font = Enum.Font.GothamBold
    moduleDesc.TextSize = 10
    moduleDesc.TextColor3 = Color3.fromRGB(152, 181, 255)
    moduleDesc.TextTransparency = 0.7
    moduleDesc.TextXAlignment = Enum.TextXAlignment.Left
    moduleDesc.Size = UDim2.new(0, 205, 0, 13)
    moduleDesc.Position = UDim2.new(0.073, 0, 0.42, 0)
    moduleDesc.AnchorPoint = Vector2.new(0, 0.5)
    moduleDesc.BackgroundTransparency = 1
    moduleDesc.Parent = header
    
    -- Toggle
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(0, 25, 0, 12)
    toggleFrame.Position = UDim2.new(0.82, 0, 0.757, 0)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggleFrame.BackgroundTransparency = 0.7
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = header
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleFrame
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Name = "Circle"
    toggleCircle.Size = UDim2.new(0, 12, 0, 12)
    toggleCircle.Position = UDim2.new(0, 0, 0.5, 0)
    toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(66, 80, 115)
    toggleCircle.BackgroundTransparency = 0.2
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleFrame
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    -- Keybind Display
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(0, 33, 0, 15)
    keybindFrame.Position = UDim2.new(0.15, 0, 0.735, 0)
    keybindFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    keybindFrame.BackgroundTransparency = 0.7
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = header
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 3)
    keybindCorner.Parent = keybindFrame
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Text = "None"
    keybindLabel.Font = Enum.Font.GothamBold
    keybindLabel.TextSize = 10
    keybindLabel.TextColor3 = Color3.fromRGB(209, 222, 255)
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.Size = UDim2.new(0, 25, 0, 13)
    keybindLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    keybindLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Parent = keybindFrame
    
    -- Dividers
    local divider1 = Instance.new("Frame")
    divider1.Name = "Divider"
    divider1.Size = UDim2.new(0, 241, 0, 1)
    divider1.Position = UDim2.new(0.5, 0, 0.62, 0)
    divider1.AnchorPoint = Vector2.new(0.5, 0)
    divider1.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    divider1.BackgroundTransparency = 0.5
    divider1.BorderSizePixel = 0
    divider1.Parent = header
    
    local divider2 = Instance.new("Frame")
    divider2.Name = "Divider"
    divider2.Size = UDim2.new(0, 241, 0, 1)
    divider2.Position = UDim2.new(0.5, 0, 1, 0)
    divider2.AnchorPoint = Vector2.new(0.5, 0)
    divider2.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    divider2.BackgroundTransparency = 0.5
    divider2.BorderSizePixel = 0
    divider2.Parent = header
    
    -- Options Container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(0, 241, 0, 8)
    optionsFrame.Position = UDim2.new(0, 0, 1, 0)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.LayoutOrder = 1
    optionsFrame.Parent = moduleFrame
    
    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, 8)
    optionsPadding.Parent = optionsFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 5)
    optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsFrame
    
    module.frame = moduleFrame
    module.optionsFrame = optionsFrame
    module.toggleFrame = toggleFrame
    module.toggleCircle = toggleCircle
    module.keybindLabel = keybindLabel
    
    -- Toggle function
    local function SetState(state)
        module.state = state
        self.config:SetFlag(module.flag, state)
        
        if state then
            Tween(toggleFrame, {BackgroundColor3 = Color3.fromRGB(152, 181, 255)}, 0.5)
            Tween(toggleCircle, {
                BackgroundColor3 = Color3.fromRGB(152, 181, 255),
                Position = UDim2.fromScale(0.53, 0.5)
            }, 0.5)
        else
            Tween(toggleFrame, {BackgroundColor3 = Color3.fromRGB(0, 0, 0)}, 0.5)
            Tween(toggleCircle, {
                BackgroundColor3 = Color3.fromRGB(66, 80, 115),
                Position = UDim2.fromScale(0, 0.5)
            }, 0.5)
        end
        
        local newSize = module.state and (93 + module.elementHeight + 8) or 93
        Tween(moduleFrame, {Size = UDim2.new(0, 241, 0, newSize)}, 0.5)
        
        task.spawn(function()
            module.callback(state)
        end)
    end
    
    -- Initialize state
    if module.state then
        SetState(true)
    end
    
    -- Click handler
    header.MouseButton1Click:Connect(function()
        SetState(not module.state)
    end)
    
    -- Keybind handler
    local savedKeybind = self.config:GetKeybind(module.flag)
    if savedKeybind then
        local displayText = savedKeybind:gsub("Enum.KeyCode.", "")
        keybindLabel.Text = displayText
        
        local textSize = TextService:GetTextSize(displayText, 10, Enum.Font.GothamBold, Vector2.new(1000, 15))
        keybindFrame.Size = UDim2.new(0, textSize.X + 8, 0, 15)
        
        -- Connect keybind
        table.insert(self.connections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if tostring(input.KeyCode) == savedKeybind then
                SetState(not module.state)
            end
        end))
    end
    
    header.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton3 then return end
        if self.choosingKeybind then return end
        
        self.choosingKeybind = true
        keybindLabel.Text = "..."
        keybindFrame.Size = UDim2.new(0, 33, 0, 15)
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(keyInput, processed)
            if processed then return end
            if keyInput.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if keyInput.KeyCode == Enum.KeyCode.Unknown then return end
            
            connection:Disconnect()
            self.choosingKeybind = false
            
            if keyInput.KeyCode == Enum.KeyCode.Backspace then
                keybindLabel.Text = "None"
                keybindFrame.Size = UDim2.new(0, 33, 0, 15)
                self.config:SetKeybind(module.flag, nil)
                return
            end
            
            local keycodeStr = tostring(keyInput.KeyCode)
            local displayText = keycodeStr:gsub("Enum.KeyCode.", "")
            keybindLabel.Text = displayText
            
            local textSize = TextService:GetTextSize(displayText, 10, Enum.Font.GothamBold, Vector2.new(1000, 15))
            keybindFrame.Size = UDim2.new(0, textSize.X + 8, 0, 15)
            
            self.config:SetKeybind(module.flag, keycodeStr)
            
            -- Reconnect keybind
            table.insert(self.connections, UserInputService.InputBegan:Connect(function(input2, gameProcessed2)
                if gameProcessed2 then return end
                if tostring(input2.KeyCode) == keycodeStr then
                    SetState(not module.state)
                end
            end))
        end)
    end)
    
    module.SetState = SetState
    
    table.insert(tab.modules, module)
    
    -- Return module with element creation methods
    return setmetatable(module, {
        __index = {
            CreateSlider = function(m, opts) return self:CreateSlider(m, opts) end,
            CreateCheckbox = function(m, opts) return self:CreateCheckbox(m, opts) end,
            CreateDropdown = function(m, opts) return self:CreateDropdown(m, opts) end,
            CreateMultiDropdown = function(m, opts) return self:CreateMultiDropdown(m, opts) end,
            CreateTextbox = function(m, opts) return self:CreateTextbox(m, opts) end,
            CreateButton = function(m, opts) return self:CreateButton(m, opts) end,
            CreateColorpicker = function(m, opts) return self:CreateColorpicker(m, opts) end,
            CreateKeybind = function(m, opts) return self:CreateKeybind(m, opts) end
        }
    })
end

-- Slider Element
function Library:CreateSlider(module, options)
    options = options or {}
    local slider = {}
    slider.title = options.title or "Slider"
    slider.flag = options.flag or slider.title
    slider.min = options.minimum_value or options.min or 0
    slider.max = options.maximum_value or options.max or 100
    slider.value = self.config:GetFlag(slider.flag, options.value or options.default or slider.min)
    slider.round = options.round_number or options.round or false
    slider.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 27
    local sliderFrame = Instance.new("TextButton")
    sliderFrame.Name = "Slider"
    sliderFrame.Size = UDim2.new(0, 207, 0, 22)
    sliderFrame.BackgroundTransparency = 1
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Text = ""
    sliderFrame.AutoButtonColor = false
    sliderFrame.Parent = module.optionsFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = slider.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 153, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.05, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = sliderFrame
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(slider.value)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextTransparency = 0.2
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Size = UDim2.new(0, 42, 0, 13)
    valueLabel.Position = UDim2.new(1, 0, 0, 0)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = sliderFrame
    local dragFrame = Instance.new("Frame")
    dragFrame.Name = "Drag"
    dragFrame.Size = UDim2.new(0, 207, 0, 4)
    dragFrame.Position = UDim2.new(0.5, 0, 0.95, 0)
    dragFrame.AnchorPoint = Vector2.new(0.5, 1)
    dragFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    dragFrame.BackgroundTransparency = 0.9
    dragFrame.BorderSizePixel = 0
    dragFrame.Parent = sliderFrame

    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(1, 0)
    dragCorner.Parent = dragFrame
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "Fill"
    fillFrame.Size = UDim2.new(0, 103, 0, 4)
    fillFrame.Position = UDim2.new(0, 0, 0.5, 0)
    fillFrame.AnchorPoint = Vector2.new(0, 0.5)
    fillFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    fillFrame.BackgroundTransparency = 0.5
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = dragFrame
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fillFrame
    local fillGradient = Instance.new("UIGradient")
    fillGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79))}
    fillGradient.Parent = fillFrame
    local circle = Instance.new("Frame")
    circle.Name = "Circle"
    circle.Size = UDim2.new(0, 6, 0, 6)
    circle.Position = UDim2.new(1, 0, 0.5, 0)
    circle.AnchorPoint = Vector2.new(1, 0.5)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = fillFrame
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = circle
    local function SetValue(value)
        value = math.clamp(value, slider.min, slider.max)
        if slider.round then value = Round(value, 0) else value = Round(value, 1) end
        slider.value = value
        valueLabel.Text = tostring(value)
        local percentage = (value - slider.min) / (slider.max - slider.min)
        local fillSize = math.clamp(percentage, 0.02, 1) * dragFrame.AbsoluteSize.X
        Tween(fillFrame, {Size = UDim2.new(0, fillSize, 0, 4)}, 0.2)
        self.config:SetFlag(slider.flag, value)
        task.spawn(function() slider.callback(value) end)
    end
    SetValue(slider.value)
    local dragging = false
    local mouse = Players.LocalPlayer:GetMouse()
    sliderFrame.MouseButton1Down:Connect(function()
        dragging = true
        local function Update()
            local mousePos = (mouse.X - dragFrame.AbsolutePosition.X) / dragFrame.AbsoluteSize.X
            local value = slider.min + (slider.max - slider.min) * mousePos
            SetValue(value)
        end
        Update()

        local moveConnection = mouse.Move:Connect(Update)
        local releaseConnection
        releaseConnection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                moveConnection:Disconnect()
                releaseConnection:Disconnect()
            end
        end)
    end)
    slider.SetValue = SetValue
    table.insert(module.elements, slider)
    return slider
end

function Library:CreateCheckbox(module, options)
    options = options or {}
    local checkbox = {}
    checkbox.title = options.title or "Checkbox"
    checkbox.flag = options.flag or checkbox.title
    checkbox.state = self.config:GetFlag(checkbox.flag, options.default or false)
    checkbox.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 20
    local checkboxFrame = Instance.new("TextButton")
    checkboxFrame.Name = "Checkbox"
    checkboxFrame.Size = UDim2.new(0, 207, 0, 15)
    checkboxFrame.BackgroundTransparency = 1
    checkboxFrame.BorderSizePixel = 0
    checkboxFrame.Text = ""
    checkboxFrame.AutoButtonColor = false
    checkboxFrame.Parent = module.optionsFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = checkbox.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 142, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = checkboxFrame
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box"
    boxFrame.Size = UDim2.new(0, 15, 0, 15)
    boxFrame.Position = UDim2.new(1, 0, 0.5, 0)
    boxFrame.AnchorPoint = Vector2.new(1, 0.5)
    boxFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    boxFrame.BackgroundTransparency = 0.9
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = checkboxFrame
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = boxFrame

    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "Fill"
    fillFrame.Size = UDim2.new(0, 0, 0, 0)
    fillFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    fillFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fillFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    fillFrame.BackgroundTransparency = 0.2
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = boxFrame
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fillFrame
    local function SetState(state)
        checkbox.state = state
        self.config:SetFlag(checkbox.flag, state)
        if state then
            Tween(boxFrame, {BackgroundTransparency = 0.7}, 0.5)
            Tween(fillFrame, {Size = UDim2.new(0, 9, 0, 9)}, 0.5)
        else
            Tween(boxFrame, {BackgroundTransparency = 0.9}, 0.5)
            Tween(fillFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
        end
        task.spawn(function() checkbox.callback(state) end)
    end
    SetState(checkbox.state)
    checkboxFrame.MouseButton1Click:Connect(function() SetState(not checkbox.state) end)
    checkbox.SetState = SetState
    table.insert(module.elements, checkbox)
    return checkbox
end

function Library:CreateDropdown(module, options)
    options = options or {}
    local dropdown = {}
    dropdown.title = options.title or "Dropdown"
    dropdown.flag = options.flag or dropdown.title
    dropdown.options = options.options or {}
    dropdown.multi = options.multi_dropdown or false
    dropdown.maxVisible = options.maximum_options or math.min(#dropdown.options, 5)
    dropdown.selected = self.config:GetFlag(dropdown.flag, dropdown.multi and {} or (options.default or nil))
    dropdown.callback = options.callback or function() end
    dropdown.open = false
    local baseHeight = 44
    module.elementHeight = module.elementHeight + baseHeight
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(0, 207, 0, 39)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ClipsDescendants = true
    dropdownFrame.Parent = module.optionsFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = dropdown.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 207, 0, 13)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = dropdownFrame
    local selectButton = Instance.new("TextButton")
    selectButton.Name = "Select"
    selectButton.Size = UDim2.new(0, 207, 0, 22)
    selectButton.Position = UDim2.new(0, 0, 0, 17)
    selectButton.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    selectButton.BackgroundTransparency = 0.9
    selectButton.BorderSizePixel = 0
    selectButton.Text = ""
    selectButton.AutoButtonColor = false
    selectButton.Parent = dropdownFrame
    local selectCorner = Instance.new("UICorner")
    selectCorner.CornerRadius = UDim.new(0, 4)
    selectCorner.Parent = selectButton
    local selectLabel = Instance.new("TextLabel")
    selectLabel.Text = "None"
    selectLabel.Font = Enum.Font.GothamBold
    selectLabel.TextSize = 10
    selectLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    selectLabel.TextTransparency = 0.2
    selectLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectLabel.Size = UDim2.new(1, -25, 1, 0)
    selectLabel.Position = UDim2.new(0, 8, 0, 0)
    selectLabel.BackgroundTransparency = 1
    selectLabel.TextTruncate = Enum.TextTruncate.AtEnd
    selectLabel.Parent = selectButton
    local arrow = Instance.new("TextLabel")
    arrow.Text = "▼"
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 8
    arrow.TextColor3 = Color3.fromRGB(255, 255, 255)
    arrow.TextTransparency = 0.2
    arrow.Size = UDim2.new(0, 15, 1, 0)
    arrow.Position = UDim2.new(1, -15, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Parent = selectButton
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "Options"
    optionsFrame.Size = UDim2.new(0, 207, 0, 0)
    optionsFrame.Position = UDim2.new(0, 0, 0, 40)
    optionsFrame.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    optionsFrame.BackgroundTransparency = 0.5
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ScrollBarThickness = 4
    optionsFrame.ScrollBarImageColor3 = Color3.fromRGB(152, 181, 255)
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    optionsFrame.Visible = false
    optionsFrame.Parent = dropdownFrame

    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 4)
    optionsCorner.Parent = optionsFrame
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsFrame
    local function UpdateText()
        if dropdown.multi then
            if type(dropdown.selected) == "table" and #dropdown.selected > 0 then
                selectLabel.Text = table.concat(dropdown.selected, ", ")
            else
                selectLabel.Text = "None"
            end
        else
            selectLabel.Text = dropdown.selected or "None"
        end
    end
    local function Toggle(option)
        if dropdown.multi then
            if type(dropdown.selected) ~= "table" then dropdown.selected = {} end
            local found = false
            for i, v in ipairs(dropdown.selected) do
                if v == option then
                    table.remove(dropdown.selected, i)
                    found = true
                    break
                end
            end
            if not found then table.insert(dropdown.selected, option) end
        else
            dropdown.selected = option
        end
        UpdateText()
        self.config:SetFlag(dropdown.flag, dropdown.selected)
        task.spawn(function() dropdown.callback(dropdown.selected) end)
    end
    for _, option in ipairs(dropdown.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = option
        optionButton.Size = UDim2.new(1, -4, 0, 20)
        optionButton.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
        optionButton.BackgroundTransparency = 0.5
        optionButton.BorderSizePixel = 0
        optionButton.Text = ""
        optionButton.AutoButtonColor = false
        optionButton.Parent = optionsFrame
        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 3)
        optionCorner.Parent = optionButton
        local optionLabel = Instance.new("TextLabel")
        optionLabel.Text = option
        optionLabel.Font = Enum.Font.GothamBold
        optionLabel.TextSize = 10
        optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionLabel.TextTransparency = 0.3
        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
        optionLabel.Size = UDim2.new(1, -8, 1, 0)
        optionLabel.Position = UDim2.new(0, 8, 0, 0)
        optionLabel.BackgroundTransparency = 1
        optionLabel.Parent = optionButton
        optionButton.MouseButton1Click:Connect(function()
            Toggle(option)
            if not dropdown.multi then
                dropdown.open = false
                optionsFrame.Visible = false
                Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 39)}, 0.3)
                Tween(arrow, {Rotation = 0}, 0.3)
                local newModuleSize = 93 + module.elementHeight + 8
                Tween(module.frame, {Size = UDim2.new(0, 241, 0, newModuleSize)}, 0.3)
            end
        end)
    end

    selectButton.MouseButton1Click:Connect(function()
        dropdown.open = not dropdown.open
        optionsFrame.Visible = dropdown.open
        if dropdown.open then
            local optionHeight = math.min(#dropdown.options, dropdown.maxVisible) * 22
            Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 39 + optionHeight + 4)}, 0.3)
            Tween(optionsFrame, {Size = UDim2.new(0, 207, 0, optionHeight)}, 0.3)
            Tween(arrow, {Rotation = 180}, 0.3)
            local newModuleSize = 93 + module.elementHeight + optionHeight + 8
            Tween(module.frame, {Size = UDim2.new(0, 241, 0, newModuleSize)}, 0.3)
        else
            Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 39)}, 0.3)
            Tween(optionsFrame, {Size = UDim2.new(0, 207, 0, 0)}, 0.3)
            Tween(arrow, {Rotation = 0}, 0.3)
            local newModuleSize = 93 + module.elementHeight + 8
            Tween(module.frame, {Size = UDim2.new(0, 241, 0, newModuleSize)}, 0.3)
        end
    end)
    UpdateText()
    dropdown.SetValue = function(newOptions)
        if type(newOptions) == "table" then
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            dropdown.options = newOptions
            dropdown.maxVisible = math.min(#newOptions, 5)
            for _, option in ipairs(newOptions) do
                local optionButton = Instance.new("TextButton")
                optionButton.Name = option
                optionButton.Size = UDim2.new(1, -4, 0, 20)
                optionButton.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
                optionButton.BackgroundTransparency = 0.5
                optionButton.BorderSizePixel = 0
                optionButton.Text = ""
                optionButton.AutoButtonColor = false
                optionButton.Parent = optionsFrame
                local optionCorner = Instance.new("UICorner")
                optionCorner.CornerRadius = UDim.new(0, 3)
                optionCorner.Parent = optionButton
                local optionLabel = Instance.new("TextLabel")
                optionLabel.Text = option
                optionLabel.Font = Enum.Font.GothamBold
                optionLabel.TextSize = 10
                optionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                optionLabel.TextTransparency = 0.3
                optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                optionLabel.Size = UDim2.new(1, -8, 1, 0)
                optionLabel.Position = UDim2.new(0, 8, 0, 0)
                optionLabel.BackgroundTransparency = 1
                optionLabel.Parent = optionButton
                optionButton.MouseButton1Click:Connect(function()
                    Toggle(option)
                    if not dropdown.multi then
                        dropdown.open = false
                        optionsFrame.Visible = false
                        Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 39)}, 0.3)
                        Tween(arrow, {Rotation = 0}, 0.3)
                        local newModuleSize = 93 + module.elementHeight + 8
                        Tween(module.frame, {Size = UDim2.new(0, 241, 0, newModuleSize)}, 0.3)
                    end
                end)
            end
        else
            dropdown.selected = newOptions
            UpdateText()
        end
    end
    table.insert(module.elements, dropdown)
    return dropdown
end

function Library:CreateTextbox(module, options)
    options = options or {}
    local textbox = {}
    textbox.title = options.title or "Textbox"
    textbox.flag = options.flag or textbox.title
    textbox.placeholder = options.placeholder or "Enter text..."
    textbox.text = self.config:GetFlag(textbox.flag, options.default or "")
    textbox.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 32
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = textbox.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 207, 0, 13)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = module.optionsFrame
    local textboxFrame = Instance.new("TextBox")
    textboxFrame.Name = "Textbox"
    textboxFrame.Size = UDim2.new(0, 207, 0, 15)
    textboxFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    textboxFrame.BackgroundTransparency = 0.9
    textboxFrame.BorderSizePixel = 0
    textboxFrame.Font = Enum.Font.SourceSans
    textboxFrame.TextSize = 10
    textboxFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    textboxFrame.PlaceholderText = textbox.placeholder
    textboxFrame.Text = textbox.text
    textboxFrame.ClearTextOnFocus = false
    textboxFrame.Parent = module.optionsFrame
    local textboxCorner = Instance.new("UICorner")
    textboxCorner.CornerRadius = UDim.new(0, 4)
    textboxCorner.Parent = textboxFrame
    textboxFrame.FocusLost:Connect(function()
        textbox.text = textboxFrame.Text
        self.config:SetFlag(textbox.flag, textbox.text)
        task.spawn(function() textbox.callback(textbox.text) end)
    end)
    textbox.SetText = function(text)
        textbox.text = text
        textboxFrame.Text = text
    end
    textbox.textboxFrame = textboxFrame
    table.insert(module.elements, textbox)
    return textbox
end


function Library:CreateButton(module, options)
    local button = {}
    button.title = options.title or "Button"
    button.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 25
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button"
    buttonFrame.Size = UDim2.new(0, 207, 0, 20)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    buttonFrame.BackgroundTransparency = 0.8
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Text = ""
    buttonFrame.AutoButtonColor = false
    buttonFrame.Parent = module.optionsFrame
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = buttonFrame
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Text = button.title
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.TextSize = 11
    buttonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonLabel.TextTransparency = 0.2
    buttonLabel.Size = UDim2.new(1, 0, 1, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Parent = buttonFrame
    buttonFrame.MouseEnter:Connect(function()
        Tween(buttonFrame, {BackgroundTransparency = 0.6}, 0.3)
    end)
    buttonFrame.MouseLeave:Connect(function()
        Tween(buttonFrame, {BackgroundTransparency = 0.8}, 0.3)
    end)
    buttonFrame.MouseButton1Click:Connect(function()
        Tween(buttonFrame, {BackgroundTransparency = 0.4}, 0.1)
        task.wait(0.1)
        Tween(buttonFrame, {BackgroundTransparency = 0.6}, 0.1)
        task.spawn(function() button.callback() end)
    end)
    table.insert(module.elements, button)
    return button
end

function Library:CreateColorpicker(module, options)
    options = options or {}
    local colorpicker = {}
    colorpicker.title = options.title or "Color"
    colorpicker.flag = options.flag or colorpicker.title
    colorpicker.default = options.default or Color3.fromRGB(255, 255, 255)
    colorpicker.color = self.config:GetFlag(colorpicker.flag, colorpicker.default)
    colorpicker.callback = options.callback or function() end
    colorpicker.open = false
    module.elementHeight = module.elementHeight + 20
    local colorFrame = Instance.new("TextButton")
    colorFrame.Name = "Colorpicker"
    colorFrame.Size = UDim2.new(0, 207, 0, 15)
    colorFrame.BackgroundTransparency = 1
    colorFrame.BorderSizePixel = 0
    colorFrame.Text = ""
    colorFrame.AutoButtonColor = false
    colorFrame.Parent = module.optionsFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = colorpicker.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 142, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = colorFrame
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Name = "Display"
    colorDisplay.Size = UDim2.new(0, 30, 0, 15)
    colorDisplay.Position = UDim2.new(1, 0, 0.5, 0)
    colorDisplay.AnchorPoint = Vector2.new(1, 0.5)
    colorDisplay.BackgroundColor3 = colorpicker.color
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Text = ""
    colorDisplay.AutoButtonColor = false
    colorDisplay.Parent = colorFrame
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = colorDisplay
    local displayStroke = Instance.new("UIStroke")
    displayStroke.Color = Color3.fromRGB(255, 255, 255)
    displayStroke.Transparency = 0.7
    displayStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    displayStroke.Parent = colorDisplay
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Name = "Picker"
    pickerFrame.Size = UDim2.new(0, 180, 0, 150)
    pickerFrame.Position = UDim2.new(0, 0, 0, 20)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    pickerFrame.BackgroundTransparency = 0.1
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 100
    pickerFrame.Parent = colorFrame
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = pickerFrame
    local pickerStroke = Instance.new("UIStroke")
    pickerStroke.Color = Color3.fromRGB(52, 66, 89)
    pickerStroke.Transparency = 0.5
    pickerStroke.Parent = pickerFrame
    local saturationFrame = Instance.new("ImageButton")
    saturationFrame.Name = "Saturation"
    saturationFrame.Size = UDim2.new(0, 140, 0, 120)
    saturationFrame.Position = UDim2.new(0, 10, 0, 10)
    saturationFrame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    saturationFrame.BorderSizePixel = 0
    saturationFrame.AutoButtonColor = false
    saturationFrame.Parent = pickerFrame
    local satCorner = Instance.new("UICorner")
    satCorner.CornerRadius = UDim.new(0, 4)
    satCorner.Parent = saturationFrame
    local satGradient1 = Instance.new("UIGradient")
    satGradient1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))}
    satGradient1.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
    satGradient1.Parent = saturationFrame
    local satOverlay = Instance.new("Frame")
    satOverlay.Size = UDim2.new(1, 0, 1, 0)
    satOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    satOverlay.BorderSizePixel = 0
    satOverlay.Parent = saturationFrame
    local satCorner2 = Instance.new("UICorner")
    satCorner2.CornerRadius = UDim.new(0, 4)
    satCorner2.Parent = satOverlay
    local satGradient2 = Instance.new("UIGradient")
    satGradient2.Rotation = 90
    satGradient2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
    satGradient2.Parent = satOverlay
    local hueFrame = Instance.new("ImageButton")
    hueFrame.Name = "Hue"
    hueFrame.Size = UDim2.new(0, 15, 0, 120)
    hueFrame.Position = UDim2.new(0, 160, 0, 10)
    hueFrame.BorderSizePixel = 0
    hueFrame.AutoButtonColor = false
    hueFrame.Parent = pickerFrame
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 4)
    hueCorner.Parent = hueFrame
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Rotation = 90
    hueGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
    }
    hueGradient.Parent = hueFrame
    local h, s, v = 0, 1, 1
    local function UpdateColor()
        local color = Color3.fromHSV(h, s, v)
        colorpicker.color = color
        colorDisplay.BackgroundColor3 = color
        saturationFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        self.config:SetFlag(colorpicker.flag, color)
        task.spawn(function() colorpicker.callback(color) end)
    end
    local function ColorToHSV(color)
        return color:ToHSV()
    end
    h, s, v = ColorToHSV(colorpicker.color)
    saturationFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    local draggingSat = false
    local draggingHue = false
    saturationFrame.MouseButton1Down:Connect(function()
        draggingSat = true
        local function update()
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos - saturationFrame.AbsolutePosition
            s = math.clamp(relativePos.X / saturationFrame.AbsoluteSize.X, 0, 1)
            v = 1 - math.clamp(relativePos.Y / saturationFrame.AbsoluteSize.Y, 0, 1)
            UpdateColor()
        end
        update()
        local connection
        connection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSat = false
                connection:Disconnect()
            end
        end)
    end)
    saturationFrame.MouseMoved:Connect(function()
        if not draggingSat then return end
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - saturationFrame.AbsolutePosition
        s = math.clamp(relativePos.X / saturationFrame.AbsoluteSize.X, 0, 1)
        v = 1 - math.clamp(relativePos.Y / saturationFrame.AbsoluteSize.Y, 0, 1)
        UpdateColor()
    end)
    hueFrame.MouseButton1Down:Connect(function()
        draggingHue = true
        local function update()
            local mousePos = UserInputService:GetMouseLocation()
            local relativePos = mousePos - hueFrame.AbsolutePosition
            h = math.clamp(relativePos.Y / hueFrame.AbsoluteSize.Y, 0, 1)
            UpdateColor()
        end
        update()
        local connection
        connection = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = false
                connection:Disconnect()
            end
        end)
    end)
    hueFrame.MouseMoved:Connect(function()
        if not draggingHue then return end
        local mousePos = UserInputService:GetMouseLocation()
        local relativePos = mousePos - hueFrame.AbsolutePosition
        h = math.clamp(relativePos.Y / hueFrame.AbsoluteSize.Y, 0, 1)
        UpdateColor()
    end)
    colorDisplay.MouseButton1Click:Connect(function()
        colorpicker.open = not colorpicker.open
        pickerFrame.Visible = colorpicker.open
    end)
    local function SetColor(color)
        colorpicker.color = color
        colorDisplay.BackgroundColor3 = color
        h, s, v = ColorToHSV(color)
        saturationFrame.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        self.config:SetFlag(colorpicker.flag, color)
        task.spawn(function() colorpicker.callback(color) end)
    end
    colorpicker.SetColor = SetColor
    table.insert(module.elements, colorpicker)
    return colorpicker
end

function Library:CreateMultiDropdown(module, options)
    options.multi_dropdown = true
    return self:CreateDropdown(module, options)
end

function Library:CreateKeybind(module, options)
    options = options or {}
    local keybind = {}
    keybind.title = options.title or "Keybind"
    keybind.flag = options.flag or keybind.title
    keybind.default = options.default
    keybind.key = self.config:GetKeybind(keybind.flag) or keybind.default
    keybind.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 20
    local keybindFrame = Instance.new("TextButton")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(0, 207, 0, 15)
    keybindFrame.BackgroundTransparency = 1
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Text = ""
    keybindFrame.AutoButtonColor = false
    keybindFrame.Parent = module.optionsFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = keybind.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 142, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = keybindFrame
    local keyDisplay = Instance.new("Frame")
    keyDisplay.Name = "Display"
    keyDisplay.Size = UDim2.new(0, 33, 0, 15)
    keyDisplay.Position = UDim2.new(1, 0, 0.5, 0)
    keyDisplay.AnchorPoint = Vector2.new(1, 0.5)
    keyDisplay.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    keyDisplay.BackgroundTransparency = 0.7
    keyDisplay.BorderSizePixel = 0
    keyDisplay.Parent = keybindFrame
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 3)
    displayCorner.Parent = keyDisplay
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Text = keybind.key and keybind.key:gsub("Enum.KeyCode.", "") or "None"
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 10
    keyLabel.TextColor3 = Color3.fromRGB(209, 222, 255)
    keyLabel.Size = UDim2.new(1, -4, 1, 0)
    keyLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    keyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Parent = keyDisplay
    if keybind.key then
        local textSize = TextService:GetTextSize(keyLabel.Text, 10, Enum.Font.GothamBold, Vector2.new(1000, 15))
        keyDisplay.Size = UDim2.new(0, textSize.X + 8, 0, 15)
    end
    local function SetKey(keycode)
        keybind.key = keycode
        local displayText = keycode and keycode:gsub("Enum.KeyCode.", "") or "None"
        keyLabel.Text = displayText
        local textSize = TextService:GetTextSize(displayText, 10, Enum.Font.GothamBold, Vector2.new(1000, 15))
        keyDisplay.Size = UDim2.new(0, textSize.X + 8, 0, 15)
        self.config:SetKeybind(keybind.flag, keycode)
        task.spawn(function() keybind.callback(keycode) end)
    end
    keybindFrame.MouseButton1Click:Connect(function()
        if self.choosingKeybind then return end
        self.choosingKeybind = true
        keyLabel.Text = "..."
        keyDisplay.Size = UDim2.new(0, 33, 0, 15)
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            connection:Disconnect()
            self.choosingKeybind = false
            if input.KeyCode == Enum.KeyCode.Backspace then
                SetKey(nil)
            else
                SetKey(tostring(input.KeyCode))
            end
        end)
    end)
    keybind.SetKey = SetKey
    table.insert(module.elements, keybind)
    return keybind
end

return Library
