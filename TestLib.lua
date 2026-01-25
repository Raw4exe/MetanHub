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
                if Toggles[idx] then Toggles[idx]:SetValue(data.value) end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = 'Slider', idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                if Options[idx] then Options[idx]:SetValue(tonumber(data.value)) end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = 'Dropdown', idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                if Options[idx] then Options[idx]:SetValue(data.value) end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency or 0 }
            end,
            Load = function(idx, data)
                if Options[idx] then Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency) end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = 'KeyPicker', idx = idx, mode = object.Mode or 'Toggle', key = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] then Options[idx]:SetValue(data.key) end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = 'Input', idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                if Options[idx] and type(data.text) == 'string' then Options[idx]:SetValue(data.text) end
            end,
        },
    }
    function SaveManager:SetIgnoreIndexes(list)
        for _, key in next, list do self.Ignore[key] = true end
    end
    function SaveManager:SetFolder(folder)
        self.Folder = folder
        self:BuildFolderTree()
    end
    function SaveManager:BuildFolderTree()
        local paths = { self.Folder, self.Folder .. '/themes', self.Folder .. '/settings' }
        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then makefolder(str) end
        end
    end
    function SaveManager:Save(name)
        if not name then return false, 'no config file is selected' end
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
        if not success then return false, 'failed to encode data' end
        writefile(fullPath, encoded)
        return true
    end
    function SaveManager:Load(name)
        if not name then return false, 'no config file is selected' end
        local file = self.Folder .. '/settings/' .. name .. '.json'
        if not isfile(file) then return false, 'invalid file' end
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(file))
        if not success then return false, 'decode error' end
        for _, option in next, decoded.objects do
            if self.Parser[option.type] then
                task.spawn(function() self.Parser[option.type].Load(option.idx, option) end)
            end
        end
        return true
    end
    function SaveManager:Delete(name)
        if not name then return false end
        local file = self.Folder .. '/settings/' .. name .. '.json'
        if isfile(file) then delfile(file) return true end
        return false
    end
    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({ "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName' })
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
                if char == '/' or char == '\\' then table.insert(out, file:sub(pos + 1, start - 1)) end
            end
        end
        return out
    end
    function SaveManager:SetLibrary(library) self.Library = library end
    function SaveManager:LoadAutoloadConfig()
        if isfile(self.Folder .. '/settings/autoload.txt') then
            local name = readfile(self.Folder .. '/settings/autoload.txt')
            local success, err = self:Load(name)
            if not success then
                if self.Library then self.Library:SendNotification({ title = 'Config', text = 'Failed to load autoload config: ' .. tostring(err), duration = 3 }) end
                return
            end
            if self.Library then self.Library:SendNotification({ title = 'Config', text = string.format('Auto loaded config %q', name), duration = 3 }) end
        end
    end
    function SaveManager:GetAutoloadConfig()
        if isfile(self.Folder .. '/settings/autoload.txt') then return readfile(self.Folder .. '/settings/autoload.txt') end
        return nil
    end
    function SaveManager:SetAutoloadConfig(name) writefile(self.Folder .. '/settings/autoload.txt', name) end
    function SaveManager:DeleteAutoloadConfig()
        local path = self.Folder .. '/settings/autoload.txt'
        if isfile(path) then delfile(path) end
    end
    SaveManager:BuildFolderTree()
end

local ThemeManager = {}
do
    ThemeManager.Folder = 'MarchUI'
    ThemeManager.Library = nil
    ThemeManager.BuiltInThemes = {
        Ocean = { Primary = Color3.fromRGB(64, 156, 255), Background = Color3.fromRGB(10, 15, 25), Secondary = Color3.fromRGB(15, 25, 40), Accent = Color3.fromRGB(30, 50, 80), Text = Color3.fromRGB(200, 220, 255) },
        Sunset = { Primary = Color3.fromRGB(255, 107, 107), Background = Color3.fromRGB(25, 15, 20), Secondary = Color3.fromRGB(40, 25, 30), Accent = Color3.fromRGB(80, 40, 50), Text = Color3.fromRGB(255, 200, 200) },
        Forest = { Primary = Color3.fromRGB(76, 175, 80), Background = Color3.fromRGB(15, 20, 15), Secondary = Color3.fromRGB(25, 35, 25), Accent = Color3.fromRGB(40, 60, 40), Text = Color3.fromRGB(200, 255, 200) },
        Midnight = { Primary = Color3.fromRGB(138, 43, 226), Background = Color3.fromRGB(10, 10, 15), Secondary = Color3.fromRGB(20, 15, 30), Accent = Color3.fromRGB(40, 30, 60), Text = Color3.fromRGB(220, 200, 255) },
        Volcano = { Primary = Color3.fromRGB(255, 87, 34), Background = Color3.fromRGB(20, 10, 10), Secondary = Color3.fromRGB(35, 20, 15), Accent = Color3.fromRGB(70, 35, 25), Text = Color3.fromRGB(255, 220, 200) },
        Arctic = { Primary = Color3.fromRGB(100, 200, 255), Background = Color3.fromRGB(15, 18, 22), Secondary = Color3.fromRGB(25, 30, 38), Accent = Color3.fromRGB(45, 55, 70), Text = Color3.fromRGB(220, 240, 255) },
        Space = { Primary = Color3.fromRGB(147, 51, 234), Background = Color3.fromRGB(8, 8, 15), Secondary = Color3.fromRGB(15, 15, 25), Accent = Color3.fromRGB(30, 25, 50), Text = Color3.fromRGB(200, 180, 255) },
        Cherry = { Primary = Color3.fromRGB(255, 105, 180), Background = Color3.fromRGB(20, 12, 15), Secondary = Color3.fromRGB(35, 22, 28), Accent = Color3.fromRGB(70, 40, 55), Text = Color3.fromRGB(255, 200, 230) },
        Emerald = { Primary = Color3.fromRGB(80, 200, 120), Background = Color3.fromRGB(10, 18, 15), Secondary = Color3.fromRGB(18, 30, 25), Accent = Color3.fromRGB(35, 55, 45), Text = Color3.fromRGB(200, 255, 220) },
        Gold = { Primary = Color3.fromRGB(255, 193, 7), Background = Color3.fromRGB(18, 15, 10), Secondary = Color3.fromRGB(30, 28, 20), Accent = Color3.fromRGB(60, 50, 35), Text = Color3.fromRGB(255, 240, 200) }
    }
    function ThemeManager:SetLibrary(library) self.Library = library end
    function ThemeManager:SetFolder(folder) self.Folder = folder self:BuildFolderTree() end
    function ThemeManager:BuildFolderTree()
        local paths = { self.Folder, self.Folder .. '/themes', self.Folder .. '/settings' }
        for i = 1, #paths do
            local str = paths[i]
            if not isfolder(str) then makefolder(str) end
        end
    end
    function ThemeManager:ApplyTheme(theme)
        if self.Library then self.Library:UpdateColorsUsingRegistry() end
    end
    function ThemeManager:LoadDefault()
        local path = self.Folder .. '/themes/default.txt'
        if isfile(path) then
            local themeName = readfile(path)
            if self.BuiltInThemes[themeName] then return themeName end
            local customPath = self.Folder .. '/themes/' .. themeName .. '.json'
            if isfile(customPath) then return themeName end
        end
        return nil
    end
    function ThemeManager:SaveDefault(themeName) writefile(self.Folder .. '/themes/default.txt', themeName) end
    function ThemeManager:DeleteDefault()
        local path = self.Folder .. '/themes/default.txt'
        if isfile(path) then delfile(path) end
    end
    function ThemeManager:GetCustomTheme(name)
        local path = self.Folder .. '/themes/' .. name .. '.json'
        if not isfile(path) then return nil end
        local success, decoded = pcall(HttpService.JSONDecode, HttpService, readfile(path))
        if not success then return nil end
        local theme = {}
        for key, value in pairs(decoded) do
            if type(value) == 'string' then theme[key] = Color3.fromHex(value) end
        end
        return theme
    end
    function ThemeManager:SaveCustomTheme(name, themeData)
        local data = {}
        for key, color in pairs(themeData) do data[key] = color:ToHex() end
        local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
        if not success then return false end
        writefile(self.Folder .. '/themes/' .. name .. '.json', encoded)
        return true
    end
    function ThemeManager:DeleteCustomTheme(name)
        local path = self.Folder .. '/themes/' .. name .. '.json'
        if isfile(path) then delfile(path) return true end
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
                if char == '/' or char == '\\' then table.insert(out, file:sub(pos + 1, start - 1)) end
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
Library.Fonts = { "Gotham", "GothamBold", "GothamBlack", "SourceSans", "SourceSansBold", "SourceSansLight", "SourceSansItalic", "Arial", "ArialBold", "RobotoMono", "Roboto", "RobotoCondensed", "Ubuntu", "Oswald", "Michroma", "Bangers", "Creepster", "DenkOne", "Fondamento", "FredokaOne", "Jura", "Merriweather", "Nunito", "PatrickHand", "PermanentMarker", "Sarpanch", "SciFi", "SpecialElite", "TitilliumWeb" }
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
            if self.Registry[i] == data then table.remove(self.Registry, i) end
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
                if theme[colorKey] then instance[property] = theme[colorKey] end
            end
        end
    end
    if self.currentTab then
        local tab = self.currentTab
        local icon = tab.button.Icon
        local label = tab.button.Label
        icon.ImageColor3 = theme.Primary
        label.TextColor3 = theme.Primary
    end
    for _, tab in ipairs(self.tabs) do
        for _, module in ipairs(tab.modules) do
            if module.toggleFrame and module.state then
                module.toggleFrame.BackgroundColor3 = theme.Primary
            elseif module.toggleFrame then
                module.toggleFrame.BackgroundColor3 = theme.Accent
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
            if tostring(input.KeyCode) == savedKeybind then self:ToggleUI() end
        end)
    end
end
function Library:SetUIKeybind(keycode)
    self.uiKeybind = keycode
    if self.uiKeybindConnection then self.uiKeybindConnection:Disconnect() self.uiKeybindConnection = nil end
    if keycode then
        self.uiKeybindConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if tostring(input.KeyCode) == keycode then self:ToggleUI() end
        end)
    end
