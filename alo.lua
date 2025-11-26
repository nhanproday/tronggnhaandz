local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Biến toàn cục
local AutoHeal = false
local AutoFarm = false
local AutoFarmGiangho = false
local AutoBangGacFr = false
local AttackWeapon
local DisableALLautogiangho = false
local AutoAttack = false
local NoclipEnabled = false
local WasNoclipEnabledBeforeLoot = false
local IsLooting = false
local LootEndTime = 0
local RainbowFireEnabled = false
local LockCameraEnabled = false
local OriginalCameraCFrame = nil
local AutoLoot = false
local LootFreezeEnabled = false
local UserRadius = 15
local UserSpeed = 25

-- ========== PHẦN THANH MÁU BOSS ==========
local bossHealthGui = Instance.new("ScreenGui")
bossHealthGui.Name = "BossHealthGUI"
bossHealthGui.IgnoreGuiInset = true
bossHealthGui.ResetOnSpawn = false
bossHealthGui.Parent = game:GetService("CoreGui")

local healthBarContainer = Instance.new("Frame")
healthBarContainer.Name = "HealthBarContainer"
healthBarContainer.Size = UDim2.new(0.3, 0, 0, 60)
healthBarContainer.Position = UDim2.new(0.35, 0, 0.02, 0)
healthBarContainer.BackgroundColor3 = Color3.new(0, 0, 0)
healthBarContainer.BackgroundTransparency = 0.2
healthBarContainer.BorderSizePixel = 2
healthBarContainer.BorderColor3 = Color3.new(1, 1, 1)
healthBarContainer.Visible = false
healthBarContainer.Parent = bossHealthGui

local bossNameLabel = Instance.new("TextLabel")
bossNameLabel.Name = "BossNameLabel"
bossNameLabel.Size = UDim2.new(1, 0, 0.5, 0)
bossNameLabel.Position = UDim2.new(0, 0, 0, 0)
bossNameLabel.BackgroundTransparency = 1
bossNameLabel.TextColor3 = Color3.new(1, 1, 1)
bossNameLabel.Text = "NPC2 HP: 0 / 0"
bossNameLabel.Font = Enum.Font.GothamBold
bossNameLabel.TextSize = 18
bossNameLabel.TextXAlignment = Enum.TextXAlignment.Center
bossNameLabel.Parent = healthBarContainer

local healthBarBackground = Instance.new("Frame")
healthBarBackground.Name = "HealthBarBackground"
healthBarBackground.Size = UDim2.new(0.9, 0, 0, 20)
healthBarBackground.Position = UDim2.new(0.05, 0, 0.6, 0)
healthBarBackground.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
healthBarBackground.BorderSizePixel = 1
healthBarBackground.BorderColor3 = Color3.new(1, 1, 1)
healthBarBackground.Parent = healthBarContainer

local healthBar = Instance.new("Frame")
healthBar.Name = "HealthBar"
healthBar.Size = UDim2.new(1, 0, 1, 0)
healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
healthBar.BorderSizePixel = 0
healthBar.Parent = healthBarBackground

local function updateBossHealthBar(health, maxHealth)
    if healthBarContainer then
        local healthPercent = health / maxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        if healthPercent > 0.7 then
            healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
        elseif healthPercent > 0.3 then
            healthBar.BackgroundColor3 = Color3.new(1, 1, 0)
        else
            healthBar.BackgroundColor3 = Color3.new(1, 0, 0)
        end
        
        bossNameLabel.Text = string.format("NPC2 HP: %d / %d", math.floor(health), math.floor(maxHealth))
    end
end

local function setBossHealthBarVisible(visible)
    if healthBarContainer then
        healthBarContainer.Visible = visible
    end
end

local BILLBOARD_NAME = "GH2HealthBillboard"

local function getBoss2()
    local gh2 = workspace:FindFirstChild("GiangHo2")
    if not gh2 then return nil end
    local npcs = gh2:FindFirstChild("NPCs")
    if not npcs then return nil end
    return npcs:FindFirstChild("NPC2")
end

