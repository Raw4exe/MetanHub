
local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')
local TextService = game:GetService('TextService')

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
    },
    Ocean = {
        Primary = Color3.fromRGB(100, 200, 255),
        Background = Color3.fromRGB(10, 15, 20),
        Secondary = Color3.fromRGB(20, 30, 45),
        Accent = Color3.fromRGB(40, 60, 90),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Orange = {
        Primary = Color3.fromRGB(255, 150, 50),
        Background = Color3.fromRGB(18, 12, 8),
        Secondary = Color3.fromRGB(35, 25, 18),
        Accent = Color3.fromRGB(70, 50, 35),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Pink = {
        Primary = Color3.fromRGB(255, 120, 180),
        Background = Color3.fromRGB(18, 10, 15),
        Secondary = Color3.fromRGB(35, 22, 30),
        Accent = Color3.fromRGB(70, 45, 60),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Cyan = {
        Primary = Color3.fromRGB(50, 255, 220),
        Background = Color3.fromRGB(8, 15, 15),
        Secondary = Color3.fromRGB(18, 30, 30),
        Accent = Color3.fromRGB(35, 60, 60),
        Text = Color3.fromRGB(255, 255, 255)
    },
    Yellow = {
        Primary = Color3.fromRGB(255, 220, 80),
        Background = Color3.fromRGB(15, 14, 10),
        Secondary = Color3.fromRGB(30, 28, 20),
        Accent = Color3.fromRGB(60, 55, 40),
        Text = Color3.fromRGB(255, 255, 255)
    }
}

Library.Fonts = {
    "Gotham",
    "GothamBold", 
    "GothamBlack",
    "SourceSans",
    "SourceSansBold",
    "Arial",
    "ArialBold",
    "RobotoMono",
    "Ubuntu",
    "Oswald"
}

function Library.new()
    local self = setmetatable({}, Library)
    
    self.config = ConfigManager.new()
    self.tabs = {}
    self.currentTab = nil
    self.choosingKeybind = false
    self.connections = {}
    self.currentTheme = self.Themes.Default
    local savedFont = self.config:GetFlag("_UI_Font", "GothamBold")
    self.currentFont = Enum.Font[savedFont] or Enum.Font.GothamBold
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
        self.uiKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if tostring(input.KeyCode) == savedKeybind then
                self:ToggleUI()
            end
        end)
    end
end

function Library:SetUIKeybind(keycode)
    self.uiKeybind = keycode
    self.config:SetKeybind("_UI_Toggle", keycode)
    
    if self.uiKeybindConnection then
        self.uiKeybindConnection:Disconnect()
        self.uiKeybindConnection = nil
    end
    
    if keycode then
        self.uiKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if tostring(input.KeyCode) == keycode then
                self:ToggleUI()
            end
        end)
    end
end

function Library:SetTheme(themeName)
    local theme = self.Themes[themeName]
    if not theme then return end
    self.currentTheme = theme
    self:ApplyTheme()
end

function Library:SetFont(fontName)
    local font = Enum.Font[fontName]
    if not font then return end
    self.currentFont = font
    self.config:SetFlag("_UI_Font", fontName)
    self:ApplyFont()
end

