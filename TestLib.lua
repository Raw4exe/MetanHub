getgenv().Info = getgenv().Info or {}
Info.State = Info.State or {}
Info.Table = Info.Table or {}
Info.Integer = Info.Integer or {}

Info.State.ItemFarming = false
Info.State.AutoServerHop = false
Info.Integer.ItemCollectionDelay = 0.5
Info.Integer.StepDelay = 0.01
Info.Integer.BlacklistClearTime = tick()
Info.Table.FarmMode = "Fast"

Info.Table.AllItems = {
    "Diamond", "Gold Coin", "Mysterious Arrow", "Pure Rokakaka", "Rokakaka",
    "Stone Mask", "Rib Cage of The Saint's Corpse", "Steel Ball", "Ancient Scroll",
    "Dio's Diary", "Caesar's Headband", "Christmas Present", "Quinton's Glove",
    "Lucky Arrow", "Lucky Stone Mask"
}
Info.Table.SelectedItems = {}
Info.Table.ItemQueue = {}
Info.Table.CachedBodyParts = {}
Info.Table.BlacklistedServers = {}

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local UndergroundAnimation, Highlight, OriginalColors
local NoClipConnection, CameraConnection
local CurrentPatrolIndex = 1

local PatrolPositions = {
    CFrame.new(1, 0, -697), CFrame.new(-214, 0, 18), CFrame.new(-265, -30, -447),
    CFrame.new(113, 6, 71), CFrame.new(255, 5, -239), CFrame.new(-544, -25, -174),
    CFrame.new(1126, 116, -129), CFrame.new(-44, 0, -973), CFrame.new(182, -25, 578),
    CFrame.new(784, -42, 144), CFrame.new(-237, 284, 305), CFrame.new(421, 8, -287),
    CFrame.new(281, 0, 101), CFrame.new(125, -27, 438), CFrame.new(-667, 16, -299),
    CFrame.new(512, 2, 22), CFrame.new(-382, 0, -711), CFrame.new(-121, -24, 524),
    CFrame.new(-14, -0, -286), CFrame.new(-420, -34, -75), CFrame.new(264, -33, 112),
    CFrame.new(-142, -31, -577), CFrame.new(391, -31, -166), CFrame.new(917, 34, -17),
    CFrame.new(-452, -20, 206)
}

Player.CharacterAdded:Connect(function(NewChar)
    Character = NewChar
    table.clear(Info.Table.CachedBodyParts)
end)

Player.Idled:Connect(function()
    VirtualUser:ClickButton2(Vector2.new())
end)

task.spawn(function()
    while task.wait(1) do
        if tick() - Info.Integer.BlacklistClearTime >= 300 then
            Info.Table.BlacklistedServers = {}
            Info.Integer.BlacklistClearTime = tick()
        end
    end
end)

local Xenon = {}

Xenon.GetHRP = function()
    return Character:WaitForChild("HumanoidRootPart")
end

Xenon.GetHumanoid = function()
    return Character:WaitForChild("Humanoid")
end

Xenon.GetRemoteEvent = function()
    return Character:WaitForChild("RemoteEvent")
end

Xenon.PlayAnimation = function(AnimationID, AnimationSpeed, Time)
    local CreatedAnimation = Instance.new("Animation")
    CreatedAnimation.AnimationId = AnimationID
    local HumanoidEx = Xenon.GetHumanoid()
    local AnimatorEx = HumanoidEx:FindFirstChild("Animator") or HumanoidEx:WaitForChild("Animator", 3)
    local AnimationTrack = AnimatorEx:LoadAnimation(CreatedAnimation)
    AnimationTrack:Play()
    AnimationTrack:AdjustSpeed(AnimationSpeed)
    AnimationTrack.Priority = Enum.AnimationPriority.Action4
    AnimationTrack.TimePosition = Time
    return AnimationTrack
end