local function getOrCreateSimpleBillboard(head)
    if not head then return nil end
    local billboard = head:FindFirstChild(BILLBOARD_NAME)
    if not billboard then
        billboard = Instance.new("BillboardGui")
        billboard.Name = BILLBOARD_NAME
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.7, 0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = head
        billboard.Parent = head

        local label = Instance.new("TextLabel")
        label.Name = "HealthLabel"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.2
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        label.Text = ""
        label.Parent = billboard

        local healthBarBackground = Instance.new("Frame")
        healthBarBackground.Name = "HealthBarBackground"
        healthBarBackground.Size = UDim2.new(1, 0, 0.2, 0)
        healthBarBackground.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        healthBarBackground.BorderSizePixel = 0
        healthBarBackground.Parent = billboard

        local healthBar = Instance.new("Frame")
        healthBar.Name = "HealthBar"
        healthBar.Size = UDim2.new(1, 0, 1, 0)
        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBarBackground
    end
    return billboard
end

local function removeBillboard(head)
    if head then
        local billboard = head:FindFirstChild(BILLBOARD_NAME)
        if billboard then
            billboard:Destroy()
        end
    end
end

local lastHead = nil
local lastBoss = nil

RunService.Heartbeat:Connect(function()
    local npc = getBoss2()
    
    if AutoFarm and npc and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
        local h = npc.Humanoid  
        local head = npc.Head 
        
        setBossHealthBarVisible(true)
        updateBossHealthBar(h.Health, h.MaxHealth)
        
        local billboard = getOrCreateSimpleBillboard(head)  
        lastHead = head
        lastBoss = npc

        if h.Health > 0 then
            billboard.Enabled = true
            local label = billboard:FindFirstChild("HealthLabel")
            local healthBar = billboard:FindFirstChild("HealthBarBackground"):FindFirstChild("HealthBar")
            if label then
                label.Text = string.format("%d/%d", math.floor(h.Health), math.floor(h.MaxHealth))
            end
            if healthBar then
                healthBar.Size = UDim2.new(h.Health / h.MaxHealth, 0, 1, 0)
            end
        else
            billboard.Enabled = false
        end
    else
        if not AutoFarm or not npc then
            setBossHealthBarVisible(false)
        end
        
        if lastHead then
            removeBillboard(lastHead)
            lastHead = nil
        end
    end
end)

-- ========== PHẦN HITBOX ==========
local HeadSize = 10
local HitboxEnabled = false
local hitboxPlayers = {}

local function updateHitboxPlayers()
    hitboxPlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(hitboxPlayers, plr)
        end
    end
end

-- Hitbox loop
task.spawn(function()
    while true do
        if HitboxEnabled then
            for _, plr in ipairs(hitboxPlayers) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(HeadSize, HeadSize, HeadSize)
                    hrp.Transparency = 0.5
                    hrp.BrickColor = BrickColor.new("Really blue")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end
            end
        else
            for _, plr in ipairs(hitboxPlayers) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new2, 2, 1)
                    hrp.Transparency = 1
                    hrp.CanCollide = false
                end
            end
        end
        updateHitboxPlayers()
        task.wait(0.1)
    end
end)

-- Noclip System
local function noclipLoop()
    if NoclipEnabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

RunService.Stepped:Connect(noclipLoop)

-- Weapon System
local canEquip = true

function EquipWeapon(name)
    local tool = player.Backpack:FindFirstChild(name)
    if tool then
        tool.Parent = player.Character
        print("Đã trang bị vũ khí: " .. name)
        return true
    end
    return false
end

function RequestFromInventory(name)
    local args = {
        "eue",  
        name    
    }
    ReplicatedStorage
        :WaitForChild("KnitPackages")
        :WaitForChild("_Index")
        :WaitForChild("sleitnick_knit@1.7.0")
        :WaitForChild("knit")
        :WaitForChild("Services")
        :WaitForChild("InventoryService")
        :WaitForChild("RE")
        :WaitForChild("updateInventory")
        :FireServer(unpack(args))
end

-- GUI Library
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Akzai Hub - CDVN ",
    SubTitle = "Make By Trọng Nhân",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 300),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Auto Băng Gạc", Icon = "package" }),
    framboss = Window:AddTab({ Title = "Farm Boss", Icon = "sword" }),
    Detector = Window:AddTab({ Title = "webhook", Icon = "link" }),
    FixLag = Window:AddTab({ Title = "Fix Lag", Icon = "cpu" }),
    MoneyTab = Window:AddTab({ Title = "fram tiền", Icon = "dollar-sign" }),
    PvPTab = Window:AddTab({ Title = "PvP", Icon = "swords" })
}