end
function Library:SetTheme(themeName)
    local theme = ThemeManager.BuiltInThemes[themeName]
    if not theme then theme = ThemeManager:GetCustomTheme(themeName) end
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
            if descendant.Name ~= "Icon" then descendant.Font = font end
        end
    end
    if self.container then
        for _, descendant in ipairs(self.container:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
                if descendant.Name ~= "Icon" then descendant.Font = font end
            end
        end
    end
    if self.notificationGui then
        for _, descendant in ipairs(self.notificationGui:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then descendant.Font = font end
        end
    end
    if self.watermark then
        for _, descendant in ipairs(self.watermark:GetDescendants()) do
            if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then descendant.Font = font end
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
    logo.Text = "METAN"
    logo.Font = self.currentFont
    logo.TextSize = 20
    logo.TextColor3 = theme.Primary
    logo.TextTransparency = 0.2
    logo.TextXAlignment = Enum.TextXAlignment.Left
    logo.Size = UDim2.new(0, 100, 0, 20)
    logo.Position = UDim2.new(0.067, 0, 0.055, 0)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.BackgroundTransparency = 1
    logo.Parent = handler
    self:AddToRegistry(logo, { TextColor3 = 'Primary' })
    local logoGradient = Instance.new("UIGradient")
    local primaryBright = Color3.new(
        math.min(theme.Primary.R + 0.3, 1),
        math.min(theme.Primary.G + 0.3, 1),
        math.min(theme.Primary.B + 0.3, 1)
    )
    local accentBright = Color3.new(
        math.min(theme.Accent.R + 0.4, 1),
        math.min(theme.Accent.G + 0.4, 1),
        math.min(theme.Accent.B + 0.4, 1)
    )
    logoGradient.Color = ColorSequence.new{ 
        ColorSequenceKeypoint.new(0, primaryBright), 
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)), 
        ColorSequenceKeypoint.new(1, accentBright) 
    }
    logoGradient.Parent = logo
    
    task.spawn(function()
        while logo and logo.Parent and not self.unloading do
            for i = 0, 360, 2 do
                if not logo or not logo.Parent or self.unloading then break end
                logoGradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    local logoIconButton = Instance.new("ImageButton")
    logoIconButton.Name = "Icon"
    logoIconButton.Image = "rbxassetid://107819132007001"
    logoIconButton.Size = UDim2.new(0, 24, 0, 24)
    logoIconButton.Position = UDim2.new(0.024, 0, 0.058, 0)
    logoIconButton.AnchorPoint = Vector2.new(0, 0.5)
    logoIconButton.BackgroundTransparency = 1
    logoIconButton.ImageColor3 = theme.Primary
    logoIconButton.ScaleType = Enum.ScaleType.Fit
    logoIconButton.AutoButtonColor = false
    logoIconButton.Parent = handler
    self:AddToRegistry(logoIconButton, { ImageColor3 = 'Primary' })
    local logoIconGradient = Instance.new("UIGradient")
    local primaryBright = Color3.new(
        math.min(theme.Primary.R + 0.3, 1),
        math.min(theme.Primary.G + 0.3, 1),
        math.min(theme.Primary.B + 0.3, 1)
    )
    local accentBright = Color3.new(
        math.min(theme.Accent.R + 0.4, 1),
        math.min(theme.Accent.G + 0.4, 1),
        math.min(theme.Accent.B + 0.4, 1)
    )
    logoIconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, primaryBright),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, accentBright)
    }
    logoIconGradient.Parent = logoIconButton
    task.spawn(function()
        while logoIconButton and logoIconButton.Parent and not self.unloading do
            for i = 0, 360, 2 do
                if not logoIconButton or not logoIconButton.Parent or self.unloading then break end
                logoIconGradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    logoIconButton.MouseButton1Click:Connect(function() self:ToggleUI() end)
    local logoDivider = Instance.new("Frame")
    logoDivider.Name = "LogoDivider"
    logoDivider.Size = UDim2.new(0, 155, 0, 1)
    logoDivider.Position = UDim2.new(0.012, 0, 0.105, 0)
    logoDivider.BackgroundColor3 = theme.Accent
    logoDivider.BackgroundTransparency = 0.5
    logoDivider.BorderSizePixel = 0
    logoDivider.Parent = handler
    self:AddToRegistry(logoDivider, { BackgroundColor3 = 'Accent' })
    local pin = Instance.new("Frame")
    pin.Name = "Pin"
    pin.Size = UDim2.new(0, 2, 0, 16)
    pin.Position = UDim2.new(0.026, 0, 0.155, 0)
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
    tabsFrame.Size = UDim2.new(0, 129, 0, 375)
    tabsFrame.Position = UDim2.new(0.026, 0, 0.13, 0)
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
    local handler = self.handler
    local dragging = false
    local dragStart = nil
    local startPos = nil
    handler.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = container.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
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
    local primaryBright = Color3.new(
        math.min(theme.Primary.R + 0.3, 1),
        math.min(theme.Primary.G + 0.3, 1),
        math.min(theme.Primary.B + 0.3, 1)
    )
    local accentBright = Color3.new(
        math.min(theme.Accent.R + 0.4, 1),
        math.min(theme.Accent.G + 0.4, 1),
        math.min(theme.Accent.B + 0.4, 1)
    )
    labelGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, primaryBright),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, accentBright)
    }
    labelGradient.Parent = tabLabel
    task.spawn(function()
        while tabLabel and tabLabel.Parent and not self.unloading do
            for i = 0, 360, 2 do
                if not tabLabel or not tabLabel.Parent or self.unloading then break end
                labelGradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
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
    tabButton.MouseButton1Click:Connect(function() self:SelectTab(tab) end)
    table.insert(self.tabs, tab)
    if #self.tabs == 1 then self:SelectTab(tab) end
    return setmetatable(tab, { __index = { CreateModule = function(t, options) return self:CreateModule(t, options) end } })
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
            Tween(self.pin, {Position = UDim2.fromScale(0.026, 0.155 + offset)}, 0.5)
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
    local configModule = settingsTab:CreateModule({ title = "Config Manager", description = "Manage your configurations", section = "left" })
    local configNameInput, configListDropdown, autoloadLabel
    local function UpdateConfigList()
        local configs = SaveManager:RefreshConfigList()
        if configListDropdown then
            if #configs == 0 then
                configListDropdown:SetValues({"None"})
            else
                configListDropdown:SetValues(configs)
            end
        end
    end
    local function UpdateAutoloadLabel()
        local autoload = SaveManager:GetAutoloadConfig()
        if autoloadLabel then autoloadLabel:SetValue(autoload and ("Autoload: " .. autoload) or "Autoload: None") end
    end
    configListDropdown = configModule:CreateDropdown({ title = "Select Config", flag = "SaveManager_ConfigList", options = SaveManager:RefreshConfigList() })
    autoloadLabel = configModule:CreateTextbox({ title = "Autoload Status", flag = "SaveManager_AutoloadStatus", default = SaveManager:GetAutoloadConfig() and ("Autoload: " .. SaveManager:GetAutoloadConfig()) or "Autoload: None", placeholder = "No autoload set" })
    autoloadLabel.textboxFrame.TextEditable = false
    configNameInput = configModule:CreateTextbox({ title = "Config Name", flag = "SaveManager_ConfigName", placeholder = "Enter config name..." })
    configModule:CreateButton({ title = "Load Config", callback = function()
        local name = Options["SaveManager_ConfigList"] and Options["SaveManager_ConfigList"].Value
        if name and name ~= "" then
            local success, err = SaveManager:Load(name)
            if success then self:SendNotification({ title = 'Config', text = 'Loaded config: ' .. name, duration = 3 })
            else self:SendNotification({ title = 'Config', text = 'Failed to load: ' .. tostring(err), duration = 3 }) end
        else self:SendNotification({ title = 'Config', text = 'Please select a config', duration = 3 }) end
    end })
    configModule:CreateButton({ title = "Create Config", callback = function()
        local name = Options["SaveManager_ConfigName"] and Options["SaveManager_ConfigName"].Value
        if name and name ~= "" then
            local success, err = SaveManager:Save(name)
            if success then self:SendNotification({ title = 'Config', text = 'Created config: ' .. name, duration = 3 }) UpdateConfigList()
            else self:SendNotification({ title = 'Config', text = 'Failed: ' .. tostring(err), duration = 3 }) end
        else self:SendNotification({ title = 'Config', text = 'Please enter a config name', duration = 3 }) end
    end })
    configModule:CreateButton({ title = "Delete Config", callback = function()
        local name = Options["SaveManager_ConfigList"] and Options["SaveManager_ConfigList"].Value
        if name and name ~= "" then
            if SaveManager:Delete(name) then self:SendNotification({ title = 'Config', text = 'Deleted config: ' .. name, duration = 3 }) UpdateConfigList() UpdateAutoloadLabel()
            else self:SendNotification({ title = 'Config', text = 'Failed to delete config', duration = 3 }) end
        end
    end })
    configModule:CreateButton({ title = "Set as Autoload", callback = function()
        local name = Options["SaveManager_ConfigList"] and Options["SaveManager_ConfigList"].Value
        if name and name ~= "" then SaveManager:SetAutoloadConfig(name) self:SendNotification({ title = 'Config', text = 'Set autoload: ' .. name, duration = 3 }) UpdateAutoloadLabel() end
    end })
    configModule:CreateButton({ title = "Delete Autoload", callback = function() SaveManager:DeleteAutoloadConfig() self:SendNotification({ title = 'Config', text = 'Removed autoload', duration = 3 }) UpdateAutoloadLabel() end })
    local uiModule = settingsTab:CreateModule({ title = "UI Settings", description = "Customize your UI", section = "right" })
    uiModule:CreateKeybind({ title = "Toggle UI", flag = "_UI_Toggle", callback = function(key) self:SetUIKeybind(key) end })
    uiModule:CreateDropdown({ title = "Font", flag = "_UI_Font", options = self.Fonts, callback = function(font) self:SetFont(font) end })
    uiModule:CreateButton({ title = "Unload UI", callback = function() self:Unload() end })
    local themeModule = settingsTab:CreateModule({ title = "Themes", description = "Manage themes", section = "left" })
    local themeListDropdown, customThemeListDropdown, customThemeNameInput, autoloadThemeLabel
    local tempTheme = { Primary = self.currentTheme.Primary, Background = self.currentTheme.Background, Secondary = self.currentTheme.Secondary, Accent = self.currentTheme.Accent, Text = self.currentTheme.Text }
    local function UpdateCustomThemeList()
        local themes = ThemeManager:RefreshCustomThemeList()
        if customThemeListDropdown then
            if #themes == 0 then
                customThemeListDropdown:SetValues({"None"})
            else
                customThemeListDropdown:SetValues(themes)
            end
        end
    end
    local function UpdateAutoloadThemeLabel()
        local autoload = ThemeManager:LoadDefault()
        if autoloadThemeLabel then autoloadThemeLabel:SetValue(autoload or "None") end
    end
    themeModule:CreateColorpicker({ title = "Background color", flag = "BackgroundColor", default = tempTheme.Background, callback = function(color) tempTheme.Background = color end })
    themeModule:CreateColorpicker({ title = "Main color", flag = "MainColor", default = tempTheme.Primary, callback = function(color) tempTheme.Primary = color end })
    themeModule:CreateColorpicker({ title = "Accent color", flag = "AccentColor", default = tempTheme.Accent, callback = function(color) tempTheme.Accent = color end })
    themeModule:CreateColorpicker({ title = "Outline color", flag = "OutlineColor", default = tempTheme.Secondary, callback = function(color) tempTheme.Secondary = color end })
    themeModule:CreateColorpicker({ title = "Font color", flag = "FontColor", default = tempTheme.Text, callback = function(color) tempTheme.Text = color end })
    local themeNames = {}
    for name, _ in pairs(ThemeManager.BuiltInThemes) do table.insert(themeNames, name) end
    table.sort(themeNames)
    themeListDropdown = themeModule:CreateDropdown({ title = "Theme list", flag = "ThemeManager_ThemeList", options = themeNames, callback = function(themeName) if themeName then self:SetTheme(themeName) end end })
    themeModule:CreateButton({ title = "Set as default", callback = function()
        if self.currentThemeName then ThemeManager:SaveDefault(self.currentThemeName) self:SendNotification({ title = 'Theme', text = 'Set default: ' .. self.currentThemeName, duration = 3 }) UpdateAutoloadThemeLabel() end
    end })
    autoloadThemeLabel = themeModule:CreateTextbox({ title = "Autoload theme", flag = "ThemeManager_AutoloadTheme", default = ThemeManager:LoadDefault() or "None", placeholder = "None" })
    autoloadThemeLabel.textboxFrame.TextEditable = false
    customThemeNameInput = themeModule:CreateTextbox({ title = "Custom theme name", flag = "ThemeManager_CustomThemeName", placeholder = "Enter name..." })
    customThemeListDropdown = themeModule:CreateDropdown({ title = "Custom themes", flag = "ThemeManager_CustomThemeList", options = ThemeManager:RefreshCustomThemeList(), callback = function(themeName)
        if themeName then
            local theme = ThemeManager:GetCustomTheme(themeName)
            if theme then self.currentTheme = theme self.currentThemeName = themeName self:UpdateColorsUsingRegistry() end
        end
    end })
    themeModule:CreateButton({ title = "Save theme", callback = function()
        local name = Options["ThemeManager_CustomThemeName"] and Options["ThemeManager_CustomThemeName"].Value
        if name and name ~= "" then
            if ThemeManager:SaveCustomTheme(name, tempTheme) then self:SendNotification({ title = 'Theme', text = 'Saved theme: ' .. name, duration = 3 }) UpdateCustomThemeList()
            else self:SendNotification({ title = 'Theme', text = 'Failed to save theme', duration = 3 }) end
        else self:SendNotification({ title = 'Theme', text = 'Please enter a theme name', duration = 3 }) end
    end })
    themeModule:CreateButton({ title = "Load theme", callback = function()
        local name = Options["ThemeManager_CustomThemeList"] and Options["ThemeManager_CustomThemeList"].Value
        if name and name ~= "" then
            local theme = ThemeManager:GetCustomTheme(name)
            if theme then self.currentTheme = theme self.currentThemeName = name self:UpdateColorsUsingRegistry() self:SendNotification({ title = 'Theme', text = 'Loaded theme: ' .. name, duration = 3 }) end
        end
    end })
    themeModule:CreateButton({ title = "Delete theme", callback = function()
        local name = Options["ThemeManager_CustomThemeList"] and Options["ThemeManager_CustomThemeList"].Value
        if name and name ~= "" then
            if ThemeManager:DeleteCustomTheme(name) then self:SendNotification({ title = 'Theme', text = 'Deleted theme: ' .. name, duration = 3 }) UpdateCustomThemeList() end
        end
    end })
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
    module.library = self
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
    local moduleTitleGradient = Instance.new("UIGradient")
    local primaryBright = Color3.new(
        math.min(theme.Primary.R + 0.3, 1),
        math.min(theme.Primary.G + 0.3, 1),
        math.min(theme.Primary.B + 0.3, 1)
    )
    local accentBright = Color3.new(
        math.min(theme.Accent.R + 0.4, 1),
        math.min(theme.Accent.G + 0.4, 1),
        math.min(theme.Accent.B + 0.4, 1)
    )
    moduleTitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, primaryBright),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, accentBright)
    }
    moduleTitleGradient.Parent = moduleTitle
    task.spawn(function()
        while moduleTitle and moduleTitle.Parent and not self.unloading do
            for i = 0, 360, 2 do
                if not moduleTitle or not moduleTitle.Parent or self.unloading then break end
                moduleTitleGradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
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
    local moduleDescGradient = Instance.new("UIGradient")
    local primaryBright = Color3.new(
        math.min(theme.Primary.R + 0.3, 1),
        math.min(theme.Primary.G + 0.3, 1),
        math.min(theme.Primary.B + 0.3, 1)
    )
    local accentBright = Color3.new(
        math.min(theme.Accent.R + 0.4, 1),
        math.min(theme.Accent.G + 0.4, 1),
        math.min(theme.Accent.B + 0.4, 1)
    )
    moduleDescGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, primaryBright),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 220, 220)),
        ColorSequenceKeypoint.new(1, accentBright)
    }
    moduleDescGradient.Parent = moduleDesc
    task.spawn(function()
        while moduleDesc and moduleDesc.Parent and not self.unloading do
            for i = 0, 360, 2 do
                if not moduleDesc or not moduleDesc.Parent or self.unloading then break end
                moduleDescGradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    local decorIcon = Instance.new("ImageLabel")
    decorIcon.Name = "DecorIcon"
    decorIcon.Image = "rbxassetid://10747361219"
    decorIcon.Size = UDim2.new(0, 18, 0, 18)
    decorIcon.Position = UDim2.new(0.89, 0, 0.23, 0)
    decorIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    decorIcon.BackgroundTransparency = 1
    decorIcon.ImageColor3 = theme.Primary
    decorIcon.ImageTransparency = 0.3
    decorIcon.ScaleType = Enum.ScaleType.Fit
    decorIcon.Parent = header
    self:AddToRegistry(decorIcon, { ImageColor3 = 'Primary' })
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
    module.decorIcon = decorIcon
    
    local keybindConnection = nil
    
    header.MouseButton1Click:Connect(function()
        module.state = not module.state
        local newSize = module.state and (93 + module.elementHeight + module.multiplier) or 93
        Tween(moduleFrame, {Size = UDim2.new(0, 241, 0, newSize)}, 0.5)
        Tween(optionsFrame, {Size = UDim2.new(0, 241, 0, module.state and (module.elementHeight + module.multiplier) or 0)}, 0.5)
        if module.state then
            Tween(decorIcon, {ImageTransparency = 0, Rotation = 360}, 0.5)
        else
            Tween(decorIcon, {ImageTransparency = 0.3, Rotation = 0}, 0.5)
        end
    end)
    
    keybindFrame.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
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
                if keybindConnection then
                    keybindConnection:Disconnect()
                    keybindConnection = nil
                end
                return
            end
            local keycodeStr = tostring(keyInput.KeyCode)
            local displayText = keycodeStr:gsub("Enum.KeyCode.", "")
            keybindLabel.Text = displayText
            local width = math.max(33, GetTextWidth(displayText, 10, Enum.Font.GothamBold) + 16)
            keybindFrame.Size = UDim2.new(0, width, 0, 15)
            if keybindConnection then
                keybindConnection:Disconnect()
                keybindConnection = nil
            end
            keybindConnection = UserInputService.InputBegan:Connect(function(input2, gameProcessed2)
                if gameProcessed2 then return end
                if tostring(input2.KeyCode) == keycodeStr then
                    module.state = not module.state
                    local newSize = module.state and (93 + module.elementHeight + module.multiplier) or 93
                    Tween(moduleFrame, {Size = UDim2.new(0, 241, 0, newSize)}, 0.5)
                    Tween(optionsFrame, {Size = UDim2.new(0, 241, 0, module.state and (module.elementHeight + module.multiplier) or 0)}, 0.5)
                    if module.state then
                        Tween(decorIcon, {ImageTransparency = 0}, 0.3)
                    else
                        Tween(decorIcon, {ImageTransparency = 0.3}, 0.3)
                    end
                end
            end)
            table.insert(self.connections, keybindConnection)
        end)
    end)
    module.UpdateSize = function()
        if module.state then
            local newSize = 93 + module.elementHeight + module.multiplier
            moduleFrame.Size = UDim2.new(0, 241, 0, newSize)
            optionsFrame.Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)
        end
    end
    module.RefreshSize = function()
        module.UpdateSize()
    end
    module.RemoveElement = function(element)
        if not element or not element.frame then return end
        if element.Type == 'Slider' then
            module.elementHeight = module.elementHeight - 30
        elseif element.Type == 'Toggle' then
            module.elementHeight = module.elementHeight - 22
        elseif element.Type == 'Dropdown' then
            module.elementHeight = module.elementHeight - 46
        elseif element.Type == 'Input' then
            module.elementHeight = module.elementHeight - 44
        elseif element.Type == 'Button' then
            module.elementHeight = module.elementHeight - 26
        elseif element.Type == 'ColorPicker' then
            module.elementHeight = module.elementHeight - 26
        end
        for i, el in ipairs(module.elements) do
            if el == element then
                table.remove(module.elements, i)
                break
            end
        end
        if element.flag then
            if element.Type == 'Toggle' then
                Toggles[element.flag] = nil
            else
                Options[element.flag] = nil
            end
        end
        pcall(function()
            element.frame:Destroy()
        end)
        task.wait(0.05)
        module.UpdateSize()
    end
    if module.state then task.spawn(function() task.wait(0.1) module.UpdateSize() end) end
    table.insert(tab.modules, module)
    return setmetatable(module, { __index = {
        CreateSlider = function(m, opts) return self:CreateSlider(m, opts) end,
        CreateCheckbox = function(m, opts) return self:CreateCheckbox(m, opts) end,
        CreateDropdown = function(m, opts) return self:CreateDropdown(m, opts) end,
        CreateMultiDropdown = function(m, opts) return self:CreateMultiDropdown(m, opts) end,
        CreateTextbox = function(m, opts) return self:CreateTextbox(m, opts) end,
        CreateButton = function(m, opts) return self:CreateButton(m, opts) end,
        CreateColorpicker = function(m, opts) return self:CreateColorpicker(m, opts) end,
        CreateKeybind = function(m, opts) return self:CreateKeybind(m, opts) end,
        CreateLabel = function(m, opts) return self:CreateLabel(m, opts) end,
        CreateDivider = function(m, opts) return self:CreateDivider(m, opts) end,
        RemoveElement = function(m, el) return m.RemoveElement(el) end
    } })
