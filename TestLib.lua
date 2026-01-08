local UserInputService = game:GetService('UserInputService')
local TweenService = game:GetService('TweenService')
local RunService = game:GetService('RunService')
local Players = game:GetService('Players')
local CoreGui = game:GetService('CoreGui')
local HttpService = game:GetService('HttpService')
local TextService = game:GetService('TextService')
local Toggles = {}
local Options = {}
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
local function GetTextWidth(text, textSize, font)
    local size = TextService:GetTextSize(text, textSize, font, Vector2.new(math.huge, 100))
    return size.X
end
local SaveManager = {}
do
    SaveManager.Folder = 'MarchUI'
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = 'Toggle', idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                if Toggles[idx] then
                    Toggles[idx]:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(tonumber(data.value))
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency or 0 }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = 'KeyPicker', idx = idx, mode = object.Mode or 'Toggle', key = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] then
                    Options[idx]:SetValue(data.key)
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = 'Input', idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] and type(data.text) == 'string' then
                    Options[idx]:SetValue(data.text)
                end
            end,
        },
    }
    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do
            self.Ignore[key] = true
        end
    end
    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end
    function SaveManager:BuildFolderTree()
        local paths = {
            self.Folder,
            self.Folder .. '/themes',
            self.Folder .. '/settings'
        }
        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end
    function SaveManager:Save(name)
        if not name then
            return false, 'no config file is selected'
        end
        local fullPath = self.Folder .. '/settings/' .. name .. '.json'
        local data = { objects = {} }
        for idx, toggle in next, Toggles do
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser.Toggle.Save(idx, toggle))
        end
        for idx, option in next, Options do
            if not self.Parser[option.Type] then continue end
            if self.Ignore[idx] then continue end
            table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
        end
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then
            return false, 'failed to encode data'
        end
        writefile(fullPath, encoded)
        return true
    end
    function SaveManager:Load(name)
        if not name then
            return false, 'no config file is selected'
        end
        local file = self.Folder .. '/settings/' .. name .. '.json'
        if not isfile(file) then return false, 'invalid file' end
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then return false, 'decode error' end
        for _, option in next, decoded.objects do
            if self.Parser[option.type] then
                task.spawn(function()
                    self.Parser[option.type].Load(option.idx, option)
                end)
            end
        end
        return true
    end
    function SaveManager:Delete(name)
        if not name then return false end
        local file = self.Folder .. '/settings/' .. name .. '.json'
        if isfile(file) then
            delfile(file)
            return true
        end
        return false
    end
    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor",
            "ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName',
        })
    end
    function SaveManager:RefreshConfigList()
        local list = listfiles(self.Folder .. '/settings')
        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == '.json' then
                local pos = file:find('.json', 1, true)
                local start = pos
                local char = file:sub(pos, pos)
                while char ~= '/' and char ~= '\\' and char ~= '' do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end
                if char == '/' or char == '\\' then
                    table.insert(out, file:sub(pos + 1, start - 1))
                end
            end
        end
        return out
    end
    function SaveManager:SetLibrary(library)
        self.Library = library
    end
    function SaveManager:LoadAutoloadConfig()
        if isfile(self.Folder .. '/settings/autoload.txt') then
            local name = readfile(self.Folder .. '/settings/autoload.txt')
            local success, err = self:Load(name)
            if not success then
                if self.Library then
                    self.Library:SendNotification({
                        title = 'Config',
                        text = 'Failed to load autoload config: ' .. tostring(err),
                        duration = 3
                    })
                end
                return
            end
            if self.Library then
                self.Library:SendNotification({
                    title = 'Config',
                    text = string.format('Auto loaded config %q', name),
                    duration = 3
                })
            end
        end
    end
    function SaveManager:GetAutoloadConfig()
        if isfile(self.Folder .. '/settings/autoload.txt') then
            return readfile(self.Folder .. '/settings/autoload.txt')
        end
        return nil
    end
    function SaveManager:SetAutoloadConfig(name)
        writefile(self.Folder .. '/settings/autoload.txt', name)
    end
    function SaveManager:DeleteAutoloadConfig()
        local path = self.Folder .. '/settings/autoload.txt'
        if isfile(path) then
            delfile(path)
        end
    end
    SaveManager:BuildFolderTree()
end
local ThemeManager = {}
do
    ThemeManager.Folder = 'MarchUI'
    ThemeManager.Library = nil
    ThemeManager.BuiltInThemes = {
        Ocean = {
            Primary = Color3.fromRGB(64, 156, 255),
            Background = Color3.fromRGB(10, 15, 25),
            Secondary = Color3.fromRGB(15, 25, 40),
            Accent = Color3.fromRGB(30, 50, 80),
            Text = Color3.fromRGB(200, 220, 255)
        },
        Sunset = {
            Primary = Color3.fromRGB(255, 107, 107),
            Background = Color3.fromRGB(25, 15, 20),
            Secondary = Color3.fromRGB(40, 25, 30),
            Accent = Color3.fromRGB(80, 40, 50),
            Text = Color3.fromRGB(255, 200, 200)
        },
        Forest = {
            Primary = Color3.fromRGB(76, 175, 80),
            Background = Color3.fromRGB(15, 20, 15),
            Secondary = Color3.fromRGB(25, 35, 25),
            Accent = Color3.fromRGB(40, 60, 40),
            Text = Color3.fromRGB(200, 255, 200)
        },
        Midnight = {
            Primary = Color3.fromRGB(138, 43, 226),
            Background = Color3.fromRGB(10, 10, 15),
            Secondary = Color3.fromRGB(20, 15, 30),
            Accent = Color3.fromRGB(40, 30, 60),
            Text = Color3.fromRGB(220, 200, 255)
        },
        Volcano = {
            Primary = Color3.fromRGB(255, 87, 34),
            Background = Color3.fromRGB(20, 10, 10),
            Secondary = Color3.fromRGB(35, 20, 15),
            Accent = Color3.fromRGB(70, 35, 25),
            Text = Color3.fromRGB(255, 220, 200)
        },
        Arctic = {
            Primary = Color3.fromRGB(100, 200, 255),
            Background = Color3.fromRGB(15, 18, 22),
            Secondary = Color3.fromRGB(25, 30, 38),
            Accent = Color3.fromRGB(45, 55, 70),
            Text = Color3.fromRGB(220, 240, 255)
        },
        Space = {
            Primary = Color3.fromRGB(147, 51, 234),
            Background = Color3.fromRGB(8, 8, 15),
            Secondary = Color3.fromRGB(15, 15, 25),
            Accent = Color3.fromRGB(30, 25, 50),
            Text = Color3.fromRGB(200, 180, 255)
        },
        Cherry = {
            Primary = Color3.fromRGB(255, 105, 180),
            Background = Color3.fromRGB(20, 12, 15),
            Secondary = Color3.fromRGB(35, 22, 28),
            Accent = Color3.fromRGB(70, 40, 55),
            Text = Color3.fromRGB(255, 200, 230)
        },
        Emerald = {
            Primary = Color3.fromRGB(80, 200, 120),
            Background = Color3.fromRGB(10, 18, 15),
            Secondary = Color3.fromRGB(18, 30, 25),
            Accent = Color3.fromRGB(35, 55, 45),
            Text = Color3.fromRGB(200, 255, 220)
        },
        Gold = {
            Primary = Color3.fromRGB(255, 193, 7),
            Background = Color3.fromRGB(18, 15, 10),
            Secondary = Color3.fromRGB(30, 28, 20),
            Accent = Color3.fromRGB(60, 50, 35),
            Text = Color3.fromRGB(255, 240, 200)
        }
    }
    function ThemeManager:SetLibrary(library)
        self.Library = library
    end
    function ThemeManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end
    function ThemeManager:BuildFolderTree()
        local paths = {
            self.Folder,
            self.Folder .. '/themes',
            self.Folder .. '/settings'
        }
        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then
                makefolder(str)
            end
        end
    end
    function ThemeManager:ApplyTheme(theme)
        if self.Library then
            self.Library:UpdateColorsUsingRegistry()
        end
    end
    function ThemeManager:ThemeUpdate()
        if self.Library then
            self.Library:UpdateColorsUsingRegistry()
        end
    end
    function ThemeManager:LoadDefault()
        local path = self.Folder .. '/themes/default.txt'
        if isfile(path) then
            local themeName = readfile(path)
            if self.BuiltInThemes[themeName] then
                return themeName
            end
            local customPath = self.Folder .. '/themes/' .. themeName .. '.json'
            if isfile(customPath) then
                return themeName
            end
        end
        return nil
    end
    function ThemeManager:SaveDefault(themeName)
        writefile(self.Folder .. '/themes/default.txt', themeName)
    end
    function ThemeManager:DeleteDefault()
        local path = self.Folder .. '/themes/default.txt'
        if isfile(path) then
            delfile(path)
        end
    end
    function ThemeManager:GetCustomTheme(name)
        local path = self.Folder .. '/themes/' .. name .. '.json'
        if not isfile(path) then return nil end
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
        if not success then return nil end
        local theme = {}
        for key, value in pairs(decoded) do
            if type(value) == 'string' then
                theme[key] = Color3.fromHex(value)
            end
        end
        return theme
    end
    function ThemeManager:SaveCustomTheme(name, themeData)
        local data = {}
        for key, color in pairs(themeData) do
            data[key] = color:ToHex()
        end
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then return false end
        writefile(self.Folder .. '/themes/' .. name .. '.json', encoded)
        return true
    end
    function ThemeManager:DeleteCustomTheme(name)
        local path = self.Folder .. '/themes/' .. name .. '.json'
        if isfile(path) then
            delfile(path)
            return true
        end
        return false
    end
    function ThemeManager:RefreshCustomThemeList()
        local list = listfiles(self.Folder .. '/themes')
        local out = {}
        for i = 1, #list do
            local file = list[i]
            if file:sub(-5) == '.json' then
                local pos = file:find('.json', 1, true)
                local start = pos
                local char = file:sub(pos, pos)
                while char ~= '/' and char ~= '\\' and char ~= '' do
                    pos = pos - 1
                    char = file:sub(pos, pos)
                end
                if char == '/' or char == '\\' then
                    table.insert(out, file:sub(pos + 1, start - 1))
                end
            end
        end
        return out
    end
    ThemeManager:BuildFolderTree()