-- Thêm hitbox controls vào tab PvP
Tabs.PvPTab:AddInput("HitboxSizeInput", {
    Title = "Kích thước Hitbox",
    Default = "10",
    Placeholder = "Nhập kích thước hitbox",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            HeadSize = num
        end
    end
})

Tabs.PvPTab:AddToggle("HitboxToggle", {
    Title = "Bật Hitbox",
    Default = false,
    Callback = function(state)
        HitboxEnabled = state
    end
})

-- Auto Băng Gạc Tab
Tabs.Main:AddButton({
    Title = "Tắt Balo",
    Callback = function()
        local playerGui = player:WaitForChild("PlayerGui")
        local inv = playerGui:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild("MainFrame") then
            inv.MainFrame.Visible = false
        end
    end
})

Tabs.Main:AddButton({
    Title = "Bật Lại Balo",
    Callback = function()
        local playerGui = player:WaitForChild("PlayerGui")
        local inv = playerGui:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild("MainFrame") then
            inv.MainFrame.Visible = true
        end
    end
})

local AutoBangGac = false
local CanUseBandage = true

Tabs.Main:AddToggle("AutoBangGac", {
    Title = "Auto Băng Gạc (HP < 60)",
    Default = false,
    Callback = function(state) AutoBangGac = state end
})

local function GetBackpack(itemName)
    pcall(function()
        local Knit = game:GetService("ReplicatedStorage"):WaitForChild("KnitPackages")
            :WaitForChild("_Index"):WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit")
        local RE = Knit.Services.InventoryService.RE.updateInventory
        RE:FireServer("refresh")
        task.wait(1)
        RE:FireServer("eue", itemName)
    end)
end

task.spawn(function()
    while task.wait(1) do
        if AutoBangGac and CanUseBandage then
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local backpack = player:FindFirstChildOfClass("Backpack")
            if humanoid and humanoid.Health < 80 then
                CanUseBandage = false
                if backpack and not backpack:FindFirstChild("băng gạc") then
                    GetBackpack("băng gạc")
                    task.wait(1.5)
                end
                local tool = backpack and backpack:FindFirstChild("băng gạc")
                if tool then
                    humanoid:EquipTool(tool)
                    task.wait(0.3)
                    tool:Activate()
                end
                repeat task.wait(1) until (humanoid.Health > 80) or (not AutoBangGac)
                task.wait(2)
                CanUseBandage = true
            end
        end
    end
end)

local AutoBuyBandage = false

Tabs.Main:AddToggle("AutoBuyBandage", {
    Title = "Auto Mua Băng Gạc (5s)",
    Default = false,
    Callback = function(state) AutoBuyBandage = state end
})

task.spawn(function()
    while task.wait(5) do
        if AutoBuyBandage then
            pcall(function()
                local args = {"băng gạc", 5}
                local ShopRE = game:GetService("ReplicatedStorage")
                    :WaitForChild("KnitPackages"):WaitForChild("_Index")
                    :WaitForChild("sleitnick_knit@1.7.0"):WaitForChild("knit")
                    :WaitForChild("Services"):WaitForChild("ShopService")
                    :WaitForChild("RE"):WaitForChild("buyItem")
                ShopRE:FireServer(unpack(args))
            end)
        end
    end
end)

-- Farm Boss Tab
Tabs.framboss:AddToggle("NoclipToggle", {
    Title = "Noclip (Xuyên tường)",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
    end
})

Tabs.framboss:AddToggle("AutoAttackToggle", {
    Title = "Auto Đánh",
    Default = false,
    Callback = function(state)
        AutoAttack = state
    end
})

-- Rainbow Fire System
local rainbowFireParts = {}
local rainbowFireConnections = {}

local function AddRainbowFireToTool(tool)
    if rainbowFireParts[tool] then return end
    
    local handle = tool:FindFirstChild("Handle")
    if not handle then return end
    
    local fire = Instance.new("Fire")
    fire.Name = "RainbowFire"
    fire.Size = 5
    fire.Heat = 2
    fire.Color = Color3.new(1, 0, 0)
    fire.SecondaryColor = Color3.new(1, 1, 0)
    fire.Parent = handle
    
    rainbowFireParts[tool] = fire
    
    task.spawn(function()
        local hue = 0
        while RainbowFireEnabled and fire and fire.Parent do
            hue = (hue + 0.01) % 1
            local color = Color3.fromHSV(hue, 1, 1)
            fire.Color = color
            fire.SecondaryColor = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
            task.wait(0.1)
        end
    end)
