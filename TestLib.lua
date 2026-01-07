
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
    main.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    main.BackgroundTransparency = 0.150
    main.Position = UDim2.new(0.5, 0, 2, 0)
    main.Size = UDim2.new(0, 481, 0, 389)

    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 12)
    uc.Parent = main

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

    -- Minimize button (white circle)
    local minimizeCircle = Instance.new("TextButton")
    minimizeCircle.Name = "minimizeCircle"
    minimizeCircle.Parent = scrgui
    minimizeCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    minimizeCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minimizeCircle.BackgroundTransparency = 0.150
    minimizeCircle.Position = UDim2.new(0.1, 0, 0.1, 0)
    minimizeCircle.Size = UDim2.new(0, 50, 0, 50)
    minimizeCircle.Visible = false
    minimizeCircle.AutoButtonColor = false
    minimizeCircle.Text = ""
    minimizeCircle.ZIndex = 10

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = minimizeCircle

    local circleIcon = Instance.new("TextLabel")
    circleIcon.Name = "icon"
    circleIcon.Parent = minimizeCircle
    circleIcon.BackgroundTransparency = 1
    circleIcon.Size = UDim2.new(1, 0, 1, 0)
    circleIcon.Font = Enum.Font.GothamBold
    circleIcon.Text = "+"
    circleIcon.TextColor3 = Color3.fromRGB(95, 95, 95)
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
    workarea.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    workarea.Position = UDim2.new(0, 0, 0.1, 0)
    workarea.Size = UDim2.new(1, 0, 0.9, 0)
    workarea.BackgroundTransparency = 1
    workarea.BorderSizePixel = 0
    -- Simple text buttons

    local buttons = Instance.new("Frame")
    buttons.Name = "buttons"
    buttons.Parent = main
    buttons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buttons.BackgroundTransparency = 1
    buttons.Position = UDim2.new(1, -60, 0, 5)
    buttons.Size = UDim2.new(0, 55, 0, 25)

    local ull_3 = Instance.new("UIListLayout")
    ull_3.Parent = buttons
    ull_3.FillDirection = Enum.FillDirection.Horizontal
    ull_3.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ull_3.SortOrder = Enum.SortOrder.LayoutOrder
    ull_3.VerticalAlignment = Enum.VerticalAlignment.Center
    ull_3.Padding = UDim.new(0, 10)


    local minimize = Instance.new("TextButton")
    minimize.Name = "minimize"
    minimize.Parent = buttons
    minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    minimize.BackgroundTransparency = 1
    minimize.Size = UDim2.new(0, 20, 0, 20)
    minimize.AutoButtonColor = false
    minimize.Font = Enum.Font.GothamBold
    minimize.Text = "-"
    minimize.TextColor3 = Color3.fromRGB(95, 95, 95)
    minimize.TextSize = 20


    local close = Instance.new("TextButton")
    close.Name = "close"
    close.Parent = buttons
    close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    close.BackgroundTransparency = 1
    close.Size = UDim2.new(0, 20, 0, 20)
    close.AutoButtonColor = false
    close.Font = Enum.Font.GothamBold
    close.Text = "x"
    close.TextColor3 = Color3.fromRGB(95, 95, 95)
    close.TextSize = 18
    close.MouseButton1Click:Connect(function()
        scrgui:Destroy()
    end)

    -- title text at topbar

    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = main
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 2
    title.Position = UDim2.new(0.15, 0, 0.0351027399, 0)
    title.Size = UDim2.new(0, 267, 0, 10)
    title.Font = Enum.Font.Gotham
    title.LineHeight = 1.180
    title.TextColor3 = Color3.fromRGB(0, 0, 0)
    title.TextSize = 19
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left

    if ti then
        title.Text = ti
    else
        title.Text = ""
    end
       tp(main, UDim2.new(0.5, 0, 0.5, 0), 1)
    window = {}

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
        tempnotif.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        tempnotif.BackgroundTransparency = 0.150
        tempnotif.Position = UDim2.new(1, 300, 0, newYPos) -- Начинаем справа за экраном на правильной высоте
        tempnotif.Size = UDim2.new(0, 220, 0, 55)
        tempnotif.Visible = true
        tempnotif.ZIndex = 4

        local uc_21 = Instance.new("UICorner")
        uc_21.CornerRadius = UDim.new(0, 8)
        uc_21.Parent = tempnotif

        local t2 = Instance.new("TextLabel")
        t2.Name = "t2"
        t2.Parent = tempnotif
        t2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        t2.BackgroundTransparency = 1
        t2.Position = UDim2.new(0.25, 0, 0.5, 0)
        t2.Size = UDim2.new(0, 155, 0, 25)
        t2.ZIndex = 4
        t2.Font = Enum.Font.Gotham
        t2.Text = text2
        t2.TextColor3 = Color3.fromRGB(95, 95, 95)
        t2.TextSize = 9
        t2.TextWrapped = true
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.TextYAlignment = Enum.TextYAlignment.Top

        local t1 = Instance.new("TextLabel")
        t1.Name = "t1"
        t1.Parent = tempnotif
        t1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        t1.BackgroundTransparency = 1
        t1.Position = UDim2.new(0.25, 0, 0.15, 0)
        t1.Size = UDim2.new(0, 155, 0, 15)
        t1.ZIndex = 4
        t1.Font = Enum.Font.GothamBold
        t1.Text = text1
        t1.TextColor3 = Color3.fromRGB(95, 95, 95)
        t1.TextSize = 12
        t1.TextXAlignment = Enum.TextXAlignment.Left

        local ticon = Instance.new("ImageLabel")
        ticon.Name = "ticon"
        ticon.Parent = tempnotif
        ticon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ticon.BackgroundTransparency = 1
        ticon.Position = UDim2.new(0.05, 0, 0.2, 0)
        ticon.Size = UDim2.new(0, 33, 0, 33)
        ticon.ZIndex = 4
        ticon.Image = icon
        ticon.ImageColor3 = Color3.fromRGB(95, 95, 95)
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

    function window:Section(name)
        -- No sidebar buttons needed
        
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
        workareamain.AutomaticCanvasSize = Enum.AutomaticSize.Y
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = true

        local ull = Instance.new("UIListLayout")
        ull.Parent = workareamain
        ull.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ull.SortOrder = Enum.SortOrder.LayoutOrder
        ull.Padding = UDim.new(0, 5)
    
        table.insert(workareas, workareamain)

        local sec = {}
        function sec:Select()
            -- Auto-visible, no switching needed
            for b, v in next, workareas do
                v.Visible = false
            end
            workareamain.Visible = true
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
            button.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
            button.BackgroundTransparency = 1
            button.Size = UDim2.new(0, 418, 0, 37)
            button.ZIndex = 2
            button.Font = Enum.Font.Gotham
            button.TextColor3 = Color3.fromRGB(21, 103, 251)
            button.TextSize = 21

            local uc_3 = Instance.new("UICorner")
            uc_3.CornerRadius = UDim.new(0, 9)
            uc_3.Parent = button

            local us = Instance.new("UIStroke", button)
            us.ApplyStrokeMode = "Border"
            us.Color = Color3.fromRGB(21, 103, 251)
            us.Thickness = 1


            if callback then
                button.MouseButton1Click:Connect(function() 
                    coroutine.wrap(function()
                        button.TextSize -= 3
                        task.wait(0.06)
                        button.TextSize += 3
                    end)()
                    callback()
                end)
            end
        end

        function sec:Label(name)
            local label = Instance.new("TextLabel")
            label.Name = "label"
            label.Parent = workareamain
            label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 2
            label.Size = UDim2.new(0, 418, 0, 37)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = Color3.fromRGB(95, 95, 95)
            label.TextSize = 21
            label.TextWrapped = true
            label.Text = name
        end

        function sec:Switch(name, defaultmode, callback)
            local mode = defaultmode
            local toggleswitch = Instance.new("TextLabel")
            toggleswitch.Name = "toggleswitch"
            toggleswitch.Parent = workareamain
            toggleswitch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleswitch.BackgroundTransparency = 1
            toggleswitch.BorderSizePixel = 2
            toggleswitch.Size = UDim2.new(0, 418, 0, 37)
            toggleswitch.Font = Enum.Font.Gotham
            toggleswitch.Text = name
            toggleswitch.TextColor3 = Color3.fromRGB(95, 95, 95)
            toggleswitch.TextSize = 21
            toggleswitch.TextWrapped = true
            toggleswitch.TextXAlignment = Enum.TextXAlignment.Left

            local Frame = Instance.new("TextButton")
            Frame.Parent = toggleswitch
            Frame.Position = UDim2.new(0.832535863, 0, 0.0270270277, 0)
            Frame.Size = UDim2.new(0, 70, 0, 36)
            Frame.Text=""
            Frame.AutoButtonColor = false

            local uc_4 = Instance.new("UICorner")
            uc_4.CornerRadius = UDim.new(5, 0)
            uc_4.Parent = Frame

            local TextButton = Instance.new("TextButton")
            TextButton.Parent = Frame
            TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.Size = UDim2.new(0, 34, 0, 34)
            TextButton.AutoButtonColor = false
            TextButton.Text = ""

            local uc_5 = Instance.new("UICorner")
            uc_5.CornerRadius = UDim.new(5, 0)
            uc_5.Parent = TextButton

            if defaultmode == false then
                TextButton.Position = UDim2.new(0, 1, 0, 1)
                Frame.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
            else
                TextButton.Position = UDim2.new(0, 35, 0, 1)
                Frame.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
            end

            Frame.MouseButton1Click:Connect(function()
                mode = not mode

                if callback then
                    callback(mode)
                end

                if mode then
                    TextButton:TweenPosition(UDim2.new(0, 35, 0, 1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
                else
                    TextButton:TweenPosition(UDim2.new(0,1,0,1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
                end
            end)
            TextButton.MouseButton1Click:Connect(function()
                mode = not mode

                if callback then
                    callback(mode)
                end

                if mode then
                    TextButton:TweenPosition(UDim2.new(0, 35, 0, 1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(21, 103, 251)
                else
                    TextButton:TweenPosition(UDim2.new(0,1,0,1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(216, 216, 216)
                end
            end)
        end

        function sec:TextField(name, placeholder, callback)
            local textfield = Instance.new("TextLabel")
            textfield.Name = "textfield"
            textfield.Parent = workareamain
            textfield.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            textfield.BackgroundTransparency = 1
            textfield.BorderSizePixel = 2
            textfield.Size = UDim2.new(0, 418, 0, 37)
            textfield.Font = Enum.Font.Gotham
            textfield.Text = name
            textfield.TextColor3 = Color3.fromRGB(95, 95, 95)
            textfield.TextSize = 21
            textfield.TextWrapped = true
            textfield.TextXAlignment = Enum.TextXAlignment.Left

            local Frame_2 = Instance.new("Frame")
            Frame_2.Parent = textfield
            Frame_2.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
            Frame_2.Position = UDim2.new(0.441926777, 0, 0.0270270277, 0)
            Frame_2.Size = UDim2.new(0, 233, 0, 34)

            local uc_6 = Instance.new("UICorner")
            uc_6.CornerRadius = UDim.new(0, 9)
            uc_6.Parent = Frame_2

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = Frame_2
            TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.BackgroundTransparency = 1
            TextBox.BorderColor3 = Color3.fromRGB(27, 42, 53)
            TextBox.BorderSizePixel = 0
            TextBox.ClipsDescendants = true
            TextBox.Position = UDim2.new(0.0643776804, 0, 0, -2)
            TextBox.Size = UDim2.new(0, 203, 0, 34)
            TextBox.ClearTextOnFocus = false
            TextBox.Font = Enum.Font.Gotham
            TextBox.LineHeight = 0.870
            TextBox.PlaceholderColor3 = Color3.fromRGB(113, 113, 113)
            TextBox.PlaceholderText = placeholder or "Type..."
            TextBox.Text = ""
            TextBox.TextColor3 = Color3.fromRGB(12, 12, 12)
            TextBox.TextSize = 21
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            if callback then
                TextBox.FocusLost:Connect(function()
                    callback(TextBox.Text)
                end)
            end
        end

        return sec
    end

    return window
end

return lib