end

local Library = {}
Library.__index = Library
Library.Registry = {}
Library.RegistryMap = {}
Library.Fonts = {
    "Gotham", "GothamBold", "GothamBlack", "SourceSans", "SourceSansBold",
    "SourceSansLight", "SourceSansItalic", "Arial", "ArialBold", "RobotoMono",
    "Roboto", "RobotoCondensed", "Ubuntu", "Oswald", "Michroma", "Bangers",
    "Creepster", "DenkOne", "Fondamento", "FredokaOne", "Jura", "Merriweather",
    "Nunito", "PatrickHand", "PermanentMarker", "Sarpanch", "SciFi",
    "SpecialElite", "TitilliumWeb"
}
function Library:AddToRegistry(instance, properties)
    if not instance then return end
    local data = { Instance = instance, Properties = properties }
    self.Registry[#self.Registry + 1] = data
    self.RegistryMap[instance] = data
end
function Library:RemoveFromRegistry(instance)
    local data = self.RegistryMap[instance]
    if data then
        for i = #self.Registry, 1, -1 do
            if self.Registry[i] == data then
                table.remove(self.Registry, i)
            end
        end
        self.RegistryMap[instance] = nil
    end
end
function Library:UpdateColorsUsingRegistry()
    local theme = self.currentTheme
    if not theme then return end
    for _, data in next, self.Registry do
        local instance = data.Instance
        local properties = data.Properties
        if instance and instance.Parent then
            for property, colorKey in pairs(properties) do
                if theme[colorKey] then
                    instance[property] = theme[colorKey]
                end
            end
        end
    end
end
function Library.new()
    local self = setmetatable({}, Library)
    self.tabs = {}
    self.currentTab = nil
    self.choosingKeybind = false
    self.connections = {}
    self.Registry = {}
    self.RegistryMap = {}
    SaveManager:SetLibrary(self)
    ThemeManager:SetLibrary(self)
    local defaultThemeName = ThemeManager:LoadDefault()
    if defaultThemeName then
        local customTheme = ThemeManager:GetCustomTheme(defaultThemeName)
        if customTheme then
            self.currentTheme = customTheme
            self.currentThemeName = defaultThemeName
        elseif ThemeManager.BuiltInThemes[defaultThemeName] then
            self.currentTheme = ThemeManager.BuiltInThemes[defaultThemeName]
            self.currentThemeName = defaultThemeName
        else
            self.currentTheme = ThemeManager.BuiltInThemes.Ocean
            self.currentThemeName = "Ocean"
        end
    else
        self.currentTheme = ThemeManager.BuiltInThemes.Ocean
        self.currentThemeName = "Ocean"
    end
    self.currentFont = Enum.Font.GothamBold
    self.uiVisible = true
    self.uiKeybind = nil
    self:CreateUI()
    self:SetupUIKeybind()
    return self
end
function Library:SetupUIKeybind()
    local savedKeybind = Options["_UI_Toggle"] and Options["_UI_Toggle"].Value
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
    local theme = ThemeManager.BuiltInThemes[themeName]
    if not theme then
        theme = ThemeManager:GetCustomTheme(themeName)
    end
    if not theme then return end
    self.currentTheme = theme
    self.currentThemeName = themeName
    self:UpdateColorsUsingRegistry()
end
function Library:SetFont(fontName)
    local font = Enum.Font[fontName]
    if not font then return end
    self.currentFont = font
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
    if self.notificationGui then
        for _, descendant in ipairs(self.notificationGui:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                descendant.Font = font
            end
        end
    end
    if self.watermark then
        for _, descendant in ipairs(self.watermark:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                descendant.Font = font
            end
        end
    end
end

function Library:CreateUI()
    local oldUI = CoreGui:FindFirstChild("MarchUI")
    if oldUI then oldUI:Destroy() end
    local theme = self.currentTheme
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MarchUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = CoreGui
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0, 698, 0, 479)
    container.Position = UDim2.new(0.5, 0, 0.5, 0)
    container.AnchorPoint = Vector2.new(0.5, 0.5)
    container.BackgroundColor3 = theme.Background
    container.BackgroundTransparency = 0.05
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Active = true
    container.Parent = screenGui
    self:AddToRegistry(container, { BackgroundColor3 = 'Background' })
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container
    local containerStroke = Instance.new("UIStroke")
    containerStroke.Color = theme.Accent
    containerStroke.Transparency = 0.5
    containerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    containerStroke.Parent = container
    self:AddToRegistry(containerStroke, { Color = 'Accent' })
    local handler = Instance.new("Frame")
    handler.Name = "Handler"
    handler.Size = UDim2.new(1, 0, 1, 0)
    handler.BackgroundTransparency = 1
    handler.Parent = container
    local logo = Instance.new("TextLabel")
    logo.Name = "Logo"
    logo.Text = "Metan"
    logo.Font = self.currentFont
    logo.TextSize = 18
    logo.TextColor3 = theme.Primary
    logo.TextTransparency = 0.2
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Size = UDim2.new(0, 100, 0, 16)
    logo.Position = UDim2.new(0.056, 0, 0.055, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Parent = handler
    self:AddToRegistry(logo, { TextColor3 = 'Primary' })
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
    logoIconButton.ImageColor3 = theme.Primary
    logoIconButton.ScaleType = Enum.ScaleType.Fit
    logoIconButton.AutoButtonColor = false
    logoIconButton.Parent = handler
    self:AddToRegistry(logoIconButton, { ImageColor3 = 'Primary' })
    logoIconButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    local pin = Instance.new("Frame")
    pin.Name = "Pin"
    pin.Size = UDim2.new(0, 2, 0, 16)
    pin.Position = UDim2.new(0.026, 0, 0.136, 0)
    pin.BackgroundColor3 = theme.Primary
    pin.BorderSizePixel = 0
    pin.Parent = handler
    self:AddToRegistry(pin, { BackgroundColor3 = 'Primary' })
    local pinCorner = Instance.new("UICorner")
    pinCorner.CornerRadius = UDim.new(1, 0)
    pinCorner.Parent = pin
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(0, 1, 0, 479)
    divider.Position = UDim2.new(0.235, 0, 0, 0)
    divider.BackgroundColor3 = theme.Accent
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = handler
    self:AddToRegistry(divider, { BackgroundColor3 = 'Accent' })
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
    tabsLayout.PFrame
    local sectionsFolder = Instance.new("Folder")
    sectionsFolder.Name = "Sections"
    sectionsFolder.Parent = handler
    self.ui = screenGui
    self.container = container
    self.handler = handler
    self.tabsFrame = tabsFrame
    self.sectionsFolder = sectionsFolder
  pin = pin
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
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Tween(container, {Position = newPos}, 0.2)
        end
    end)
end
function Library:Load()
    self:CreateWatermark()
    SaveManager:LoadAutoloadConfig()
end

function Library:CreateTab(name, icon)
    local tab = {}
    tab.name = name
    tab.icon = icon
    tab.modules = {}
    local theme = self.currentTheme
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "Tab"
    tabButton.Size = UDim2.new(0, 129, 0, 38)
    tabButton.BackgroundColor3 = theme.Secondary
    tabButton.BackgroundTransparency = 1
    tabButton.BorderSizePixel = 0
    tabButton.Text = ""
    tabButton.AutoButtonColor = false
    tabButton.LayoutOrder = #self.tabs
    tabButton.Parent = self.tabsFrame
    self:AddToRegistry(tabButton, { BackgroundColor3 = 'Secondary' })
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
    local theme = self.currentTheme
    for i, t in ipairs(self.tabs) do
        local button = t.button
        local icon = button.Icon
        local label = button.Label
        if t == tab then
            Tween(button, {BackgroundTransparency = 0.5}, 0.5)
            Tween(icon, {ImageTransparency = 0.2, ImageColor3 = theme.Primary}, 0.5)
            Tween(label, {TextTransparency = 0.2, TextColor3 = theme.Primary}, 0.5)
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
    local configNameInput
    local configListDropdown
    local autoloadLabel
    local function UpdateConfigList()
        local configs = SaveManager:RefreshConfigList()
        if #configs == 0 then configs = {"No configs"} end
        if configListDropdown then
            configListDropdown:SetValues(configs)
        end
    end
    local function UpdateAutoloadLabel()
        local autoload = SaveManager:GetAutoloadConfig()
        if autoloadLabel then
            autoloadLabel:SetText(autoload and ("Autoload: " .. autoload) or "Autoload: None")
        end
    end
    configListDropdown = configModule:CreateDropdown({
        title = "Select Config",
        flag = "SaveManager_ConfigList",
        options = #SaveManager:RefreshConfigList() > 0 and SaveManager:RefreshConfigList() or {"No configs"},
        callback = function(value)
            if value and value ~= "No configs" then
                local success, err = SaveManager:Load(value)
                if success then
                    self:SendNotification({ title = 'Config', text = 'Loaded config: ' .. value, duration = 3 })
                else
                    self:SendNotification({ title = 'Config', text = 'Failed to load: ' .. tostring(err), duration = 3 })
                end
            end
        end
    })
    autoloadLabel = configModule:CreateTextbox({
        title = "Autoload Status",
        flag = "SaveManager_AutoloadStatus",
        default = SaveManager:GetAutoloadConfig() and ("Autoload: " .. SaveManager:GetAutoloadConfig()) or "Autoload: None",
        placeholder = "No autoload set"
    })
    autoloadLabel.textboxFrame.TextEditable = false
    configNameInput = configModule:CreateTextbox({
        title = "Config Name",
        flag = "SaveManager_ConfigName",
        placeholder = "Enter config name..."
    })
    configModule:CreateButton({
        title = "Create Config",
        callback = function()
            local name = Options["SaveManager_ConfigName"] and Options["SaveManager_ConfigName"].Value
            if name and name ~= "" then
                local success, err = SaveManager:Save(name)
                if success then
                    self:SendNotification({ title = 'Config', text = 'Created config: ' .. name, duration = 3 })
                    UpdateConfigList()
                else
                    self:SendNotification({ title = 'Config', text = 'Failed: ' .. tostring(err), duration = 3 })
                end
            else
                self:SendNotification({ title = 'Config', text = 'Please enter a config name', duration = 3 })
            end
        end
    })
    configModule:CreateButton({
        title = "Delete Config",
        callback = function()
            local name = Options["SaveManager_ConfigList"] and Options["SaveManager_ConfigList"].Value
            if name and name ~= "" and name ~= "No configs" then
                if SaveManager:Delete(name) then
                    self:SendNotification({ title = 'Config', text = 'Deleted config: ' .. name, duration = 3 })
                    UpdateConfigList()
                    UpdateAutoloadLabel()
                else
                    self:SendNotification({ title = 'Config', text = 'Failed to delete config', duration = 3 })
                end
            end
        end
    })
    configModule:CreateButton({
        title = "Set as Autoload",
        callback = function()
            local name = Options["SaveManager_ConfigList"] and Options["SaveManager_ConfigList"].Value
            if name and name ~= "" and name ~= "No configs" then
                SaveManager:SetAutoloadConfig(name)
                self:SendNotification({ title = 'Config', text = 'Set autoload: ' .. name, duration = 3 })
                UpdateAutoloadLabel()
            end
        end
    })
    configModule:CreateButton({
        title = "Delete Autoload",
        callback = function()
            SaveManager:DeleteAutoloadConfig()
            self:SendNotification({ title = 'Config', text = 'Removed autoload', duration = 3 })
            UpdateAutoloadLabel()
        end
    })
    configModule:CreateButton({
        title = "Refresh List",
        callback = function()
            UpdateConfigList()
            self:SendNotification({ title = 'Config', text = 'Refreshed config list', duration = 2 })
        end
    })
    local uiModule = settingsTab:CreateModule({
        title = "UI Settings",
        description = "Customize your UI",
        section = "right"
    })
    uiModule:CreateKeybind({
        title = "Toggle UI",
        flag = "_UI_Toggle",
        callback = function(key)
            self:SetUIKeybind(key)
        end
    })
    uiModule:CreateDropdown({
        title = "Font",
        flag = "_UI_Font",
        options = self.Fonts,
        callback = function(font)
            self:SetFont(font)
        end
    })
    uiModule:CreateButton({
        title = "Unload UI",
        callback = function()
            self:Unload()
        end
    })
    local themeModule = settingsTab:CreateModule({
        title = "Themes",
        description = "Manage themes",
        section = "left"
    })
    local themeListDropdown
    local customThemeListDropdown
    local customThemeNameInput
    local autoloadThemeLabel
    local tempTheme = {
        Primary = self.currentTheme.Primary,
        Background = self.currentTheme.Background,
        Secondary = self.currentTheme.Secondary,
        Accent = self.currentTheme.Accent,
        Text = self.currentTheme.Text
    }
    local function UpdateCustomThemeList()
        local themes = ThemeManager:RefreshCustomThemeList()
        if #themes == 0 then themes = {"--"} end
        if customThemeListDropdown then
            customThemeListDropdown:SetValues(themes)
        end
    end
    local function UpdateAutoloadThemeLabel()
        local autoload = ThemeManager:LoadDefault()
        if autoloadThemeLabel then
            autoloadThemeLabel:SetText(autoload or "None")
        end
    end
    themeModule:CreateColorpicker({
        title = "Background color",
        flag = "BackgroundColor",
        default = tempTheme.Background,
        callback = function(color)
            tempTheme.Background = color
        end
    })
    themeModule:CreateColorpicker({
        title = "Main color",
        flag = "MainColor",
        default = tempTheme.Primary,
        callback = function(color)
            tempTheme.Primary = color
        end
    })
    themeModule:CreateColorpicker({
        title = "Accent color",
        flag = "AccentColor",
        default = tempTheme.Accent,
        callback = function(color)
            tempTheme.Accent = color
        end
    })
    themeModule:CreateColorpicker({
        title = "Outline color",
        flag = "OutlineColor",
        default = tempTheme.Secondary,
        callback = function(color)
            tempTheme.Secondary = color
        end
    })
    themeModule:CreateColorpicker({
        title = "Font color",
        flag = "FontColor",
        default = tempTheme.Text,
        callback = function(color)
            tempTheme.Text = color
        end
    })
    local themeNames = {}
    for name, _ in pairs(ThemeManager.BuiltInThemes) do
        table.insert(themeNames, name)
    end
    table.sort(themeNames)
    themeListDropdown = themeModule:CreateDropdown({
        title = "Theme list",
        flag = "ThemeManager_ThemeList",
        options = themeNames,
        callback = function(themeName)
            if themeName then
                self:SetTheme(themeName)
            end
        end
    })
    themeModule:CreateButton({
        title = "Set as default",
        callback = function()
            if self.currentThemeName then
                ThemeManager:SaveDefault(self.currentThemeName)
                self:SendNotification({ title = 'Theme', text = 'Set default: ' .. self.currentThemeName, duration = 3 })
                UpdateAutoloadThemeLabel()
            end
        end
    })
    autoloadThemeLabel = themeModule:CreateTextbox({
        title = "Autoload theme",
        flag = "ThemeManager_AutoloadTheme",
        default = ThemeManager:LoadDefault() or "None",
        placeholder = "None"
    })
    autoloadThemeLabel.textboxFrame.TextEditable = false
    customThemeNameInput = themeModule:CreateTextbox({
        title = "Custom theme name",
        flag = "ThemeManager_CustomThemeName",
        placeholder = "Enter name..."
    })
    customThemeListDropdown = themeModule:CreateDropdown({
        title = "Custom themes",
        flag = "ThemeManager_CustomThemeList",
        options = #ThemeManager:RefreshCustomThemeList() > 0 and ThemeManager:RefreshCustomThemeList() or {"--"},
        callback = function(themeName)
            if themeName and themeName ~= "--" then
                local theme = ThemeManager:GetCustomTheme(themeName)
                if theme then
                    self.currentTheme = theme
                    self.currentThemeName = themeName
                    self:UpdateColorsUsingRegistry()
                end
            end
        end
    })
    themeModule:CreateButton({
        title = "Save theme",
        callback = function()
            local name = Options["ThemeManager_CustomThemeName"] and Options["ThemeManager_CustomThemeName"].Value
            if name and name ~= "" then
                if ThemeManager:SaveCustomTheme(name, tempTheme) then
                    self:SendNotification({ title = 'Theme', text = 'Saved theme: ' .. name, duration = 3 })
                    UpdateCustomThemeList()
                else
                    self:SendNotification({ title = 'Theme', text = 'Failed to save theme', duration = 3 })
                end
            else
                self:SendNotification({ title = 'Theme', text = 'Please enter a theme name', duration = 3 })
            end
        end
    })
    themeModule:CreateButton({
        title = "Load theme",
        callback = function()
            local name = Options["ThemeManager_CustomThemeList"] and Options["ThemeManager_CustomThemeList"].Value
            if name and name ~= "" and name ~= "--" then
                local theme = ThemeManager:GetCustomTheme(name)
                if theme then
                    self.currentTheme = theme
                    self.currentThemeName = name
                    self:UpdateColorsUsingRegistry()
                    self:SendNotification({ title = 'Theme', text = 'Loaded theme: ' .. name, duration = 3 })
                end
            end
        end
    })
    themeModule:CreateButton({
        title = "Refresh list",
        callback = function()
            UpdateCustomThemeList()
            self:SendNotification({ title = 'Theme', text = 'Refreshed theme list', duration = 2 })
        end
    })
    themeModule:CreateButton({
        title = "Delete theme",
        callback = function()
            local name = Options["ThemeManager_CustomThemeList"] and Options["ThemeManager_CustomThemeList"].Value
            if name and name ~= "" and name ~= "--" then
                if ThemeManager:DeleteCustomTheme(name) then
                    self:SendNotification({ title = 'Theme', text = 'Deleted theme: ' .. name, duration = 3 })
                    UpdateCustomThemeList()
                end
            end
        end
    })
    SaveManager:IgnoreThemeSettings()
    UpdateCustomThemeList()
    UpdateAutoloadThemeLabel()
    return settingsTab
end

function Library:CreateModule(tab, options)
    local module = {}
    module.title = options.title or "Module"
    module.description = options.description or ""
    module.flag = options.flag or module.title
    module.callback = options.callback or function() end
    module.section = options.section == "right" and tab.rightSection or tab.leftSection
    module.state = Toggles[module.flag] and Toggles[module.flag].Value or false
    module.elements = {}
    module.elementHeight = 8
    module.multiplier = 0
    local theme = self.currentTheme
    local moduleFrame = Instance.new("Frame")
    moduleFrame.Name = "Module"
    moduleFrame.Size = UDim2.new(0, 241, 0, 93)
    moduleFrame.BackgroundColor3 = theme.Secondary
    moduleFrame.BackgroundTransparency = 0.5
    moduleFrame.BorderSizePixel = 0
    moduleFrame.ClipsDescendants = true
    moduleFrame.Parent = module.section
    self:AddToRegistry(moduleFrame, { BackgroundColor3 = 'Secondary' })
    local moduleCorner = Instance.new("UICorner")
    moduleCorner.CornerRadius = UDim.new(0, 5)
    moduleCorner.Parent = moduleFrame
    local moduleStroke = Instance.new("UIStroke")
    moduleStroke.Color = theme.Accent
    moduleStroke.Transparency = 0.5
    moduleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    moduleStroke.Parent = moduleFrame
    self:AddToRegistry(moduleStroke, { Color = 'Accent' })
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
    moduleIcon.ImageColor3 = theme.Primary
    moduleIcon.ImageTransparency = 0.7
    moduleIcon.ScaleType = Enum.ScaleType.Fit
    moduleIcon.Parent = header
    self:AddToRegistry(moduleIcon, { ImageColor3 = 'Primary' })
    local moduleTitle = Instance.new("TextLabel")
    moduleTitle.Name = "Title"
    moduleTitle.Text = module.title
    moduleTitle.Font = Enum.Font.GothamBold
    moduleTitle.TextSize = 14
    moduleTitle.TextColor3 = theme.Primary
    moduleTitle.TextTransparency = 0.2
    moduleTitle.TextXAlignment = Enum.TextXAlignment.Left
    moduleTitle.Size = UDim2.new(0, 205, 0, 13)
    moduleTitle.Position = UDim2.new(0.073, 0, 0.23, 0)
    moduleTitle.AnchorPoint = Vector2.new(0, 0.5)
    moduleTitle.BackgroundTransparency = 1
    moduleTitle.Parent = header
    self:AddToRegistry(moduleTitle, { TextColor3 = 'Primary' })
    local moduleDesc = Instance.new("TextLabel")
    moduleDesc.Name = "Description"
    moduleDesc.Text = module.description
    moduleDesc.Font = Enum.Font.GothamBold
    moduleDesc.TextSize = 10
    moduleDesc.TextColor3 = theme.Primary
    moduleDesc.TextTransparency = 0.7
    moduleDesc.TextXAlignment = Enum.TextXAlignment.Left
    moduleDesc.Size = UDim2.new(0, 205, 0, 13)
    moduleDesc.Position = UDim2.new(0.073, 0, 0.42, 0)
    moduleDesc.AnchorPoint = Vector2.new(0, 0.5)
    moduleDesc.BackgroundTransparency = 1
    moduleDesc.Parent = header
    self:AddToRegistry(moduleDesc, { TextColor3 = 'Primary' })
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = "Toggle"
    toggleFrame.Size = UDim2.new(0, 25, 0, 12)
    toggleFrame.Position = UDim2.new(0.82, 0, 0.757, 0)
    toggleFrame.BackgroundColor3 = theme.Accent
    toggleFrame.BackgroundTransparency = 0.5
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
    toggleCircle.BackgroundColor3 = theme.Text
    toggleCircle.BackgroundTransparency = 0.3
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleFrame
    self:AddToRegistry(toggleCircle, { BackgroundColor3 = 'Text' })
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(0, 33, 0, 15)
    keybindFrame.Position = UDim2.new(0.15, 0, 0.735, 0)
    keybindFrame.BackgroundColor3 = theme.Primary
    keybindFrame.BackgroundTransparency = 0.7
    keybindFrame.BorderSizePixel = 0
    keybindFrame.Parent = header
    self:AddToRegistry(keybindFrame, { BackgroundColor3 = 'Primary' })
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 3)
    keybindCorner.Parent = keybindFrame
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Text = "None"
    keybindLabel.Font = Enum.Font.GothamBold
    keybindLabel.TextSize = 10
    keybindLabel.TextColor3 = Color3.fromRGB(209, 222, 255)
    keybindLabel.Size = UDim2.new(1, -4, 1, 0)
    keybindLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    keybindLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Parent = keybindFrame
    local divider1 = Instance.new("Frame")
    divider1.Name = "Divider"
    divider1.Size = UDim2.new(0, 241, 0, 1)
    divider1.Position = UDim2.new(0.5, 0, 0.62, 0)
    divider1.AnchorPoint = Vector2.new(0.5, 0)
    divider1.BackgroundColor3 = theme.Accent
    divider1.BackgroundTransparency = 0.5
    divider1.BorderSizePixel = 0
    divider1.Parent = header
    self:AddToRegistry(divider1, { BackgroundColor3 = 'Accent' })
    local divider2 = Instance.new("Frame")
    divider2.Name = "Divider"
    divider2.Size = UDim2.new(0, 241, 0, 1)
    divider2.Position = UDim2.new(0.5, 0, 1, 0)
    divider2.AnchorPoint = Vector2.new(0.5, 0)
    divider2.BackgroundColor3 = theme.Accent
    divider2.BackgroundTransparency = 0.5
    divider2.BorderSizePixel = 0
    divider2.Parent = header
    self:AddToRegistry(divider2, { BackgroundColor3 = 'Accent' })
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
    optionsLayout.Padding = UDim.new(0, 4)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    optionsLayout.Parent = optionsFrame
    module.frame = moduleFrame
    module.optionsFrame = optionsFrame
    module.toggleFrame = toggleFrame
    module.toggleCircle = toggleCircle
    local toggleData = { Type = 'Toggle', Value = module.state }
    toggleData.SetValue = function(self2, value)
        module.state = value
        toggleData.Value = value
        if value then
            Tween(toggleFrame, {BackgroundColor3 = theme.Primary, BackgroundTransparency = 0.2}, 0.5)
            Tween(toggleCircle, {BackgroundColor3 = theme.Text, BackgroundTransparency = 0, Position = UDim2.fromScale(0.53, 0.5)}, 0.5)
        else
            Tween(toggleFrame, {BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.5}, 0.5)
            Tween(toggleCircle, {BackgroundColor3 = theme.Text, BackgroundTransparency = 0.3, Position = UDim2.fromScale(0, 0.5)}, 0.5)
        end
        local newSize = value and (93 + module.elementHeight + module.multiplier) or 93
        Tween(moduleFrame, {Size = UDim2.new(0, 241, 0, newSize)}, 0.5)
        Tween(optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
        task.spawn(function() module.callback(value) end)
    end
    Toggles[module.flag] = toggleData
    local function SetState(state)
        toggleData:SetValue(state)
    end
    if module.state then
        toggleFrame.BackgroundColor3 = theme.Primary
        toggleFrame.BackgroundTransparency = 0.2
        toggleCircle.BackgroundColor3 = theme.Text
        toggleCircle.BackgroundTransparency = 0
        toggleCircle.Position = UDim2.fromScale(0.53, 0.5)
    end
    header.MouseButton1Click:Connect(function()
        SetState(not module.state)
    end)
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
                return
            end
            local keycodeStr = tostring(keyInput.KeyCode)
            local displayText = keycodeStr:gsub("Enum.KeyCode.", "")
            keybindLabel.Text = displayText
            local width = math.max(33, GetTextWidth(displayText, 10, Enum.Font.GothamBold) + 16)
            keybindFrame.Size = UDim2.new(0, width, 0, 15)
            table.insert(self.connections, UserInputService.InputBegan:Connect(function(input2, gameProcessed2)
                if gameProcessed2 then return end
                if tostring(input2.KeyCode) == keycodeStr then
                    SetState(not module.state)
                end
            end))
        end)
    end)
    module.SetState = SetState
    module.UpdateSize = function()
        if module.state then
            local newSize = 93 + module.elementHeight + module.multiplier
            moduleFrame.Size = UDim2.new(0, 241, 0, newSize)
            optionsFrame.Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)
        end
    end
    if module.state then
        task.spawn(function()
            task.wait(0.1)
            module.UpdateSize()
        end)
    end
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
    slider.round = options.round_number or options.round or false
    slider.callback = options.callback or function() end
    slider.Type = 'Slider'
    module.elementHeight = module.elementHeight + 30
    local theme = self.currentTheme
    local existingValue = Options[slider.flag] and Options[slider.flag].Value
    slider.value = existingValue or options.value or options.default or slider.min
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
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 153, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.05, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = sliderFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(slider.value)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 10
    valueLabel.TextColor3 = theme.Text
    valueLabel.TextTransparency = 0.2
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Size = UDim2.new(0, 42, 0, 13)
    valueLabel.Position = UDim2.new(1, 0, 0, 0)
    valueLabel.AnchorPoint = Vector2.new(1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Parent = sliderFrame
    self:AddToRegistry(valueLabel, { TextColor3 = 'Text' })
    local dragFrame = Instance.new("Frame")
    dragFrame.Name = "Drag"
    dragFrame.Size = UDim2.new(0, 207, 0, 4)
    dragFrame.Position = UDim2.new(0.5, 0, 0.95, 0)
    dragFrame.AnchorPoint = Vector2.new(0.5, 1)
    dragFrame.BackgroundColor3 = theme.Primary
    dragFrame.BackgroundTransparency = 0.9
    dragFrame.BorderSizePixel = 0
    dragFrame.Parent = sliderFrame
    self:AddToRegistry(dragFrame, { BackgroundColor3 = 'Primary' })
    local dragCorner = Instance.new("UICorner")
    dragCorner.CornerRadius = UDim.new(1, 0)
    dragCorner.Parent = dragFrame
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "Fill"
    fillFrame.Size = UDim2.new(0, 103, 0, 4)
    fillFrame.Position = UDim2.new(0, 0, 0.5, 0)
    fillFrame.AnchorPoint = Vector2.new(0, 0.5)
    fillFrame.BackgroundColor3 = theme.Primary
    fillFrame.BackgroundTransparency = 0.5
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = dragFrame
    self:AddToRegistry(fillFrame, { BackgroundColor3 = 'Primary' })
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
    slider.Value = slider.value
    slider.SetValue = function(self2, value)
        value = math.clamp(value, slider.min, slider.max)
        if slider.round then value = Round(value, 0) else value = Round(value, 1) end
        slider.value = value
        slider.Value = value
        valueLabel.Text = tostring(value)
        local percentage = (value - slider.min) / (slider.max - slider.min)
        local fillSize = math.clamp(percentage, 0.02, 1) * dragFrame.AbsoluteSize.X
        Tween(fillFrame, {Size = UDim2.new(0, fillSize, 0, 4)}, 0.2)
        task.spawn(function() slider.callback(value) end)
    end
    Options[slider.flag] = slider
    slider:SetValue(slider.value)
    local dragging = false
    local mouse = Players.LocalPlayer:GetMouse()
    sliderFrame.MouseButton1Down:Connect(function()
        dragging = true
        local function Update()
            local mousePos = (mouse.X - dragFrame.AbsolutePosition.X) / dragFrame.AbsoluteSize.X
            local value = slider.min + (slider.max - slider.min) * mousePos
            slider:SetValue(value)
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
    table.insert(module.elements, slider)
    return slider
end
function Library:CreateCheckbox(module, options)
    options = options or {}
    local checkbox = {}
    checkbox.title = options.title or "Checkbox"
    checkbox.flag = options.flag or checkbox.title
    checkbox.callback = options.callback or function() end
    checkbox.Type = 'Toggle'
    module.elementHeight = module.elementHeight + 22
    local theme = self.currentTheme
    local existingValue = Toggles[checkbox.flag] and Toggles[checkbox.flag].Value
    checkbox.state = existingValue ~= nil and existingValue or (options.default or false)
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
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 142, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = checkboxFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local boxFrame = Instance.new("Frame")
    boxFrame.Name = "Box"
    boxFrame.Size = UDim2.new(0, 15, 0, 15)
    boxFrame.Position = UDim2.new(1, 0, 0.5, 0)
    boxFrame.AnchorPoint = Vector2.new(1, 0.5)
    boxFrame.BackgroundColor3 = theme.Primary
    boxFrame.BackgroundTransparency = 0.9
    boxFrame.BorderSizePixel = 0
    boxFrame.Parent = checkboxFrame
    self:AddToRegistry(boxFrame, { BackgroundColor3 = 'Primary' })
    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = boxFrame
    local fillFrame = Instance.new("Frame")
    fillFrame.Name = "Fill"
    fillFrame.Size = UDim2.new(0, 0, 0, 0)
    fillFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    fillFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    fillFrame.BackgroundColor3 = theme.Primary
    fillFrame.BackgroundTransparency = 0.2
    fillFrame.BorderSizePixel = 0
    fillFrame.Parent = boxFrame
    self:AddToRegistry(fillFrame, { BackgroundColor3 = 'Primary' })
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 3)
    fillCorner.Parent = fillFrame
    checkbox.Value = checkbox.state
    checkbox.SetValue = function(self2, state)
        checkbox.state = state
        checkbox.Value = state
        if state then
            Tween(boxFrame, {BackgroundTransparency = 0.7}, 0.5)
            Tween(fillFrame, {Size = UDim2.new(0, 9, 0, 9)}, 0.5)
        else
            Tween(boxFrame, {BackgroundTransparency = 0.9}, 0.5)
            Tween(fillFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.5)
        end
        task.spawn(function() checkbox.callback(state) end)
    end
    Toggles[checkbox.flag] = checkbox
    checkbox:SetValue(checkbox.state)
    checkboxFrame.MouseButton1Click:Connect(function()
        checkbox:SetValue(not checkbox.state)
    end)
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
    dropdown.callback = options.callback or function() end
    dropdown.open = false
    dropdown.size = 0
    dropdown.Type = 'Dropdown'
    dropdown.Multi = dropdown.multi
    local theme = self.currentTheme
    local existingValue = Options[dropdown.flag] and Options[dropdown.flag].Value
    dropdown.selected = existingValue or (dropdown.multi and {} or (options.default or nil))
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
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 207, 0, 13)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = dropdownFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local box = Instance.new("Frame")
    box.Name = "Box"
    box.ClipsDescendants = true
    box.AnchorPoint = Vector2.new(0.5, 0)
    box.BackgroundTransparency = 0.9
    box.Position = UDim2.new(0.5, 0, 1.2, 0)
    box.Size = UDim2.new(0, 207, 0, 22)
    box.BorderSizePixel = 0
    box.BackgroundColor3 = theme.Primary
    box.Parent = titleLabel
    self:AddToRegistry(box, { BackgroundColor3 = 'Primary' })
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
    currentOption.TextColor3 = theme.Text
    currentOption.TextTransparency = 0.2
    currentOption.Text = "None"
    currentOption.Size = UDim2.new(0, 161, 0, 13)
    currentOption.AnchorPoint = Vector2.new(0, 0.5)
    currentOption.Position = UDim2.new(0.05, 0, 0.5, 0)
    currentOption.BackgroundTransparency = 1
    currentOption.TextXAlignment = Enum.TextXAlignment.Left
    currentOption.Parent = header
    self:AddToRegistry(currentOption, { TextColor3 = 'Text' })
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
    local optionsScrollFrame = Instance.new("ScrollingFrame")
    optionsScrollFrame.Name = "Options"
    optionsScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    optionsScrollFrame.Active = true
    optionsScrollFrame.ScrollBarImageTransparency = 1
    optionsScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.XY
    optionsScrollFrame.ScrollBarThickness = 0
    optionsScrollFrame.Size = UDim2.new(0, 207, 0, 0)
    optionsScrollFrame.BackgroundTransparency = 1
    optionsScrollFrame.Position = UDim2.new(0, 0, 1, 0)
    optionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0.5, 0)
    optionsScrollFrame.Parent = box
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsScrollFrame
    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, -1)
    optionsPadding.PaddingLeft = UDim.new(0, 10)
    optionsPadding.Parent = optionsScrollFrame
    local boxLayout = Instance.new("UIListLayout")
    boxLayout.SortOrder = Enum.SortOrder.LayoutOrder
    boxLayout.Parent = box
    dropdown.Value = dropdown.selected
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
        dropdown.Value = dropdown.selected
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
        task.spawn(function() dropdown.callback(dropdown.selected) end)
    end
    dropdown.size = 3
    dropdown.updateFunctions = {}
    local function CreateOptionButton(option, index)
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
        optionButton.Parent = optionsScrollFrame
        local optGradient = Instance.new("UIGradient")
        optGradient.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(0.7, 0),
            NumberSequenceKeypoint.new(0.87, 0.36),
            NumberSequenceKeypoint.new(1, 1)
        }
        optGradient.Parent = optionButton
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
            local t = self.currentTheme
            if isSelected then
                optionButton.TextTransparency = 0.2
                optionButton.TextColor3 = t.Primary
            else
                optionButton.TextTransparency = 0.7
                optionButton.TextColor3 = t.Text
            end
        end
        table.insert(dropdown.updateFunctions, UpdateOptionAppearance)
        UpdateOptionAppearance()
        optionButton.MouseButton1Click:Connect(function()
            Toggle(option)
            for _, updateFunc in ipairs(dropdown.updateFunctions) do
                updateFunc()
            end
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
        if index <= dropdown.maxVisible then
            dropdown.size = dropdown.size + 16
        end
    end
    for index, option in ipairs(dropdown.options) do
        CreateOptionButton(option, index)
    end
    optionsScrollFrame.Size = UDim2.fromOffset(207, dropdown.size)
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
    dropdown.SetValue = function(self2, newValue)
        if type(newValue) == "table" and not dropdown.multi then
            return
        end
        dropdown.selected = newValue
        dropdown.Value = newValue
        UpdateText()
        for _, updateFunc in ipairs(dropdown.updateFunctions) do
            updateFunc()
        end
    end
    dropdown.SetValues = function(self2, newOptions)
        for _, child in ipairs(optionsScrollFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        dropdown.updateFunctions = {}
        dropdown.options = newOptions
        dropdown.maxVisible = math.min(#newOptions, 5)
        dropdown.size = 3
        for index, option in ipairs(newOptions) do
            CreateOptionButton(option, index)
        end
        optionsScrollFrame.Size = UDim2.fromOffset(207, dropdown.size)
    end
    dropdown.box = box
    Options[dropdown.flag] = dropdown
    table.insert(module.elements, dropdown)
    return dropdown
end
function Library:CreateMultiDropdown(module, options)
    options.multi_dropdown = true
    return self:CreateDropdown(module, options)
end

function Library:CreateTextbox(module, options)
    options = options or {}
    local textbox = {}
    textbox.title = options.title or "Textbox"
    textbox.flag = options.flag or textbox.title
    textbox.placeholder = options.placeholder or "Enter text..."
    textbox.callback = options.callback or function() end
    textbox.Type = 'Input'
    module.elementHeight = module.elementHeight + 32
    local theme = self.currentTheme
    local existingValue = Options[textbox.flag] and Options[textbox.flag].Value
    textbox.text = existingValue or options.default or ""
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = textbox.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 207, 0, 13)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = module.optionsFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local textboxFrame = Instance.new("TextBox")
    textboxFrame.Name = "Textbox"
    textboxFrame.Text = textbox.text
    textboxFrame.PlaceholderText = textbox.placeholder
    textboxFrame.Font = Enum.Font.GothamBold
    textboxFrame.TextSize = 10
    textboxFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    textboxFrame.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    textboxFrame.TextXAlignment = Enum.TextXAlignment.Left
    textboxFrame.Size = UDim2.new(0, 207, 0, 18)
    textboxFrame.BackgroundColor3 = theme.Primary
    textboxFrame.BackgroundTransparency = 0.9
    textboxFrame.BorderSizePixel = 0
    textboxFrame.ClearTextOnFocus = false
    textboxFrame.Parent = module.optionsFrame
    self:AddToRegistry(textboxFrame, { BackgroundColor3 = 'Primary' })
    local textboxCorner = Instance.new("UICorner")
    textboxCorner.CornerRadius = UDim.new(0, 4)
    textboxCorner.Parent = textboxFrame
    local textboxPadding = Instance.new("UIPadding")
    textboxPadding.PaddingLeft = UDim.new(0, 8)
    textboxPadding.Parent = textboxFrame
    textbox.Value = textbox.text
    textbox.SetValue = function(self2, value)
        textbox.text = value
        textbox.Value = value
        textboxFrame.Text = value
    end
    textbox.SetText = function(self2, value)
        textbox:SetValue(value)
    end
    textboxFrame.FocusLost:Connect(function(enterPressed)
        textbox.text = textboxFrame.Text
        textbox.Value = textboxFrame.Text
        task.spawn(function() textbox.callback(textbox.text) end)
    end)
    textbox.textboxFrame = textboxFrame
    Options[textbox.flag] = textbox
    table.insert(module.elements, textbox)
    return textbox
end
function Library:CreateButton(module, options)
    options = options or {}
    local button = {}
    button.title = options.title or "Button"
    button.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 22
    local theme = self.currentTheme
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button"
    buttonFrame.Text = button.title
    buttonFrame.Font = Enum.Font.GothamBold
    buttonFrame.TextSize = 11
    buttonFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
    buttonFrame.Size = UDim2.new(0, 207, 0, 18)
    buttonFrame.BackgroundColor3 = theme.Primary
    buttonFrame.BackgroundTransparency = 0.8
    buttonFrame.BorderSizePixel = 0
    buttonFrame.AutoButtonColor = false
    buttonFrame.Parent = module.optionsFrame
    self:AddToRegistry(buttonFrame, { BackgroundColor3 = 'Primary' })
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = buttonFrame
    buttonFrame.MouseEnter:Connect(function()
        Tween(buttonFrame, {BackgroundTransparency = 0.6}, 0.2)
    end)
    buttonFrame.MouseLeave:Connect(function()
        Tween(buttonFrame, {BackgroundTransparency = 0.8}, 0.2)
    end)
    buttonFrame.MouseButton1Click:Connect(function()
        task.spawn(button.callback)
    end)
    table.insert(module.elements, button)
    return button
end

function Library:CreateColorpicker(module, options)
    options = options or {}
    local colorpicker = {}
    colorpicker.title = options.title or "Color"
    colorpicker.flag = options.flag or colorpicker.title
    colorpicker.callback = options.callback or function() end
    colorpicker.Type = 'ColorPicker'
    colorpicker.Transparency = 0
    module.elementHeight = module.elementHeight + 22
    local theme = self.currentTheme
    local existingValue = Options[colorpicker.flag] and Options[colorpicker.flag].Value
    colorpicker.color = existingValue or options.default or Color3.fromRGB(255, 255, 255)
    local h, s, v = colorpicker.color:ToHSV()
    colorpicker.hue = h
    colorpicker.sat = s
    colorpicker.vib = v
    local colorFrame = Instance.new("TextButton")
    colorFrame.Name = "ColorPicker"
    colorFrame.Size = UDim2.new(0, 207, 0, 18)
    colorFrame.BackgroundTransparency = 1
    colorFrame.BorderSizePixel = 0
    colorFrame.Text = ""
    colorFrame.AutoButtonColor = false
    colorFrame.Parent = module.optionsFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = colorpicker.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 11
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 142, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = colorFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local colorDisplay = Instance.new("TextButton")
    colorDisplay.Name = "Display"
    colorDisplay.Size = UDim2.new(0, 25, 0, 15)
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
    dialog.Size = UDim2.fromOffset(250, 185)
    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.BackgroundColor3 = theme.Secondary
    dialog.BorderSizePixel = 0
    dialog.ZIndex = 1000
    dialog.Visible = false
    dialog.Parent = self.container
    self:AddToRegistry(dialog, { BackgroundColor3 = 'Secondary' })
    local dialogCorner = Instance.new("UICorner")
    dialogCorner.CornerRadius = UDim.new(0, 8)
    dialogCorner.Parent = dialog
    local dialogStroke = Instance.new("UIStroke")
    dialogStroke.Color = theme.Accent
    dialogStroke.Transparency = 0.5
    dialogStroke.Parent = dialog
    self:AddToRegistry(dialogStroke, { Color = 'Accent' })
    local satVibMap = Instance.new("ImageLabel")
    satVibMap.Size = UDim2.fromOffset(165, 130)
    satVibMap.Position = UDim2.fromOffset(10, 10)
    satVibMap.Image = "rbxassetid://4155801252"
    satVibMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    satVibMap.BorderSizePixel = 0
    satVibMap.ZIndex = 1001
    satVibMap.Active = true
    satVibMap.Parent = dialog
    local satVibCorner = Instance.new("UICorner")
    satVibCorner.CornerRadius = UDim.new(0, 6)
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
    hueSlider.Position = UDim2.fromOffset(186, 10)
    hueSlider.BorderSizePixel = 0
    hueSlider.ZIndex = 1001
    hueSlider.Active = true
    hueSlider.Parent = dialog
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 10)
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
    hueDrag.Size = UDim2.fromOffset(20, 20)
    hueDrag.Image = "http://www.roblox.com/asset/?id=12266946128"
    hueDrag.Position = UDim2.new(0, 0, h, -10)
    hueDrag.BackgroundTransparency = 1
    hueDrag.ZIndex = 1003
    hueDrag.Parent = hueDragHolder
    local colorPreview = Instance.new("Frame")
    colorPreview.Size = UDim2.fromOffset(30, 25)
    colorPreview.Position = UDim2.fromOffset(10, 150)
    colorPreview.BackgroundColor3 = colorpicker.color
    colorPreview.BorderSizePixel = 0
    colorPreview.ZIndex = 1001
    colorPreview.Parent = dialog
    local previewCorner = Instance.new("UICorner")
    previewCorner.CornerRadius = UDim.new(0, 6)
    previewCorner.Parent = colorPreview
    local acceptBtn = Instance.new("TextButton")
    acceptBtn.Text = "Accept"
    acceptBtn.Font = Enum.Font.GothamBold
    acceptBtn.TextSize = 11
    acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    acceptBtn.Size = UDim2.fromOffset(50, 25)
    acceptBtn.Position = UDim2.fromOffset(135, 150)
    acceptBtn.BackgroundColor3 = theme.Primary
    acceptBtn.BackgroundTransparency = 0.2
    acceptBtn.BorderSizePixel = 0
    acceptBtn.ZIndex = 1001
    acceptBtn.AutoButtonColor = false
    acceptBtn.Parent = dialog
    self:AddToRegistry(acceptBtn, { BackgroundColor3 = 'Primary' })
    local acceptCorner = Instance.new("UICorner")
    acceptCorner.CornerRadius = UDim.new(0, 6)
    acceptCorner.Parent = acceptBtn
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Text = "Cancel"
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 11
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Size = UDim2.fromOffset(50, 25)
    cancelBtn.Position = UDim2.fromOffset(190, 150)
    cancelBtn.BackgroundColor3 = theme.Primary
    cancelBtn.BackgroundTransparency = 0.2
    cancelBtn.BorderSizePixel = 0
    cancelBtn.ZIndex = 1001
    cancelBtn.AutoButtonColor = false
    cancelBtn.Parent = dialog
    self:AddToRegistry(cancelBtn, { BackgroundColor3 = 'Primary' })
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 6)
    cancelCorner.Parent = cancelBtn
    colorpicker.Value = colorpicker.color
    local function UpdateDisplay()
        local color = Color3.fromHSV(h, s, v)
        satVibMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        hueDrag.Position = UDim2.new(0, 0, h, -10)
        cursor.Position = UDim2.new(s, 0, 1 - v, 0)
        colorPreview.BackgroundColor3 = color
    end
    local function ShowDialog()
        blurOverlay.Visible = true
        Tween(blurOverlay, {BackgroundTransparency = 0.1}, 0.2)
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
    local draggingHue = false
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
            draggingHue = false
        end
    end)
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
    acceptBtn.MouseEnter:Connect(function()
        Tween(acceptBtn, {BackgroundTransparency = 0}, 0.2)
    end)
    acceptBtn.MouseLeave:Connect(function()
        Tween(acceptBtn, {BackgroundTransparency = 0.2}, 0.2)
    end)
    cancelBtn.MouseEnter:Connect(function()
        Tween(cancelBtn, {BackgroundTransparency = 0}, 0.2)
    end)
    cancelBtn.MouseLeave:Connect(function()
        Tween(cancelBtn, {BackgroundTransparency = 0.2}, 0.2)
    end)
    acceptBtn.MouseButton1Click:Connect(function()
        local color = Color3.fromHSV(h, s, v)
        colorpicker.color = color
        colorpicker.Value = color
        colorpicker.hue = h
        colorpicker.sat = s
        colorpicker.vib = v
        colorDisplay.BackgroundColor3 = color
        task.spawn(function() colorpicker.callback(color) end)
        HideDialog()
    end)
    cancelBtn.MouseButton1Click:Connect(function()
        HideDialog()
    end)
    colorDisplay.MouseButton1Click:Connect(function()
        ShowDialog()
    end)
    colorpicker.SetValueRGB = function(self2, color, transparency)
        colorpicker.color = color
        colorpicker.Value = color
        colorpicker.Transparency = transparency or 0
        colorDisplay.BackgroundColor3 = color
        h, s, v = color:ToHSV()
        colorpicker.hue = h
        colorpicker.sat = s
        colorpicker.vib = v
        colorPreview.BackgroundColor3 = color
        task.spawn(function() colorpicker.callback(color) end)
    end
    UpdateDisplay()
    Options[colorpicker.flag] = colorpicker
    table.insert(module.elements, colorpicker)
    return colorpicker