end

function Library:CreateSlider(module, options)
    options = options or {}
    local slider = {}
    slider.title = options.title or "Slider"
    slider.flag = options.flag or slider.title
    slider.min = options.minimum_value or options.min or 0
    slider.max = options.maximum_value or options.max or 100
    slider.round = options.round_number or options.round or false
    slider.step = options.step or nil
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
    fillGradient.Color = ColorSequence.new{ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(79, 79, 79)) }
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
        if slider.step then
            value = math.floor((value - slider.min) / slider.step + 0.5) * slider.step + slider.min
            -- Определяем количество десятичных знаков для отображения
            local decimals = 0
            local stepStr = tostring(slider.step)
            if stepStr:find("%.") then
                decimals = #stepStr - stepStr:find("%.")
            end
            value = Round(value, decimals)
        elseif slider.round then
            value = Round(value, 0)
        else
            value = Round(value, 1)
        end
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
    slider.frame = sliderFrame
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
    checkboxFrame.MouseButton1Click:Connect(function() checkbox:SetValue(not checkbox.state) end)
    checkbox.frame = checkboxFrame
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
    dropdown.maxVisible = options.maximum_options or #dropdown.options
    dropdown.callback = options.callback or function() end
    dropdown.open = false
    dropdown.size = 0
    dropdown.Type = 'Dropdown'
    dropdown.Multi = dropdown.multi
    local theme = self.currentTheme
    local existingValue = Options[dropdown.flag] and Options[dropdown.flag].Value
    dropdown.selected = existingValue or (dropdown.multi and {} or (options.default or nil))
    local baseHeight = 46
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
    optionGradient.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0), NumberSequenceKeypoint.new(0.87, 0.36), NumberSequenceKeypoint.new(1, 1) }
    optionGradient.Parent = currentOption
    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.AnchorPoint = Vector2.new(0, 0.5)
    arrow.Image = "rbxassetid://10747361219"
    arrow.BackgroundTransparency = 1
    arrow.ImageColor3 = theme.Primary
    arrow.ImageTransparency = 0.3
    arrow.Position = UDim2.new(0.91, 0, 0.5, 0)
    arrow.Size = UDim2.new(0, 12, 0, 12)
    arrow.ScaleType = Enum.ScaleType.Fit
    arrow.Parent = header
    self:AddToRegistry(arrow, { ImageColor3 = 'Primary' })
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
            if type(dropdown.selected) == "table" and #dropdown.selected > 0 then currentOption.Text = table.concat(dropdown.selected, ", ")
            else currentOption.Text = "None" end
        else currentOption.Text = dropdown.selected or "None" end
        dropdown.Value = dropdown.selected
    end
    local function Toggle(option)
        if dropdown.multi then
            if type(dropdown.selected) ~= "table" then dropdown.selected = {} end
            local found = false
            for i, v in ipairs(dropdown.selected) do
                if v == option then table.remove(dropdown.selected, i) found = true break end
            end
            if not found then table.insert(dropdown.selected, option) end
        else dropdown.selected = option end
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
        optionButton.Text = "    " .. option
        optionButton.AutoButtonColor = false
        optionButton.BackgroundTransparency = 1
        optionButton.TextXAlignment = Enum.TextXAlignment.Left
        optionButton.Selectable = false
        optionButton.Parent = optionsScrollFrame
        local optGradient = Instance.new("UIGradient")
        optGradient.Transparency = NumberSequence.new{ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0), NumberSequenceKeypoint.new(0.87, 0.36), NumberSequenceKeypoint.new(1, 1) }
        optGradient.Parent = optionButton
        local dot = Instance.new("Frame")
        dot.Name = "Dot"
        dot.Size = UDim2.new(0, 4, 0, 4)
        dot.Position = UDim2.new(0, 2, 0.5, 0)
        dot.AnchorPoint = Vector2.new(0, 0.5)
        dot.BackgroundColor3 = self.currentTheme.Primary
        dot.BorderSizePixel = 0
        dot.BackgroundTransparency = 1
        dot.Parent = optionButton
        self:AddToRegistry(dot, { BackgroundColor3 = 'Primary' })
        local dotCorner = Instance.new("UICorner")
        dotCorner.CornerRadius = UDim.new(1, 0)
        dotCorner.Parent = dot
        local function UpdateOptionAppearance()
            local isSelected = false
            if dropdown.multi then
                if type(dropdown.selected) == "table" then
                    for _, v in ipairs(dropdown.selected) do if v == option then isSelected = true break end end
                end
            else isSelected = (dropdown.selected == option) end
            local t = self.currentTheme
            if isSelected then
                Tween(optionButton, {TextTransparency = 0.2}, 0.3)
                optionButton.TextColor3 = t.Primary
                Tween(dot, {BackgroundTransparency = 0}, 0.3)
            else
                Tween(optionButton, {TextTransparency = 0.7}, 0.3)
                optionButton.TextColor3 = t.Text
                Tween(dot, {BackgroundTransparency = 1}, 0.3)
            end
        end
        table.insert(dropdown.updateFunctions, UpdateOptionAppearance)
        UpdateOptionAppearance()
        optionButton.MouseButton1Click:Connect(function()
            Toggle(option)
            for _, updateFunc in ipairs(dropdown.updateFunctions) do updateFunc() end
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
        dropdown.size = dropdown.size + 16
    end
    for index, option in ipairs(dropdown.options) do CreateOptionButton(option, index) end
    
    -- Полный размер для всех опций без ограничений
    optionsScrollFrame.Size = UDim2.fromOffset(207, dropdown.size)
    
    dropdownFrame.MouseButton1Click:Connect(function()
        dropdown.open = not dropdown.open
        if dropdown.open then
            module.multiplier = module.multiplier + dropdown.size
            Tween(module.frame, {Size = UDim2.new(0, 241, 0, 93 + module.elementHeight + module.multiplier)}, 0.5)
            Tween(module.optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
            Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 42 + dropdown.size)}, 0.5)
            Tween(box, {Size = UDim2.new(0, 207, 0, 22 + dropdown.size)}, 0.5)
            Tween(arrow, {Rotation = 180, ImageTransparency = 0}, 0.5)
        else
            module.multiplier = module.multiplier - dropdown.size
            Tween(module.frame, {Size = UDim2.new(0, 241, 0, 93 + module.elementHeight + module.multiplier)}, 0.5)
            Tween(module.optionsFrame, {Size = UDim2.new(0, 241, 0, module.elementHeight + module.multiplier)}, 0.5)
            Tween(dropdownFrame, {Size = UDim2.new(0, 207, 0, 42)}, 0.5)
            Tween(box, {Size = UDim2.new(0, 207, 0, 22)}, 0.5)
            Tween(arrow, {Rotation = 0, ImageTransparency = 0.3}, 0.5)
        end
    end)
    UpdateText()
    dropdown.SetValue = function(self2, newValue)
        dropdown.selected = newValue
        dropdown.Value = newValue
        UpdateText()
        for _, updateFunc in ipairs(dropdown.updateFunctions) do updateFunc() end
        task.spawn(function() dropdown.callback(dropdown.selected) end)
    end
    dropdown.SetValues = function(self2, newOptions)
        for _, child in ipairs(optionsScrollFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
        dropdown.updateFunctions = {}
        dropdown.options = newOptions
        dropdown.maxVisible = #newOptions
        dropdown.size = 3
        for index, option in ipairs(newOptions) do CreateOptionButton(option, index) end
        optionsScrollFrame.Size = UDim2.fromOffset(207, dropdown.size)
    end
    dropdown.box = box
    dropdown.frame = dropdownFrame
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
    module.elementHeight = module.elementHeight + 44
    local theme = self.currentTheme
    local existingValue = Options[textbox.flag] and Options[textbox.flag].Value
    textbox.value = existingValue or options.default or ""
    local textboxContainer = Instance.new("Frame")
    textboxContainer.Name = "Textbox"
    textboxContainer.Size = UDim2.new(0, 207, 0, 40)
    textboxContainer.BackgroundTransparency = 1
    textboxContainer.BorderSizePixel = 0
    textboxContainer.Parent = module.optionsFrame
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = textbox.title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 10
    titleLabel.TextColor3 = theme.Text
    titleLabel.TextTransparency = 0.2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(0, 207, 0, 13)
    titleLabel.Position = UDim2.new(0, 0, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = textboxContainer
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.Size = UDim2.new(0, 207, 0, 22)
    inputFrame.Position = UDim2.new(0, 0, 0, 16)
    inputFrame.BackgroundColor3 = theme.Primary
    inputFrame.BackgroundTransparency = 0.9
    inputFrame.BorderSizePixel = 0
    inputFrame.Parent = textboxContainer
    self:AddToRegistry(inputFrame, { BackgroundColor3 = 'Primary' })
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = inputFrame
    local textboxInput = Instance.new("TextBox")
    textboxInput.Name = "Input"
    textboxInput.Font = Enum.Font.GothamBold
    textboxInput.TextSize = 10
    textboxInput.TextColor3 = theme.Text
    textboxInput.TextTransparency = 0.2
    textboxInput.PlaceholderText = textbox.placeholder
    textboxInput.PlaceholderColor3 = theme.Text
    textboxInput.Text = textbox.value
    textboxInput.Size = UDim2.new(1, -10, 1, 0)
    textboxInput.Position = UDim2.new(0.5, 0, 0.5, 0)
    textboxInput.AnchorPoint = Vector2.new(0.5, 0.5)
    textboxInput.BackgroundTransparency = 1
    textboxInput.TextXAlignment = Enum.TextXAlignment.Left
    textboxInput.ClearTextOnFocus = false
    textboxInput.Parent = inputFrame
    self:AddToRegistry(textboxInput, { TextColor3 = 'Text', PlaceholderColor3 = 'Text' })
    textbox.Value = textbox.value
    textbox.SetValue = function(self2, value)
        textbox.value = value
        textbox.Value = value
        textboxInput.Text = value
    end
    textbox.SetText = function(self2, value)
        textbox.value = value
        textbox.Value = value
        textboxInput.Text = value
    end
    textboxInput.FocusLost:Connect(function(enterPressed)
        textbox.value = textboxInput.Text
        textbox.Value = textboxInput.Text
        task.spawn(function() textbox.callback(textboxInput.Text, enterPressed) end)
    end)
    textbox.textboxFrame = textboxInput
    textbox.frame = textboxContainer
    Options[textbox.flag] = textbox
    table.insert(module.elements, textbox)
    return textbox
end
function Library:CreateButton(module, options)
    options = options or {}
    local button = {}
    button.title = options.title or "Button"
    button.callback = options.callback or function() end
    module.elementHeight = module.elementHeight + 26
    local theme = self.currentTheme
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Name = "Button"
    buttonFrame.Size = UDim2.new(0, 207, 0, 22)
    buttonFrame.BackgroundColor3 = theme.Primary
    buttonFrame.BackgroundTransparency = 0.9
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Text = ""
    buttonFrame.AutoButtonColor = false
    buttonFrame.Parent = module.optionsFrame
    self:AddToRegistry(buttonFrame, { BackgroundColor3 = 'Primary' })
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 4)
    buttonCorner.Parent = buttonFrame
    local buttonLabel = Instance.new("TextLabel")
    buttonLabel.Text = button.title
    buttonLabel.Font = Enum.Font.GothamBold
    buttonLabel.TextSize = 10
    buttonLabel.TextColor3 = theme.Text
    buttonLabel.TextTransparency = 0.2
    buttonLabel.Size = UDim2.new(1, 0, 1, 0)
    buttonLabel.BackgroundTransparency = 1
    buttonLabel.Parent = buttonFrame
    self:AddToRegistry(buttonLabel, { TextColor3 = 'Text' })
    buttonFrame.MouseEnter:Connect(function() Tween(buttonFrame, {BackgroundTransparency = 0.7}, 0.3) end)
    buttonFrame.MouseLeave:Connect(function() Tween(buttonFrame, {BackgroundTransparency = 0.9}, 0.3) end)
    buttonFrame.MouseButton1Click:Connect(function()
        Tween(buttonFrame, {BackgroundTransparency = 0.5}, 0.1)
        task.wait(0.1)
        Tween(buttonFrame, {BackgroundTransparency = 0.9}, 0.1)
        task.spawn(function() button.callback() end)
    end)
    button.frame = buttonFrame
    table.insert(module.elements, button)
    return button
end

function Library:CreateColorpicker(module, options)
    options = options or {}
    local colorpicker = {}
    colorpicker.title = options.title or "Colorpicker"
    colorpicker.flag = options.flag or colorpicker.title
    colorpicker.callback = options.callback or function() end
    colorpicker.Type = 'ColorPicker'
    module.elementHeight = module.elementHeight + 26
    local theme = self.currentTheme
    local existingValue = Options[colorpicker.flag] and Options[colorpicker.flag].Value
    colorpicker.color = existingValue or options.default or Color3.fromRGB(255, 255, 255)
    colorpicker.transparency = 0
    colorpicker.open = false
    local colorpickerFrame = Instance.new("TextButton")
    colorpickerFrame.Name = "Colorpicker"
    colorpickerFrame.Size = UDim2.new(0, 207, 0, 22)
    colorpickerFrame.BackgroundTransparency = 1
    colorpickerFrame.BorderSizePixel = 0
    colorpickerFrame.Text = ""
    colorpickerFrame.AutoButtonColor = false
    colorpickerFrame.Parent = module.optionsFrame
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
    titleLabel.Parent = colorpickerFrame
    self:AddToRegistry(titleLabel, { TextColor3 = 'Text' })
    local colorBox = Instance.new("Frame")
    colorBox.Name = "ColorBox"
    colorBox.Size = UDim2.new(0, 30, 0, 15)
    colorBox.Position = UDim2.new(1, 0, 0.5, 0)
    colorBox.AnchorPoint = Vector2.new(1, 0.5)
    colorBox.BackgroundColor3 = colorpicker.color
    colorBox.BorderSizePixel = 0
    colorBox.Parent = colorpickerFrame
    local colorBoxCorner = Instance.new("UICorner")
    colorBoxCorner.CornerRadius = UDim.new(0, 4)
    colorBoxCorner.Parent = colorBox
    local colorBoxStroke = Instance.new("UIStroke")
    colorBoxStroke.Color = theme.Accent
    colorBoxStroke.Transparency = 0.5
    colorBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    colorBoxStroke.Parent = colorBox
    self:AddToRegistry(colorBoxStroke, { Color = 'Accent' })
    local dialogOverlay = Instance.new("Frame")
    dialogOverlay.Name = "DialogOverlay"
    dialogOverlay.Size = UDim2.new(1, 0, 1, 0)
    dialogOverlay.Position = UDim2.new(0, 0, 0, 0)
    dialogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    dialogOverlay.BackgroundTransparency = 0.5
    dialogOverlay.BorderSizePixel = 0
    dialogOverlay.Visible = false
    dialogOverlay.ZIndex = 1000
    dialogOverlay.Parent = self.container
    local overlayCorner = Instance.new("UICorner")
    overlayCorner.CornerRadius = UDim.new(0, 10)
    overlayCorner.Parent = dialogOverlay
    local pickerPopup = Instance.new("Frame")
    pickerPopup.Name = "PickerPopup"
    pickerPopup.Size = UDim2.new(0, 280, 0, 295)
    pickerPopup.Position = UDim2.new(0.5, 0, 0.5, 0)
    pickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
    pickerPopup.BackgroundColor3 = theme.Background
    pickerPopup.BackgroundTransparency = 0.05
    pickerPopup.BorderSizePixel = 0
    pickerPopup.ZIndex = 1001
    pickerPopup.Parent = dialogOverlay
    self:AddToRegistry(pickerPopup, { BackgroundColor3 = 'Background' })
    local popupCorner = Instance.new("UICorner")
    popupCorner.CornerRadius = UDim.new(0, 10)
    popupCorner.Parent = pickerPopup
    local popupStroke = Instance.new("UIStroke")
    popupStroke.Color = theme.Accent
    popupStroke.Transparency = 0.5
    popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    popupStroke.Parent = pickerPopup
    self:AddToRegistry(popupStroke, { Color = 'Accent' })
    local satValFrame = Instance.new("ImageButton")
    satValFrame.Name = "SatVal"
    satValFrame.Size = UDim2.new(0, 200, 0, 150)
    satValFrame.Position = UDim2.new(0, 15, 0, 20)
    satValFrame.BackgroundColor3 = Color3.fromHSV(1, 1, 1)
    satValFrame.BorderSizePixel = 0
    satValFrame.AutoButtonColor = false
    satValFrame.ZIndex = 1002
    satValFrame.Parent = pickerPopup
    local satValCorner = Instance.new("UICorner")
    satValCorner.CornerRadius = UDim.new(0, 6)
    satValCorner.Parent = satValFrame
    local satGradient = Instance.new("UIGradient")
    satGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)), ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))}
    satGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
    satGradient.Parent = satValFrame
    local valOverlay = Instance.new("Frame")
    valOverlay.Name = "ValOverlay"
    valOverlay.Size = UDim2.new(1, 0, 1, 0)
    valOverlay.BackgroundColor3 = Color3.new(0, 0, 0)
    valOverlay.BackgroundTransparency = 1
    valOverlay.BorderSizePixel = 0
    valOverlay.ZIndex = 1003
    valOverlay.Parent = satValFrame
    local valOverlayCorner = Instance.new("UICorner")
    valOverlayCorner.CornerRadius = UDim.new(0, 6)
    valOverlayCorner.Parent = valOverlay
    local valGradient = Instance.new("UIGradient")
    valGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}
    valGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
    valGradient.Rotation = 90
    valGradient.Parent = valOverlay
    local satValCursor = Instance.new("Frame")
    satValCursor.Name = "Cursor"
    satValCursor.Size = UDim2.new(0, 10, 0, 10)
    satValCursor.Position = UDim2.new(1, 0, 0, 0)
    satValCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    satValCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    satValCursor.BorderSizePixel = 0
    satValCursor.ZIndex = 1004
    satValCursor.Parent = satValFrame
    local satValCursorCorner = Instance.new("UICorner")
    satValCursorCorner.CornerRadius = UDim.new(1, 0)
    satValCursorCorner.Parent = satValCursor
    local satValCursorStroke = Instance.new("UIStroke")
    satValCursorStroke.Color = Color3.new(0, 0, 0)
    satValCursorStroke.Thickness = 2
    satValCursorStroke.Parent = satValCursor
    local hueFrame = Instance.new("ImageButton")
    hueFrame.Name = "Hue"
    hueFrame.Size = UDim2.new(0, 30, 0, 150)
    hueFrame.Position = UDim2.new(0, 230, 0, 20)
    hueFrame.BorderSizePixel = 0
    hueFrame.AutoButtonColor = false
    hueFrame.ZIndex = 1002
    hueFrame.Parent = pickerPopup
    local hueCorner = Instance.new("UICorner")
    hueCorner.CornerRadius = UDim.new(0, 6)
    hueCorner.Parent = hueFrame
    local hueGradient = Instance.new("UIGradient")
    hueGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)), ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)), ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)), ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)), ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))}
    hueGradient.Rotation = 90
    hueGradient.Parent = hueFrame
    local hueCursor = Instance.new("Frame")
    hueCursor.Name = "Cursor"
    hueCursor.Size = UDim2.new(1, 6, 0, 6)
    hueCursor.Position = UDim2.new(0.5, 0, 0, 0)
    hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    hueCursor.BackgroundColor3 = Color3.new(1, 1, 1)
    hueCursor.BorderSizePixel = 0
    hueCursor.ZIndex = 1003
    hueCursor.Parent = hueFrame
    local hueCursorCorner = Instance.new("UICorner")
    hueCursorCorner.CornerRadius = UDim.new(0, 3)
    hueCursorCorner.Parent = hueCursor
    local hueCursorStroke = Instance.new("UIStroke")
    hueCursorStroke.Color = Color3.new(0, 0, 0)
    hueCursorStroke.Thickness = 2
    hueCursorStroke.Parent = hueCursor
    local hexLabel = Instance.new("TextLabel")
    hexLabel.Text = "Hex:"
    hexLabel.Font = Enum.Font.GothamBold
    hexLabel.TextSize = 11
    hexLabel.TextColor3 = theme.Text
    hexLabel.TextTransparency = 0.2
    hexLabel.Size = UDim2.new(0, 40, 0, 20)
    hexLabel.Position = UDim2.new(0, 15, 0, 185)
    hexLabel.BackgroundTransparency = 1
    hexLabel.TextXAlignment = Enum.TextXAlignment.Left
    hexLabel.ZIndex = 1002
    hexLabel.Parent = pickerPopup
    self:AddToRegistry(hexLabel, { TextColor3 = 'Text' })
    local hexInput = Instance.new("TextBox")
    hexInput.Name = "HexInput"
    hexInput.Size = UDim2.new(0, 190, 0, 28)
    hexInput.Position = UDim2.new(0, 60, 0, 180)
    hexInput.BackgroundColor3 = theme.Secondary
    hexInput.BackgroundTransparency = 0.5
    hexInput.BorderSizePixel = 0
    hexInput.Font = Enum.Font.GothamBold
    hexInput.TextSize = 11
    hexInput.TextColor3 = theme.Text
    hexInput.Text = "#" .. colorpicker.color:ToHex()
    hexInput.ClearTextOnFocus = false
    hexInput.ZIndex = 1002
    hexInput.Parent = pickerPopup
    self:AddToRegistry(hexInput, { BackgroundColor3 = 'Secondary', TextColor3 = 'Text' })
    local hexInputCorner = Instance.new("UICorner")
    hexInputCorner.CornerRadius = UDim.new(0, 6)
    hexInputCorner.Parent = hexInput
    local rgbLabel = Instance.new("TextLabel")
    rgbLabel.Text = "RGB:"
    rgbLabel.Font = Enum.Font.GothamBold
    rgbLabel.TextSize = 11
    rgbLabel.TextColor3 = theme.Text
    rgbLabel.TextTransparency = 0.2
    rgbLabel.Size = UDim2.new(0, 40, 0, 20)
    rgbLabel.Position = UDim2.new(0, 15, 0, 220)
    rgbLabel.BackgroundTransparency = 1
    rgbLabel.TextXAlignment = Enum.TextXAlignment.Left
    rgbLabel.ZIndex = 1002
    rgbLabel.Parent = pickerPopup
    self:AddToRegistry(rgbLabel, { TextColor3 = 'Text' })
    local rgbDisplay = Instance.new("TextLabel")
    rgbDisplay.Name = "RGBDisplay"
    rgbDisplay.Text = string.format("%d, %d, %d", math.floor(colorpicker.color.R * 255), math.floor(colorpicker.color.G * 255), math.floor(colorpicker.color.B * 255))
    rgbDisplay.Font = Enum.Font.GothamBold
    rgbDisplay.TextSize = 11
    rgbDisplay.TextColor3 = theme.Text
    rgbDisplay.TextTransparency = 0.2
    rgbDisplay.Size = UDim2.new(0, 190, 0, 28)
    rgbDisplay.Position = UDim2.new(0, 60, 0, 215)
    rgbDisplay.BackgroundColor3 = theme.Secondary
    rgbDisplay.BackgroundTransparency = 0.5
    rgbDisplay.BorderSizePixel = 0
    rgbDisplay.ZIndex = 1002
    rgbDisplay.Parent = pickerPopup
    self:AddToRegistry(rgbDisplay, { BackgroundColor3 = 'Secondary', TextColor3 = 'Text' })
    local rgbDisplayCorner = Instance.new("UICorner")
    rgbDisplayCorner.CornerRadius = UDim.new(0, 6)
    rgbDisplayCorner.Parent = rgbDisplay
    local doneButton = Instance.new("TextButton")
    doneButton.Name = "Done"
    doneButton.Size = UDim2.new(0, 120, 0, 30)
    doneButton.Position = UDim2.new(0, 15, 0, 255)
    doneButton.BackgroundColor3 = theme.Primary
    doneButton.BackgroundTransparency = 0.3
    doneButton.BorderSizePixel = 0
    doneButton.Font = Enum.Font.GothamBold
    doneButton.TextSize = 12
    doneButton.TextColor3 = theme.Text
    doneButton.Text = "Done"
    doneButton.AutoButtonColor = false
    doneButton.ZIndex = 1002
    doneButton.Parent = pickerPopup
    self:AddToRegistry(doneButton, { BackgroundColor3 = 'Primary', TextColor3 = 'Text' })
    local doneCorner = Instance.new("UICorner")
    doneCorner.CornerRadius = UDim.new(0, 6)
    doneCorner.Parent = doneButton
    local cancelButton = Instance.new("TextButton")
    cancelButton.Name = "Cancel"
    cancelButton.Size = UDim2.new(0, 120, 0, 30)
    cancelButton.Position = UDim2.new(0, 145, 0, 255)
    cancelButton.BackgroundColor3 = theme.Accent
    cancelButton.BackgroundTransparency = 0.5
    cancelButton.BorderSizePixel = 0
    cancelButton.Font = Enum.Font.GothamBold
    cancelButton.TextSize = 12
    cancelButton.TextColor3 = theme.Text
    cancelButton.Text = "Cancel"
    cancelButton.AutoButtonColor = false
    cancelButton.ZIndex = 1002
    cancelButton.Parent = pickerPopup
    self:AddToRegistry(cancelButton, { BackgroundColor3 = 'Accent', TextColor3 = 'Text' })
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 6)
    cancelCorner.Parent = cancelButton
    local h, s, v = colorpicker.color:ToHSV()
    colorpicker.hue = h
    colorpicker.sat = s
    colorpicker.val = v
    colorpicker.Value = colorpicker.color
    colorpicker.Transparency = colorpicker.transparency
    colorpicker.tempColor = colorpicker.color
    local function UpdateColor(updateCallback)
        local newColor = Color3.fromHSV(colorpicker.hue, colorpicker.sat, colorpicker.val)
        colorpicker.tempColor = newColor
        colorBox.BackgroundColor3 = newColor
        satValFrame.BackgroundColor3 = Color3.fromHSV(colorpicker.hue, 1, 1)
        hexInput.Text = "#" .. newColor:ToHex()
        rgbDisplay.Text = string.format("%d, %d, %d", math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255))
        satValCursor.Position = UDim2.new(colorpicker.sat, 0, 1 - colorpicker.val, 0)
        hueCursor.Position = UDim2.new(0.5, 0, colorpicker.hue, 0)
        if updateCallback then
            colorpicker.color = newColor
            colorpicker.Value = newColor
            task.spawn(function() colorpicker.callback(newColor) end)
        end
    end
    colorpicker.SetValue = function(self2, color)
        local hue, sat, val = color:ToHSV()
        colorpicker.hue = hue
        colorpicker.sat = sat
        colorpicker.val = val
        colorpicker.color = color
        colorpicker.Value = color
        UpdateColor(false)
    end
    colorpicker.SetValueRGB = function(self2, color, transparency)
        colorpicker:SetValue(color)
        colorpicker.transparency = transparency or 0
        colorpicker.Transparency = colorpicker.transparency
    end
    local draggingSatVal = false
    local draggingHue = false
    satValFrame.MouseButton1Down:Connect(function()
        draggingSatVal = true
        local mouse = Players.LocalPlayer:GetMouse()
        local function Update()
            local relX = math.clamp((mouse.X - satValFrame.AbsolutePosition.X) / satValFrame.AbsoluteSize.X, 0, 1)
            local relY = math.clamp((mouse.Y - satValFrame.AbsolutePosition.Y) / satValFrame.AbsoluteSize.Y, 0, 1)
            colorpicker.sat = relX
            colorpicker.val = 1 - relY
            UpdateColor(false)
        end
        Update()
        local moveConn = mouse.Move:Connect(Update)
        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSatVal = false
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    hueFrame.MouseButton1Down:Connect(function()
        draggingHue = true
        local mouse = Players.LocalPlayer:GetMouse()
        local function Update()
            local relY = math.clamp((mouse.Y - hueFrame.AbsolutePosition.Y) / hueFrame.AbsoluteSize.Y, 0, 1)
            colorpicker.hue = relY
            UpdateColor(false)
        end
        Update()
        local moveConn = mouse.Move:Connect(Update)
        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingHue = false
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
    hexInput.FocusLost:Connect(function()
        local text = hexInput.Text:gsub("#", "")
        local success, color = pcall(function() return Color3.fromHex(text) end)
        if success then
            local hue, sat, val = color:ToHSV()
            colorpicker.hue = hue
            colorpicker.sat = sat
            colorpicker.val = val
            UpdateColor(false)
        else
            hexInput.Text = "#" .. colorpicker.tempColor:ToHex()
        end
    end)
    doneButton.MouseEnter:Connect(function() Tween(doneButton, {BackgroundTransparency = 0.1}, 0.2) end)
    doneButton.MouseLeave:Connect(function() Tween(doneButton, {BackgroundTransparency = 0.3}, 0.2) end)
    doneButton.MouseButton1Click:Connect(function()
        colorpicker.color = colorpicker.tempColor
        colorpicker.Value = colorpicker.tempColor
        task.spawn(function() colorpicker.callback(colorpicker.tempColor) end)
        colorpicker.open = false
        dialogOverlay.Visible = false
    end)
    cancelButton.MouseEnter:Connect(function() Tween(cancelButton, {BackgroundTransparency = 0.3}, 0.2) end)
    cancelButton.MouseLeave:Connect(function() Tween(cancelButton, {BackgroundTransparency = 0.5}, 0.2) end)
    cancelButton.MouseButton1Click:Connect(function()
        local hue, sat, val = colorpicker.color:ToHSV()
        colorpicker.hue = hue
        colorpicker.sat = sat
        colorpicker.val = val
        UpdateColor(false)
        colorpicker.open = false
        dialogOverlay.Visible = false
    end)
    colorpickerFrame.MouseButton1Click:Connect(function()
        colorpicker.open = not colorpicker.open
        dialogOverlay.Visible = colorpicker.open
        if colorpicker.open then
            UpdateColor(false)
        end
    end)
    dialogOverlay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local hue, sat, val = colorpicker.color:ToHSV()
            colorpicker.hue = hue
            colorpicker.sat = sat
            colorpicker.val = val
            UpdateColor(false)
            colorpicker.open = false
            dialogOverlay.Visible = false
        end
    end)
    UpdateColor(false)
    colorpicker.frame = colorpickerFrame
    Options[colorpicker.flag] = colorpicker
    table.insert(module.elements, colorpicker)
    return colorpicker
end

function Library:CreateKeybind(module, options)
    options = options or {}
    local keybind = {}
    keybind.title = options.title or "Keybind"
    keybind.flag = options.flag or keybind.title
    keybind.callback = options.callback or function() end
    keybind.Type = 'KeyPicker'
    keybind.Mode = options.mode or 'Toggle'
    module.elementHeight = module.elementHeight + 26
    local theme = self.currentTheme
    local existingValue = Options[keybind.flag] and Options[keybind.flag].Value
    keybind.key = existingValue or options.default or nil
    local keybindFrame = Instance.new("TextButton")
    keybindFrame.Name = "Keybind"
    keybindFrame.Size = UDim2.new(0, 207, 0, 22)
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
    local keyBox = Instance.new("Frame")
    keyBox.Name = "KeyBox"
    keyBox.Size = UDim2.new(0, 50, 0, 18)
    keyBox.Position = UDim2.new(1, 0, 0.5, 0)
    keyBox.AnchorPoint = Vector2.new(1, 0.5)
    keyBox.BackgroundColor3 = theme.Primary
    keyBox.BackgroundTransparency = 0.7
    keyBox.BorderSizePixel = 0
    keyBox.Parent = keybindFrame
    self:AddToRegistry(keyBox, { BackgroundColor3 = 'Primary' })
    local keyBoxCorner = Instance.new("UICorner")
    keyBoxCorner.CornerRadius = UDim.new(0, 4)
    keyBoxCorner.Parent = keyBox
    local keyLabel = Instance.new("TextLabel")
    keyLabel.Text = keybind.key and keybind.key:gsub("Enum.KeyCode.", "") or "None"
    keyLabel.Font = Enum.Font.GothamBold
    keyLabel.TextSize = 10
    keyLabel.TextColor3 = theme.Text
    keyLabel.TextTransparency = 0.2
    keyLabel.Size = UDim2.new(1, -4, 1, 0)
    keyLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    keyLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    keyLabel.BackgroundTransparency = 1
    keyLabel.Parent = keyBox
    self:AddToRegistry(keyLabel, { TextColor3 = 'Text' })
    keybind.Value = keybind.key
    keybind.SetValue = function(self2, key)
        keybind.key = key
        keybind.Value = key
        keyLabel.Text = key and key:gsub("Enum.KeyCode.", "") or "None"
        local width = math.max(50, GetTextWidth(keyLabel.Text, 10, Enum.Font.GothamBold) + 16)
        keyBox.Size = UDim2.new(0, width, 0, 18)
    end
    keybindFrame.MouseButton1Click:Connect(function()
        if self.choosingKeybind then return end
        self.choosingKeybind = true
        keyLabel.Text = "..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            if input.KeyCode == Enum.KeyCode.Unknown then return end
            connection:Disconnect()
            self.choosingKeybind = false
            if input.KeyCode == Enum.KeyCode.Backspace then
                keybind:SetValue(nil)
                task.spawn(function() keybind.callback(nil) end)
                return
            end
            local keyStr = tostring(input.KeyCode)
            keybind:SetValue(keyStr)
            task.spawn(function() keybind.callback(keyStr) end)
        end)
    end)
    Options[keybind.flag] = keybind
    keybind.frame = keybindFrame
    table.insert(module.elements, keybind)
    return keybind