end

local function StartRainbowFire()
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") then
            AddRainbowFireToTool(tool)
        end
    end
    
    for _, tool in pairs(player.Character:GetChildren()) do
        if tool:IsA("Tool") then
            AddRainbowFireToTool(tool)
        end
    end
    
    rainbowFireConnections.backpack = player.Backpack.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            AddRainbowFireToTool(tool)
        end
    end)
    
    rainbowFireConnections.character = player.Character.ChildAdded:Connect(function(tool)
        if tool:IsA("Tool") then
            AddRainbowFireToTool(tool)
        end
    end)
end

local function StopRainbowFire()
    for _, connection in pairs(rainbowFireConnections) do
        connection:Disconnect()
    end
    rainbowFireConnections = {}
    
    for tool, fire in pairs(rainbowFireParts) do
        if fire and fire.Parent then
            fire:Destroy()
        end
    end
    rainbowFireParts = {}
end

Tabs.framboss:AddToggle("RainbowFireToggle", {
    Title = "Lửa Cầu Vồng",
    Default = false,
    Callback = function(state)
        RainbowFireEnabled = state
        if state then
            StartRainbowFire()
        else
            StopRainbowFire()
        end
    end
})

-- Lock Camera System
local function StartLockCamera()
    local camera = workspace.CurrentCamera
    OriginalCameraCFrame = camera.CFrame
    
    task.spawn(function()
        while LockCameraEnabled do
            camera.CFrame = OriginalCameraCFrame
            RunService.RenderStepped:Wait()
        end
    end)
end

local function StopLockCamera()
end

Tabs.framboss:AddToggle("LockCameraToggle", {
    Title = "Khóa Camera",
    Default = false,
    Callback = function(state)
        LockCameraEnabled = state
        if state then
            StartLockCamera()
        else
            StopLockCamera()
        end
    end
})

-- Weapon Selection
local weaponButton = Tabs.framboss:AddButton({
    Title = "Select Weapon",
    Description = "Weapon Hiện Tại : None",
    Callback = function()
        local weaponButtons = {}
        for i, v in pairs(player.Backpack:GetChildren()) do
            table.insert(weaponButtons, {
                Title = v.Name,
                Callback = function()
                    AttackWeapon = v.Name
                    print("Vũ khí đã chọn: " .. v.Name)
                end
            })
        end
        for i, v in pairs(player.Character:GetChildren()) do
            if v:IsA("Tool") then
                table.insert(weaponButtons, {
                    Title = v.Name,
                    Callback = function()
                        AttackWeapon = v.Name
                        print("Vũ khí đã chọn: " .. v.Name)
                    end
                })
            end
        end

        Window:Dialog({
            Title = "Select Weapon",
            Content = "Chọn một vũ khí:",
            Buttons = weaponButtons
        })
    end
})

task.spawn(function()
    while task.wait() do
        if AttackWeapon then
            weaponButton:SetDesc("Weapon Hiện Tại : " .. AttackWeapon)
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if AttackWeapon and canEquip then
            canEquip = false
            
            if player.Character:FindFirstChild(AttackWeapon) then
                print("Vũ khí đã có trong nhân vật.")
            elseif player.Backpack:FindFirstChild(AttackWeapon) then
                EquipWeapon(AttackWeapon)
            else
                RequestFromInventory(AttackWeapon)
            end
            
            task.wait(1)
            canEquip = true
        end
    end
end)

-- Auto Farm System
Tabs.framboss:AddToggle("AutoFarmToggle", { 
    Title = "Farm Boss", 
    Default = false,
    Callback = function(val) 
        AutoFarm = val 
        if val then 
            StartAutoFarm() 
        else
            setBossHealthBarVisible(false)
        end
    end
})

-- Auto Loot System
local function isBossAlive()
    local npc = getBoss2()
    return npc and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0
end

local function resetLootState()
    if WasNoclipEnabledBeforeLoot then
        NoclipEnabled = true
        WasNoclipEnabledBeforeLoot = false
    end
    IsLooting = false
    LootFreezeEnabled = false
    
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.PlatformStand = false
        humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

Tabs.framboss:AddToggle("AutoLootToggle", { 
    Title = "Auto Loot (Range 500)", 
    Default = false,
    Callback = function(val) 
        AutoLoot = val 
        if val then
            StartAutoLoot()
        else
            resetLootState()
        end
    end
})