end

function Library:CreateKeybind(module, options)
    options = options or {}
    local keybind = {}
    keybind.title = options.title or "Keybind"
    keybind.flag = options.flag or keybind.title
    keybind.default = options.default
    keybind.callback = options.callback or function() end
    keybind.Type = 'KeyPicker'
    module.elementHeight = module.elementHeight + 20
    local theme = self.currentTheme
    local existingValue = Options[keybind.flag] and Options[keybind.flag].Value
    keybind.key = existingValue or keybind.default
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
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 142, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
    titleLabel.AnchorPoint = Vector2.new(0, 0.5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = keybindFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
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
    keybind.Value = keybind.key
    local function UpdateKeySize(text)
        local width = math.max(33, GetTextWidth(text, 10, Enum.Font.GothamBold) + 16)
        keyDisplay.Size = UDim2.new(0, width, 0, 15)
    end
    if keybind.key then
        UpdateKeySize(keyLabel.Text)
    end
    keybind.SetValue = function(self2, keycode)
        keybind.key = keycode
        keybind.Value = keycode
        local displayText = keycode and keycode:gsub("Enum.KeyCode.", "") or "None"
        keyLabel.Text = displayText
        UpdateKeySize(displayText)
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
                keybind:SetValue(nil)
            else
                keybind:SetValue(tostring(input.KeyCode))
            end
        end)
    end)
    Options[keybind.flag] = keybind
    table.insert(module.elements, keybind)
    return keybind