function Library:ApplyFont()
    local font = self.currentFont
    if not self.ui then return end
    
    for _, descendant in ipairs(self.ui:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            if descendant.Name ~= "Icon" then
                descendant.Font = font
            end
        end
    end
    
    if self.container then
        for _, descendant in ipairs(self.container:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                if descendant.Name ~= "Icon" then
                    descendant.Font = font
                end
            end
        end
    end
end

function Library:ApplyTheme()
    local theme = self.currentTheme
    if not self.container then return end
    
    Tween(self.container, {BackgroundColor3 = theme.Background}, 0.3)
    
    Tween(self.logo, {TextColor3 = theme.Primary}, 0.3)
    Tween(self.logoIcon, {ImageColor3 = theme.Primary}, 0.3)
    Tween(self.pin, {BackgroundColor3 = theme.Primary}, 0.3)
    
    local divider = self.handler:FindFirstChild("Divider")
    if divider then
        Tween(divider, {BackgroundColor3 = theme.Accent}, 0.3)
    end
    
    local containerStroke = self.container:FindFirstChildOfClass("UIStroke")
    if containerStroke then
        Tween(containerStroke, {Color = theme.Accent}, 0.3)
    end
    
    for _, tab in ipairs(self.tabs) do
        if tab.button then
            local isSelected = (tab == self.currentTab)
            if isSelected then
                Tween(tab.button, {BackgroundColor3 = theme.Secondary}, 0.3)
                local icon = tab.button:FindFirstChild("Icon")
                local label = tab.button:FindFirstChild("Label")
                if icon then Tween(icon, {ImageColor3 = theme.Primary}, 0.3) end
                if label then Tween(label, {TextColor3 = theme.Primary}, 0.3) end
            else
                Tween(tab.button, {BackgroundColor3 = theme.Secondary}, 0.3)
            end
        end
        
        for _, module in ipairs(tab.modules) do
            if module.frame then
                Tween(module.frame, {BackgroundColor3 = theme.Secondary}, 0.3)
                local stroke = module.frame:FindFirstChildOfClass("UIStroke")
                if stroke then
                    Tween(stroke, {Color = theme.Accent}, 0.3)
                end
            end
            
            if module.toggleFrame then
                if module.state then
                    Tween(module.toggleFrame, {BackgroundColor3 = theme.Primary}, 0.3)
                    Tween(module.toggleCircle, {BackgroundColor3 = theme.Primary}, 0.3)
                end
            end
            
            local header = module.frame and module.frame:FindFirstChild("Header")
            if header then
                local title = header:FindFirstChild("Title")
                local desc = header:FindFirstChild("Description")
                local icon = header:FindFirstChild("Icon")
                if title then Tween(title, {TextColor3 = theme.Primary}, 0.3) end
                if desc then Tween(desc, {TextColor3 = theme.Primary}, 0.3) end
                if icon then Tween(icon, {ImageColor3 = theme.Primary}, 0.3) end
                
                for _, child in ipairs(header:GetChildren()) do
                    if child.Name == "Divider" then
                        Tween(child, {BackgroundColor3 = theme.Accent}, 0.3)
                    end
                end
                
                local keybindFrame = header:FindFirstChild("Keybind")
                if keybindFrame then
                    Tween(keybindFrame, {BackgroundColor3 = theme.Primary}, 0.3)
                end
            end
            
            for _, element in ipairs(module.elements or {}) do
                if element.dragFrame then
                    Tween(element.dragFrame, {BackgroundColor3 = theme.Primary}, 0.3)
                    if element.fillFrame then
                        Tween(element.fillFrame, {BackgroundColor3 = theme.Primary}, 0.3)
                    end
                end
                
                if element.boxFrame then
                    Tween(element.boxFrame, {BackgroundColor3 = theme.Primary}, 0.3)
                    if element.fillFrame and element.state then
                        Tween(element.fillFrame, {BackgroundColor3 = theme.Primary}, 0.3)
                    end
                end
            end
        end
    end
end

function Library:CreateUI()
    local oldUI = CoreGui:FindFirstChild("MarchUI")
    if oldUI then
        oldUI:Destroy()
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MarchUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    
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
    
    local handler = Instance.new("Frame")
    handler.Name = "Handler"
    handler.Size = UDim2.new(0, 698, 0, 479)
    handler.BackgroundTransparency = 1
    handler.Parent = container
    
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
    
    local logoIconButton = Instance.new("ImageButton")
    logoIconButton.Name = "Icon"
    logoIconButton.Image = "rbxassetid://107819132007001"
    logoIconButton.Size = UDim2.new(0, 18, 0, 18)
    logoIconButton.Position = UDim2.new(0.025, 0, 0.055, 0)
    logoIconButton.AnchorPoint = Vector2.new(0, 0.5)
    logoIconButton.BackgroundTransparency = 1
    logoIconButton.ImageColor3 = Color3.fromRGB(152, 181, 255)
    logoIconButton.ScaleType = Enum.ScaleType.Fit
    logoIconButton.AutoButtonColor = false
    logoIconButton.Parent = handler
    
    logoIconButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    
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
    
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0, 1, 0, 479)
    divider.Position = UDim2.new(0.235, 0, 0, 0)
    divider.BackgroundColor3 = Color3.fromRGB(52, 66, 89)
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = handler
    
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
    
    local sectionsFolder = Instance.new("Folder")
    sectionsFolder.Name = "Sections"
    sectionsFolder.Parent = handler
    
    self.ui = screenGui
    self.container = container
    self.handler = handler
    self.tabsFrame = tabsFrame
    self.sectionsFolder = sectionsFolder
    self.pin = pin
    self.logo = logo
    self.logoIcon = logoIconButton
    
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
    self:CreateWatermark()
end

function Library:CreateTab(name, icon)
    local tab = {}
    tab.name = name
    tab.icon = icon
    tab.modules = {}
    
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
    
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tab)
    end)
    
    table.insert(self.tabs, tab)
    
    if #self.tabs == 1 then
        self:SelectTab(tab)
    end
    
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
    
    for _, t in ipairs(self.tabs) do
        t.leftSection.Visible = false
        t.rightSection.Visible = false
    end
    
    tab.leftSection.Visible = true
    tab.rightSection.Visible = true
    
    for i, t in ipairs(self.tabs) do
        local button = t.button
        local icon = button.Icon
        local label = button.Label
        
        if t == tab then
            Tween(button, {BackgroundTransparency = 0.5}, 0.5)
            Tween(icon, {ImageTransparency = 0.2, ImageColor3 = Color3.fromRGB(152, 181, 255)}, 0.5)
            Tween(label, {TextTransparency = 0.2, TextColor3 = Color3.fromRGB(152, 181, 255)}, 0.5)
            Tween(label.UIGradient, {Offset = Vector2.new(1, 0)}, 0.5)
            
            local offset = (i - 1) * (0.113 / 1.3)
            Tween(self.pin, {Position = UDim2.fromScale(0.026, 0.135 + offset)}, 0.5)
        else
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
        options = {"Default", "Ocean", "Purple", "Green", "Red", "Orange", "Pink", "Cyan", "Yellow", "Dark"},
        default = "Default",
        callback = function(theme)
            self:SetTheme(theme)
            print("Theme changed to:", theme)
        end
    })
    
    uiModule:CreateDropdown({
        title = "Font",
        options = self.Fonts,
        default = self.config:GetFlag("_UI_Font", "GothamBold"),
        callback = function(font)
            self:SetFont(font)
            print("Font changed to:", font)
            print("Note: Restart UI to apply font changes")
        end
    })
    
    uiModule:CreateButton({
        title = "Unload UI",
        callback = function()
            self:Unload()
        end
    })
    
    return settingsTab
