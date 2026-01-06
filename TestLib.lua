-- METAN UI Library - Minimalist Design
-- Created with clean aesthetics in mind

local lib = {}
local tabs = {}
local pages = {}

local function tween(obj, props, time)
    game:GetService("TweenService"):Create(obj, TweenInfo.new(time or 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

function lib:Create(title)
    local gui = Instance.new("ScreenGui")
    if syn then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui.Parent = gethui()
    else
        gui.Parent = game:GetService("CoreGui")
    end
    gui.Name = "MetanUI"
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Main Frame
    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Parent = gui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    main.BorderSizePixel = 0
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    main.Size = UDim2.new(0, 550, 0, 350)
    main.ClipsDescendants = true
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = main
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(40, 40, 40)
    mainStroke.Thickness = 1
    mainStroke.Parent = main
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.1)
        end
    end)
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Parent = main
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, 45)
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = header
    
    local headerFix = Instance.new("Frame")
    headerFix.Parent = header
    headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    headerFix.BorderSizePixel = 0
    headerFix.Position = UDim2.new(0, 0, 0.7, 0)
    headerFix.Size = UDim2.new(1, 0, 0.3, 0)
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = header
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 20, 0, 0)
    titleLabel.Size = UDim2.new(0, 200, 1, 0)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title or "METAN"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Parent = header
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    closeBtn.Position = UDim2.new(1, -15, 0.5, 0)
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.AutoButtonColor = false
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    closeBtn.TextSize = 20
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(1, 0)
    closeBtnCorner.Parent = closeBtn
    
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(255, 60, 60)})
        tween(closeBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)})
    end)
    
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
        tween(closeBtn, {TextColor3 = Color3.fromRGB(200, 200, 200)})
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    -- Minimize Button
    local minBtn = Instance.new("TextButton")
    minBtn.Name = "Minimize"
    minBtn.Parent = header
    minBtn.AnchorPoint = Vector2.new(1, 0.5)
    minBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    minBtn.Position = UDim2.new(1, -50, 0.5, 0)
    minBtn.Size = UDim2.new(0, 28, 0, 28)
    minBtn.AutoButtonColor = false
    minBtn.Font = Enum.Font.GothamBold
    minBtn.Text = "−"
    minBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minBtn.TextSize = 18
    
    local minBtnCorner = Instance.new("UICorner")
    minBtnCorner.CornerRadius = UDim.new(1, 0)
    minBtnCorner.Parent = minBtn
    
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
    end)
    
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
    end)
    
    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Parent = main
    sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0, 0, 0, 45)
    sidebar.Size = UDim2.new(0, 140, 1, -45)
    
    local sidebarList = Instance.new("UIListLayout")
    sidebarList.Parent = sidebar
    sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    sidebarList.Padding = UDim.new(0, 5)
    
    local sidebarPadding = Instance.new("UIPadding")
    sidebarPadding.Parent = sidebar
    sidebarPadding.PaddingTop = UDim.new(0, 10)
    sidebarPadding.PaddingLeft = UDim.new(0, 10)
    sidebarPadding.PaddingRight = UDim.new(0, 10)
    
    -- Content Area
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Parent = main
    content.BackgroundTransparency = 1
    content.Position = UDim2.new(0, 140, 0, 45)
    content.Size = UDim2.new(1, -140, 1, -45)
    
    -- Minimize Circle
    local minimized = false
    local circle
    
    local function toggleMinimize()
        minimized = not minimized
        if minimized then
            tween(main, {Position = UDim2.new(0.5, 0, 1.5, 0)}, 0.4)
            task.wait(0.4)
            
            circle = Instance.new("Frame")
            circle.Name = "MinCircle"
            circle.Parent = gui
            circle.AnchorPoint = Vector2.new(0.5, 0.5)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Position = UDim2.new(0.92, 0, 0.08, 0)
            circle.Size = UDim2.new(0, 55, 0, 55)
            
            local circleCorner = Instance.new("UICorner")
            circleCorner.CornerRadius = UDim.new(1, 0)
            circleCorner.Parent = circle
            
            local circleStroke = Instance.new("UIStroke")
            circleStroke.Color = Color3.fromRGB(200, 200, 200)
            circleStroke.Thickness = 2
            circleStroke.Parent = circle
            
            local circleText = Instance.new("TextLabel")
            circleText.Parent = circle
            circleText.BackgroundTransparency = 1
            circleText.Size = UDim2.new(1, 0, 1, 0)
            circleText.Font = Enum.Font.GothamBold
            circleText.Text = "M"
            circleText.TextColor3 = Color3.fromRGB(20, 20, 20)
            circleText.TextSize = 26
            
            -- Circle dragging
            local circleDragging, circleDragInput, circleDragStart, circleStartPos
            circle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    circleDragging = true
                    circleDragStart = input.Position
                    circleStartPos = circle.Position
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            circleDragging = false
                        end
                    end)
                end
            end)
            
            circle.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    circleDragInput = input
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == circleDragInput and circleDragging then
                    local delta = input.Position - circleDragStart
                    circle.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
                end
            end)
            
            -- Click to open
            local clickBtn = Instance.new("TextButton")
            clickBtn.Parent = circle
            clickBtn.BackgroundTransparency = 1
            clickBtn.Size = UDim2.new(1, 0, 1, 0)
            clickBtn.Text = ""
            clickBtn.MouseButton1Click:Connect(function()
                toggleMinimize()
            end)
        else
            if circle then
                circle:Destroy()
            end
            tween(main, {Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.4)
        end
    end
    
    minBtn.MouseButton1Click:Connect(toggleMinimize)
    
    -- Keybind
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftControl then
            toggleMinimize()
        end
    end)
    
    -- Show keybind notification
    task.spawn(function()
        task.wait(0.5)
        local notif = Instance.new("Frame")
        notif.Parent = gui
        notif.AnchorPoint = Vector2.new(0.5, 0)
        notif.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        notif.Position = UDim2.new(0.5, 0, 0, 20)
        notif.Size = UDim2.new(0, 320, 0, 60)
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 10)
        notifCorner.Parent = notif
        
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = Color3.fromRGB(60, 60, 60)
        notifStroke.Thickness = 1
        notifStroke.Parent = notif
        
        local notifText = Instance.new("TextLabel")
        notifText.Parent = notif
        notifText.BackgroundTransparency = 1
        notifText.Size = UDim2.new(1, 0, 1, 0)
        notifText.Font = Enum.Font.GothamBold
        notifText.Text = "Press LEFT CONTROL to toggle UI"
        notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
        notifText.TextSize = 14
        
        task.wait(3)
        tween(notif, {Position = UDim2.new(0.5, 0, 0, -80)}, 0.5)
        task.wait(0.5)
        notif:Destroy()
    end)
    
    local window = {}
    
    function window:Tab(name, icon)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name
        tabBtn.Parent = sidebar
        tabBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        tabBtn.BackgroundTransparency = 1
        tabBtn.Size = UDim2.new(1, 0, 0, 38)
        tabBtn.AutoButtonColor = false
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.Text = "    " .. name
        tabBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
        tabBtn.TextSize = 14
        tabBtn.TextXAlignment = Enum.TextXAlignment.Left
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn
        
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "Icon"
        tabIcon.Parent = tabBtn
        tabIcon.BackgroundTransparency = 1
        tabIcon.Position = UDim2.new(0, 8, 0.5, -10)
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.Image = icon or "rbxassetid://4871684504"
        tabIcon.ImageColor3 = Color3.fromRGB(160, 160, 160)
        
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Parent = content
        page.Active = true
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.new(1, 0, 1, 0)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.ScrollBarThickness = 3
        page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
        page.Visible = false
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local pageList = Instance.new("UIListLayout")
        pageList.Parent = page
        pageList.SortOrder = Enum.SortOrder.LayoutOrder
        pageList.Padding = UDim.new(0, 8)
        
        local pagePadding = Instance.new("UIPadding")
        pagePadding.Parent = page
        pagePadding.PaddingTop = UDim.new(0, 15)
        pagePadding.PaddingLeft = UDim.new(0, 15)
        pagePadding.PaddingRight = UDim.new(0, 15)
        pagePadding.PaddingBottom = UDim.new(0, 15)
        
        table.insert(tabs, tabBtn)
        table.insert(pages, page)
        
        tabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                tween(t, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(160, 160, 160)})
                if t:FindFirstChild("Icon") then
                    tween(t.Icon, {ImageColor3 = Color3.fromRGB(160, 160, 160)})
                end
            end
            for _, p in pairs(pages) do
                p.Visible = false
            end
            
            tween(tabBtn, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
            tween(tabIcon, {ImageColor3 = Color3.fromRGB(255, 255, 255)})
            page.Visible = true
        end)
        
        local elements = {}
        
        function elements:Button(text, callback)
            local btn = Instance.new("TextButton")
            btn.Name = "Button"
            btn.Parent = page
            btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.AutoButtonColor = false
            btn.Font = Enum.Font.GothamSemibold
            btn.Text = text
            btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            btn.TextSize = 14
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = btn
            
            local btnStroke = Instance.new("UIStroke")
            btnStroke.Color = Color3.fromRGB(50, 50, 50)
            btnStroke.Thickness = 1
            btnStroke.Parent = btn
            
            btn.MouseEnter:Connect(function()
                tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            end)
            
            btn.MouseLeave:Connect(function()
                tween(btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
            end)
            
            btn.MouseButton1Click:Connect(function()
                tween(btn, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                task.wait(0.1)
                tween(btn, {BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
                if callback then
                    callback()
                end
            end)
        end
        
        function elements:Toggle(text, default, callback)
            local toggled = default or false
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Name = "Toggle"
            toggleFrame.Parent = page
            toggleFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            toggleFrame.Size = UDim2.new(1, 0, 0, 36)
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 8)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Parent = toggleFrame
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Position = UDim2.new(0, 12, 0, 0)
            toggleLabel.Size = UDim2.new(1, -70, 1, 0)
            toggleLabel.Font = Enum.Font.GothamSemibold
            toggleLabel.Text = text
            toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            toggleLabel.TextSize = 14
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local toggleBtn = Instance.new("TextButton")
            toggleBtn.Parent = toggleFrame
            toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
            toggleBtn.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
            toggleBtn.Position = UDim2.new(1, -12, 0.5, 0)
            toggleBtn.Size = UDim2.new(0, 50, 0, 24)
            toggleBtn.AutoButtonColor = false
            toggleBtn.Text = ""
            
            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(1, 0)
            toggleBtnCorner.Parent = toggleBtn
            
            local toggleCircle = Instance.new("Frame")
            toggleCircle.Parent = toggleBtn
            toggleCircle.BackgroundColor3 = toggled and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
            toggleCircle.Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            toggleCircle.Size = UDim2.new(0, 20, 0, 20)
            
            local toggleCircleCorner = Instance.new("UICorner")
            toggleCircleCorner.CornerRadius = UDim.new(1, 0)
            toggleCircleCorner.Parent = toggleCircle
            
            toggleBtn.MouseButton1Click:Connect(function()
                toggled = not toggled
                tween(toggleBtn, {BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)})
                tween(toggleCircle, {
                    Position = toggled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
                    BackgroundColor3 = toggled and Color3.fromRGB(20, 20, 20) or Color3.fromRGB(255, 255, 255)
                })
                if callback then
                    callback(toggled)
                end
            end)
        end
        
        function elements:Input(text, placeholder, callback)
            local inputFrame = Instance.new("Frame")
            inputFrame.Name = "Input"
            inputFrame.Parent = page
            inputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            inputFrame.Size = UDim2.new(1, 0, 0, 36)
            
            local inputCorner = Instance.new("UICorner")
            inputCorner.CornerRadius = UDim.new(0, 8)
            inputCorner.Parent = inputFrame
            
            local inputLabel = Instance.new("TextLabel")
            inputLabel.Parent = inputFrame
            inputLabel.BackgroundTransparency = 1
            inputLabel.Position = UDim2.new(0, 12, 0, 0)
            inputLabel.Size = UDim2.new(0, 120, 1, 0)
            inputLabel.Font = Enum.Font.GothamSemibold
            inputLabel.Text = text
            inputLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            inputLabel.TextSize = 14
            inputLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local inputBox = Instance.new("TextBox")
            inputBox.Parent = inputFrame
            inputBox.AnchorPoint = Vector2.new(1, 0.5)
            inputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            inputBox.Position = UDim2.new(1, -12, 0.5, 0)
            inputBox.Size = UDim2.new(0, 150, 0, 26)
            inputBox.Font = Enum.Font.Gotham
            inputBox.PlaceholderText = placeholder or "Enter text..."
            inputBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            inputBox.Text = ""
            inputBox.TextColor3 = Color3.fromRGB(220, 220, 220)
            inputBox.TextSize = 13
            inputBox.ClearTextOnFocus = false
            
            local inputBoxCorner = Instance.new("UICorner")
            inputBoxCorner.CornerRadius = UDim.new(0, 6)
            inputBoxCorner.Parent = inputBox
            
            local inputBoxStroke = Instance.new("UIStroke")
            inputBoxStroke.Color = Color3.fromRGB(50, 50, 50)
            inputBoxStroke.Thickness = 1
            inputBoxStroke.Parent = inputBox
            
            inputBox.FocusLost:Connect(function()
                if callback then
                    callback(inputBox.Text)
                end
            end)
        end
        
        function elements:Label(text)
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.Parent = page
            label.BackgroundTransparency = 1
            label.Size = UDim2.new(1, 0, 0, 28)
            label.Font = Enum.Font.Gotham
            label.Text = text
            label.TextColor3 = Color3.fromRGB(160, 160, 160)
            label.TextSize = 13
            label.TextWrapped = true
            label.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        function elements:Section(text)
            local section = Instance.new("TextLabel")
            section.Name = "Section"
            section.Parent = page
            section.BackgroundTransparency = 1
            section.Size = UDim2.new(1, 0, 0, 32)
            section.Font = Enum.Font.GothamBold
            section.Text = text
            section.TextColor3 = Color3.fromRGB(220, 220, 220)
            section.TextSize = 15
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.TextYAlignment = Enum.TextYAlignment.Bottom
        end
        
        if #tabs == 1 then
            tabBtn.MouseButton1Click()
        end
        
        return elements
    end
    
    return window
end

return lib