end

function Library:CreateLabel(module, options)
    options = options or {}
    local label = {}
    label.title = options.title or options.text or "Label"
    label.flag = options.flag or label.title
    label.Type = 'Label'
    
    module.elementHeight = module.elementHeight + 42
    
    local theme = self.currentTheme
    
    -- Container Frame
    local TextFrame = Instance.new('Frame')
    TextFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    TextFrame.BackgroundTransparency = 0.1
    TextFrame.Size = UDim2.new(0, 207, 0, 42)
    TextFrame.BorderSizePixel = 0
    TextFrame.Name = "Label"
    TextFrame.AutomaticSize = Enum.AutomaticSize.Y
    TextFrame.Parent = module.optionsFrame
    
    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = TextFrame
    
    -- Body Text
    local Body = Instance.new('TextLabel')
    Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Body.TextColor3 = Color3.fromRGB(180, 180, 180)
    Body.Text = label.title
    Body.Size = UDim2.new(1, -10, 1, 0)
    Body.Position = UDim2.new(0, 5, 0, 5)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Center
    Body.TextYAlignment = Enum.TextYAlignment.Center
    Body.TextSize = 11
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = TextFrame
    
    -- Hover effect
    TextFrame.MouseEnter:Connect(function()
        Tween(TextFrame, {BackgroundColor3 = Color3.fromRGB(42, 50, 66)}, 0.3)
    end)
    
    TextFrame.MouseLeave:Connect(function()
        Tween(TextFrame, {BackgroundColor3 = Color3.fromRGB(32, 38, 51)}, 0.3)
    end)
    
    label.Value = label.title
    label.SetValue = function(self2, text)
        label.title = text
        label.Value = text
        Body.Text = text
    end
    
    label.SetText = function(self2, text)
        label.title = text
        label.Value = text
        Body.Text = text
    end
    
    Options[label.flag] = label
    table.insert(module.elements, label)
    return label