end

function Library:CreateModule(tab, options)
    local module = {}
    module.title = options.title or "Module"
    module.description = options.description or ""
    module.flag = options.flag or module.title
    module.callback = options.callback or function() end
    module.section = options.section == "right" and tab.rightSection or tab.leftSection
    module.state = self.config:GetFlag(module.flag, false)
    module.elements = {}
    module.elementHeight = 8  
    module.multiplier = 0
    
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
    
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(0, 241, 0, 93)
    header.BackgroundTransparency = 1
    header.BorderSizePixel = 0
    header.Text = ""
    header.AutoButtonColor = false
    header.LayoutOrder = 0
    header.Parent = moduleFrame
    
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
        
        local newSize = module.state and (93 + module.elementHeight + module.multiplier) or 93
        Tween(moduleFrame, {Size = UDim2.new(0, 241, 0, newSize)}, 0.5)
        Tween(optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
        
        task.spawn(function()
            module.callback(state)
        end)
    end
    
    if module.state then
        SetState(true)
    end
    
    header.MouseButton1Click:Connect(function()
        SetState(not module.state)
    end)
    
    local savedKeybind = self.config:GetKeybind(module.flag)
    if savedKeybind then
        local displayText = savedKeybind:gsub("Enum.KeyCode.", "")
        keybindLabel.Text = displayText
        
        local length = #displayText
        local width = math.max(33, length * 7 + 8)
        keybindFrame.Size = UDim2.new(0, width, 0, 15)
        
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
            
            local length = #displayText
            local width = math.max(33, length * 7 + 8)
            keybindFrame.Size = UDim2.new(0, width, 0, 15)
            
            self.config:SetKeybind(module.flag, keycodeStr)
            
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
    module.elementHeight = module.elementHeight + 30
    local sliderFrame = Instance.new("TextButton")
    sliderFrame.Name = "Slider"
    sliderFrame.Size = UDim2.new(0, 207, 0, 25)
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
    module.elementHeight = module.elementHeight + 22
    local checkboxFrame = Instance.new("TextButton")
    checkboxFrame.Name = "Checkbox"
    checkboxFrame.Size = UDim2.new(0, 207, 0, 18)
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
    dropdown.size = 0
    
    local baseHeight = 48
    module.elementHeight = module.elementHeight + baseHeight
    
    local dropdownFrame = Instance.new("TextButton")
    dropdownFrame.Name = "Dropdown"
    dropdownFrame.Size = UDim2.new(0, 207, 0, 42)
    dropdownFrame.BackgroundTransparency = 1
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.Text = ""
    dropdownFrame.AutoButtonColor = false
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
    
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.ClipsDescendants = true
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.BackgroundTransparency = 0.9
    box.Position = UDim2.new(0.5, 0, 1.2, 0)
    box.Size = UDim2.new(0, 207, 0, 22)
    box.BorderSizePixel = 0
    box.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    box.Parent = titleLabel
    
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.AnchorPoint = Vector2.new(0.5, 0)
    header.BackgroundTransparency = 1
    header.Position = UDim2.new(0.5, 0, 0, 0)
    header.Size = UDim2.new(0, 207, 0, 22)
    header.BorderSizePixel = 0
    header.Parent = box
    
    local currentOption = Instance.new("TextLabel")
    currentOption.Name = "CurrentOption"
    currentOption.Font = Enum.Font.GothamBold
    currentOption.TextSize = 10
    currentOption.TextColor3 = Color3.fromRGB(255, 255, 255)
    currentOption.TextTransparency = 0.2
    currentOption.Text = "None"
    currentOption.Size = UDim2.new(0, 161, 0, 13)
    currentOption.AnchorPoint = Vector2.new(0, 0.5)
    currentOption.Position = UDim2.new(0.05, 0, 0.5, 0)
    currentOption.BackgroundTransparency = 1
    currentOption.TextXAlignment = Enum.TextXAlignment.Left
    currentOption.Parent = header
    
    local optionGradient = Instance.new("UIGradient")
    optionGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(0.87, 0.36),
        NumberSequenceKeypoint.new(1, 1)
    }
    optionGradient.Parent = currentOption
    
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.AnchorPoint = Vector2.new(0, 0.5)
    arrow.Image = "rbxassetid://84232453189324"
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(0.91, 0, 0.5, 0)
    arrow.Size = UDim2.new(0, 8, 0, 8)
    arrow.Parent = header
    
    local optionsFrame = Instance.new("ScrollingFrame")
    optionsFrame.Name = "Options"
    optionsFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    optionsFrame.Active = true
    optionsFrame.ScrollBarImageTransparency = 1
    optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
    optionsFrame.ScrollBarThickness = 0
    optionsFrame.Size = UDim2.new(0, 207, 0, 0)
    optionsFrame.BackgroundTransparency = 1
    optionsFrame.Position = UDim2.new(0, 0, 1, 0)
    optionsFrame.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    optionsFrame.Parent = box
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsFrame
    
    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, -1)
    optionsPadding.PaddingLeft = UDim.new(0, 10)
    optionsPadding.Parent = optionsFrame
    
    local boxLayout = Instance.new("UIListLayout")
    boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    boxLayout.Parent = box
    
    local function UpdateText()
        if dropdown.multi then
            if type(dropdown.selected) == "table" and #dropdown.selected > 0 then
                currentOption.Text = table.concat(dropdown.selected, ", ")
            else
                currentOption.Text = "None"
            end
        else
            currentOption.Text = dropdown.selected or "None"
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
    
    dropdown.size = 3
    dropdown.updateFunctions = {}
    
    for index, option in ipairs(dropdown.options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Name = "Option"
        optionButton.Font = Enum.Font.GothamBold
        optionButton.Active = false
        optionButton.TextTransparency = 0.6
        optionButton.AnchorPoint = Vector2.new(0, 0.5)
        optionButton.TextSize = 10
        optionButton.Size = UDim2.new(0, 186, 0, 16)
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.Text = option
        optionButton.AutoButtonColor = false
        optionButton.BackgroundTransparency = 1
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Selectable = false
        optionButton.Parent = optionsFrame
        
        local optionGradient = Instance.new("UIGradient")
        optionGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.7, 0),
            NumberSequenceKeypoint.new(0.87, 0.36),
            NumberSequenceKeypoint.new(1, 1)
        }
        optionGradient.Parent = optionButton
        
        local function UpdateOptionAppearance()
            local isSelected = false
            if dropdown.multi then
                if type(dropdown.selected) == "table" then
                    for _, v in ipairs(dropdown.selected) do
                        if v == option then
                            isSelected = true
                            break
                        end
                    end
                end
            else
                isSelected = (dropdown.selected == option)
            end
            
            if isSelected then
                optionButton.TextTransparency = 0.2
                optionButton.TextColor3 = Color3.fromRGB(152, 181, 255)
            else
                optionButton.TextTransparency = 0.7
                optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            end
        end
        
        table.insert(dropdown.updateFunctions, UpdateOptionAppearance)
        
        UpdateOptionAppearance()
        
        optionButton.MouseButton1Click:Connect(function()
            Toggle(option)
            if dropdown.updateFunctions then
                for _, updateFunc in ipairs(dropdown.updateFunctions) do
                    updateFunc()
                end
            end
            UpdateOptionAppearance()
            if not dropdown.multi then
                dropdown.open = false
                Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 42)}, 0.5)
                Tween(box, {Size = UDim2.new(0, 207, 0, 22)}, 0.5)
                Tween(arrow, {Rotation = 0}, 0.5)
                module.multiplier = module.multiplier - dropdown.size
                Tween(module.frame, {Size = UDim2.new(0, 241, 0, 93 + module.elementHeight + module.multiplier)}, 0.5)
                Tween(module.optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
            end
        end)
        
        if index > dropdown.maxVisible then
            continue
        end
        dropdown.size = dropdown.size + 16
        optionsFrame.Size = UDim2.fromOffset(207, dropdown.size)
    end
    
    dropdownFrame.MouseButton1Click:Connect(function()
        dropdown.open = not dropdown.open
        if dropdown.open then
            module.multiplier = module.multiplier + dropdown.size
            Tween(module.frame, {Size = UDim2.new(0, 241, 0, 93 + module.elementHeight + module.multiplier)}, 0.5)
            Tween(module.optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
            Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 42 + dropdown.size)}, 0.5)
            Tween(box, {Size = UDim2.new(0, 207, 0, 22 + dropdown.size)}, 0.5)
            Tween(arrow, {Rotation = 180}, 0.5)
        else
            module.multiplier = module.multiplier - dropdown.size
            Tween(module.frame, {Size = UDim2.new(0, 241, 0, 93 + module.elementHeight + module.multiplier)}, 0.5)
            Tween(module.optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
            Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 42)}, 0.5)
            Tween(box, {Size = UDim2.new(0, 207, 0, 22)}, 0.5)
            Tween(arrow, {Rotation = 0}, 0.5)
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
                        Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 42)}, 0.3)
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
    
    local h, s, v = colorpicker.color:ToHSV()
    colorpicker.hue = h
    colorpicker.sat = s
    colorpicker.vib = v
    
    module.elementHeight = module.elementHeight + 22
    
    local colorFrame = Instance.new("TextButton")
    colorFrame.Name = "Colorpicker"
    colorFrame.Size = UDim2.new(0, 207, 0, 17)
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
    
    local displayChecker = Instance.new("ImageLabel")
    displayChecker.Size = UDim2.new(0, 26, 0, 15)
    displayChecker.Position = UDim2.new(1, 0, 0.5, 0)
    displayChecker.AnchorPoint = Vector2.new(1, 0.5)
    displayChecker.Image = "http://www.roblox.com/asset/?id=14204231522"
    displayChecker.ImageTransparency = 0.45
    displayChecker.ScaleType = Enum.ScaleType.Tile
    displayChecker.TileSize = UDim2.fromOffset(40, 40)
    displayChecker.BackgroundTransparency = 1
    displayChecker.Parent = colorFrame
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = displayChecker
    
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Size = UDim2.fromScale(1, 1)
    colorDisplay.BackgroundColor3 = colorpicker.color
    colorDisplay.BorderSizePixel = 0
    colorDisplay.Text = ""
    colorDisplay.AutoButtonColor = false
    colorDisplay.Parent = displayChecker
    
    local displayCorner2 = Instance.new("UICorner")
    displayCorner2.CornerRadius = UDim.new(0, 4)
    displayCorner2.Parent = colorDisplay
    
    local blurOverlay = Instance.new("Frame")
    blurOverlay.Name = "BlurOverlay"
    blurOverlay.Size = UDim2.new(1, 0, 1, 0)
    blurOverlay.Position = UDim2.new(0, 0, 0, 0)
    blurOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blurOverlay.BackgroundTransparency = 1
    blurOverlay.BorderSizePixel = 0
    blurOverlay.ZIndex = 999
    blurOverlay.Visible = false
    blurOverlay.Parent = self.container
    
    local dialog = Instance.new("Frame")
    dialog.Name = "ColorDialog"
    dialog.Size = UDim2.fromOffset(260, 230)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    dialog.BackgroundTransparency = 0.05
    dialog.BorderSizePixel = 0
    dialog.Visible = false
    dialog.ZIndex = 1000
    dialog.Parent = self.container
    
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 6)
    dialogCorner.Parent = dialog
    
    local dialogStroke = Instance.new("UIStroke")
    dialogStroke.Color = Color3.fromRGB(52, 66, 89)
    dialogStroke.Transparency = 0.5
    dialogStroke.Parent = dialog
    
    local dialogTitle = Instance.new("TextLabel")
    dialogTitle.Text = colorpicker.title
    dialogTitle.Font = Enum.Font.GothamBold
    dialogTitle.TextSize = 13
    dialogTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    dialogTitle.Size = UDim2.new(1, -20, 0, 25)
    dialogTitle.Position = UDim2.fromOffset(10, 5)
    dialogTitle.BackgroundTransparency = 1
    dialogTitle.TextXAlignment = Enum.TextXAlignment.Left
    dialogTitle.ZIndex = 1001
    dialogTitle.Parent = dialog
    
    local satVibMap = Instance.new("ImageButton")
    satVibMap.Size = UDim2.fromOffset(190, 130)
    satVibMap.Position = UDim2.fromOffset(15, 35)
    satVibMap.Image = "rbxassetid://4155801252"
    satVibMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    satVibMap.BorderSizePixel = 0
    satVibMap.AutoButtonColor = false
    satVibMap.ZIndex = 1001
    satVibMap.Parent = dialog
    
    local satVibCorner = Instance.new("UICorner")
    satVibCorner.CornerRadius = UDim.new(0, 4)
    satVibCorner.Parent = satVibMap
    
    local cursor = Instance.new("ImageLabel")
    cursor.Size = UDim2.fromOffset(18, 18)
    cursor.ScaleType = Enum.ScaleType.Fit
    cursor.AnchorPoint = Vector2.new(0.5, 0.5)
    cursor.BackgroundTransparency = 1
    cursor.Image = "http://www.roblox.com/asset/?id=4805639000"
    cursor.Position = UDim2.new(s, 0, 1 - v, 0)
    cursor.ZIndex = 1002
    cursor.Parent = satVibMap
    
    local hueSlider = Instance.new("Frame")
    hueSlider.Size = UDim2.fromOffset(14, 130)
    hueSlider.Position = UDim2.fromOffset(215, 35)
    hueSlider.BorderSizePixel = 0
    hueSlider.ZIndex = 1001
    hueSlider.Parent = dialog
    
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(1, 0)
    hueCorner.Parent = hueSlider
    
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
    hueGradient.Parent = hueSlider
    
    local hueDragHolder = Instance.new("Frame")
    hueDragHolder.Size = UDim2.new(1, 0, 1, -10)
    hueDragHolder.Position = UDim2.fromOffset(0, 5)
    hueDragHolder.BackgroundTransparency = 1
    hueDragHolder.ZIndex = 1002
    hueDragHolder.Parent = hueSlider
    
    local hueDrag = Instance.new("ImageLabel")
    hueDrag.Size = UDim2.fromOffset(14, 14)
    hueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
    hueDrag.Position = UDim2.new(0, 0, h, -6)
    hueDrag.BackgroundTransparency = 1
    hueDrag.ZIndex = 1003
    hueDrag.Parent = hueDragHolder
    
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.fromOffset(35, 28)
    colorPreview.Position = UDim2.fromOffset(15, 175)
    colorPreview.BackgroundColor3 = colorpicker.color
    colorPreview.BorderSizePixel = 0
    colorPreview.ZIndex = 1001
    colorPreview.Parent = dialog
    
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 4)
    previewCorner.Parent = colorPreview
    
    local hexInput = Instance.new("TextBox")
    hexInput.Size = UDim2.fromOffset(80, 28)
    hexInput.Position = UDim2.fromOffset(55, 175)
    hexInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    hexInput.BackgroundTransparency = 0.5
    hexInput.BorderSizePixel = 0
    hexInput.Font = Enum.Font.GothamBold
    hexInput.TextSize = 11
    hexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    hexInput.Text = "#" .. colorpicker.color:ToHex()
    hexInput.PlaceholderText = "#FFFFFF"
    hexInput.ClearTextOnFocus = false
    hexInput.ZIndex = 1001
    hexInput.Parent = dialog
    
    local hexCorner = Instance.new("UICorner")
    hexCorner.CornerRadius = UDim.new(0, 4)
    hexCorner.Parent = hexInput
    
    -- Accept Button
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Text = "Accept"
    acceptBtn.Font = Enum.Font.GothamBold
    acceptBtn.TextSize = 11
    acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptBtn.Size = UDim2.fromOffset(55, 28)
    acceptBtn.Position = UDim2.fromOffset(140, 175)
    acceptBtn.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    acceptBtn.BackgroundTransparency = 0.3
    acceptBtn.BorderSizePixel = 0
    acceptBtn.ZIndex = 1001
    acceptBtn.Parent = dialog
    
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 4)
    acceptCorner.Parent = acceptBtn
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Text = "Cancel"
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 11
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Size = UDim2.fromOffset(55, 28)
    cancelBtn.Position = UDim2.fromOffset(200, 175)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    cancelBtn.BackgroundTransparency = 0.3
    cancelBtn.BorderSizePixel = 0
    cancelBtn.ZIndex = 1001
    cancelBtn.Parent = dialog
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 4)
    cancelCorner.Parent = cancelBtn
    
    local function UpdateDisplay()
        local color = Color3.fromHSV(h, s, v)
        satVibMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        hueDrag.Position = UDim2.new(0, 0, h, -6)
        cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        colorPreview.BackgroundColor3 = color
        hexInput.Text = "#" .. color:ToHex()
    end
    
    local function ShowDialog()
        blurOverlay.Visible = true
        Tween(blurOverlay, {BackgroundTransparency = 0.5}, 0.2)
        dialog.Visible = true
        h, s, v = colorpicker.hue, colorpicker.sat, colorpicker.vib
        UpdateDisplay()
    end
    
    local function HideDialog()
        Tween(blurOverlay, {BackgroundTransparency = 1}, 0.2)
        task.delay(0.2, function()
            blurOverlay.Visible = false
        end)
        dialog.Visible = false
    end
    
    local draggingSat = false
    local guiInset = game:GetService("GuiService"):GetGuiInset()
    
    satVibMap.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSat = true
            local minX = satVibMap.AbsolutePosition.X
            local maxX = minX + satVibMap.AbsoluteSize.X
            local mousePos = UserInputService:GetMouseLocation() - guiInset
            local mouseX = math.clamp(mousePos.X, minX, maxX)
            local minY = satVibMap.AbsolutePosition.Y
            local maxY = minY + satVibMap.AbsoluteSize.Y
            local mouseY = math.clamp(mousePos.Y, minY, maxY)
            s = (mouseX - minX) / (maxX - minX)
            v = 1 - ((mouseY - minY) / (maxY - minY))
            UpdateDisplay()
        end
    end)
    
    satVibMap.MouseMoved:Connect(function()
        if not draggingSat then return end
        local minX = satVibMap.AbsolutePosition.X
        local maxX = minX + satVibMap.AbsoluteSize.X
        local mousePos = UserInputService:GetMouseLocation() - guiInset
        local mouseX = math.clamp(mousePos.X, minX, maxX)
        local minY = satVibMap.AbsolutePosition.Y
        local maxY = minY + satVibMap.AbsoluteSize.Y
        local mouseY = math.clamp(mousePos.Y, minY, maxY)
        s = (mouseX - minX) / (maxX - minX)
        v = 1 - ((mouseY - minY) / (maxY - minY))
        UpdateDisplay()
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSat = false
        end
    end)
    
    local draggingHue = false
    local function updateHue()
        local minY = hueSlider.AbsolutePosition.Y
        local maxY = minY + hueSlider.AbsoluteSize.Y
        local mousePos = UserInputService:GetMouseLocation() - guiInset
        local mouseY = math.clamp(mousePos.Y, minY, maxY)
        h = (mouseY - minY) / (maxY - minY)
        UpdateDisplay()
    end
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = true
            updateHue()
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingHue and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateHue()
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingHue = false
        end
    end)
    
    hexInput.FocusLost:Connect(function(enter)
        if enter then
            local success, result = pcall(Color3.fromHex, hexInput.Text)
            if success and typeof(result) == "Color3" then
                h, s, v = result:ToHSV()
                UpdateDisplay()
            end
        end
    end)
    
    acceptBtn.MouseButton1Click:Connect(function()
        local color = Color3.fromHSV(h, s, v)
        colorpicker.color = color
        colorpicker.hue = h
        colorpicker.sat = s
        colorpicker.vib = v
        colorDisplay.BackgroundColor3 = color
        self.config:SetFlag(colorpicker.flag, color)
        task.spawn(function() colorpicker.callback(color) end)
        HideDialog()
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        HideDialog()
    end)
    
    colorDisplay.MouseButton1Click:Connect(function()
        ShowDialog()
    end)
    
    blurOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            HideDialog()
        end
    end)
    
    function colorpicker:SetColor(color)
        colorpicker.color = color
        colorDisplay.BackgroundColor3 = color
        h, s, v = color:ToHSV()
        colorpicker.hue = h
        colorpicker.sat = s
        colorpicker.vib = v
        colorPreview.BackgroundColor3 = color
        self.config:SetFlag(colorpicker.flag, color)
        task.spawn(function() colorpicker.callback(color) end)
    end
    
    UpdateDisplay()
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
    
    local function UpdateKeySize(text)
        local length = #text
        local width = math.max(33, length * 7 + 8)
        keyDisplay.Size = UDim2.new(0, width, 0, 15)
    end
    
    if keybind.key then
        UpdateKeySize(keyLabel.Text)
    end
    
    local function SetKey(keycode)
        keybind.key = keycode
        local displayText = keycode and keycode:gsub("Enum.KeyCode.", "") or "None"
        keyLabel.Text = displayText
        UpdateKeySize(displayText)
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