function StartAutoLoot()
    task.spawn(function()
        while AutoLoot do
            task.wait(0.5)
            
            local foundItem = false
            for _, drop in pairs(workspace.GiangHo2.Drop:GetChildren()) do
                local prompt = drop:FindFirstChild("ProximityPrompt") or drop:FindFirstChildOfClass("ProximityPrompt")
                if prompt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - drop.Position).Magnitude
                    if distance <= 500 then
                        foundItem = true
                        
                        if NoclipEnabled and not IsLooting then
                            WasNoclipEnabledBeforeLoot = true
                            NoclipEnabled = false
                            IsLooting = true
                            LootFreezeEnabled = true
                            LootEndTime = tick() + 30
                        end
                        
                        player.Character.HumanoidRootPart.CFrame = drop.CFrame
                        
                        if LootFreezeEnabled then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if humanoid and hrp then
                                humanoid.PlatformStand = true
                                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            end
                        end
                        
                        fireproximityprompt(prompt)
                        task.wait(0.1)
                    end
                end
            end
            
            if IsLooting then
                if tick() >= LootEndTime then
                    resetLootState()
                end
                
                if isBossAlive() then
                    resetLootState()
                end
                
                if not foundItem and tick() >= LootEndTime - 25 then
                    resetLootState()
                end
                
                if not AutoLoot then
                    resetLootState()
                end
            end
        end
    end)
end

-- Farm Settings
local radiusInput = Tabs.framboss:AddInput("RadiusInput", {
    Title = "Khoảng cách",
    Default = tostring(UserRadius),
    Placeholder = "Nhập khoảng cách (vd: 20)",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            UserRadius = num
        end
    end
})

local speedInput = Tabs.framboss:AddInput("SpeedInput", {
    Title = "Tốc độ quay",
    Default = tostring(UserSpeed),
    Placeholder = "Nhập tốc độ quay (vd: 2.5)",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            UserSpeed = num
        end
    end
})

function StartAutoFarm()
    task.spawn(function()
        while AutoFarm do
            local boss = nil

            for _, v in pairs(workspace.GiangHo2.NPCs:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                    boss = v
                    break
                end
            end

            if boss then
                local bossRoot = boss:FindFirstChild("HumanoidRootPart")
                if bossRoot then
                    if not NoclipEnabled then
                        NoclipEnabled = true
                    end
                    
                    if LootFreezeEnabled then
                        LootFreezeEnabled = false
                        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid.PlatformStand = false
                        end
                    end
                    
                    CircleAroundBoss(bossRoot)
                end

                if player.Character and AttackWeapon and not player.Character:FindFirstChild(AttackWeapon) then
                    EquipWeapon(AttackWeapon)
                end

                while AutoFarm and boss and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 do
                    task.wait()
                end

                task.wait(5)
            else
                task.wait()
            end
        end
    end)
end

function CircleAroundBoss(bossRoot)
    task.spawn(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or not bossRoot then return end

        local radius, speed, angle = UserRadius, UserSpeed, 0

        while AutoFarm and bossRoot.Parent and bossRoot.Parent:FindFirstChild("Humanoid") and bossRoot.Parent.Humanoid.Health > 0 do
            angle = angle + speed * task.wait()
            angle = angle % (2 * math.pi)

            local pos = bossRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            root.CFrame = CFrame.lookAt(pos + Vector3.new(0, 2, 0), bossRoot.Position)

            if AutoAttack then
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
            end
        end
    end)
end

Tabs.framboss:AddButton({
    Title = "Tele vào chỗ boss",
    Description = "Tele vào chỗ boss",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")

        local targetCFrame = CFrame.new(
            -2572.62158, 279.985016, -1368.58911,
             0.679292798, 2.51945931e-08, -0.733867347,
             1.43844403e-08, 1, 4.76459938e-08,
             0.733867347, -4.2921851e-08, 0.679292798
        )

        hrp.CFrame = targetCFrame
    end
})

-- Webhook Detector
local webhookUrl = ""
local detecting = false
local seen = {}
local radius = 50
local heartbeatConn

local function getVNTimeString()
    return os.date("%d/%m/%Y %H:%M:%S")
end

local function sendEmbed(itemName)
    if webhookUrl == "" then return end

    local embed = {
        title = "Item Spawn!",
        description = ("Phát hiện **%s** gần bạn!"):format(itemName:upper()),
        color = 65280,
        fields = {
            { name = "Thời gian (VN)", value = getVNTimeString(), inline = true },
            { name = "Người chơi", value = player.Name .. " (UserId: " .. player.UserId .. ")", inline = true },
        },
        footer = { text = "Loot Alert System" }
    }

    local req = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)
    if req then
        req({
            Url = webhookUrl,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ embeds = { embed } })
        })
    end