end

function Library:CreateDivider(module, options)
    options = options or {}
    local divider = {}
    divider.title = options.title or ""
    divider.show_title = options.show_title or false
    divider.show_line = options.show_line ~= false
    divider.Type = 'Divider'
    
    module.elementHeight = module.elementHeight + 27
    
    local theme = self.currentTheme
    
    local dividerHeight = 1
    local dividerWidth = 207
    
    -- Create the outer frame to control spacing
    local OuterFrame = Instance.new('Frame')
    OuterFrame.Size = UDim2.new(0, dividerWidth, 0, 20)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Name = 'Divider'
    OuterFrame.Parent = module.optionsFrame
    
    -- Title text if enabled
    if divider.show_title and divider.title ~= "" then
        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextTransparency = 0
        TextLabel.Text = divider.title
        TextLabel.Size = UDim2.new(0, 153, 0, 13)
        TextLabel.Position = UDim2.new(0.5, 0, 0.501, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Center
        TextLabel.BorderSizePixel = 0
        TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.TextSize = 11
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.ZIndex = 3
        TextLabel.TextStrokeTransparency = 0
        TextLabel.Parent = OuterFrame
    end
    
    -- Divider line if enabled
    if divider.show_line then
        local DividerLine = Instance.new('Frame')
        DividerLine.Size = UDim2.new(1, 0, 0, dividerHeight)
        DividerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DividerLine.BorderSizePixel = 0
        DividerLine.Name = 'DividerLine'
        DividerLine.Parent = OuterFrame
        DividerLine.ZIndex = 2
        DividerLine.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2)
        
        -- Add gradient for transparency on edges
        local Gradient = Instance.new('UIGradient')
        Gradient.Parent = DividerLine
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        Gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        Gradient.Rotation = 0
        
        -- Corner radius for smooth edges
        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 2)
        UICorner.Parent = DividerLine
    end
    
    table.insert(module.elements, divider)
    return divider