function Library:CreateNotificationContainer()
    if self.notificationContainer then return end
    
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 300, 0, 0)
    container.Position = UDim2.new(1, -310, 0, 10)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = self.ui
    container.AutomaticSize = Enum.AutomaticSize.Y
    -- Position like Library.lua - right side
    container.Position = UDim2.new(0.8, 0, 0, 10)
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = container
    
    self.notificationContainer = container
end

function Library:SendNotification(settings)
    self:CreateNotificationContainer()
    
    local title = settings.title or "Notification"
    local text = settings.text or ""
    local duration = settings.duration or 5
    
    -- Like Library.lua
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.Size = UDim2.new(1, 0, 0, 60)
    notification.BackgroundTransparency = 1
    notification.BorderSizePixel = 0
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.Parent = self.notificationContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notification
    
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerFrame"
    innerFrame.Size = UDim2.new(1, 0, 0, 60)
    innerFrame.Position = UDim2.new(-1, 0, 0, 0)
    innerFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    innerFrame.BackgroundTransparency = 0.1
    innerFrame.BorderSizePixel = 0
    innerFrame.AutomaticSize = Enum.AutomaticSize.Y
    innerFrame.Parent = notification
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 4)
    innerCorner.Parent = innerFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.TextWrapped = true
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.Parent = innerFrame
    
    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Name = "Body"
    bodyLabel.Text = text
    bodyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    bodyLabel.Font = Enum.Font.Gotham
    bodyLabel.TextSize = 12
    bodyLabel.Size = UDim2.new(1, -10, 0, 30)
    bodyLabel.Position = UDim2.new(0, 5, 0, 25)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.TextWrapped = true
    bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
    bodyLabel.Parent = innerFrame
    
    -- Adjust size like Library.lua
    task.spawn(function()
        task.wait(0.1)
        local totalHeight = titleLabel.TextBounds.Y + bodyLabel.TextBounds.Y + 10
        innerFrame.Size = UDim2.new(1, 0, 0, totalHeight)
    end)
    
    -- Slide in from left, slide out to right
    task.spawn(function()
        local tweenIn = TweenService:Create(innerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        })
        tweenIn:Play()
        
        task.wait(duration)
        
        local tweenOut = TweenService:Create(innerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 310, 0, 0)
        })
        tweenOut:Play()
        
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end)
    
    return notification