end

local function getAnyPos(inst)
    if inst:IsA("BasePart") then return inst.Position end
    if inst:IsA("Tool") then
        local p = inst:FindFirstChildWhichIsA("BasePart"); if p then return p.Position end
    end
    if inst:IsA("Model") then
        local pp = inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart"); if pp then return pp.Position end
    end
    return nil
end

local function getLootNameAndPos(inst)
    if inst.Name == "Cash" or inst.Name == "Chest" then
        local pos = getAnyPos(inst); if pos then return inst.Name, pos end
    end
    local p = inst.Parent
    if p and (p.Name == "Cash" or p.Name == "Chest") then
        local pos = getAnyPos(p) or getAnyPos(inst); if pos then return p.Name, pos end
    end
    return nil, nil
end

local function startDetecting()
    heartbeatConn = RunService.Heartbeat:Connect(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, inst in ipairs(workspace:GetDescendants()) do
            if inst:IsA("BasePart") or inst:IsA("Model") or inst:IsA("Tool") then
                local name, pos = getLootNameAndPos(inst)
                if name and pos and (pos - hrp.Position).Magnitude <= radius then
                    if not seen[inst] then
                        seen[inst] = tick()
                        sendEmbed(name)
                    end
                end
            end
        end

        for obj, t in pairs(seen) do
            if tick() - t > 10 then
                seen[obj] = nil
            end
        end
    end)
end

local function stopDetecting()
    if heartbeatConn then
        heartbeatConn:Disconnect()
        heartbeatConn = nil
    end
end

Tabs.Detector:AddInput("WebhookInput", {
    Title = "Webhook URL",
    Default = "",
    Placeholder = "Dán link webhook vào đây...",
    Callback = function(Value)
        webhookUrl = Value
    end
})

Tabs.Detector:AddToggle("DetectorToggle", {
    Title = "Bật Detector",
    Default = false,
    Callback = function(Value)
        detecting = Value
        if detecting then
            startDetecting()
        else
            stopDetecting()
        end
    end
})

-- Fix Lag Tab
local function clearGraphics(level)
    local Lighting = game:GetService("Lighting")
    local Terrain = workspace:FindFirstChildOfClass("Terrain")

    if level >= 10 then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end

    if level >= 20 then
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("SunRaysEffect") then
                v.Enabled = false
            end
        end
    end

    if level >= 30 then
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("ColorCorrectionEffect") or v:IsA("BlurEffect") then
                v.Enabled = false
            end
        end
    end

    if level >= 40 and Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
    end

    if level >= 50 then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Material = Enum.Material.SmoothPlastic
            end
        end
    end

    if level >= 60 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            end
        end
    end

    if level >= 70 then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            elseif obj:IsA("MeshPart") then
                obj.TextureID = ""
            end
        end
    end

    if level >= 80 then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.new(1,1,1)
            end
        end
    end
end

for _, lvl in ipairs({10,20,30,40,50,60,70,80}) do
    Tabs.FixLag:AddButton({
        Title = "Xóa Đồ Họa " .. lvl .. "%",
        Callback = function()
            clearGraphics(lvl)
        end
    })
end

local whiteGui = nil
Tabs.FixLag:AddToggle("WhiteScreenToggle", {
    Title = "White Screen Mode",
    Default = false,
    Callback = function(Value)
        if Value then
            if not whiteGui then
                whiteGui = Instance.new("ScreenGui")
                whiteGui.Name = "WhiteScreen"
                whiteGui.IgnoreGuiInset = true
                whiteGui.ResetOnSpawn = false
                whiteGui.Parent = game:GetService("CoreGui")

                local frame = Instance.new("Frame")
                frame.BackgroundColor3 = Color3.new(1,1,1)
                frame.Size = UDim2.new(1,0,1,0)
                frame.Parent = whiteGui
            end
        else
            if whiteGui then
                whiteGui:Destroy()
                whiteGui = nil
            end
        end
    end
})