Xenon.MakeInvisible = function()
    local HUD = Player.PlayerGui:FindFirstChild("HUD")
    if HUD then
        HUD.Parent = StarterGui
    else
        pcall(function()
            StarterGui:FindFirstChild("HUD").Parent = Player.PlayerGui
            HUD = Player.PlayerGui:FindFirstChild("HUD")
        end)
    end
    UndergroundAnimation = Xenon.PlayAnimation("rbxassetid://7189062263", 0, 5)
    Player.Character = nil
    UndergroundAnimation:Stop()
    Player.Character = Character
    pcall(function()
        HUD.Parent = Player.PlayerGui
    end)
    local color = Color3.fromRGB(255, 255, 255)
    local darkerColor = Color3.new(color.R * 0.7, color.G * 0.7, color.B * 0.7)
    Highlight = Instance.new("Highlight")
    Highlight.Parent = Character
    Highlight.Enabled = true
    Highlight.FillColor = color
    Highlight.OutlineColor = darkerColor
    Highlight.FillTransparency = 0.5
    OriginalColors = {}
    for _, Part in Character:GetChildren() do
        if Part:IsA("BasePart") then
            OriginalColors[Part] = {Color = Part.Color, Material = Part.Material}
            Part.Material = Enum.Material.ForceField
            Part.Color = color
        end
    end
end

Xenon.MakeVisible = function()
    Xenon.PlayAnimation("rbxassetid://7189062263", 0, 5):Stop()
    if Highlight then
        Highlight:Destroy()
        Highlight = nil
    end
    if OriginalColors then
        for _, Part in Character:GetChildren() do
            if Part:IsA("BasePart") and OriginalColors[Part] then
                Part.Material = OriginalColors[Part].Material
                Part.Color = OriginalColors[Part].Color
            end
        end
        OriginalColors = {}
    end
end

Xenon.CountItem = function(Item)
    local Count = 0
    for _, CheckedItem in Player.Backpack:GetChildren() do
        if CheckedItem.Name == Item then
            Count = Count + 1
        end
    end
    if Character and Character:FindFirstChildWhichIsA("Tool") and Character:FindFirstChildWhichIsA("Tool").Name == Item then
        Count = Count + 1
    end
    return Count
end

Xenon.Has2X = function()
    local success, result = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 14597778)
    end)
    return success and result
end

Xenon.IsMax = function(Item)
    local MaxItems = {
        ["Diamond"] = 30, ["Gold Coin"] = 45, ["Mysterious Arrow"] = 25,
        ["Pure Rokakaka"] = 10, ["Rokakaka"] = 25, ["Stone Mask"] = 10,
        ["Rib Cage of The Saint's Corpse"] = 10, ["Steel Ball"] = 10,
        ["Ancient Scroll"] = 10, ["Dio's Diary"] = 10, ["Caesar's Headband"] = 10,
        ["Christmas Present"] = 40, ["Quinton's Glove"] = 10,
        ["Lucky Arrow"] = 10, ["Lucky Stone Mask"] = 10
    }
    if Xenon.Has2X() then
        for ItemName, ItemMax in MaxItems do
            MaxItems[ItemName] = ItemMax * 2
        end
    end
    return Xenon.CountItem(Item) >= MaxItems[Item]
end

Xenon.Sell = function(Item)
    Xenon.GetHumanoid():EquipTool(Player.Backpack:FindFirstChild(Item))
    Xenon.GetRemoteEvent():FireServer("EndDialogue", {
        NPC = "Merchant",
        Option = "Option1",
        Dialogue = "Dialogue5"
    })
end

Xenon.IdentifyItem = function(Item)
    repeat task.wait() until Item:FindFirstChild("ProximityPrompt")
    for _, Instance in Item:GetChildren() do
        if Instance:IsA("ProximityPrompt") and Instance.MaxActivationDistance > 0 then
            return Instance.ObjectText
        end
    end
    return "Invalid Item"
end