end

function Library:CreateNotificationContainer()
    if self.notificationGui then return end
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "MarchUI_Notifications"
    notifGui.ResetOnSpawn = false
    notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    notifGui.Parent = CoreGui
    local notifContainer = Instance.new("Frame")
    notifContainer.Name = "Container"
    notifContainer.Size = UDim2.new(0, 300, 1, 0)
    notifContainer.Position = UDim2.new(1, -20, 0, 0)
    notifContainer.AnchorPoint = Vector2.new(1, 0)
    notifContainer.BackgroundTransparency = 1
    notifContainer.Parent = notifGui
    local notifLayout = Instance.new("UIListLayout")
    notifLayout.Padding = UDim.new(0, 8)
    notifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    notifLayout.Parent = notifContainer
    local notifPadding = Instance.new("UIPadding")
    notifPadding.PaddingBottom = UDim.new(0, 20)
    notifPadding.Parent = notifContainer
    self.notificationGui = notifGui
    self.notificationContainer = notifContainer
end
function Library:SendNotification(options)
    self:CreateNotificationContainer()
    local theme = self.currentTheme
    local title = options.title or "Notification"
    local text = options.text or ""
    local duration = options.duration or 3
    local button = options.button -- {text = "Button", callback = function() end}
    
    -- Увеличиваем высоту если есть кнопка
    local notifHeight = button and 85 or 60
    
    local notif = Instance.new("Frame")
    notif.Name = "Notification"
    notif.Size = UDim2.new(0, 280, 0, notifHeight)
    notif.BackgroundColor3 = theme.Secondary
    notif.BackgroundTransparency = 0.1
    notif.BorderSizePixel = 0
    notif.Parent = self.notificationContainer
    self:AddToRegistry(notif, { BackgroundColor3 = 'Secondary' })
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 6)
    notifCorner.Parent = notif
    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = theme.Accent
    notifStroke.Transparency = 0.5
    notifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    notifStroke.Parent = notif
    self:AddToRegistry(notifStroke, { Color = 'Accent' })
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 3, 1, -10)
    accentBar.Position = UDim2.new(0, 5, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = theme.Primary
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notif
    self:AddToRegistry(accentBar, { BackgroundColor3 = 'Primary' })
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.TextColor3 = theme.Primary
    titleLabel.TextTransparency = 0.1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Size = UDim2.new(1, -25, 0, 16)
    titleLabel.Position = UDim2.new(0, 15, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Parent = notif
    self:AddToRegistry(titleLabel, { TextColor3 = 'Primary' })
    local textLabel = Instance.new("TextLabel")
    textLabel.Text = text
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 11
    textLabel.TextColor3 = theme.Text
    textLabel.TextTransparency = 0.3
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.Size = UDim2.new(1, -25, 0, 30)
    textLabel.Position = UDim2.new(0, 15, 0, 28)
    textLabel.BackgroundTransparency = 1
    textLabel.Parent = notif
    self:AddToRegistry(textLabel, { TextColor3 = 'Text' })
    
    -- Кнопка в нотификации
    local notifButton = nil
    if button then
        notifButton = Instance.new("TextButton")
        notifButton.Name = "ActionButton"
        notifButton.Text = button.text or "Action"
        notifButton.Font = Enum.Font.GothamBold
        notifButton.TextSize = 11
        notifButton.TextColor3 = theme.Text
        notifButton.Size = UDim2.new(0, 80, 0, 22)
        notifButton.Position = UDim2.new(0, 15, 1, -28)
        notifButton.BackgroundColor3 = theme.Primary
        notifButton.BackgroundTransparency = 0.3
        notifButton.BorderSizePixel = 0
        notifButton.AutoButtonColor = false
        notifButton.Parent = notif
        self:AddToRegistry(notifButton, { BackgroundColor3 = 'Primary', TextColor3 = 'Text' })
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = notifButton
        
        -- Hover эффект
        notifButton.MouseEnter:Connect(function()
            Tween(notifButton, {BackgroundTransparency = 0.1}, 0.2)
        end)
        notifButton.MouseLeave:Connect(function()
            Tween(notifButton, {BackgroundTransparency = 0.3}, 0.2)
        end)
        
        -- Callback при нажатии
        notifButton.MouseButton1Click:Connect(function()
            if button.callback then
                task.spawn(button.callback)
            end
            -- Закрываем нотификацию после нажатия
            Tween(notif, {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
            task.wait(0.3)
            self:RemoveFromRegistry(notif)
            self:RemoveFromRegistry(notifStroke)
            self:RemoveFromRegistry(accentBar)
            self:RemoveFromRegistry(titleLabel)
            self:RemoveFromRegistry(textLabel)
            if notifButton then self:RemoveFromRegistry(notifButton) end
            notif:Destroy()
        end)
    end
    
    notif.Position = UDim2.new(1, 0, 0, 0)
    Tween(notif, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)
    task.delay(duration, function()
        if not notif.Parent then return end -- Уже удалена кнопкой
        Tween(notif, {Position = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        task.wait(0.3)
        self:RemoveFromRegistry(notif)
        self:RemoveFromRegistry(notifStroke)
        self:RemoveFromRegistry(accentBar)
        self:RemoveFromRegistry(titleLabel)
        self:RemoveFromRegistry(textLabel)
        if notifButton then self:RemoveFromRegistry(notifButton) end
        notif:Destroy()
    end)
end

function Library:CreateWatermark()
    if self.watermark then return end
    local oldWatermark = CoreGui:FindFirstChild("MarchUI_Watermark")
    if oldWatermark then oldWatermark:Destroy() end
    local theme = self.currentTheme
    local watermarkGui = Instance.new("ScreenGui")
    watermarkGui.Name = "MarchUI_Watermark"
    watermarkGui.ResetOnSpawn = false
    watermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    watermarkGui.Parent = CoreGui
    local watermark = Instance.new("ImageButton")
    watermark.Name = "Watermark"
    watermark.Size = UDim2.new(0, 32, 0, 32)
    watermark.Position = UDim2.new(0.5, -16, 0, 10)
    watermark.AnchorPoint = Vector2.new(0.5, 0)
    watermark.BackgroundColor3 = theme.Background
    watermark.BackgroundTransparency = 0.1
    watermark.BorderSizePixel = 0
    watermark.Visible = false
    watermark.AutoButtonColor = false
    watermark.Image = "rbxassetid://107819132007001"
    watermark.ImageColor3 = theme.Primary
    watermark.ScaleType = Enum.ScaleType.Fit
    watermark.Parent = watermarkGui
    self:AddToRegistry(watermark, { BackgroundColor3 = 'Background', ImageColor3 = 'Primary' })
    local watermarkCorner = Instance.new("UICorner")
    watermarkCorner.CornerRadius = UDim.new(0, 6)
    watermarkCorner.Parent = watermark
    local watermarkStroke = Instance.new("UIStroke")
    watermarkStroke.Color = theme.Accent
    watermarkStroke.Transparency = 0.5
    watermarkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    watermarkStroke.Parent = watermark
    self:AddToRegistry(watermarkStroke, { Color = 'Accent' })
    local iconGradient = Instance.new("UIGradient")
    local primaryBright = Color3.new(
        math.min(theme.Primary.R + 0.3, 1),
        math.min(theme.Primary.G + 0.3, 1),
        math.min(theme.Primary.B + 0.3, 1)
    )
    local accentBright = Color3.new(
        math.min(theme.Accent.R + 0.4, 1),
        math.min(theme.Accent.G + 0.4, 1),
        math.min(theme.Accent.B + 0.4, 1)
    )
    iconGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, primaryBright),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, accentBright)
    }
    iconGradient.Parent = watermark
    task.spawn(function()
        while watermark and watermark.Parent and not self.unloading do
            for i = 0, 360, 2 do
                if not watermark or not watermark.Parent or self.unloading then break end
                iconGradient.Rotation = i
                task.wait(0.03)
            end
        end
    end)
    watermark.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    watermark.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = watermark.Position
        end
    end)
    watermark.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            Tween(watermark, {Position = newPos}, 0.1)
        end
    end)
    self.watermark = watermarkGui
    self.watermarkFrame = watermark
end
function Library:ToggleUI()
    self.uiVisible = not self.uiVisible
    if self.container then
        self.container.Visible = self.uiVisible
    end
    if self.watermarkFrame then
        self.watermarkFrame.Visible = not self.uiVisible
    end
end
function Library:CreateLabel(module, options)
    options = options or {}
    local label = {}
    label.title = options.title or options.text or "Label"
    label.flag = options.flag or label.title
    label.Type = 'Label'
    
    module.elementHeight = module.elementHeight + 42
    
    local theme = self.currentTheme
    
    -- Container Frame
    local TextFrame = Instance.new('Frame')
    TextFrame.BackgroundColor3 = Color3.fromRGB(32, 38, 51)
    TextFrame.BackgroundTransparency = 0.1
    TextFrame.Size = UDim2.new(0, 207, 0, 36)
    TextFrame.BorderSizePixel = 0
    TextFrame.Name = "Label"
    TextFrame.AutomaticSize = Enum.AutomaticSize.Y
    TextFrame.Parent = module.optionsFrame
    
    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = TextFrame
    
    -- Body Text
    local Body = Instance.new('TextLabel')
    Body.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    Body.TextColor3 = Color3.fromRGB(180, 180, 180)
    Body.Text = label.title
    Body.Size = UDim2.new(1, -10, 1, 0)
    Body.Position = UDim2.new(0, 5, 0, 5)
    Body.BackgroundTransparency = 1
    Body.TextXAlignment = Enum.TextXAlignment.Center
    Body.TextYAlignment = Enum.TextYAlignment.Center
    Body.TextSize = 11
    Body.TextWrapped = true
    Body.AutomaticSize = Enum.AutomaticSize.Y
    Body.Parent = TextFrame
    
    -- Hover effect
    TextFrame.MouseEnter:Connect(function()
        Tween(TextFrame, {BackgroundColor3 = Color3.fromRGB(42, 50, 66)}, 0.3)
    end)
    
    TextFrame.MouseLeave:Connect(function()
        Tween(TextFrame, {BackgroundColor3 = Color3.fromRGB(32, 38, 51)}, 0.3)
    end)
    
    label.Value = label.title
    label.SetValue = function(self2, text)
        label.title = text
        label.Value = text
        Body.Text = text
    end
    
    label.SetText = function(self2, text)
        label.title = text
        label.Value = text
        Body.Text = text
    end
    
    Options[label.flag] = label
    table.insert(module.elements, label)
    return label
end

function Library:CreateDivider(module, options)
    options = options or {}
    local divider = {}
    divider.title = options.title or ""
    divider.show_title = options.show_title or false
    divider.show_line = options.show_line ~= false
    divider.Type = 'Divider'
    
    module.elementHeight = module.elementHeight + 27
    
    local theme = self.currentTheme
    
    local dividerHeight = 1
    local dividerWidth = 207
    
    -- Create the outer frame to control spacing
    local OuterFrame = Instance.new('Frame')
    OuterFrame.Size = UDim2.new(0, dividerWidth, 0, 20)
    OuterFrame.BackgroundTransparency = 1
    OuterFrame.Name = 'Divider'
    OuterFrame.Parent = module.optionsFrame
    
    -- Title text if enabled
    if divider.show_title and divider.title ~= "" then
        local TextLabel = Instance.new('TextLabel')
        TextLabel.FontFace = Font.new('rbxasset://fonts/families/GothamSSm.json', Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextTransparency = 0
        TextLabel.Text = divider.title
        TextLabel.Size = UDim2.new(0, 153, 0, 13)
        TextLabel.Position = UDim2.new(0.5, 0, 0.501, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.TextXAlignment = Enum.TextXAlignment.Center
        TextLabel.BorderSizePixel = 0
        TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.TextSize = 11
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.ZIndex = 3
        TextLabel.TextStrokeTransparency = 0
        TextLabel.Parent = OuterFrame
    end
    
    -- Divider line if enabled
    if divider.show_line then
        local DividerLine = Instance.new('Frame')
        DividerLine.Size = UDim2.new(1, 0, 0, dividerHeight)
        DividerLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        DividerLine.BorderSizePixel = 0
        DividerLine.Name = 'DividerLine'
        DividerLine.Parent = OuterFrame
        DividerLine.ZIndex = 2
        DividerLine.Position = UDim2.new(0, 0, 0.5, -dividerHeight / 2)
        
        -- Add gradient for transparency on edges
        local Gradient = Instance.new('UIGradient')
        Gradient.Parent = DividerLine
        Gradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
        })
        Gradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        Gradient.Rotation = 0
        
        -- Corner radius for smooth edges
        local UICorner = Instance.new('UICorner')
        UICorner.CornerRadius = UDim.new(0, 2)
        UICorner.Parent = DividerLine
    end
    
    table.insert(module.elements, divider)
    return divider
end

function Library:Unload()
    self.unloading = true
    task.wait(0.1)
    if self.ui then
        self.ui:Destroy()
        self.ui = nil
    end
    if self.notificationGui then
        self.notificationGui:Destroy()
        self.notificationGui = nil
    end
    if self.watermark then
        self.watermark:Destroy()
        self.watermark = nil
    end
end
return { Library = Library, SaveManager = SaveManager, ThemeManager = ThemeManager, Toggles = Toggles, Options = Options }