-- Money Tracker
local leaderstats = player:WaitForChild("leaderstats")
local VND = leaderstats:WaitForChild("VND")

local function formatNumber(n)
    local str = tostring(n)
    local result
    while true do
        str, k = str:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        result = str
        if k == 0 then break end
    end
    return result
end

local totalEarned = 0
local lastValue = VND.Value

local earnedLabel = Tabs.MoneyTab:AddParagraph({
    Title = "Đếm Số Tiền Đã Farm",
    Content = formatNumber(totalEarned) .. " VND"
})

local currentLabel = Tabs.MoneyTab:AddParagraph({
    Title = "Số Tiền Hiện Tại",
    Content = formatNumber(lastValue) .. " VND"
})

Tabs.MoneyTab:AddButton({
    Title = "Reset đếm số tiền farm lại đầu",
    Callback = function()
        totalEarned = 0
        earnedLabel:SetDesc(formatNumber(totalEarned) .. " VND")
    end
})

VND:GetPropertyChangedSignal("Value"):Connect(function()
    local newValue = VND.Value
    if newValue > lastValue then
        local gained = newValue - lastValue
        totalEarned = totalEarned + gained
        earnedLabel:SetDesc(formatNumber(totalEarned) .. " VND")
    end
    currentLabel:SetDesc(formatNumber(newValue) .. " VND")
    lastValue = newValue
end)

-- Anti AFK
local antiAfkEnabled = false
local antiAfkConn

Tabs.MoneyTab:AddToggle("AntiAFKToggle", {
    Title = "Anti AFK ",
    Default = false,
    Callback = function(state)
        antiAfkEnabled = state
        if antiAfkEnabled then
            if antiAfkConn then antiAfkConn:Disconnect() end
            antiAfkConn = Players.LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        else
            if antiAfkConn then
                antiAfkConn:Disconnect()
                antiAfkConn = nil
            end
        end
    end
})

-- PvP Tab
local LocalPlayer = Players.LocalPlayer
local spinning, spinSpeed = false, 5
local selectedTarget, aiming = nil, false
local espEnabled = false
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = workspace

Tabs.PvPTab:AddSlider("SpinSpeedSlider", {
    Title = "Tốc độ Spin",
    Min = 1,
    Max = 10000,
    Default = 5,
    Rounding = 1,
    Callback = function(val)
        spinSpeed = val
    end
})

Tabs.PvPTab:AddToggle("PvPSpinToggle", {
    Title = "PvP Spin (Xoay liên tục)",
    Default = false,
    Callback = function(state)
        spinning = state
        local char = LocalPlayer.Character
        if not char then return end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not hrp then return end

        if state then
            humanoid.AutoRotate = false
            task.spawn(function()
                while spinning and humanoid and hrp do
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0)
                    task.wait(0.03)
                end
            end)
        else
            humanoid.AutoRotate = true
        end
    end
})