Xenon.AddToQueue = function(Item)
    local IdentifiedItem = Xenon.IdentifyItem(Item)
    if IdentifiedItem ~= "Invalid Item" then
        repeat task.wait() until Item:FindFirstChild("ProximityPrompt")
        local ItemData = {
            CFrame = Item.PrimaryPart.CFrame,
            Prompt = Item.ProximityPrompt,
            ItemName = IdentifiedItem,
            ItemModel = Item
        }
        Item.Name = IdentifiedItem
        Info.Table.ItemQueue[ItemData.Prompt] = ItemData
    end
end

Xenon.HasSelectedItems = function()
    for Prompt, Item in pairs(Info.Table.ItemQueue) do
        if table.find(Info.Table.SelectedItems, Item.ItemName) and Item.ItemModel.Parent then
            return true
        end
    end
    return false
end

Xenon.ServerHop = function()
    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data
    local server = servers[math.random(1, #servers)]
    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, Player)
end

Xenon.GetClosestItem = function()
    local hrp = Xenon.GetHRP()
    if not hrp then return nil end
    local closest, closestDist = nil, math.huge
    for Prompt, ItemData in pairs(Info.Table.ItemQueue) do
        if ItemData.ItemModel.Parent and ItemData.ItemModel.PrimaryPart then
            local ItemName = ItemData.ItemName
            if table.find(Info.Table.SelectedItems, ItemName) then
                local dist = (hrp.Position - ItemData.ItemModel.PrimaryPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = {item = ItemData.ItemModel, prompt = Prompt}
                end
            end
        end
    end
    return closest
end

Xenon.TeleportTo = function(targetCFrame)
    local hrp = Xenon.GetHRP()
    if not hrp then return end
    local targetPos = targetCFrame.Position
    local dist = (hrp.Position - targetPos).Magnitude
    while dist > 49 do
        local dir = (targetPos - hrp.Position).Unit
        hrp.CFrame = CFrame.new(hrp.Position + (dir * 49))
        task.wait(Info.Integer.StepDelay)
        dist = (hrp.Position - targetPos).Magnitude
    end
    hrp.CFrame = CFrame.new(targetPos)
end

Xenon.EnableNoClip = function()
    if NoClipConnection then NoClipConnection:Disconnect() end
    NoClipConnection = RunService.Stepped:Connect(function()
        if Info.State.ItemFarming and Player.Character then
            for _, part in Player.Character:GetDescendants() do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

Xenon.DisableNoClip = function()
    if NoClipConnection then
        NoClipConnection:Disconnect()
        NoClipConnection = nil
    end
    if Player.Character then
        for _, part in Player.Character:GetDescendants() do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

Xenon.EnableCameraUp = function()
    if CameraConnection then CameraConnection:Disconnect() end
    Camera.CameraType = Enum.CameraType.Custom
    CameraConnection = RunService.RenderStepped:Connect(function()
        if Info.State.ItemFarming and Player.Character then
            local hrp = Xenon.GetHRP()
            if hrp then
                Camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 25, 0), hrp.Position)
            end
        end
    end)
end

Xenon.DisableCameraUp = function()
    if CameraConnection then
        CameraConnection:Disconnect()
        CameraConnection = nil
    end
end

pcall(function()
    local OldNamecallTP
    OldNamecallTP = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local Arguments = {...}
        local Method = getnamecallmethod()
        if Method == "InvokeServer" and Arguments[1] == "idklolbrah2de" then
            return "  ___XP DE KEY"
        end
        return OldNamecallTP(self, ...)
    end))
end)

pcall(function()
    local FunctionLibrary = require(ReplicatedStorage:WaitForChild("Modules").FunctionLibrary)
    local Old = FunctionLibrary.pcall
    FunctionLibrary.pcall = function(...)
        local f = ...
        if type(f) == "function" and #getupvalues(f) == 11 then
            return
        end
        return Old(...)
    end
end)