end

function Library:SendNotificationWithButton(settings)
    self:CreateNotificationContainer()
    
    local title = settings.title or "Notification"
    local text = settings.text or ""
    local duration = settings.duration or 10
    local buttonText = settings.buttonText or "Action"
    local buttonCallback = settings.buttonCallback or function() end
    
    local notification = Instance.new("Frame")
    notification.Name = "NotificationWithButton"
    notification.Size = UDim2.new(1, 0, 0, 70)
    notification.BackgroundTransparency = 1
    notification.BorderSizePixel = 0
    notification.AutomaticSize = Enum.AutomaticSize.Y
    notification.Parent = self.notificationContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = notification
    
    local innerFrame = Instance.new("Frame")
    innerFrame.Name = "InnerFrame"
    innerFrame.Size = UDim2.new(1, 0, 0, 70)
    innerFrame.Position = UDim2.new(-1, 0, 0, 0)
    innerFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    innerFrame.BackgroundTransparency = 0.1
    innerFrame.BorderSizePixel = 0
    innerFrame.AutomaticSize = Enum.AutomaticSize.Y
    innerFrame.Parent = notification
    
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 4)
    innerCorner.Parent = innerFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(210, 210, 210)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.TextWrapped = true
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.Parent = innerFrame
    
    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Name = "Body"
    bodyLabel.Text = text
    bodyLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    bodyLabel.Font = Enum.Font.Gotham
    bodyLabel.TextSize = 12
    bodyLabel.Size = UDim2.new(1, -80, 0, 30)
    bodyLabel.Position = UDim2.new(0, 5, 0, 25)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.TextWrapped = true
    bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
    bodyLabel.Parent = innerFrame
    
    local actionButton = Instance.new("TextButton")
    actionButton.Name = "ActionButton"
    actionButton.Text = buttonText
    actionButton.Font = Enum.Font.GothamBold
    actionButton.TextSize = 11
    actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionButton.Size = UDim2.new(0, 65, 0, 25)
    actionButton.Position = UDim2.new(1, -70, 0, 30)
    actionButton.BackgroundColor3 = Color3.fromRGB(152, 181, 255)
    actionButton.BackgroundTransparency = 0.2
    actionButton.BorderSizePixel = 0
    actionButton.AutoButtonColor = false
    actionButton.Parent = innerFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = actionButton
    
    task.spawn(function()
        task.wait(0.1)
        local totalHeight = titleLabel.TextBounds.Y + math.max(bodyLabel.TextBounds.Y, 25) + 15
        innerFrame.Size = UDim2.new(1, 0, 0, math.max(70, totalHeight))
    end)
    
    local closed = false
    
    local function closeNotification()
        if closed then return end
        closed = true
        local tweenOut = TweenService:Create(innerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 310, 0, 0)
        })
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            notification:Destroy()
        end)
    end
    
    actionButton.MouseButton1Click:Connect(function()
        task.spawn(buttonCallback)
        closeNotification()
    end)
    
    task.spawn(function()
        local tweenIn = TweenService:Create(innerFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, 0, 0, 0)
        })
        tweenIn:Play()
        
        task.wait(duration)
        closeNotification()
    end)
    
    return notification