LocalPlayer.CharacterAdded:Connect(function(char)
    if spinning then
        task.wait(0.5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then humanoid.AutoRotate = false end
    end
end)

Tabs.PvPTab:AddToggle("MaxLevelToggle", {
    Title = "inf stamina",
    Default = false,
    Callback = function(state)
        if state then
            local stats = LocalPlayer:FindFirstChild("stats")
            local level = stats and stats:FindFirstChild("Level")
            if level then
                level.Value = 1e9
            end
        end
    end
})

local function GetPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

Tabs.PvPTab:AddToggle("ESPToggle", {
    Title = "Hiện ESP Line & Tên",
    Default = false,
    Callback = function(state)
        espEnabled = state
        if not espEnabled then
            for _, obj in pairs(ESPFolder:GetChildren()) do
                obj:Destroy()
            end
        end
    end
})

local aimConnection
Tabs.PvPTab:AddToggle("AimPlayerToggle", {
    Title = "Aim Player",
    Default = false,
    Callback = function(state)
        aiming = state

        if aimConnection then
            aimConnection:Disconnect()
            aimConnection = nil
        end

        if aiming then
            aimConnection = RunService.RenderStepped:Connect(function()
                if not selectedTarget then return end
                local targetPlayer = Players:FindFirstChild(selectedTarget)
                local lpChar = LocalPlayer.Character
                if not targetPlayer or not lpChar then return end
                local targetChar = targetPlayer.Character
                if not targetChar then return end
                local targetHead = targetChar:FindFirstChild("Head")
                local lpHRP = lpChar:FindFirstChild("HumanoidRootPart")
                if not targetHead or not lpHRP then return end

                local direction = (targetHead.Position - lpHRP.Position).Unit
                local newCFrame = CFrame.new(lpHRP.Position, lpHRP.Position + direction)
                lpHRP.CFrame = newCFrame
            end)
        end
    end
})

local function CreateESP(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "NameESP_"..player.Name
    billboard.Size = UDim2.new(0,150,0,35)
    billboard.Adornee = hrp
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2000
    billboard.Parent = ESPFolder

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.fromScale(1,1)
    textLabel.BackgroundTransparency = 0.5
    textLabel.BackgroundColor3 = Color3.new(0,0,0)
    textLabel.Text = player.Name
    textLabel.TextColor3 = Color3.new(1,0,0)
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard

    local line = Drawing.new("Line")
    line.Visible = true
    line.Color = Color3.new(1,0,0)
    line.Thickness = 2

    RunService.RenderStepped:Connect(function()
        if not espEnabled then
            line.Visible = false
            billboard.Enabled = false
            return
        end
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local camera = workspace.CurrentCamera
            local hrpPos = camera:WorldToViewportPoint(hrp.Position)
            local lpPos = camera:WorldToViewportPoint(LocalPlayer.Character.HumanoidRootPart.Position)
            line.From = Vector2.new(lpPos.X, lpPos.Y)
            line.To = Vector2.new(hrpPos.X, hrpPos.Y)
            line.Visible = true
            billboard.Enabled = true
        else
            line.Visible = false
            billboard.Enabled = false
        end
    end)
end

task.spawn(function()
    while true do
        if espEnabled then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and not ESPFolder:FindFirstChild("NameESP_"..plr.Name) then
                    CreateESP(plr)
                end
            end
        else
            for _, obj in pairs(ESPFolder:GetChildren()) do
                obj:Destroy()
            end
        end
        task.wait(2)
    end
end)

local selectTargetBtn = Tabs.PvPTab:AddButton({
    Title = "Chọn Target",
    Description = "Target hiện tại: None",
    Callback = function()
        local playerNames = GetPlayerList()
        if #playerNames == 0 then
            return
        end

        local page = 1
        local perPage = 5

        local function showPage()
            local buttons = {}
            local startIndex = (page-1)*perPage + 1
            local endIndex = math.min(page*perPage, #playerNames)

            for i = startIndex, endIndex do
                local name = playerNames[i]
                table.insert(buttons, {
                    Title = name,
                    Callback = function()
                        selectedTarget = name
                    end
                })
            end

            table.insert(buttons, {
                Title = "Không chọn",
                Callback = function() selectedTarget = nil end
            })
            table.insert(buttons, {
                Title = "Thoát",
                Callback = function() end
            })

            if page > 1 then
                table.insert(buttons, {
                    Title = "Trang trước",
                    Callback = function() page = page - 1; showPage() end
                })
            end
            if endIndex < #playerNames then
                table.insert(buttons, {
                    Title = "Trang sau",
                    Callback = function() page = page + 1; showPage() end
                })
            end

            Window:Dialog({
                Title = "Chọn Target (Trang "..page..")",
                Content = "Chọn player bạn muốn nhắm:",
                Buttons = buttons
            })
        end

        showPage()
    end
})

task.spawn(function()
    while task.wait(1) do
        if selectedTarget then
            selectTargetBtn:SetDesc("Target hiện tại: "..selectedTarget)
        else
            selectTargetBtn:SetDesc("Target hiện tại: None")
        end
    end
end)

Tabs.PvPTab:AddButton({
    Title = "PvP VIP",
    Description = "Auto đánh + Băng gạc + Hitbox Tool + Thanh máu",
    Callback = function()
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/nhanproday/tronggnhaandz/refs/heads/main/CDVNVIP.lua"))()
        end)
        
        if not success then
            warn("Lỗi PvP VIP:", result)
        end
    end
})

Window:SelectTab(1)

-- Anti AFK Global
task.spawn(function()
	local vu = game:GetService("VirtualUser")

	game:GetService("Players").LocalPlayer.Idled:Connect(function()
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end)

	while task.wait(1170) do
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	end
end)