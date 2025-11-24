local RunService = game:GetService("RunService")
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

RunService.Heartbeat:Connect(function()
    local npc = getBoss2()
    if npc and npc:FindFirstChild("Humanoid") and npc:FindFirstChild("Head") then
        local h = npc.Humanoid  
        local head = npc.Head 
        local billboard = getOrCreateSimpleBillboard(head)  
        lastHead = head

        if h.Health > 0 then
            billboard.Enabled = true
            local label = billboard:FindFirstChild("HealthLabel")
            local healthBar = billboard:FindFirstChild("HealthBar")
            if label then
                label.Text = string.format("%d/%d", math.floor(h.Health), math.floor(h.MaxHealth))
            end
            if healthBar then
              
                healthBar.Size = UDim2.new(h.Health / h.MaxHealth, 0, 1, 0)
            end
        else
           
            billboard.Enabled = false
        end
    elseif lastHead then
     
        removeBillboard(lastHead)
        lastHead = nil
    end
end)
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local gui = Instance.new("ScreenGui")
gui.Name = "RightCtrlVirtual"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local ctrlButton = Instance.new("ImageButton")
ctrlButton.Name = "RightCtrlButton"
ctrlButton.Size = UDim2.new(0, 55, 0, 55)
ctrlButton.Position = UDim2.new(0, 600, 0.10, 0)
ctrlButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ctrlButton.BorderSizePixel = 0
ctrlButton.Image = "rbxassetid://95661408247291"
ctrlButton.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1, 0)
corner.Parent = ctrlButton

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5
stroke.Parent = ctrlButton

ctrlButton.MouseButton1Down:Connect(function()
    pcall(function()
        keypress(Enum.KeyCode.RightControl)
    end)
end)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local AutoHeal = false
local AutoFarm = false
local AutoFarmGiangho = false
local AutoBangGacFr = false
local AttackWeapon
local DisableALLautogiangho = false

function EquipWeapon(name)
    local tool = player.Backpack:FindFirstChild(name)
    if tool then
        tool.Parent = player.Character
    end
end

function UnInventoryWeapon(name)
    local inventory = player.PlayerGui.Inventory.MainFrame.List
    for _, item in pairs(inventory:GetChildren()) do
        if item.Name == name then
            item:Activate()
        end
    end
end


local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Uzumaki Hub - CDVN ",
    SubTitle = "Make By Ph67_",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 300),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Auto Băng Gạc", Icon = "package" }),
}

Tabs.Main:AddButton({
    Title = "Tắt Balo",
    Callback = function()
        local inv = playerGui:FindFirstChild("Inventory")
        if inv and inv:FindFirstChild("MainFrame") then
            inv.MainFrame.Visible = false
        end
    end
})