end

function Library:CreateWatermark()
    if self.watermark then return end
    
    local Stats = game:GetService("Stats")
    
    -- Create separate ScreenGui for watermark so it stays visible when main UI is hidden
    local watermarkGui = Instance.new("ScreenGui")
    watermarkGui.Name = "MarchUI_Watermark"
    watermarkGui.ResetOnSpawn = false
    watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    watermarkGui.Parent = CoreGui
    
    self.watermarkGui = watermarkGui
    
    local watermark = Instance.new("Frame")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 220, 0, 30)
    watermark.Position = UDim2.new(0.5, 0, 0.4, 0)
    watermark.AnchorPoint = Vector2.new(0.5, 0.5)
    watermark.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    watermark.BackgroundTransparency = 0.2
    watermark.BorderSizePixel = 0
    watermark.Visible = false
    watermark.Active = true
    watermark.Parent = watermarkGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = watermark
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(52, 66, 89)
    stroke.Transparency = 0.5
    stroke.Parent = watermark
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Text = "FPS: 60 | Ping: 50ms | Click to open"
    infoLabel.Font = Enum.Font.GothamBold
    infoLabel.TextSize = 11
    infoLabel.TextColor3 = Color3.fromRGB(152, 181, 255)
    infoLabel.Size = UDim2.new(1, -10, 1, 0)
    infoLabel.Position = UDim2.new(0, 5, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = watermark
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = watermark.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            watermark.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local clickButton = Instance.new("TextButton")
    clickButton.Name = "ClickArea"
    clickButton.Size = UDim2.new(1, 0, 1, 0)
    clickButton.BackgroundTransparency = 1
    clickButton.Text = ""
    clickButton.Parent = watermark
    
    clickButton.MouseButton1Click:Connect(function()
        if not dragging then
            self:ToggleUI()
        end
    end)
    
    local fps = 60
    local frameCount = 0
    local lastTime = tick()
    
    local updateConnection = RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        if currentTime - lastTime >= 1 then
            fps = math.floor(frameCount / (currentTime - lastTime))
            frameCount = 0
            lastTime = currentTime
        end
        
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        local time = os.date("%H:%M")
        local player = Players.LocalPlayer.Name
        
        infoLabel.Text = string.format("FPS: %d | Ping: %dms | %s", fps, ping, time)
    end)
    
    table.insert(self.connections, updateConnection)
    
    self.watermark = watermark
    self.watermarkVisible = false
end

function Library:ToggleUI()
    self.uiVisible = not self.uiVisible
    if self.uiVisible then
        self.ui.Enabled = true
        Tween(self.container, {Size = UDim2.new(0, 698, 0, 479)}, 0.3)
        if self.watermark then
            self.watermark.Visible = false
            self.watermarkVisible = false
        end
    else
        Tween(self.container, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        self.ui.Enabled = false
        if self.watermark then
            self.watermark.Visible = true
            self.watermarkVisible = true
        end
    end
end

function Library:Unload()
    self.config:Save()
    
    for _, connection in ipairs(self.connections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    self.connections = {}
    
    if self.uiKeybindConnection then
        self.uiKeybindConnection:Disconnect()
        self.uiKeybindConnection = nil
    end
    
    if self.watermarkGui then
        self.watermarkGui:Destroy()
        self.watermarkGui = nil
    end
    
    if self.ui then
        self.ui:Destroy()
        self.ui = nil
    end
    
    print("MarchUI Unloaded")
end

return Library