if game.PlaceId == 2809202155 then
    pcall(function()
        local OldIndexItem
        OldIndexItem = hookfunction(getrawmetatable(Xenon.GetHRP().Position).__index, function(self, key)
            if getcallingscript().Name == "ItemSpawn" and key:lower() == "magnitude" then
                return 0
            end
            return OldIndexItem(self, key)
        end)
    end)
    
    task.spawn(function()
        for _, Item in workspace.Item_Spawns.Items:GetChildren() do
            Xenon.AddToQueue(Item)
        end
    end)
    workspace.Item_Spawns.Items.ChildAdded:Connect(function(Child)
        Xenon.AddToQueue(Child)
    end)
else
    local Folder = Instance.new("Folder", workspace)
    Folder.Name = "Item_Spawns"
    local Folder2 = Instance.new("Folder", Folder)
    Folder2.Name = "Items"
end

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Raw4exe/MetanHub/refs/heads/main/TestLib.lua"))()
local Library = Lib.Library
local UI = Library.new()
local MainTab = UI:CreateTab("Item Farm", "rbxassetid://7733960981")
local ItemFarmModule = MainTab:CreateModule({title = "Item Farm", section = "left", flag = "ItemFarmModule"})

local collectionDelaySlider = nil
local stepDelaySlider = nil

local function checkSliderIntegrity(name, slider)
    if slider then
        warn(name, "integrity check - Type:", slider.Type, "frame:", slider.frame and slider.frame.Name or "nil")
    end
end

ItemFarmModule:CreateCheckbox({
    title = "Enable Item Farm",
    flag = "ItemFarmCheckbox",
    default = false,
    callback = function(state)
        Info.State.ItemFarming = state
        if state then
            if #Info.Table.SelectedItems == 0 then
                Info.State.ItemFarming = false
                return
            end
            Xenon.MakeInvisible()
            if Info.Table.FarmMode == "Stud" then
                Xenon.EnableNoClip()
                Xenon.EnableCameraUp()
            else
                if #Info.Table.CachedBodyParts == 0 then
                    for _, Part in Character:GetDescendants() do
                        if (Part:IsA("BasePart") or Part:IsA("UnionOperation") or Part:IsA("MeshPart")) and Part.CanCollide == true then
                            table.insert(Info.Table.CachedBodyParts, Part)
                            Part.CanCollide = false
                        end
                    end
                else
                    for _, Part in Info.Table.CachedBodyParts do
                        Part.CanCollide = false
                    end
                end
            end
        else
            Xenon.MakeVisible()
            if Info.Table.FarmMode == "Stud" then
                Xenon.DisableNoClip()
                Xenon.DisableCameraUp()
            else
                if #Info.Table.CachedBodyParts ~= 0 then
                    for _, Part in Info.Table.CachedBodyParts do
                        Part.CanCollide = true
                    end
                end
            end
        end
        
        task.spawn(function()
            while Info.State.ItemFarming do
                if #Info.Table.SelectedItems == 0 then
                    task.wait(1)
                    continue
                end
                if Info.Table.FarmMode == "Fast" then
                    if Info.State.AutoServerHop and not Xenon.HasSelectedItems() then
                        Xenon.ServerHop()
                        return
                    end
                    local foundItem = false
                    for Prompt, Item in pairs(Info.Table.ItemQueue) do
                        if not Info.State.ItemFarming then break end
                        local ItemName = Item.ItemName
                        if not table.find(Info.Table.SelectedItems, ItemName) then continue end
                        if Item.ItemModel.Parent and table.find(Info.Table.SelectedItems, ItemName) then
                            foundItem = true
                            if Xenon.IsMax(ItemName) then Xenon.Sell(ItemName) end
                            Xenon.GetHRP().CFrame = Item.ItemModel.PrimaryPart.CFrame
                            task.wait(Info.Integer.ItemCollectionDelay)
                            local PickupStart = tick()
                            repeat
                                task.wait()
                                fireproximityprompt(Item.Prompt)
                            until Item.ItemModel.Parent ~= workspace.Item_Spawns.Items or tick() - PickupStart >= 3
                        end
                    end
                    task.wait(foundItem and 0.1 or 1)
                else
                    local target = Xenon.GetClosestItem()
                    if target then
                        local itemName = target.item.Name
                        if itemName and Xenon.IsMax(itemName) then Xenon.Sell(itemName) end
                        Xenon.TeleportTo(target.item.PrimaryPart.CFrame)
                        repeat task.wait() until target.prompt.Enabled
                        task.wait(Info.Integer.ItemCollectionDelay)
                        repeat
                            fireproximityprompt(target.prompt)
                            task.wait()
                        until not target.item.Parent
                    else
                        local hrp = Xenon.GetHRP()
                        if hrp then
                            Xenon.TeleportTo(PatrolPositions[CurrentPatrolIndex])
                            CurrentPatrolIndex = CurrentPatrolIndex + 1
                            if CurrentPatrolIndex > #PatrolPositions then
                                CurrentPatrolIndex = 1
                            end
                        end
                    end
                end
            end
        end)
    end
})

