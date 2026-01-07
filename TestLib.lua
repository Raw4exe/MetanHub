-- SimpleUI Library - Minimalist UI Library
-- Clean and simple design without complex effects

local SimpleUI = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Utility Functions
local function Tween(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, dragFrame)
    local dragging = false
    local dragInput, mousePos, framePos

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- Create Window
function SimpleUI:CreateWindow(config)
    local WindowName = config.Name or "SimpleUI"
    local WindowSize = config.Size or UDim2.new(0, 500, 0, 400)
    
    -- Remove old UI
    if CoreGui:FindFirstChild("SimpleUI_" .. WindowName) then
        CoreGui:FindFirstChild("SimpleUI_" .. WindowName):Destroy()
    end
    
    -- Main ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "SimpleUI_" .. WindowName
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = WindowSize
    MainFrame.Position = UDim2.new(0.5, -WindowSize.X.Offset/2, 0.5, -WindowSize.Y.Offset/2)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    -- Title Text
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -50, 1, 0)
    TitleLabel.Position = UDim2.new(0, 15, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = WindowName
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0, 5)
    CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 14
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 6)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        Tween(MainFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
        task.wait(0.3)
        ScreenGui:Destroy()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(220, 70, 70)}, 0.2)
    end)
    
    CloseButton.MouseLeave:Connect(function()
        Tween(CloseButton, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, 0.2)
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 120, 1, -50)
    TabContainer.Position = UDim2.new(0, 5, 0, 45)
    TabContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 6)
    TabCorner.Parent = TabContainer
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 5)
    TabList.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -135, 1, -50)
    ContentContainer.Position = UDim2.new(0, 130, 0, 45)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.Parent = MainFrame
    
    -- Make draggable
    MakeDraggable(MainFrame, TitleBar)
    
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Create Tab
    function Window:CreateTab(name)
        local Tab = {
            Name = name,
            Elements = {}
        }
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Size = UDim2.new(1, -10, 0, 35)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer
        
        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 6)
        TabButtonCorner.Parent = TabButton
        
        local TabLabel = Instance.new("TextLabel")
        TabLabel.Size = UDim2.new(1, -10, 1, 0)
        TabLabel.Position = UDim2.new(0, 10, 0, 0)
        TabLabel.BackgroundTransparency = 1
        TabLabel.Text = name
        TabLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabLabel.TextSize = 14
        TabLabel.Font = Enum.Font.Gotham
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = "TabContent"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 70)
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Padding = UDim.new(0, 8)
        ContentList.SortOrder = Enum.SortOrder.LayoutOrder
        ContentList.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 5)
        ContentPadding.PaddingLeft = UDim.new(0, 5)
        ContentPadding.PaddingRight = UDim.new(0, 5)
        ContentPadding.Parent = TabContent
        
        -- Tab switching
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                Tween(tab.Button.TextLabel, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
            end
            TabContent.Visible = true
            Tween(TabLabel, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            Window.CurrentTab = Tab
        end)
        
        TabButton.MouseEnter:Connect(function()
            if TabContent.Visible then return end
            Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}, 0.2)
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent.Visible then return end
            Tween(TabButton, {BackgroundColor3 = Color3.fromRGB(30, 30, 35)}, 0.2)
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- Toggle
        function Tab:CreateToggle(config)
            local Toggle = {
                Name = config.Name or "Toggle",
                Value = config.Default or false,
                Callback = config.Callback or function() end
            }
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = Toggle.Name
            ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleLabel.TextSize = 13
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            
            local ToggleButtonCorner = Instance.new("UICorner")
            ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
            ToggleButtonCorner.Parent = ToggleButton
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
            ToggleCircle.Position = UDim2.new(0, 2, 0.5, -8)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = ToggleCircle
            
            function Toggle:Set(value)
                Toggle.Value = value
                if value then
                    Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(100, 150, 255)}, 0.2)
                    Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
                else
                    Tween(ToggleButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}, 0.2)
                    Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
                end
                Toggle.Callback(value)
            end
            
            ToggleButton.MouseButton1Click:Connect(function()
                Toggle:Set(not Toggle.Value)
            end)
            
            if Toggle.Value then
                Toggle:Set(true)
            end
            
            table.insert(Tab.Elements, Toggle)
            return Toggle
        end
        
        -- Button
        function Tab:CreateButton(config)
            local Button = {
                Name = config.Name or "Button",
                Callback = config.Callback or function() end
            }
            
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Name = "Button"
            ButtonFrame.Size = UDim2.new(1, -10, 0, 35)
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(60, 100, 200)
            ButtonFrame.BorderSizePixel = 0
            ButtonFrame.Text = ""
            ButtonFrame.AutoButtonColor = false
            ButtonFrame.Parent = TabContent
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame
            
            local ButtonLabel = Instance.new("TextLabel")
            ButtonLabel.Size = UDim2.new(1, 0, 1, 0)
            ButtonLabel.BackgroundTransparency = 1
            ButtonLabel.Text = Button.Name
            ButtonLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonLabel.TextSize = 13
            ButtonLabel.Font = Enum.Font.GothamBold
            ButtonLabel.Parent = ButtonFrame
            
            ButtonFrame.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(80, 120, 220)}, 0.1)
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(60, 100, 200)}, 0.1)
                Button.Callback()
            end)
            
            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(70, 110, 210)}, 0.2)
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(60, 100, 200)}, 0.2)
            end)
            
            table.insert(Tab.Elements, Button)
            return Button
        end
        
        -- Slider
        function Tab:CreateSlider(config)
            local Slider = {
                Name = config.Name or "Slider",
                Min = config.Min or 0,
                Max = config.Max or 100,
                Default = config.Default or 50,
                Value = config.Default or 50,
                Callback = config.Callback or function() end
            }
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = "Slider"
            SliderFrame.Size = UDim2.new(1, -10, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -20, 0, 20)
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Text = Slider.Name
            SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderLabel.TextSize = 13
            SliderLabel.Font = Enum.Font.Gotham
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderFrame
            
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Size = UDim2.new(0, 50, 0, 20)
            SliderValue.Position = UDim2.new(1, -60, 0, 5)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(Slider.Value)
            SliderValue.TextColor3 = Color3.fromRGB(200, 200, 200)
            SliderValue.TextSize = 12
            SliderValue.Font = Enum.Font.Gotham
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = SliderFrame
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 1, -15)
            SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = SliderFrame
            
            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(1, 0)
            SliderBarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.new(0.5, 0, 1, 0)
            SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            local dragging = false
            
            function Slider:Set(value)
                Slider.Value = math.clamp(value, Slider.Min, Slider.Max)
                local percent = (Slider.Value - Slider.Min) / (Slider.Max - Slider.Min)
                SliderValue.Text = tostring(Slider.Value)
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                Slider.Callback(Slider.Value)
            end
            
            local function updateSlider(input)
                local pos = (input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X
                pos = math.clamp(pos, 0, 1)
                local value = math.floor(Slider.Min + (Slider.Max - Slider.Min) * pos)
                Slider:Set(value)
            end
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateSlider(input)
                end
            end)
            
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateSlider(input)
                end
            end)
            
            Slider:Set(Slider.Default)
            
            table.insert(Tab.Elements, Slider)
            return Slider
        end
        
        -- Dropdown
        function Tab:CreateDropdown(config)
            local Dropdown = {
                Name = config.Name or "Dropdown",
                Options = config.Options or {},
                Default = config.Default or "",
                Value = config.Default or "",
                Callback = config.Callback or function() end,
                Open = false
            }
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown"
            DropdownFrame.Size = UDim2.new(1, -10, 0, 35)
            DropdownFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabContent
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 35)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = DropdownFrame
            
            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Size = UDim2.new(1, -50, 0, 35)
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Text = Dropdown.Name .. ": " .. Dropdown.Value
            DropdownLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownLabel.TextSize = 13
            DropdownLabel.Font = Enum.Font.Gotham
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            DropdownLabel.Parent = DropdownFrame
            
            local DropdownArrow = Instance.new("TextLabel")
            DropdownArrow.Size = UDim2.new(0, 20, 0, 35)
            DropdownArrow.Position = UDim2.new(1, -30, 0, 0)
            DropdownArrow.BackgroundTransparency = 1
            DropdownArrow.Text = "▼"
            DropdownArrow.TextColor3 = Color3.fromRGB(200, 200, 200)
            DropdownArrow.TextSize = 12
            DropdownArrow.Font = Enum.Font.Gotham
            DropdownArrow.Parent = DropdownFrame
            
            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Size = UDim2.new(1, 0, 0, 0)
            OptionsContainer.Position = UDim2.new(0, 0, 0, 35)
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Parent = DropdownFrame
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsList.Parent = OptionsContainer
            
            function Dropdown:Set(value)
                Dropdown.Value = value
                DropdownLabel.Text = Dropdown.Name .. ": " .. value
                Dropdown.Callback(value)
            end
            
            function Dropdown:Toggle()
                Dropdown.Open = not Dropdown.Open
                if Dropdown.Open then
                    local height = 35 + (#Dropdown.Options * 30)
                    Tween(DropdownFrame, {Size = UDim2.new(1, -10, 0, height)}, 0.2)
                    Tween(DropdownArrow, {Rotation = 180}, 0.2)
                else
                    Tween(DropdownFrame, {Size = UDim2.new(1, -10, 0, 35)}, 0.2)
                    Tween(DropdownArrow, {Rotation = 0}, 0.2)
                end
            end
            
            for _, option in ipairs(Dropdown.Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = ""
                OptionButton.AutoButtonColor = false
                OptionButton.Parent = OptionsContainer
                
                local OptionLabel = Instance.new("TextLabel")
                OptionLabel.Size = UDim2.new(1, -20, 1, 0)
                OptionLabel.Position = UDim2.new(0, 10, 0, 0)
                OptionLabel.BackgroundTransparency = 1
                OptionLabel.Text = option
                OptionLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                OptionLabel.TextSize = 12
                OptionLabel.Font = Enum.Font.Gotham
                OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                OptionLabel.Parent = OptionButton
                
                OptionButton.MouseButton1Click:Connect(function()
                    Dropdown:Set(option)
                    Dropdown:Toggle()
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}, 0.2)
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}, 0.2)
                end)
            end
            
            DropdownButton.MouseButton1Click:Connect(function()
                Dropdown:Toggle()
            end)
            
            table.insert(Tab.Elements, Dropdown)
            return Dropdown
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            TabContent.Visible = true
            TabLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    return Window
end

return SimpleUI