end
function Library:CreateNotificationContainer()
    if self.notificationContainer then return end
    local notificationGui = Instance.new("ScreenGui")
    notificationGui.Name = "MarchUI_Notifications"
    notificationGui.ResetOnSpawn = false
    notificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notificationGui.Parent = CoreGui
    self.notificationGui = notificationGui
    local container = Instance.new("Frame")
    container.Name = "NotificationContainer"
    container.Size = UDim2.new(0, 300, 0, 0)
    container.Position = UDim2.new(0.8, 0, 0, 10)
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = notificationGui
    container.AutomaticSize = Enum.AutomaticSize.Y
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
    local theme = self.currentTheme
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
    innerFrame.Position = UDim2.new(0, 0, 0, 0)
    innerFrame.BackgroundColor3 = theme.Secondary
    innerFrame.BackgroundTransparency = 0.1
    innerFrame.BorderSizePixel = 0
    innerFrame.AutomaticSize = Enum.AutomaticSize.Y
    innerFrame.Parent = notification
    self:AddToRegistry(innerFrame, { BackgroundColor3 = 'Secondary' })
    local innerCorner = Instance.new("UICorner")
    innerCorner.CornerRadius = UDim.new(0, 4)
    innerCorner.Parent = innerFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = title
    titleLabel.TextColor3 = theme.Primary
    titleLabel.Font = self.currentFont
    titleLabel.TextSize = 14
    titleLabel.Size = UDim2.new(1, -10, 0, 20)
    titleLabel.Position = UDim2.new(0, 5, 0, 5)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.TextWrapped = true
    titleLabel.AutomaticSize = Enum.AutomaticSize.Y
    titleLabel.Parent = innerFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Primary' })
    local bodyLabel = Instance.new("TextLabel")
    bodyLabel.Name = "Body"
    bodyLabel.Text = text
    bodyLabel.TextColor3 = theme.Text
    bodyLabel.Font = self.currentFont
    bodyLabel.TextSize = 12
    bodyLabel.Size = UDim2.new(1, -10, 0, 30)
    bodyLabel.Position = UDim2.new(0, 5, 0, 25)
    bodyLabel.BackgroundTransparency = 1
    bodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    bodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    bodyLabel.TextWrapped = true
    bodyLabel.AutomaticSize = Enum.AutomaticSize.Y
    bodyLabel.Parent = innerFrame
    self:AddToRegistry(bodyLabel, { TextColor3 = 'Text' })
    task.spawn(function()
        task.wait(0.1)
        local totalHeight = titleLabel.TextBounds.Y + bodyLabel.TextBounds.Y + 10
        innerFrame.Size = UDim2.new(1, 0, 0, totalHeight)
    end)
    task.spawn(function()
        task.wait(duration)
        notification:Destroy()
    end)
    return notification