ItemFarmModule:CreateDropdown({
    title = "Farm Mode",
    flag = "FarmModeDropdown",
    options = {"Fast", "Stud"},
    multi_dropdown = false,
    maximum_options = 1,
    callback = function(value)
        Info.Table.FarmMode = value
        if value == "Stud" then
            if not collectionDelaySlider or collectionDelaySlider.Type ~= 'Slider' then
                warn("Creating collectionDelaySlider...")
                collectionDelaySlider = ItemFarmModule:CreateSlider({
                    title = "Collection Delay",
                    flag = "ItemCollectionDelaySlider",
                    minimum_value = 0,
                    maximum_value = 2,
                    value = 0.5,
                    round_number = false,
                    callback = function(val)
                        Info.Integer.ItemCollectionDelay = val
                    end
                })
                warn("Created collectionDelaySlider, Type:", collectionDelaySlider.Type, "frame.Name:", collectionDelaySlider.frame and collectionDelaySlider.frame.Name or "nil")
            else
                warn("collectionDelaySlider already exists, skipping creation")
            end
            if not stepDelaySlider or stepDelaySlider.Type ~= 'Slider' then
                warn("Creating stepDelaySlider...")
                stepDelaySlider = ItemFarmModule:CreateSlider({
                    title = "Step Delay",
                    flag = "StepDelaySlider",
                    minimum_value = 0,
                    maximum_value = 0.5,
                    value = 0.01,
                    round_number = false,
                    callback = function(val)
                        Info.Integer.StepDelay = val
                    end
                })
                warn("Created stepDelaySlider, Type:", stepDelaySlider.Type, "frame.Name:", stepDelaySlider.frame and stepDelaySlider.frame.Name or "nil")
            else
                warn("stepDelaySlider already exists, skipping creation")
            end
            ItemFarmModule:RefreshSize()
        else
            warn("Switching to Fast mode, about to remove sliders")
            checkSliderIntegrity("collectionDelaySlider before remove", collectionDelaySlider)
            checkSliderIntegrity("stepDelaySlider before remove", stepDelaySlider)
            if collectionDelaySlider then
                ItemFarmModule:RemoveElement(collectionDelaySlider)
                collectionDelaySlider = nil
            end
            if stepDelaySlider then
                ItemFarmModule:RemoveElement(stepDelaySlider)
                stepDelaySlider = nil
            end
        end
    end
})

ItemFarmModule:CreateCheckbox({
    title = "Auto Server Hop",
    flag = "AutoServerHopCheckbox",
    default = false,
    callback = function(state)
        Info.State.AutoServerHop = state
    end
})

ItemFarmModule:CreateDropdown({
    title = "Select Items",
    flag = "ItemsDropdown",
    options = Info.Table.AllItems,
    multi_dropdown = true,
    maximum_options = #Info.Table.AllItems,
    callback = function(selected)
        Info.Table.SelectedItems = selected
    end
})

UI:CreateSettingsTab()
UI:Load()
