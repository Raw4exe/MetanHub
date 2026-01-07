
-- vars

local lib = {}
local sections = {}
local workareas = {}
local notifs = {}
local visible = true
local dbcooper = false

local function tp(ins, pos, time, thing)
    game:GetService("TweenService"):Create(ins, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut),{Position = pos}):Play()
end

function lib:init(ti, dosplash, visiblekey, deleteprevious)
    if syn then
        
         cg = game:GetService("CoreGui")
        if cg:FindFirstChild("ScreenGui") and deleteprevious then
           tp(cg.ScreenGui.main, cg.ScreenGui.main.Position + UDim2.new(0,0,2,0), 0.5)
            game:GetService("Debris"):AddItem(cg.ScreenGui, 1)
      end

         -- main
        scrgui = Instance.new("ScreenGui")
        syn.protect_gui(scrgui)
        scrgui.Parent = game:GetService("CoreGui")
    elseif gethui then
        if gethui():FindFirstChild("ScreenGui") and deleteprevious then
            gethui().ScreenGui.main:TweenPosition(gethui().ScreenGui.main.Position + UDim2.new(0,0,2,0), "InOut", "Quart", 0.5)
            game:GetService("Debris"):AddItem(gethui().ScreenGui, 1)
        end

        -- main
         scrgui = Instance.new("ScreenGui")
        scrgui.Parent = gethui()
    else
        cg = game:GetService("CoreGui")
        if cg:FindFirstChild("ScreenGui") and deleteprevious then
            tp(cg.ScreenGui.main, cg.ScreenGui.main.Position + UDim2.new(0,0,2,0), 0.5)
            game:GetService("Debris"):AddItem(cg.ScreenGui, 1)
        end
         scrgui = Instance.new("ScreenGui")
        scrgui.Parent = cg
    end
        
    
    
    

    if dosplash then
        local splash = Instance.new("Frame")
        splash.Name = "splash"
        splash.Parent = scrgui
        splash.AnchorPoint = Vector2.new(0.5, 0.5)
        splash.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        splash.BackgroundTransparency = 0.600
        splash.Position = UDim2.new(0.5, 0, 2, 0)
        splash.Size = UDim2.new(0, 340, 0, 340)
        splash.Visible = true
        splash.ZIndex = 40

        local uc_22 = Instance.new("UICorner")
        uc_22.CornerRadius = UDim.new(0, 18)
        uc_22.Parent = splash

        local sicon = Instance.new("ImageLabel")
        sicon.Name = "sicon"
        sicon.Parent = splash
        sicon.AnchorPoint = Vector2.new(0.5, 0.5)
        sicon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sicon.BackgroundTransparency = 1
        sicon.Position = UDim2.new(0.5, 0, 0.5, 0)
        sicon.Size = UDim2.new(0, 191, 0, 190)
        sicon.ZIndex = 40
        sicon.Image = "rbxassetid://12621719043"
        sicon.ScaleType = Enum.ScaleType.Fit
        sicon.TileSize = UDim2.new(1, 0, 20, 0)

        local ug = Instance.new("UIGradient")
        ug.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(0.01, Color3.fromRGB(61, 61, 61)), ColorSequenceKeypoint.new(0.47, Color3.fromRGB(41, 41, 41)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 0, 0))}
        ug.Rotation = 90
        ug.Parent = sicon

        local sshadow = Instance.new("ImageLabel")
        sshadow.Name = "sshadow"
        sshadow.Parent = splash
        sshadow.AnchorPoint = Vector2.new(0.5, 0.5)
        sshadow.BackgroundTransparency = 1
        sshadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        sshadow.Size = UDim2.new(1.20000005, 0, 1.20000005, 0)
        sshadow.ZIndex = 39
        sshadow.Image = "rbxassetid://313486536"
        sshadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        sshadow.ImageTransparency = 0.400
        sshadow.TileSize = UDim2.new(0, 1, 0, 1)
        splash:TweenPosition(UDim2.new(0.5, 0, 0.5, 0), "InOut", "Quart", 1)
        wait(2)
        splash:TweenPosition(UDim2.new(0.5, 0, 2, 0), "InOut", "Quart", 1)
        game:GetService("Debris"):AddItem(splash, 1)
    end
        

    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = scrgui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    main.BackgroundTransparency = 0
    main.Position = UDim2.new(0.5, 0, 2, 0)
    main.Size = UDim2.new(0, 420, 0, 480)

    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 12)
    uc.Parent = main
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = Color3.fromRGB(44, 58, 66)
    mainStroke.Thickness = 1
    mainStroke.Parent = main
    
    -- Top navigation bar (separate from main window)
    local topNav = Instance.new("Frame")
    topNav.Name = "topNav"
    topNav.Parent = scrgui
    topNav.AnchorPoint = Vector2.new(0.5, 0)
    topNav.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    topNav.BackgroundTransparency = 0
    topNav.Position = UDim2.new(0.5, 0, 0, 10)
    topNav.Size = UDim2.new(0, 100, 0, 50)
    topNav.ZIndex = 5
    topNav.Visible = true
    
    local topNavCorner = Instance.new("UICorner")
    topNavCorner.CornerRadius = UDim.new(0, 12)
    topNavCorner.Parent = topNav
    
    local topNavStroke = Instance.new("UIStroke")
    topNavStroke.Color = Color3.fromRGB(44, 58, 66)
    topNavStroke.Thickness = 1
    topNavStroke.Parent = topNav
    
    local topNavLayout = Instance.new("UIListLayout")
    topNavLayout.Parent = topNav
    topNavLayout.FillDirection = Enum.FillDirection.Horizontal
    topNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    topNavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    topNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    topNavLayout.Padding = UDim.new(0, 8)
    
    local topNavPadding = Instance.new("UIPadding")
    topNavPadding.Parent = topNav
    topNavPadding.PaddingLeft = UDim.new(0, 10)
    topNavPadding.PaddingRight = UDim.new(0, 10)
    topNavPadding.PaddingTop = UDim.new(0, 8)
    topNavPadding.PaddingBottom = UDim.new(0, 8)
    
    -- Auto-resize topNav based on content
    task.spawn(function()
        while topNav and topNav.Parent do
            task.wait(0.1)
            local contentSize = topNavLayout.AbsoluteContentSize.X + 20
            if contentSize > 50 then
                topNav.Size = UDim2.new(0, contentSize, 0, 50)
            end
        end
    end)

    local UserInputService = game:GetService("UserInputService")
    local dragging
    local dragInput
    local dragStart
    local startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    -- Minimize button (dark circle)
    local minimizeCircle = Instance.new("TextButton")
    minimizeCircle.Name = "minimizeCircle"
    minimizeCircle.Parent = scrgui
    minimizeCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeCircle.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    minimizeCircle.BackgroundTransparency = 0
    minimizeCircle.Position = UDim2.new(0.1, 0, 0.1, 0)
    minimizeCircle.Size = UDim2.new(0, 50, 0, 50)
    minimizeCircle.Visible = false
    minimizeCircle.AutoButtonColor = false
    minimizeCircle.Text = ""
    minimizeCircle.ZIndex = 10

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = minimizeCircle
    
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = Color3.fromRGB(44, 58, 66)
    circleStroke.Thickness = 2
    circleStroke.Parent = minimizeCircle

    local circleIcon = Instance.new("TextLabel")
    circleIcon.Name = "icon"
    circleIcon.Parent = minimizeCircle
    circleIcon.BackgroundTransparency = 1
    circleIcon.Size = UDim2.new(1, 0, 1, 0)
    circleIcon.Font = Enum.Font.GothamBold
    circleIcon.Text = "+"
    circleIcon.TextColor3 = Color3.fromRGB(200, 200, 200)
    circleIcon.TextSize = 24
    circleIcon.ZIndex = 11

    -- Dragging for minimize circle
    local circleDragging
    local circleDragInput
    local circleDragStart
    local circleStartPos
    
    local function updateCircle(input)
        local delta = input.Position - circleDragStart
        minimizeCircle.Position = UDim2.new(circleStartPos.X.Scale, circleStartPos.X.Offset + delta.X, circleStartPos.Y.Scale, circleStartPos.Y.Offset + delta.Y)
    end
    
    minimizeCircle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            circleDragging = true
            circleDragStart = input.Position
            circleStartPos = minimizeCircle.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    circleDragging = false
                end
            end)
        end
    end)
    
    minimizeCircle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            circleDragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == circleDragInput and circleDragging then
            updateCircle(input)
        end
    end)

    -- Click animation for minimize circle
    minimizeCircle.MouseButton1Click:Connect(function()
        -- Animation: shrink then grow
        game:GetService("TweenService"):Create(minimizeCircle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 40, 0, 40)}):Play()
        task.wait(0.1)
        game:GetService("TweenService"):Create(minimizeCircle, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50)}):Play()
    end)

    -- workarea full screen

    local workarea = Instance.new("Frame")
    workarea.Name = "workarea"
    workarea.Parent = main
    workarea.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    workarea.Position = UDim2.new(0, 0, 0, 40)
    workarea.Size = UDim2.new(1, 0, 1, -40)
    workarea.BackgroundTransparency = 1
    workarea.BorderSizePixel = 0
    -- Simple text buttons

    local buttons = Instance.new("Frame")
    buttons.Name = "buttons"
    buttons.Parent = main
    buttons.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    buttons.BackgroundTransparency = 1
    buttons.Position = UDim2.new(1, -70, 0, 8)
    buttons.Size = UDim2.new(0, 60, 0, 24)

    local ull_3 = Instance.new("UIListLayout")
    ull_3.Parent = buttons
    ull_3.FillDirection = Enum.FillDirection.Horizontal
    ull_3.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ull_3.SortOrder = Enum.SortOrder.LayoutOrder
    ull_3.VerticalAlignment = Enum.VerticalAlignment.Center
    ull_3.Padding = UDim.new(0, 15)


    local minimize = Instance.new("TextButton")
    minimize.Name = "minimize"
    minimize.Parent = buttons
    minimize.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    minimize.BackgroundTransparency = 1
    minimize.Size = UDim2.new(0, 20, 0, 20)
    minimize.AutoButtonColor = false
    minimize.Font = Enum.Font.GothamBold
    minimize.Text = "-"
    minimize.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimize.TextSize = 20


    local close = Instance.new("TextButton")
    close.Name = "close"
    close.Parent = buttons
    close.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    close.BackgroundTransparency = 1
    close.Size = UDim2.new(0, 20, 0, 20)
    close.AutoButtonColor = false
    close.Font = Enum.Font.GothamBold
    close.Text = "x"
    close.TextColor3 = Color3.fromRGB(200, 200, 200)
    close.TextSize = 18
    close.MouseButton1Click:Connect(function()
        scrgui:Destroy()
    end)

    -- title text at topbar

    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = main
    title.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 0
    title.Position = UDim2.new(0, 15, 0, 8)
    title.Size = UDim2.new(0, 300, 0, 24)
    title.Font = Enum.Font.GothamBold
    title.LineHeight = 1.180
    title.TextColor3 = Color3.fromRGB(200, 200, 200)
    title.TextSize = 16
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left

    if ti then
        title.Text = ti
    else
        title.Text = ""
    end
       tp(main, UDim2.new(0.5, 0, 0.5, 0), 1)
    window = {}
    
    -- Config system
    local configData = {}
    local autoloadConfig = nil
    
    function window:SaveConfig(configName)
        if not configName or configName == "" then
            window:TempNotify("Error", "Config name cannot be empty", "rbxassetid://12608259004")
            return false
        end
        
        local success, err = pcall(function()
            local jsonData = game:GetService("HttpService"):JSONEncode(configData)
            writefile(configName .. ".json", jsonData)
        end)
        
        if success then
            window:TempNotify("Success", "Config saved: " .. configName, "rbxassetid://12608259004")
            return true
        else
            window:TempNotify("Error", "Failed to save config", "rbxassetid://12608259004")
            return false
        end
    end
    
    function window:LoadConfig(configName)
        if not configName or configName == "" then
            window:TempNotify("Error", "Config name cannot be empty", "rbxassetid://12608259004")
            return false
        end
        
        local success, err = pcall(function()
            if isfile(configName .. ".json") then
                local jsonData = readfile(configName .. ".json")
                configData = game:GetService("HttpService"):JSONDecode(jsonData)
                window:TempNotify("Success", "Config loaded: " .. configName, "rbxassetid://12608259004")
            else
                window:TempNotify("Error", "Config not found: " .. configName, "rbxassetid://12608259004")
            end
        end)
        
        return success
    end
    
    function window:SetAutoload(configName)
        autoloadConfig = configName
        writefile("autoload.txt", configName)
        window:TempNotify("Success", "Autoload set: " .. configName, "rbxassetid://12608259004")
    end
    
    function window:RemoveAutoload()
        autoloadConfig = nil
        if isfile("autoload.txt") then
            delfile("autoload.txt")
        end
        window:TempNotify("Success", "Autoload removed", "rbxassetid://12608259004")
    end
    
    function window:GetAutoload()
        if isfile("autoload.txt") then
            return readfile("autoload.txt")
        end
        return nil
    end
    
    function window:SetConfigValue(key, value)
        configData[key] = value
    end
    
    function window:GetConfigValue(key)
        return configData[key]
    end
    
    function window:GetConfigList()
        local configs = {}
        if not isfolder then return configs end
        
        local files = listfiles()
        for _, file in ipairs(files) do
            if file:match("%.json$") then
                local configName = file:match("([^/\\]+)%.json$")
                if configName then
                    table.insert(configs, configName)
                end
            end
        end
        
        return configs
    end
    
    function window:DeleteConfig(configName)
        if not configName or configName == "" then
            window:TempNotify("Error", "Config name cannot be empty", "rbxassetid://12608259004")
            return false
        end
        
        local success, err = pcall(function()
            if isfile(configName .. ".json") then
                delfile(configName .. ".json")
                window:TempNotify("Success", "Config deleted: " .. configName, "rbxassetid://12608259004")
            else
                window:TempNotify("Error", "Config not found: " .. configName, "rbxassetid://12608259004")
            end
        end)
        
        return success
    end

    function window:ToggleVisible()
        if dbcooper then return end
        visible = not visible
        dbcooper = true
        if visible then
            tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
            task.wait(0.5)
            dbcooper = false
        else
            tp(main, main.Position + UDim2.new(0,0,2,0), 0.5)
            task.wait(0.5)
            dbcooper = false
        end
    end

    function window:ToggleVisible()
        if dbcooper then return end
        visible = not visible
        dbcooper = true
        if visible then
            minimizeCircle.Visible = false
            tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
            task.wait(0.5)
            dbcooper = false
        else
            tp(main, main.Position + UDim2.new(0,0,2,0), 0.5)
            task.wait(0.5)
            minimizeCircle.Visible = true
            dbcooper = false
        end
    end

    if visiblekey then
        minimize.MouseButton1Click:Connect(function()
            window:ToggleVisible()
        end)
        minimizeCircle.MouseButton1Click:Connect(function()
            window:ToggleVisible()
        end)
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == visiblekey then
                window:ToggleVisible()
            end
        end)
    else
        minimize.MouseButton1Click:Connect(function()
            window:ToggleVisible()
        end)
        minimizeCircle.MouseButton1Click:Connect(function()
            window:ToggleVisible()
        end)
    end

    function window:GreenButton(callback)
        -- Green button removed, function kept for compatibility
        if callback then
            callback()
        end
    end
    
    function window:TempNotify(text1, text2, icon)
        -- Считаем количество существующих нотификаций
        local notifCount = 0
        for b,v in next, scrgui:GetChildren() do
            if v.Name == "tempnotif" then 
                notifCount = notifCount + 1
            end
        end
        
        -- Вычисляем Y-позицию для новой нотификации
        local newYPos = 10 + (notifCount * 65)
        
        local tempnotif = Instance.new("Frame")
        tempnotif.Name = "tempnotif"
        tempnotif.Parent = scrgui
        tempnotif.AnchorPoint = Vector2.new(1, 0)
        tempnotif.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
        tempnotif.BackgroundTransparency = 0
        tempnotif.Position = UDim2.new(1, 300, 0, newYPos)
        tempnotif.Size = UDim2.new(0, 220, 0, 55)
        tempnotif.Visible = true
        tempnotif.ZIndex = 4

        local uc_21 = Instance.new("UICorner")
        uc_21.CornerRadius = UDim.new(0, 8)
        uc_21.Parent = tempnotif
        
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = Color3.fromRGB(44, 58, 66)
        notifStroke.Thickness = 1
        notifStroke.Parent = tempnotif

        local t2 = Instance.new("TextLabel")
        t2.Name = "t2"
        t2.Parent = tempnotif
        t2.BackgroundTransparency = 1
        t2.Position = UDim2.new(0.25, 0, 0.5, 0)
        t2.Size = UDim2.new(0, 155, 0, 25)
        t2.ZIndex = 4
        t2.Font = Enum.Font.Gotham
        t2.Text = text2
        t2.TextColor3 = Color3.fromRGB(180, 180, 180)
        t2.TextSize = 9
        t2.TextWrapped = true
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.TextYAlignment = Enum.TextYAlignment.Top

        local t1 = Instance.new("TextLabel")
        t1.Name = "t1"
        t1.Parent = tempnotif
        t1.BackgroundTransparency = 1
        t1.Position = UDim2.new(0.25, 0, 0.15, 0)
        t1.Size = UDim2.new(0, 155, 0, 15)
        t1.ZIndex = 4
        t1.Font = Enum.Font.GothamBold
        t1.Text = text1
        t1.TextColor3 = Color3.fromRGB(200, 200, 200)
        t1.TextSize = 12
        t1.TextXAlignment = Enum.TextXAlignment.Left

        local ticon = Instance.new("ImageLabel")
        ticon.Name = "ticon"
        ticon.Parent = tempnotif
        ticon.BackgroundTransparency = 1
        ticon.Position = UDim2.new(0.05, 0, 0.2, 0)
        ticon.Size = UDim2.new(0, 33, 0, 33)
        ticon.ZIndex = 4
        ticon.Image = icon
        ticon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        ticon.ScaleType = Enum.ScaleType.Fit

        local tshadow = Instance.new("ImageLabel")
        tshadow.Name = "tshadow"
        tshadow.Parent = tempnotif
        tshadow.AnchorPoint = Vector2.new(0.5, 0.5)
        tshadow.BackgroundTransparency = 1
        tshadow.Position = UDim2.new(0.5, 0, 0.5, 0)
        tshadow.Size = UDim2.new(1.15, 0, 1.25, 0)
        tshadow.ZIndex = 3
        tshadow.Image = "rbxassetid://313486536"
        tshadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        tshadow.ImageTransparency = 0.400
        tshadow.TileSize = UDim2.new(0, 1, 0, 1)
        
        -- Анимация появления справа (въезжает влево) - отступ 10px от правого края
        tempnotif:TweenPosition(UDim2.new(1, -10, 0, newYPos), "InOut", "Quart", 0.5, true)
        
        -- Удаление через 5 секунд с анимацией
        task.spawn(function()
            task.wait(5)
            -- Получаем текущую Y-позицию перед удалением
            local currentYPos = tempnotif.Position.Y.Offset
            -- Анимация ухода вправо с текущей Y-позиции
            tempnotif:TweenPosition(UDim2.new(1, 300, 0, currentYPos), "InOut", "Quart", 0.5, true)
            task.wait(0.5)
            tempnotif:Destroy()
        end)
    end

    function window:Notify(txt1, txt2, b1, icohn, callback)
        -- Используем TempNotify вместо старой системы
        window:TempNotify(txt1, txt2, icohn)
        if callback then
            callback()
        end
    end

    function window:Notify2(txt1, txt2, b1, b2, icohn, callback, callback2)
        -- Используем TempNotify вместо старой системы
        window:TempNotify(txt1, txt2, icohn)
        if callback then
            callback()
        end
    end

    function window:Divider(name)
        -- Divider removed - no sidebar
    end

    function window:Section(name, icon)
        -- Create tab button in top navigation bar
        local tabButton = Instance.new("TextButton")
        tabButton.Name = "tabButton_" .. name
        tabButton.Parent = topNav
        tabButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tabButton.BackgroundTransparency = 0.7
        tabButton.Size = UDim2.new(0, 34, 0, 34)
        tabButton.AutoButtonColor = false
        tabButton.Text = ""
        tabButton.ZIndex = 6
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabButton
        
        local tabIcon = Instance.new("ImageLabel")
        tabIcon.Name = "icon"
        tabIcon.Parent = tabButton
        tabIcon.BackgroundTransparency = 1
        tabIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
        tabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        tabIcon.Size = UDim2.new(0, 20, 0, 20)
        tabIcon.Image = icon or "rbxassetid://12608259004"
        tabIcon.ImageColor3 = Color3.fromRGB(95, 95, 95)
        tabIcon.ScaleType = Enum.ScaleType.Fit
        tabIcon.ZIndex = 7
        
        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain"
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        workareamain.Position = UDim2.new(0, 10, 0, 10)
        workareamain.Size = UDim2.new(1, -20, 1, -20)
        workareamain.ZIndex = 3
        workareamain.CanvasSize = UDim2.new(0, 0, 0, 0)
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = false

        local ull = Instance.new("UIListLayout")
        ull.Parent = workareamain
        ull.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ull.SortOrder = Enum.SortOrder.LayoutOrder
        ull.Padding = UDim.new(0, 5)
        
        -- Auto-resize canvas based on content
        ull:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            workareamain.CanvasSize = UDim2.new(0, 0, 0, ull.AbsoluteContentSize.Y + 10)
        end)
    
        table.insert(workareas, workareamain)
        
        -- Tab button click handler
        tabButton.MouseButton1Click:Connect(function()
            -- Hide all workareas
            for b, v in next, workareas do
                v.Visible = false
            end
            -- Reset all tab buttons
            for _, btn in next, topNav:GetChildren() do
                if btn:IsA("TextButton") then
                    btn.BackgroundTransparency = 0.7
                    local ic = btn:FindFirstChild("icon")
                    if ic then
                        ic.ImageColor3 = Color3.fromRGB(95, 95, 95)
                    end
                end
            end
            -- Show selected workarea and main window
            workareamain.Visible = true
            if main.Position.Y.Scale > 1 then
                tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
            end
            -- Highlight selected tab
            tabButton.BackgroundTransparency = 0.2
            tabIcon.ImageColor3 = Color3.fromRGB(21, 103, 251)
        end)

        local sec = {}
        function sec:Select()
            -- Hide all workareas
            for b, v in next, workareas do
                v.Visible = false
            end
            -- Reset all tab buttons
            for _, btn in next, topNav:GetChildren() do
                if btn:IsA("TextButton") then
                    btn.BackgroundTransparency = 0.7
                    local ic = btn:FindFirstChild("icon")
                    if ic then
                        ic.ImageColor3 = Color3.fromRGB(95, 95, 95)
                    end
                end
            end
            -- Show this workarea and main window
            workareamain.Visible = true
            if main.Position.Y.Scale > 1 then
                tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
            end
            -- Highlight this tab
            tabButton.BackgroundTransparency = 0.2
            tabIcon.ImageColor3 = Color3.fromRGB(21, 103, 251)
        end
        function sec:Divider(name)
            local section = Instance.new("TextLabel")
            section.Name = "section"
            section.Parent = workareamain
            section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            section.BackgroundTransparency = 1
            section.BorderSizePixel = 2
            section.Size = UDim2.new(0, 418, 0, 50)
            section.Font = Enum.Font.Gotham
            section.LineHeight = 1.180
            section.Text = name
            section.TextColor3 = Color3.fromRGB(0, 0, 0)
            section.TextSize = 25
            section.TextWrapped = true
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.TextYAlignment = Enum.TextYAlignment.Bottom
        end
        function sec:Button(name, callback)
            local button = Instance.new("TextButton")
            button.Name = "button"
            button.Text = name
            button.Parent = workareamain
            button.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
            button.BackgroundTransparency = 0
            button.Size = UDim2.new(0, 377, 0, 43)
            button.ZIndex = 2
            button.Font = Enum.Font.Gotham
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 16

            local uc_3 = Instance.new("UICorner")
            uc_3.CornerRadius = UDim.new(0, 9)
            uc_3.Parent = button

            local us = Instance.new("UIStroke", button)
            us.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            us.Color = Color3.fromRGB(44, 58, 66)
            us.Thickness = 1

            button.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(65, 86, 97)}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
            end)

            if callback then
                button.MouseButton1Click:Connect(function() 
                    coroutine.wrap(function()
                        game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(84, 111, 126)}):Play()
                        task.wait(0.1)
                        game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(65, 86, 97)}):Play()
                    end)()
                    callback()
                end)
            end
        end

        function sec:Label(name)
            local label = Instance.new("TextLabel")
            label.Name = "label"
            label.Parent = workareamain
            label.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
            label.BackgroundTransparency = 0
            label.BorderSizePixel = 0
            label.Size = UDim2.new(0, 377, 0, 43)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 16
            label.TextWrapped = true
            label.Text = name
            
            local uc = Instance.new("UICorner")
            uc.CornerRadius = UDim.new(0, 9)
            uc.Parent = label
            
            local us = Instance.new("UIStroke")
            us.Color = Color3.fromRGB(44, 58, 66)
            us.Thickness = 1
            us.Parent = label
            
            label.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(65, 86, 97)}):Play()
            end)
            
            label.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
            end)
            
            return label
        end

        function sec:Switch(name, defaultmode, callback)
            local mode = defaultmode
            local toggleswitch = Instance.new("Frame")
            toggleswitch.Name = "toggleswitch"
            toggleswitch.Parent = workareamain
            toggleswitch.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
            toggleswitch.BackgroundTransparency = 0
            toggleswitch.Size = UDim2.new(0, 377, 0, 43)
            
            local uc = Instance.new("UICorner")
            uc.CornerRadius = UDim.new(0, 9)
            uc.Parent = toggleswitch
            
            local us = Instance.new("UIStroke")
            us.Color = Color3.fromRGB(44, 58, 66)
            us.Thickness = 1
            us.Parent = toggleswitch
            
            local label = Instance.new("TextLabel")
            label.Name = "label"
            label.Parent = toggleswitch
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0, 250, 1, 0)
            label.Font = Enum.Font.Gotham
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left

            local Frame = Instance.new("TextButton")
            Frame.Parent = toggleswitch
            Frame.AnchorPoint = Vector2.new(1, 0.5)
            Frame.Position = UDim2.new(1, -10, 0.5, 0)
            Frame.Size = UDim2.new(0, 45, 0, 24)
            Frame.Text = ""
            Frame.AutoButtonColor = false
            Frame.BackgroundColor3 = Color3.fromRGB(28, 37, 42)

            local uc_4 = Instance.new("UICorner")
            uc_4.CornerRadius = UDim.new(1, 0)
            uc_4.Parent = Frame
            
            local frameStroke = Instance.new("UIStroke")
            frameStroke.Color = Color3.fromRGB(44, 58, 66)
            frameStroke.Thickness = 1
            frameStroke.Parent = Frame

            local TextButton = Instance.new("ImageLabel")
            TextButton.Name = "Inner"
            TextButton.Parent = Frame
            TextButton.AnchorPoint = Vector2.new(0.5, 0.5)
            TextButton.BackgroundTransparency = 1
            TextButton.Size = UDim2.new(0, 16, 0, 16)
            TextButton.Image = "rbxassetid://12266946128"

            if defaultmode == false then
                TextButton.Position = UDim2.new(0.265, 0, 0.5, 0)
                Frame.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
                frameStroke.Color = Color3.fromRGB(44, 58, 66)
                TextButton.ImageColor3 = Color3.fromRGB(44, 58, 66)
            else
                TextButton.Position = UDim2.new(0.735, 0, 0.5, 0)
                Frame.BackgroundColor3 = Color3.fromRGB(44, 58, 66)
                frameStroke.Color = Color3.fromRGB(67, 88, 100)
                TextButton.ImageColor3 = Color3.fromRGB(67, 88, 100)
            end

            Frame.MouseButton1Click:Connect(function()
                mode = not mode

                if callback then
                    callback(mode)
                end

                if mode then
                    game:GetService("TweenService"):Create(TextButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = UDim2.new(0.735, 0, 0.5, 0)}):Play()
                    game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(44, 58, 66)}):Play()
                    game:GetService("TweenService"):Create(frameStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(67, 88, 100)}):Play()
                    game:GetService("TweenService"):Create(TextButton, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(67, 88, 100)}):Play()
                else
                    game:GetService("TweenService"):Create(TextButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {Position = UDim2.new(0.265, 0, 0.5, 0)}):Play()
                    game:GetService("TweenService"):Create(Frame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(28, 37, 42)}):Play()
                    game:GetService("TweenService"):Create(frameStroke, TweenInfo.new(0.3), {Color = Color3.fromRGB(44, 58, 66)}):Play()
                    game:GetService("TweenService"):Create(TextButton, TweenInfo.new(0.3), {ImageColor3 = Color3.fromRGB(44, 58, 66)}):Play()
                end
            end)
            
            toggleswitch.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(65, 86, 97)}):Play()
            end)
            
            toggleswitch.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
            end)
        end

        function sec:TextField(name, placeholder, callback)
            local textfield = Instance.new("Frame")
            textfield.Name = "textfield"
            textfield.Parent = workareamain
            textfield.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
            textfield.BackgroundTransparency = 0
            textfield.Size = UDim2.new(0, 377, 0, 43)
            
            local uc = Instance.new("UICorner")
            uc.CornerRadius = UDim.new(0, 9)
            uc.Parent = textfield
            
            local us = Instance.new("UIStroke")
            us.Color = Color3.fromRGB(44, 58, 66)
            us.Thickness = 1
            us.Parent = textfield
            
            local label = Instance.new("TextLabel")
            label.Name = "label"
            label.Parent = textfield
            label.BackgroundTransparency = 1
            label.Position = UDim2.new(0, 10, 0, 0)
            label.Size = UDim2.new(0, 150, 1, 0)
            label.Font = Enum.Font.Gotham
            label.Text = name
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextSize = 16
            label.TextXAlignment = Enum.TextXAlignment.Left

            local TextBox = Instance.new("TextBox")
            TextBox.Name = "TextBoxInner"
            TextBox.Parent = textfield
            TextBox.AnchorPoint = Vector2.new(1, 0.5)
            TextBox.BackgroundColor3 = Color3.fromRGB(35, 47, 53)
            TextBox.Position = UDim2.new(1, -10, 0.5, 0)
            TextBox.Size = UDim2.new(0, 180, 0, 28)
            TextBox.ClearTextOnFocus = false
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
            TextBox.PlaceholderText = placeholder or "Type..."
            TextBox.Text = ""
            TextBox.TextColor3 = Color3.fromRGB(200, 200, 200)
            TextBox.TextSize = 14
            TextBox.TextXAlignment = Enum.TextXAlignment.Center
            
            local textboxCorner = Instance.new("UICorner")
            textboxCorner.CornerRadius = UDim.new(0, 6)
            textboxCorner.Parent = TextBox
            
            local textboxStroke = Instance.new("UIStroke")
            textboxStroke.Color = Color3.fromRGB(44, 58, 66)
            textboxStroke.Thickness = 1
            textboxStroke.Parent = TextBox

            if callback then
                TextBox.FocusLost:Connect(function()
                    callback(TextBox.Text)
                end)
            end
            
            textfield.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(65, 86, 97)}):Play()
            end)
            
            textfield.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
            end)
            
            return TextBox
        end
        
        function sec:Dropdown(name, options, callback)
            local selectedOption = options[1] or "None"
            local dropdownOpen = false
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Name = "dropdown"
            dropdownFrame.Parent = workareamain
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
            dropdownFrame.BackgroundTransparency = 0
            dropdownFrame.Size = UDim2.new(0, 377, 0, 43)
            
            local uc = Instance.new("UICorner")
            uc.CornerRadius = UDim.new(0, 9)
            uc.Parent = dropdownFrame
            
            local us = Instance.new("UIStroke")
            us.Color = Color3.fromRGB(44, 58, 66)
            us.Thickness = 1
            us.Parent = dropdownFrame
            
            local dropdownLabel = Instance.new("TextLabel")
            dropdownLabel.Name = "label"
            dropdownLabel.Parent = dropdownFrame
            dropdownLabel.BackgroundTransparency = 1
            dropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            dropdownLabel.Size = UDim2.new(0, 150, 1, 0)
            dropdownLabel.Font = Enum.Font.Gotham
            dropdownLabel.Text = name
            dropdownLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            dropdownLabel.TextSize = 16
            dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Name = "button"
            dropdownButton.Parent = dropdownFrame
            dropdownButton.AnchorPoint = Vector2.new(1, 0.5)
            dropdownButton.BackgroundColor3 = Color3.fromRGB(35, 47, 53)
            dropdownButton.Position = UDim2.new(1, -10, 0.5, 0)
            dropdownButton.Size = UDim2.new(0, 180, 0, 28)
            dropdownButton.AutoButtonColor = false
            dropdownButton.Font = Enum.Font.Gotham
            dropdownButton.Text = selectedOption
            dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            dropdownButton.TextSize = 14
            
            local dropdownCorner = Instance.new("UICorner")
            dropdownCorner.CornerRadius = UDim.new(0, 6)
            dropdownCorner.Parent = dropdownButton
            
            local dropdownButtonStroke = Instance.new("UIStroke")
            dropdownButtonStroke.Color = Color3.fromRGB(44, 58, 66)
            dropdownButtonStroke.Thickness = 1
            dropdownButtonStroke.Parent = dropdownButton
            
            local dropdownList = Instance.new("ScrollingFrame")
            dropdownList.Name = "list"
            dropdownList.Parent = dropdownFrame
            dropdownList.AnchorPoint = Vector2.new(1, 0)
            dropdownList.BackgroundColor3 = Color3.fromRGB(35, 47, 53)
            dropdownList.Position = UDim2.new(1, -10, 0, 48)
            dropdownList.Size = UDim2.new(0, 180, 0, 0)
            dropdownList.Visible = false
            dropdownList.ZIndex = 10
            dropdownList.BorderSizePixel = 0
            dropdownList.ScrollBarThickness = 4
            dropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            
            local dropdownListCorner = Instance.new("UICorner")
            dropdownListCorner.CornerRadius = UDim.new(0, 6)
            dropdownListCorner.Parent = dropdownList
            
            local dropdownListStroke = Instance.new("UIStroke")
            dropdownListStroke.Color = Color3.fromRGB(44, 58, 66)
            dropdownListStroke.Thickness = 1
            dropdownListStroke.Parent = dropdownList
            
            local dropdownListLayout = Instance.new("UIListLayout")
            dropdownListLayout.Parent = dropdownList
            dropdownListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownListLayout.Padding = UDim.new(0, 3)
            
            local dropdownListPadding = Instance.new("UIPadding")
            dropdownListPadding.Parent = dropdownList
            dropdownListPadding.PaddingTop = UDim.new(0, 5)
            dropdownListPadding.PaddingBottom = UDim.new(0, 5)
            dropdownListPadding.PaddingLeft = UDim.new(0, 5)
            dropdownListPadding.PaddingRight = UDim.new(0, 5)
            
            local function updateOptions(newOptions)
                for _, child in pairs(dropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                for _, option in ipairs(newOptions) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Name = "option"
                    optionButton.Parent = dropdownList
                    optionButton.BackgroundColor3 = Color3.fromRGB(28, 37, 42)
                    optionButton.BackgroundTransparency = 0
                    optionButton.Size = UDim2.new(1, -10, 0, 28)
                    optionButton.AutoButtonColor = false
                    optionButton.Font = Enum.Font.Gotham
                    optionButton.Text = option
                    optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                    optionButton.TextSize = 13
                    optionButton.ZIndex = 11
                    
                    local optionCorner = Instance.new("UICorner")
                    optionCorner.CornerRadius = UDim.new(0, 4)
                    optionCorner.Parent = optionButton
                    
                    local optionStroke = Instance.new("UIStroke")
                    optionStroke.Color = Color3.fromRGB(44, 58, 66)
                    optionStroke.Thickness = 1
                    optionStroke.Parent = optionButton
                    
                    optionButton.MouseEnter:Connect(function()
                        game:GetService("TweenService"):Create(optionStroke, TweenInfo.new(0.1), {Color = Color3.fromRGB(76, 101, 113)}):Play()
                    end)
                    
                    optionButton.MouseLeave:Connect(function()
                        game:GetService("TweenService"):Create(optionStroke, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
                    end)
                    
                    optionButton.MouseButton1Click:Connect(function()
                        selectedOption = option
                        dropdownButton.Text = option
                        dropdownList.Visible = false
                        dropdownOpen = false
                        dropdownFrame.Size = UDim2.new(0, 377, 0, 43)
                        
                        if callback then
                            callback(option)
                        end
                    end)
                end
                
                local contentHeight = math.min(#newOptions * 31 + 10, 150)
                dropdownList.Size = UDim2.new(0, 180, 0, contentHeight)
                dropdownList.CanvasSize = UDim2.new(0, 0, 0, #newOptions * 31 + 10)
            end
            
            updateOptions(options)
            
            dropdownButton.MouseButton1Click:Connect(function()
                dropdownOpen = not dropdownOpen
                dropdownList.Visible = dropdownOpen
                
                if dropdownOpen then
                    local contentHeight = math.min(#options * 31 + 10, 150)
                    dropdownFrame.Size = UDim2.new(0, 377, 0, 43 + contentHeight + 10)
                    game:GetService("TweenService"):Create(dropdownButtonStroke, TweenInfo.new(0.1), {Color = Color3.fromRGB(84, 111, 126)}):Play()
                else
                    dropdownFrame.Size = UDim2.new(0, 377, 0, 43)
                    game:GetService("TweenService"):Create(dropdownButtonStroke, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
                end
            end)
            
            dropdownFrame.MouseEnter:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(65, 86, 97)}):Play()
            end)
            
            dropdownFrame.MouseLeave:Connect(function()
                game:GetService("TweenService"):Create(us, TweenInfo.new(0.1), {Color = Color3.fromRGB(44, 58, 66)}):Play()
            end)
            
            return {
                UpdateOptions = updateOptions,
                SetSelected = function(option)
                    selectedOption = option
                    dropdownButton.Text = option
                end
            }
        end

        return sec
    end
    
    function window:CreateConfigTab()
        local configSection = window:Section("Config", "rbxassetid://12621719043")
        
        configSection:Divider("Save/Load Config")
        
        local configNameInput = ""
        configSection:TextField("Config Name", "Enter config name...", function(text)
            configNameInput = text
        end)
        
        -- Dropdown with config list
        local configList = window:GetConfigList()
        if #configList == 0 then
            table.insert(configList, "No configs found")
        end
        
        local configDropdown = configSection:Dropdown("Select Config", configList, function(selected)
            if selected ~= "No configs found" then
                configNameInput = selected
            end
        end)
        
        configSection:Button("Refresh Config List", function()
            local newList = window:GetConfigList()
            if #newList == 0 then
                newList = {"No configs found"}
            end
            configDropdown.UpdateOptions(newList)
            window:TempNotify("Success", "Config list refreshed", "rbxassetid://12608259004")
        end)
        
        configSection:Button("Save Config", function()
            if window:SaveConfig(configNameInput) then
                local newList = window:GetConfigList()
                if #newList == 0 then
                    newList = {"No configs found"}
                end
                configDropdown.UpdateOptions(newList)
            end
        end)
        
        configSection:Button("Load Config", function()
            window:LoadConfig(configNameInput)
        end)
        
        configSection:Button("Delete Config", function()
            if window:DeleteConfig(configNameInput) then
                local newList = window:GetConfigList()
                if #newList == 0 then
                    newList = {"No configs found"}
                end
                configDropdown.UpdateOptions(newList)
                configNameInput = ""
            end
        end)
        
        configSection:Divider("Autoload")
        
        -- Autoload status label (will be updated)
        local currentAutoload = window:GetAutoload()
        local autoloadText = currentAutoload and ("Current autoload: " .. currentAutoload) or "No autoload set"
        local autoloadLabelObj = configSection:Label(autoloadText)
        
        configSection:Button("Set as Autoload", function()
            if configNameInput ~= "" then
                window:SetAutoload(configNameInput)
                -- Update status
                local newAutoload = window:GetAutoload()
                autoloadLabelObj.Text = newAutoload and ("Current autoload: " .. newAutoload) or "No autoload set"
            else
                window:TempNotify("Error", "Enter config name first", "rbxassetid://12608259004")
            end
        end)
        
        configSection:Button("Remove Autoload", function()
            window:RemoveAutoload()
            -- Update status
            autoloadLabelObj.Text = "No autoload set"
        end)
        
        configSection:Button("Refresh Autoload Status", function()
            local newAutoload = window:GetAutoload()
            autoloadLabelObj.Text = newAutoload and ("Current autoload: " .. newAutoload) or "No autoload set"
            window:TempNotify("Success", "Status refreshed", "rbxassetid://12608259004")
        end)
        
        return configSection
    end

    return window
end

return lib