Tabs.Main:AddButton({
    Title = "Bật Lại Balo",
    Callback = function()
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

Tabs.framboss = Window:AddTab({
    Title = "Farm Boss",
    Icon = "sword"
})
local canEquip = true  -- Biến kiểm tra thời gian chờ 1 giây trước khi equip lại

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

task.spawn(function()
    while task.wait(1) do  -- Chỉ kiểm tra mỗi giây
        if AttackWeapon and canEquip then
            canEquip = false  -- Đặt canEquip = false để không thể trang bị lại liên tục
            
            if player.Character:FindFirstChild(AttackWeapon) then
                -- Vũ khí đã có trong nhân vật, không làm gì
                print("Vũ khí đã có trong nhân vật.")
            elseif player.Backpack:FindFirstChild(AttackWeapon) then
                EquipWeapon(AttackWeapon)
            else
                RequestFromInventory(AttackWeapon)
            end
            
            task.wait(1)  -- Đợi 1 giây trước khi có thể equip lại
            canEquip = true  -- Bật lại khả năng equip vũ khí
        end
    end
end)


Tabs.framboss:AddToggle("AutoFarm", { Title = "Farm Boss", Default = false }):OnChanged(function(val)
    AutoFarm = val
    if val then StartAutoFarm() end
end)

local AutoLoot = false

Tabs.framboss:AddToggle("AutoLoot", { Title = "Auto Loot (Range 500)", Default = false }):OnChanged(function(val)
    AutoLoot = val
    if val then
        StartAutoLoot()
    end
end)


function StartAutoLoot()
    task.spawn(function()
        while AutoLoot do
            task.wait(0.5)
            for _, drop in pairs(workspace.GiangHo2.Drop:GetChildren()) do
                local prompt = drop:FindFirstChild("ProximityPrompt") or drop:FindFirstChildOfClass("ProximityPrompt")
                if prompt and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local distance = (player.Character.HumanoidRootPart.Position - drop.Position).Magnitude
                    if distance <= 500 then
                        player.Character.HumanoidRootPart.CFrame = drop.CFrame
                        fireproximityprompt(prompt)
                        task.wait(0.1)
                    end
                end
            end
        end
    end)
end

local UserRadius = 17
local UserSpeed = 35



local radiusInput = Tabs.framboss:AddInput("RadiusInput", {
    Title = "Bán kính quay (Radius)",
    Default = tostring(UserRadius),
    Placeholder = "Nhập bán kính (vd: 20)",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            UserRadius = num
            print("Đã cập nhật bán kính:", UserRadius)
        else
            print("Giá trị radius không hợp lệ.")
        end
    end
})

local speedInput = Tabs.framboss:AddInput("SpeedInput", {
    Title = "Tốc độ quay (Speed)",
    Default = tostring(UserSpeed),
    Placeholder = "Nhập tốc độ (vd: 2.5)",
    Numeric = true,
    Finished = true,
    Callback = function(value)
        local num = tonumber(value)
        if num then
            UserSpeed = num
            print("Đã cập nhật tốc độ:", UserSpeed)
        else
            print("Giá trị speed không hợp lệ.")
        end
    end
})

-- Thêm biến để kiểm soát tốc độ
local lastFarmCheck = 0
local farmCheckInterval = 0.5 -- Giảm tần suất kiểm tra

function StartAutoFarm()
    task.spawn(function()
        while AutoFarm do
            -- Giới hạn tần suất kiểm tra boss
            if tick() - lastFarmCheck < farmCheckInterval then
                task.wait(farmCheckInterval)
                continue
            end
            lastFarmCheck = tick()
            
            local boss = nil

            -- Tối ưu hóa việc tìm boss
            local npcsFolder = workspace:FindFirstChild("GiangHo2")
            if not npcsFolder then 
                task.wait(1)
                continue 
            end
            
            npcsFolder = npcsFolder:FindFirstChild("NPCs")
            if not npcsFolder then 
                task.wait(1)
                continue 
            end

            for _, v in pairs(npcsFolder:GetChildren()) do
                if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                    boss = v
                    break
                end
            end

            if boss then
                local bossRoot = boss:FindFirstChild("HumanoidRootPart")
                if bossRoot then
                    CircleAroundBoss(bossRoot)
                end

                -- Giảm tần suất equip weapon
                if player.Character and AttackWeapon and not player.Character:FindFirstChild(AttackWeapon) then
                    task.spawn(function()
                        EquipWeapon(AttackWeapon)
                    end)
                end

                -- Giám sát boss với độ trễ
                while AutoFarm and boss and boss.Parent and boss:FindFirstChild("Humanoid") and boss.Humanoid.Health > 0 do
                    task.wait(0.5) -- Tăng thời gian chờ
                end

                task.wait(2) -- Chờ thêm trước khi tìm boss mới
            else
                task.wait(1) -- Chờ lâu hơn khi không có boss
            end
        end
    end)
end

function CircleAroundBoss(bossRoot)
    task.spawn(function()
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not root or not bossRoot then return end

        local radius, speed, angle = UserRadius, UserSpeed, 0
        local lastUpdate = 0
        local updateInterval = 0.1 -- Giảm tần suất cập nhật vị trí

        while AutoFarm and bossRoot.Parent and bossRoot.Parent:FindFirstChild("Humanoid") and bossRoot.Parent.Humanoid.Health > 0 do
            -- Giới hạn tần suất cập nhật
            if tick() - lastUpdate < updateInterval then
                task.wait(updateInterval)
                continue
            end
            lastUpdate = tick()
            
            angle = angle + speed * updateInterval
            angle = angle % (2 * math.pi)

            local pos = bossRoot.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            
            -- Sử dụng TweenService để di chuyển mượt mà hơn thay vì đặt trực tiếp CFrame
            local tweenInfo = TweenInfo.new(updateInterval, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.lookAt(pos + Vector3.new(0, 2, 0), bossRoot.Position)})
            tween:Play()

            -- Giảm tần suất click chuột
            if math.random(1, 3) == 1 then -- Chỉ click 1/3 thời gian
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(1280, 672))
            end
            
            task.wait(updateInterval)
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
task.spawn(function()
	local vu = game:GetService("VirtualUser")

	game:GetService("Players").LocalPlayer.Idled:Connect(function()
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		print("✅ Anti-AFK kích hoạt.")
	end)

	while task.wait(1170) do
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		print("🔁 Anti-AFK tự động sau 19.5 phút.")
	end
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Tabs = {
    Detector = Window:AddTab({ Title = "webhook", Icon = "link" })
}

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
        title = "📦 Item Spawn!",
        description = ("Phát hiện **%s** gần bạn!"):format(itemName:upper()),
        color = 65280,
        fields = {
            { name = "⏰ Thời gian (VN)", value = getVNTimeString(), inline = true },
            { name = "👤 Người chơi", value = LP.Name .. " (UserId: " .. LP.UserId .. ")", inline = true },
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
        local char = LP.Character
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
        Fluent:Notify({ Title = "Webhook", Content = "Đã lưu link webhook!", Duration = 3 })
    end
})

Tabs.Detector:AddToggle("DetectorToggle", {
    Title = "Bật Detector",
    Default = false,
    Callback = function(Value)
        detecting = Value
        if detecting then
            startDetecting()
            Fluent:Notify({ Title = "Detector", Content = "Đang theo dõi item!", Duration = 3 })
        else
            stopDetecting()
            Fluent:Notify({ Title = "Detector", Content = "Đã tắt detector.", Duration = 3 })
        end
    end
})
local FixLagTab = Window:AddTab({ Title = "Fix Lag", Icon = "cpu" })

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

    Fluent:Notify({
        Title = "Fix Lag",
        Content = "Đã xoá đồ họa ở mức " .. level .. "%",
        Duration = 3
    })
end

for _, lvl in ipairs({10,20,30,40,50,60,70,80}) do
    FixLagTab:AddButton({
        Title = "Xóa Đồ Họa " .. lvl .. "%",
        Callback = function()
            clearGraphics(lvl)
        end
    })
end

local whiteGui = nil
FixLagTab:AddToggle("WhiteScreenToggle", {
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
local MoneyTab = Window:AddTab({
    Title = "fram tiền",
    Icon = "dollar-sign"
})

local Players = game:GetService("Players")
local player = Players.LocalPlayer
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

local earnedLabel = MoneyTab:AddParagraph({
    Title = "bộ đếm tiền",
    Content = formatNumber(totalEarned) .. " VND"
})

local currentLabel = MoneyTab:AddParagraph({
    Title = "Số Dư Hiện Tại",
    Content = formatNumber(lastValue) .. " VND"
})

MoneyTab:AddButton({
    Title = "Reset bộ đếm tiền",
    Callback = function()
        totalEarned = 0
        earnedLabel:SetDesc(formatNumber(totalEarned) .. " VND")
        Fluent:Notify({
            Title = "Money Tracker",
            Content = "Đã reset bộ đếm tiền!",
            Duration = 3
        })
    end
})

VND:GetPropertyChangedSignal("Value"):Connect(function()
    local newValue = VND.Value
    if newValue > lastValue then
        local gained = newValue - lastValue
        totalEarned += gained
        earnedLabel:SetDesc(formatNumber(totalEarned) .. " VND")
    end
    currentLabel:SetDesc(formatNumber(newValue) .. " VND")
    lastValue = newValue
end)

local VirtualUser = game:GetService("VirtualUser")
local antiAfkEnabled = false
local antiAfkConn
local antiAfkLoop

MoneyTab:AddToggle("AntiAFKToggle", {
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
            antiAfkLoop = task.spawn(function()
                while antiAfkEnabled do
                    task.wait(1080) 
                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    Fluent:Notify({
                        Title = "Anti-AFK",
                        Content = "Đã nhấn tự động (sau 18 phút).",
                        Duration = 3
                    })
                end
            end)
            Fluent:Notify({
                Title = "Anti-AFK",
                Content = "Đã bật chống kick (18 phút).",
                Duration = 3
            })
        else
            if antiAfkConn then
                antiAfkConn:Disconnect()
                antiAfkConn = nil
            end
            antiAfkEnabled = false
            Fluent:Notify({
                Title = "Anti-AFK",
                Content = "Đã tắt chống kick.",
                Duration = 3
            })
        end
    end
})
local PvPTab = Window:AddTab({
    Title = "PvP",
    Icon = "swords"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer

local spinning, spinSpeed = false, 5
local selectedTarget, aiming, autoTool = nil, false, false
local espEnabled, toolEspEnabled, healthEspEnabled = false, false, false
local toolEspObjects = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = workspace

-- Spin speed
PvPTab:AddSlider("SpinSpeedSlider", {
    Title = "Tốc độ Spin",
    Min = 1,
    Max = 10000,
    Default = 5,
    Rounding = 1,
    Callback = function(val)
        spinSpeed = val
    end
})

-- PvP Spin
PvPTab:AddToggle("PvPSpinToggle", {
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

-- Giữ spin khi respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    if spinning then
        task.wait(0.5)
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then humanoid.AutoRotate = false end
    end
end)

-- Infinite stamina
PvPTab:AddToggle("MaxLevelToggle", {
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

-- Lấy danh sách player
local function GetPlayerList()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- ESP line + name
PvPTab:AddToggle("ESPToggle", {
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

-- Auto Tool
PvPTab:AddToggle("AutoToolToggle", {
    Title = "Auto đánh Tool",
    Default = false,
    Callback = function(state)
        autoTool = state
        task.spawn(function()
            while autoTool do
                if LocalPlayer.Character then
                    local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if tool then
                        pcall(function() tool:Activate() end)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
})

-- Aim Player (Full Sửa)
local aimConnection
PvPTab:AddToggle("AimPlayerToggle", {
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

-- Tạo ESP
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

-- Liên tục update ESP
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

-- Chọn Target
local selectTargetBtn = PvPTab:AddButton({
    Title = "Chọn Target",
    Description = "Target hiện tại: None",
    Callback = function()
        local playerNames = GetPlayerList()
        if #playerNames == 0 then
            warn("Chưa có player nào để chọn!")
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
                        print("✅ Target đã chọn:", name)
                    end
                })
            end

            table.insert(buttons, {
                Title = "🔕 Không chọn",
                Callback = function() selectedTarget = nil end
            })
            table.insert(buttons, {
                Title = "❌ Thoát",
                Callback = function() end
            })

            if page > 1 then
                table.insert(buttons, {
                    Title = "⬅ Trang trước",
                    Callback = function() page = page - 1; showPage() end
                })
            end
            if endIndex < #playerNames then
                table.insert(buttons, {
                    Title = "➡ Trang sau",
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

-- Cập nhật mô tả target hiện tại
task.spawn(function()
    while task.wait(1) do
        if selectedTarget then
            selectTargetBtn:SetDesc("Target hiện tại: "..selectedTarget)
        else
            selectTargetBtn:SetDesc("Target hiện tại: None")
        end
    end
end)

-- Tool ESP
PvPTab:AddToggle("ToolHitboxESP", { Title = "Hiện Hitbox Vũ Khí", Default = false }):OnChanged(function(value)
    toolEspEnabled = value
    if not value then
        for tool, obj in pairs(toolEspObjects) do
            if obj and obj.Parent then obj:Destroy() end
        end
        toolEspObjects = {}
    end
end)

local function addToolESP(tool)
    if tool and tool:FindFirstChild("Handle") and not toolEspObjects[tool] then
        local handle = tool.Handle
        local box = Instance.new("SelectionBox")
        box.Name = "ToolHitboxESP"
        box.Adornee = handle
        box.LineThickness = 0.05
        box.Color3 = Color3.fromRGB(0, 255, 0)
        box.SurfaceTransparency = 1
        box.Parent = handle
        toolEspObjects[tool] = box
    end
end

RunService.RenderStepped:Connect(function()
    if toolEspEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                for _, tool in ipairs(plr.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        addToolESP(tool)
                    end
                end
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if plr.Character then
        for _, tool in ipairs(plr.Character:GetChildren()) do
            if toolEspObjects[tool] then
                toolEspObjects[tool]:Destroy()
                toolEspObjects[tool] = nil
            end
        end
    end
end)

-- Health ESP
PvPTab:AddToggle("HealthESP", { Title = "Hiện Thanh Máu", Default = false }):OnChanged(function(value)
    healthEspEnabled = value
    if not value then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                if head:FindFirstChild("HealthESP") then
                    head.HealthESP:Destroy()
                end
            end
        end
    end
end)

local function addHealthESP(character)
    if not healthEspEnabled then return end
    local head = character:FindFirstChild("Head")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if head and humanoid and not head:FindFirstChild("HealthESP") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "HealthESP"
        billboard.Size = UDim2.new(4,0,1.5,0)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Parent = head

        local barBack = Instance.new("Frame", billboard)
        barBack.Size = UDim2.new(1,0,0.2,0)
        barBack.Position = UDim2.new(0,0,0.5,0)
        barBack.BackgroundColor3 = Color3.fromRGB(50,50,50)

        local bar = Instance.new("Frame", barBack)
        bar.Name = "HealthBar"
        bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
        bar.Size = UDim2.new(1,0,1,0)

        local hpText = Instance.new("TextLabel", billboard)
        hpText.Name = "HPText"
        hpText.Size = UDim2.new(1,0,0.5,0)
        hpText.Position = UDim2.new(0,0,0,-10)
        hpText.BackgroundTransparency = 1
        hpText.TextColor3 = Color3.fromRGB(255,255,255)
        hpText.TextStrokeTransparency = 0
        hpText.Font = Enum.Font.SourceSansBold
        hpText.TextScaled = true
        hpText.Text = tostring(humanoid.Health) .. "/" .. tostring(humanoid.MaxHealth)
    end
end

RunService.RenderStepped:Connect(function()
    if healthEspEnabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                addHealthESP(plr.Character)
                local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                local head = plr.Character:FindFirstChild("Head")
                if humanoid and head and head:FindFirstChild("HealthESP") then
                    local esp = head.HealthESP
                    local bar = esp.Frame.HealthBar
                    local hpText = esp.HPText
                    bar.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)
                    local hpPercent = humanoid.Health / humanoid.MaxHealth
                    if hpPercent > 0.6 then
                        bar.BackgroundColor3 = Color3.fromRGB(0,255,0)
                    elseif hpPercent > 0.3 then
                        bar.BackgroundColor3 = Color3.fromRGB(255,255,0)
                    else
                        bar.BackgroundColor3 = Color3.fromRGB(255,0,0)
                    end
                    hpText.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                end
            end
        end
    end
end)
local SettingsTab = Window:AddTab({
    Title = "Settings",
    Icon = "settings"
})

InterfaceManager:SetLibrary(Fluent)
SaveManager:Serary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("MyHub")
SaveManager:SetFolder("MyHub/Configs")
InterfaceManager:BuildInterfaceSection(SettingsTab)
SaveManager:BuildConfigSection(SettingsTab)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