end

function Library:CreateWatermark()
    if self.watermark then return end
    local Stats = game:GetService("Stats")
    local theme = self.currentTheme
    local watermarkGui = Instance.new("ScreenGui")
    watermarkGui.Name = "MarchUI_Watermark"
    watermarkGui.ResetOnSpawn = false
    watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    watermarkGui.Parent = CoreGui
    self.watermarkGui = watermarkGui
    local watermark = Instance.new("Frame")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 250, 0, 35)
    watermark.Position = UDim2.new(0.5, 0, 0.05, 0)
    watermark.AnchorPoint = Vector2.new(0.5, 0.5)
    watermark.BackgroundColor3 = theme.Background
    watermark.BackgroundTransparency = 0
    watermark.BorderSizePixel = 0
    watermark.Visible = false
    watermark.Active = false
    watermark.Parent = watermarkGui
    self:AddToRegistry(watermark, { BackgroundColor3 = 'Background' })
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = watermark
    local stroke = Instance.new("UIStroke")
    stroke.Color = theme.Accent
    stroke.Transparency = 0
    stroke.Thickness = 1
    stroke.Parent = watermark
    self:AddToRegistry(stroke, { Color = 'Accent' })
    local iconButton = Instance.new("ImageButton")
    iconButton.Name = "Icon"
    iconButton.Image = "rbxassetid://107819132007001"
    iconButton.Size = UDim2.new(0, 20, 0, 20)
    iconButton.Position = UDim2.new(0, 8, 0.5, 0)
    iconButton.AnchorPoint = Vector2.new(0, 0.5)
    iconButton.BackgroundTransparency = 1
    iconButton.ImageColor3 = theme.Primary
    iconButton.ScaleType = Enum.ScaleType.Fit
    iconButton.AutoButtonColor = false
    iconButton.Parent = watermark
    self:AddToRegistry(iconButton, { ImageColor3 = 'Primary' })
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "Info"
    infoLabel.Text = "FPS: 60 | Ping: 50ms | 00:00"
    infoLabel.Font = self.currentFont
    infoLabel.TextSize = 12
    infoLabel.TextColor3 = theme.Text
    infoLabel.Size = UDim2.new(1, -40, 1, 0)
    infoLabel.Position = UDim2.new(0, 32, 0, 0)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.Parent = watermark
    self:AddToRegistry(infoLabel, { TextColor3 = 'Text' })
    local function UpdateWatermarkSize()
        local textBounds = TextService:GetTextSize(infoLabel.Text, infoLabel.TextSize, infoLabel.Font, Vector2.new(math.huge, math.huge))
        local newWidth = textBounds.X + 45
        watermark.Size = UDim2.new(0, newWidth, 0, 35)
    end
    local dragging = false
    local dragStart = nil
    local startPos = nil
    local dragArea = Instance.new("Frame")
    dragArea.Name = "DragArea"
    dragArea.Size = UDim2.new(1, -28, 1, 0)
    dragArea.Position = UDim2.new(0, 28, 0, 0)
    dragArea.BackgroundTransparency = 1
    dragArea.Active = true
    dragArea.Parent = watermark
    dragArea.InputBegan:Connect(function(input)
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
            watermark.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    iconButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
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
        infoLabel.Text = string.format("FPS: %d | Ping: %dms | %s", fps, ping, time)
        UpdateWatermarkSize()
    end)
    UpdateWatermarkSize()
    table.insert(self.connections, updateConnection)
    self.watermark = watermark
    self.watermarkVisible = false
end
function Library:ToggleUI()
    self.uiVisible = not self.uiVisible
    if self.uiVisible then
        self.ui.Enabled = true
        self.container.Size = UDim2.new(0, 698, 0, 479)
        if self.watermark then
            self.watermark.Visible = false
            self.watermarkVisible = false
        end
    else
        self.container.Size = UDim2.new(0, 0, 0, 0)
        self.ui.Enabled = false
        if self.watermark then
            self.watermark.Visible = true
            self.watermarkVisible = true
        end
    end
end
function Library:Unload()
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
    if self.notificationGui then
        self.notificationGui:Destroy()
        self.notificationGui = nil
    end
    if self.watermarkGui then
        self.watermarkGui:Destroy()
        self.watermarkGui = nil
    end
    if self.ui then
        self.ui:Destroy()
        self.ui = nil
    end
end
return { Library = Library, SaveManager = SaveManager, ThemeManager = ThemeManager, Toggles = Toggles, Options = Options }
