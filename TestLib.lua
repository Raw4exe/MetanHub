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
        

    local main = Instance.new("Frame")
    main.Name = "main"
    main.Parent = scrgui
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    main.BackgroundTransparency = 0.050
    main.Position = UDim2.new(0.5, 0, 2, 0)
    main.Size = UDim2.new(0, 600, 0, 380)

    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 18)
    uc.Parent = main

    local UserInputService = game:GetService("UserInputService") --- skidded ik
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

    -- workarea right side setup

    local workarea = Instance.new("Frame")
    workarea.Name = "workarea"
    workarea.Parent = main
    workarea.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    workarea.Position = UDim2.new(0.28, 0, 0.16, 0)
    workarea.Size = UDim2.new(0, 432, 0, 320)

    local uc_2 = Instance.new("UICorner")
    uc_2.CornerRadius = UDim.new(0, 18)
    uc_2.Parent = workarea

    local workareacornerhider = Instance.new("Frame")
    workareacornerhider.Name = "workareacornerhider"
    workareacornerhider.Parent = workarea
    workareacornerhider.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    workareacornerhider.BorderSizePixel = 0
    workareacornerhider.Size = UDim2.new(0, 18, 0.99895674, 0)


    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "sidebar"
    sidebar.Parent = main
    sidebar.Active = true
    sidebar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Position = UDim2.new(0.025, 0, 0.16, 0)
    sidebar.Size = UDim2.new(0, 150, 0, 305)
    sidebar.AutomaticCanvasSize = "Y"
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.ScrollBarThickness = 2

    local ull_2 = Instance.new("UIListLayout")
    ull_2.Parent = sidebar
    ull_2.SortOrder = Enum.SortOrder.LayoutOrder
    ull_2.Padding = UDim.new(0, 5)
    -- macos style buttons


    local buttons = Instance.new("Frame")
    buttons.Name = "buttons"
    buttons.Parent = main
    buttons.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    buttons.BackgroundTransparency = 1
    buttons.Size = UDim2.new(0, 105, 0, 57)

    local ull_3 = Instance.new("UIListLayout")
    ull_3.Parent = buttons
    ull_3.FillDirection = Enum.FillDirection.Horizontal
    ull_3.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ull_3.SortOrder = Enum.SortOrder.LayoutOrder
    ull_3.VerticalAlignment = Enum.VerticalAlignment.Center
    ull_3.Padding = UDim.new(0, 10)


    local close = Instance.new("TextButton")
    close.Name = "close"
    close.Parent = buttons
    close.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    close.Size = UDim2.new(0, 14, 0, 14)
    close.AutoButtonColor = false
    close.Font = Enum.Font.GothamBold
    close.Text = "×"
    close.TextColor3 = Color3.fromRGB(60, 60, 60)
    close.TextSize = 18
    close.MouseButton1Click:Connect(function()
        scrgui:Destroy()
    end)
    close.MouseEnter:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        close.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    close.MouseLeave:Connect(function()
        close.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        close.TextColor3 = Color3.fromRGB(60, 60, 60)
    end)

    local uc_18 = Instance.new("UICorner")
    uc_18.CornerRadius = UDim.new(1, 0)
    uc_18.Parent = close


    local minimize = Instance.new("TextButton")
    minimize.Name = "minimize"
    minimize.Parent = buttons
    minimize.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    minimize.Size = UDim2.new(0, 14, 0, 14)
    minimize.AutoButtonColor = false
    minimize.Font = Enum.Font.GothamBold
    minimize.Text = "−"
    minimize.TextColor3 = Color3.fromRGB(60, 60, 60)
    minimize.TextSize = 16
    minimize.MouseEnter:Connect(function()
        minimize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    minimize.MouseLeave:Connect(function()
        minimize.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        minimize.TextColor3 = Color3.fromRGB(60, 60, 60)
    end)

    local uc_19 = Instance.new("UICorner")
    uc_19.CornerRadius = UDim.new(1, 0)
    uc_19.Parent = minimize


    local resize = Instance.new("TextButton")
    resize.Name = "resize"
    resize.Parent = buttons
    resize.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    resize.Size = UDim2.new(0, 14, 0, 14)
    resize.AutoButtonColor = false
    resize.Font = Enum.Font.GothamBold
    resize.Text = "□"
    resize.TextColor3 = Color3.fromRGB(60, 60, 60)
    resize.TextSize = 12
    resize.MouseEnter:Connect(function()
        resize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        resize.TextColor3 = Color3.fromRGB(0, 0, 0)
    end)
    resize.MouseLeave:Connect(function()
        resize.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
        resize.TextColor3 = Color3.fromRGB(60, 60, 60)
    end)

    local uc_20 = Instance.new("UICorner")
    uc_20.CornerRadius = UDim.new(1, 0)
    uc_20.Parent = resize

    -- title text at topbar

    local title = Instance.new("TextLabel")
    title.Name = "title"
    title.Parent = main
    title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.BorderSizePixel = 2
    title.Position = UDim2.new(0.025, 0, 0.04, 0)
    title.Size = UDim2.new(0, 150, 0, 30)
    title.Font = Enum.Font.GothamBold
    title.LineHeight = 1.180
    title.Text = "METAN"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 26
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Left
    
    local titlegradient = Instance.new("UIGradient")
    titlegradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
    }
    titlegradient.Rotation = 90
    titlegradient.Parent = title

    -- notif1
    local notif = Instance.new("Frame")
    notif.Name = "notif"
    notif.Parent = main
    notif.AnchorPoint = Vector2.new(0.5, 0.5)
    notif.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notif.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif.Size = UDim2.new(0, 304, 0, 362)
    notif.Visible = false
    notif.ZIndex = 3

    local uc_11 = Instance.new("UICorner")
    uc_11.CornerRadius = UDim.new(0, 18)
    uc_11.Parent = notif

    local notificon = Instance.new("ImageLabel")
    notificon.Name = "notificon"
    notificon.Parent = notif
    notificon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notificon.BackgroundTransparency = 1
    notificon.Position = UDim2.new(0.335526317, 0, 0.0994475111, 0)
    notificon.Size = UDim2.new(0, 100, 0, 100)
    notificon.ZIndex = 3
    notificon.Image = "rbxassetid://4871684504"
    notificon.ImageColor3 = Color3.fromRGB(200, 200, 200)

    local notifbutton1 = Instance.new("TextButton")
    notifbutton1.Name = "notifbutton1"
    notifbutton1.Parent = notif
    notifbutton1.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    notifbutton1.Position = UDim2.new(0.0559210554, 0, 0.817679524, 0)
    notifbutton1.Size = UDim2.new(0, 270, 0, 50)
    notifbutton1.ZIndex = 3
    notifbutton1.Font = Enum.Font.Gotham
    notifbutton1.Text = "OK"
    notifbutton1.TextColor3 = Color3.fromRGB(20, 20, 20)
    notifbutton1.TextSize = 21

    local uc_12 = Instance.new("UICorner")
    uc_12.CornerRadius = UDim.new(0, 9)
    uc_12.Parent = notifbutton1

    local notifshadow = Instance.new("ImageLabel")
    notifshadow.Name = "notifshadow"
    notifshadow.Parent = notif
    notifshadow.AnchorPoint = Vector2.new(0.5, 0.5)
    notifshadow.BackgroundTransparency = 1
    notifshadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    notifshadow.Size = UDim2.new(1.20000005, 0, 1.20000005, 0)
    notifshadow.Image = "rbxassetid://313486536"
    notifshadow.ImageColor3 = Color3.fromRGB(0, 0, 0)

    local notifdarkness = Instance.new("Frame")
    notifdarkness.Name = "notifdarkness"
    notifdarkness.Parent = notif
    notifdarkness.AnchorPoint = Vector2.new(0.5, 0.5)
    notifdarkness.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifdarkness.BackgroundTransparency = 0.600
    notifdarkness.Position = UDim2.new(0.5, 0, 0.5, 0)
    notifdarkness.Size = UDim2.new(0, 721, 0, 584)
    notifdarkness.ZIndex = 2

    local uc_13 = Instance.new("UICorner")
    uc_13.CornerRadius = UDim.new(0, 18)
    uc_13.Parent = notifdarkness

    local notiftitle = Instance.new("TextLabel")
    notiftitle.Name = "notiftitle"
    notiftitle.Parent = notif
    notiftitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notiftitle.BackgroundTransparency = 1
    notiftitle.Position = UDim2.new(0.167763159, 0, 0.375690609, 0)
    notiftitle.Size = UDim2.new(0, 200, 0, 50)
    notiftitle.ZIndex = 3
    notiftitle.Font = Enum.Font.GothamMedium
    notiftitle.Text = "Notice"
    notiftitle.TextColor3 = Color3.fromRGB(220, 220, 220)
    notiftitle.TextSize = 28

    local notiftext = Instance.new("TextLabel")
    notiftext.Name = "notiftext"
    notiftext.Parent = notif
    notiftext.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notiftext.BackgroundTransparency = 1
    notiftext.Position = UDim2.new(0.0822368413, 0, 0.513812184, 0)
    notiftext.Size = UDim2.new(0, 254, 0, 66)
    notiftext.ZIndex = 3
    notiftext.Font = Enum.Font.Gotham
    notiftext.Text = "We would like to contact you regarding your car's extended warranty."
    notiftext.TextColor3 = Color3.fromRGB(180, 180, 180)
    notiftext.TextSize = 16
    notiftext.TextWrapped = true

    -- notifcation 2 (two button)

    local notif2 = Instance.new("Frame")
    notif2.Name = "notif2"
    notif2.Parent = main
    notif2.AnchorPoint = Vector2.new(0.5, 0.5)
    notif2.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    notif2.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif2.Size = UDim2.new(0, 304, 0, 362)
    notif2.Visible = false
    notif2.ZIndex = 3

    local uc_14 = Instance.new("UICorner")
    uc_14.CornerRadius = UDim.new(0, 18)
    uc_14.Parent = notif2

    local notif2icon = Instance.new("ImageLabel")
    notif2icon.Name = "notif2icon"
    notif2icon.Parent = notif2
    notif2icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notif2icon.BackgroundTransparency = 1
    notif2icon.Position = UDim2.new(0.335526317, 0, 0.0994475111, 0)
    notif2icon.Size = UDim2.new(0, 100, 0, 100)
    notif2icon.ZIndex = 3
    notif2icon.Image = "rbxassetid://12608260095"
    notif2icon.ImageColor3 = Color3.fromRGB(200, 200, 200)

    local notif2title = Instance.new("TextLabel")
    notif2title.Name = "notif2title"
    notif2title.Parent = notif2
    notif2title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notif2title.BackgroundTransparency = 1
    notif2title.Position = UDim2.new(0.167763159, 0, 0.375690609, 0)
    notif2title.Size = UDim2.new(0, 200, 0, 50)
    notif2title.ZIndex = 3
    notif2title.Font = Enum.Font.GothamMedium
    notif2title.Text = "Notice"
    notif2title.TextColor3 = Color3.fromRGB(220, 220, 220)
    notif2title.TextSize = 28


    local notif2text = Instance.new("TextLabel")
    notif2text.Name = "notif2text"
    notif2text.Parent = notif2
    notif2text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    notif2text.BackgroundTransparency = 1
    notif2text.Position = UDim2.new(0.0822368413, 0, 0.513812184, 0)
    notif2text.Size = UDim2.new(0, 254, 0, 66)
    notif2text.ZIndex = 3
    notif2text.Font = Enum.Font.Gotham
    notif2text.Text = "We would like to contact you regarding your car's extended warranty."
    notif2text.TextColor3 = Color3.fromRGB(180, 180, 180)
    notif2text.TextSize = 16
    notif2text.TextWrapped = true


    local notif2button1 = Instance.new("TextButton")
    notif2button1.Name = "notif2button1"
    notif2button1.Parent = notif2
    notif2button1.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
    notif2button1.Position = UDim2.new(0.0559210517, 0, 0.715469658, 0)
    notif2button1.Size = UDim2.new(0, 270, 0, 40)
    notif2button1.ZIndex = 3
    notif2button1.Font = Enum.Font.Gotham
    notif2button1.Text = "Sure!"
    notif2button1.TextColor3 = Color3.fromRGB(20, 20, 20)
    notif2button1.TextSize = 21

    local uc_15 = Instance.new("UICorner")
    uc_15.CornerRadius = UDim.new(0, 9)
    uc_15.Parent = notif2button1


    local notif2shadow = Instance.new("ImageLabel")
    notif2shadow.Name = "notif2shadow"
    notif2shadow.Parent = notif2
    notif2shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    notif2shadow.BackgroundTransparency = 1
    notif2shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif2shadow.Size = UDim2.new(1.20000005, 0, 1.20000005, 0)
    notif2shadow.Image = "rbxassetid://313486536"
    notif2shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)


    local notif2darkness = Instance.new("Frame")
    notif2darkness.Name = "notif2darkness"
    notif2darkness.Parent = notif2
    notif2darkness.AnchorPoint = Vector2.new(0.5, 0.5)
    notif2darkness.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notif2darkness.BackgroundTransparency = 0.600
    notif2darkness.Position = UDim2.new(0.5, 0, 0.5, 0)
    notif2darkness.Size = UDim2.new(0, 721, 0, 584)
    notif2darkness.ZIndex = 2


    local uc_16 = Instance.new("UICorner")
    uc_16.CornerRadius = UDim.new(0, 18)
    uc_16.Parent = notif2darkness


    local notif2button2 = Instance.new("TextButton")
    notif2button2.Name = "notif2button2"
    notif2button2.Parent = notif2
    notif2button2.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    notif2button2.BackgroundTransparency = 1
    notif2button2.Position = UDim2.new(0.0526315793, 0, 0.842541456, 0)
    notif2button2.Size = UDim2.new(0, 270, 0, 40)
    notif2button2.ZIndex = 3
    notif2button2.Font = Enum.Font.Gotham
    notif2button2.Text = "Go away."
    notif2button2.TextColor3 = Color3.fromRGB(160, 160, 160)
    notif2button2.TextSize = 21


    local uc_17 = Instance.new("UICorner")
    uc_17.CornerRadius = UDim.new(0, 9)
    uc_17.Parent = notif2button2

    tp(main, UDim2.new(0.5, 0, 0.5, 0), 1)
    
    -- Show notification about keybind
    task.wait(0.5)
    local keynotif = Instance.new("Frame")
    keynotif.Name = "keynotif"
    keynotif.Parent = scrgui
    keynotif.AnchorPoint = Vector2.new(0.5, 0.5)
    keynotif.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
    keynotif.BackgroundTransparency = 0.050
    keynotif.Position = UDim2.new(0.5, 0, 0.1, 0)
    keynotif.Size = UDim2.new(0, 350, 0, 80)
    keynotif.ZIndex = 50
    
    local keynotifc = Instance.new("UICorner")
    keynotifc.CornerRadius = UDim.new(0, 12)
    keynotifc.Parent = keynotif
    
    local keynotiftext = Instance.new("TextLabel")
    keynotiftext.Parent = keynotif
    keynotiftext.BackgroundTransparency = 1
    keynotiftext.Position = UDim2.new(0.05, 0, 0.2, 0)
    keynotiftext.Size = UDim2.new(0.9, 0, 0.6, 0)
    keynotiftext.Font = Enum.Font.GothamBold
    keynotiftext.Text = "Press LEFT CONTROL to toggle UI"
    keynotiftext.TextColor3 = Color3.fromRGB(255, 255, 255)
    keynotiftext.TextSize = 16
    keynotiftext.TextWrapped = true
    keynotiftext.ZIndex = 50
    
    task.wait(3)
    keynotif:TweenPosition(UDim2.new(0.5, 0, -0.1, 0), "Out", "Quad", 0.5)
    task.wait(0.5)
    keynotif:Destroy()
    
    window = {}

    function window:ToggleVisible()
        if dbcooper then return end
        visible = not visible
        dbcooper = true
        if visible then
            if scrgui:FindFirstChild("minimizedcircle") then
                scrgui.minimizedcircle:Destroy()
            end
            tp(main, UDim2.new(0.5, 0, 0.5, 0), 0.5)
            task.wait(0.5)
            dbcooper = false
        else
            tp(main, main.Position + UDim2.new(0,0,2,0), 0.5)
            task.wait(0.5)
            
            -- Create minimized circle
            local circle = Instance.new("Frame")
            circle.Name = "minimizedcircle"
            circle.Parent = scrgui
            circle.AnchorPoint = Vector2.new(0.5, 0.5)
            circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            circle.Position = UDim2.new(0.9, 0, 0.1, 0)
            circle.Size = UDim2.new(0, 50, 0, 50)
            circle.ZIndex = 100
            
            local circlecorner = Instance.new("UICorner")
            circlecorner.CornerRadius = UDim.new(1, 0)
            circlecorner.Parent = circle
            
            local circletext = Instance.new("TextLabel")
            circletext.Parent = circle
            circletext.BackgroundTransparency = 1
            circletext.Size = UDim2.new(1, 0, 1, 0)
            circletext.Font = Enum.Font.GothamBold
            circletext.Text = "M"
            circletext.TextColor3 = Color3.fromRGB(20, 20, 20)
            circletext.TextSize = 24
            circletext.ZIndex = 100
            
            -- Make circle draggable
            local dragging2
            local dragInput2
            local dragStart2
            local startPos2
            
            local function update2(input)
                local delta = input.Position - dragStart2
                circle.Position = UDim2.new(startPos2.X.Scale, startPos2.X.Offset + delta.X, startPos2.Y.Scale, startPos2.Y.Offset + delta.Y)
            end
            
            circle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging2 = true
                    dragStart2 = input.Position
                    startPos2 = circle.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging2 = false
                        end
                    end)
                end
            end)
            
            circle.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    dragInput2 = input
                end
            end)
            
            game:GetService("UserInputService").InputChanged:Connect(function(input)
                if input == dragInput2 and dragging2 then
                    update2(input)
                end
            end)
            
            -- Click to open
            local clickdetect = Instance.new("TextButton")
            clickdetect.Parent = circle
            clickdetect.BackgroundTransparency = 1
            clickdetect.Size = UDim2.new(1, 0, 1, 0)
            clickdetect.Text = ""
            clickdetect.ZIndex = 101
            clickdetect.MouseButton1Click:Connect(function()
                window:ToggleVisible()
            end)
            
            dbcooper = false
        end
    end

    if visiblekey then
        minimize.MouseButton1Click:Connect(function()
            window:ToggleVisible()
        end)
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if input.KeyCode == Enum.KeyCode.LeftControl then
                window:ToggleVisible()
            end
        end)
    end

    function window:GreenButton(callback)
        if _G.gbutton_123123 then _G.gbutton_123123:Disconnect() end
        _G.gbutton_123123 = resize.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    function window:TempNotify(text1, text2, icon)
        for b,v in next, scrgui:GetChildren() do
            if v.Name == "tempnotif" then 
                v.Position += UDim2.new(0,0,0,130)
            end
        end
        local tempnotif = Instance.new("Frame")
        tempnotif.Name = "tempnotif"
        tempnotif.Parent = scrgui
        tempnotif.AnchorPoint = Vector2.new(0.5, 0.5)
        tempnotif.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        tempnotif.BackgroundTransparency = 0.050
        tempnotif.Position = UDim2.new(1, -250, 0.0794737339, 0)
        tempnotif.Size = UDim2.new(0, 447, 0, 117)
        tempnotif.Visible = true
        tempnotif.ZIndex = 4

        local uc_21 = Instance.new("UICorner")
        uc_21.CornerRadius = UDim.new(0, 18)
        uc_21.Parent = tempnotif

        local t2 = Instance.new("TextLabel")
        t2.Name = "t2"
        t2.Parent = tempnotif
        t2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        t2.BackgroundTransparency = 1
        t2.Position = UDim2.new(0.236927822, 0, 0.470085472, 0)
        t2.Size = UDim2.new(0, 326, 0, 52)
        t2.ZIndex = 4
        t2.Font = Enum.Font.Gotham
        t2.Text = text2
        t2.TextColor3 = Color3.fromRGB(180, 180, 180)
        t2.TextSize = 16
        t2.TextWrapped = true
        t2.TextXAlignment = Enum.TextXAlignment.Left
        t2.TextYAlignment = Enum.TextYAlignment.Top


        local t1 = Instance.new("TextLabel")
        t1.Name = "t1"
        t1.Parent = tempnotif
        t1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        t1.BackgroundTransparency = 1
        t1.Position = UDim2.new(0.234690696, 0, 0.193464488, 0)
        t1.Size = UDim2.new(0, 327, 0, 25)
        t1.ZIndex = 4
        t1.Font = Enum.Font.GothamMedium
        t1.Text = text1
        t1.TextColor3 = Color3.fromRGB(220, 220, 220)
        t1.TextSize = 28
        t1.TextXAlignment = Enum.TextXAlignment.Left


        local ticon = Instance.new("ImageLabel")
        ticon.Name = "ticon"
        ticon.Parent = tempnotif
        ticon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ticon.BackgroundTransparency = 1
        ticon.Position = UDim2.new(0.0311112702, 0, 0.193464488, 0)
        ticon.Size = UDim2.new(0, 71, 0, 71)
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
        tshadow.Size = UDim2.new(1.12, 0, 1.20000005, 0)
        tshadow.ZIndex = 3
        tshadow.Image = "rbxassetid://313486536"
        tshadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
        tshadow.ImageTransparency = 0.400
        tshadow.TileSize = UDim2.new(0, 1, 0, 1)
        game:GetService("Debris"):AddItem(tempnotif, 5)
    end

    function window:Notify(txt1, txt2, b1, icohn, callback)
        if notif.Visible == true or notif2.Visible == true then return "Already visible" end
        notiftitle.Text = txt1
        notiftext.Text = txt2
        notificon = icohn
        notif.Visible = true
        notifbutton1.Text = b1
        if callback then
            con1 = notifbutton1.MouseButton1Click:Connect(function()
                con1:Disconnect()
                callback()
                notif.Visible = false
            end)
        end
    end

    function window:Notify2(txt1, txt2, b1, b2, icohn, callback, callback2)
        if notif.Visible == true or notif2.Visible == true then return "Already visible" end
        notif2title.Text = txt1
        notif2text.Text = txt2
        notif2icon = icohn
        notif2.Visible = true
        notif2button1.Text = b1
        notif2button2.Text = b2
        if callback and callback2 then
            con1 = notif2button1.MouseButton1Click:Connect(function()
                con1:Disconnect()
                con2:Disconnect()
                callback()
                notif2.Visible = false
            end)
            con2 = notif2button2.MouseButton1Click:Connect(function()
                con1:Disconnect()
                con2:Disconnect()
                callback2()
                notif2.Visible = false
            end)
        end
    end

    function window:Section(name, icon)
        local sidebar2 = Instance.new("TextButton")
        sidebar2.Name = "sidebar2"
        sidebar2.Parent = sidebar
        sidebar2.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
        sidebar2.BackgroundTransparency = 1
        sidebar2.Size = UDim2.new(0, 145, 0, 36)
        sidebar2.ZIndex = 2
        sidebar2.AutoButtonColor = false
        sidebar2.Font = Enum.Font.GothamSemibold
        sidebar2.Text = "      " .. name
        sidebar2.TextColor3 = Color3.fromRGB(200, 200, 200)
        sidebar2.TextSize = 15
        sidebar2.TextXAlignment = Enum.TextXAlignment.Left
        
        local tabicon = Instance.new("ImageLabel")
        tabicon.Name = "tabicon"
        tabicon.Parent = sidebar2
        tabicon.BackgroundTransparency = 1
        tabicon.Position = UDim2.new(0.05, 0, 0.18, 0)
        tabicon.Size = UDim2.new(0, 22, 0, 22)
        tabicon.Image = icon or "rbxassetid://4871684504"
        tabicon.ImageColor3 = Color3.fromRGB(200, 200, 200)
        
        local uc_10 = Instance.new("UICorner")
        uc_10.CornerRadius = UDim.new(0, 9)
        uc_10.Parent = sidebar2
        table.insert(sections, sidebar2)

        local workareamain = Instance.new("ScrollingFrame")
        workareamain.Name = "workareamain"
        workareamain.Parent = workarea
        workareamain.Active = true
        workareamain.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        workareamain.BackgroundTransparency = 1
        workareamain.BorderSizePixel = 0
        workareamain.Position = UDim2.new(0.04, 0, 0.03, 0)
        workareamain.Size = UDim2.new(0, 400, 0, 305)
        workareamain.ZIndex = 3
        workareamain.CanvasSize = UDim2.new(0, 0, 0, 0)
        workareamain.ScrollBarThickness = 2
        workareamain.Visible = false

        local ull = Instance.new("UIListLayout")
        ull.Parent = workareamain
        ull.HorizontalAlignment = Enum.HorizontalAlignment.Center
        ull.SortOrder = Enum.SortOrder.LayoutOrder
        ull.Padding = UDim.new(0, 5)
    
        table.insert(workareas, workareamain)

        local sec = {}
        function sec:Select()
            for b, v in next, sections do
                v.BackgroundTransparency = 1
                v.TextColor3 = Color3.fromRGB(200, 200, 200)
                if v:FindFirstChild("tabicon") then
                    v.tabicon.ImageColor3 = Color3.fromRGB(200, 200, 200)
                end
            end
            sidebar2.BackgroundTransparency = 0
            sidebar2.TextColor3 = Color3.fromRGB(20, 20, 20)
            if sidebar2:FindFirstChild("tabicon") then
                tabicon.ImageColor3 = Color3.fromRGB(20, 20, 20)
            end
            for b, v in next, workareas do
                v.Visible = false
            end
            workareamain.Visible = true
        end
        function sec:Divider(name)
            local section = Instance.new("TextLabel")
            section.Name = "section"
            section.Parent = workareamain
            section.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            section.BackgroundTransparency = 1
            section.BorderSizePixel = 2
            section.Size = UDim2.new(0, 390, 0, 32)
            section.Font = Enum.Font.GothamBold
            section.LineHeight = 1.180
            section.Text = name
            section.TextColor3 = Color3.fromRGB(220, 220, 220)
            section.TextSize = 16
            section.TextWrapped = true
            section.TextXAlignment = Enum.TextXAlignment.Left
            section.TextYAlignment = Enum.TextYAlignment.Bottom
        end
        function sec:Button(name, callback)
            local button = Instance.new("TextButton")
            button.Name = "button"
            button.Text = name
            button.Parent = workareamain
            button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            button.BackgroundTransparency = 0
            button.Size = UDim2.new(0, 390, 0, 34)
            button.ZIndex = 2
            button.Font = Enum.Font.GothamSemibold
            button.TextColor3 = Color3.fromRGB(220, 220, 220)
            button.TextSize = 15

            local uc_3 = Instance.new("UICorner")
            uc_3.CornerRadius = UDim.new(0, 8)
            uc_3.Parent = button

            local us = Instance.new("UIStroke", button)
            us.ApplyStrokeMode = "Border"
            us.Color = Color3.fromRGB(60, 60, 60)
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
            label.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            label.BackgroundTransparency = 1
            label.BorderSizePixel = 2
            label.Size = UDim2.new(0, 390, 0, 34)
            label.Font = Enum.Font.Gotham
            label.TextColor3 = Color3.fromRGB(180, 180, 180)
            label.TextSize = 14
            label.TextWrapped = true
            label.Text = name
        end

        function sec:Switch(name, defaultmode, callback)
            local mode = defaultmode
            local toggleswitch = Instance.new("TextLabel")
            toggleswitch.Name = "toggleswitch"
            toggleswitch.Parent = workareamain
            toggleswitch.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            toggleswitch.BackgroundTransparency = 1
            toggleswitch.BorderSizePixel = 2
            toggleswitch.Size = UDim2.new(0, 390, 0, 34)
            toggleswitch.Font = Enum.Font.GothamSemibold
            toggleswitch.Text = name
            toggleswitch.TextColor3 = Color3.fromRGB(200, 200, 200)
            toggleswitch.TextSize = 15
            toggleswitch.TextWrapped = true
            toggleswitch.TextXAlignment = Enum.TextXAlignment.Left

            local Frame = Instance.new("TextButton")
            Frame.Parent = toggleswitch
            Frame.Position = UDim2.new(0.82, 0, 0.15, 0)
            Frame.Size = UDim2.new(0, 55, 0, 26)
            Frame.Text=""
            Frame.AutoButtonColor = false

            local uc_4 = Instance.new("UICorner")
            uc_4.CornerRadius = UDim.new(5, 0)
            uc_4.Parent = Frame

            local TextButton = Instance.new("TextButton")
            TextButton.Parent = Frame
            TextButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextButton.Size = UDim2.new(0, 24, 0, 24)
            TextButton.AutoButtonColor = false
            TextButton.Text = ""

            local uc_5 = Instance.new("UICorner")
            uc_5.CornerRadius = UDim.new(5, 0)
            uc_5.Parent = TextButton

            if defaultmode == false then
                TextButton.Position = UDim2.new(0, 1, 0, 1)
                Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            else
                TextButton.Position = UDim2.new(0, 30, 0, 1)
                Frame.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
            end

            Frame.MouseButton1Click:Connect(function()
                mode = not mode

                if callback then
                    callback(mode)
                end

                if mode then
                    TextButton:TweenPosition(UDim2.new(0, 30, 0, 1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
                else
                    TextButton:TweenPosition(UDim2.new(0,1,0,1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end)
            TextButton.MouseButton1Click:Connect(function()
                mode = not mode

                if callback then
                    callback(mode)
                end

                if mode then
                    TextButton:TweenPosition(UDim2.new(0, 30, 0, 1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
                else
                    TextButton:TweenPosition(UDim2.new(0,1,0,1), "In", "Sine", 0.1, true)
                    Frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                end
            end)
        end

        function sec:TextField(name, placeholder, callback)
            local textfield = Instance.new("TextLabel")
            textfield.Name = "textfield"
            textfield.Parent = workareamain
            textfield.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            textfield.BackgroundTransparency = 1
            textfield.BorderSizePixel = 2
            textfield.Size = UDim2.new(0, 390, 0, 34)
            textfield.Font = Enum.Font.GothamSemibold
            textfield.Text = name
            textfield.TextColor3 = Color3.fromRGB(200, 200, 200)
            textfield.TextSize = 15
            textfield.TextWrapped = true
            textfield.TextXAlignment = Enum.TextXAlignment.Left

            local Frame_2 = Instance.new("Frame")
            Frame_2.Parent = textfield
            Frame_2.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            Frame_2.Position = UDim2.new(0.48, 0, 0.15, 0)
            Frame_2.Size = UDim2.new(0, 190, 0, 26)

            local uc_6 = Instance.new("UICorner")
            uc_6.CornerRadius = UDim.new(0, 8)
            uc_6.Parent = Frame_2
            
            local us2 = Instance.new("UIStroke", Frame_2)
            us2.ApplyStrokeMode = "Border"
            us2.Color = Color3.fromRGB(60, 60, 60)
            us2.Thickness = 1

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = Frame_2
            TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            TextBox.BackgroundTransparency = 1
            TextBox.BorderColor3 = Color3.fromRGB(27, 42, 53)
            TextBox.BorderSizePixel = 0
            TextBox.ClipsDescendants = true
            TextBox.Position = UDim2.new(0.05, 0, 0, 0)
            TextBox.Size = UDim2.new(0, 175, 0, 26)
            TextBox.ClearTextOnFocus = false
            TextBox.Font = Enum.Font.Gotham
            TextBox.LineHeight = 0.870
            TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            TextBox.PlaceholderText = placeholder or "Type..."
            TextBox.Text = ""
            TextBox.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextBox.TextSize = 21
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = Frame_2
            TextBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TextBox.BackgroundTransparency = 1
            TextBox.BorderColor3 = Color3.fromRGB(27, 42, 53)
            TextBox.BorderSizePixel = 0
            TextBox.ClipsDescendants = true
            TextBox.Position = UDim2.new(0.05, 0, 0, 0)
            TextBox.Size = UDim2.new(0, 175, 0, 28)
            TextBox.ClearTextOnFocus = false
            TextBox.Font = Enum.Font.Gotham
            TextBox.LineHeight = 0.870
            TextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            TextBox.PlaceholderText = placeholder or "Type..."
            TextBox.Text = ""
            TextBox.TextColor3 = Color3.fromRGB(220, 220, 220)
            TextBox.TextSize = 16
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

            if callback then
                TextBox.FocusLost:Connect(function()
                    callback(TextBox.Text)
                end)
            end
        end

        sidebar2.MouseButton1Click:Connect(function()
            sec:Select()
        end)

        return sec
    end

    return window
end

return lib
