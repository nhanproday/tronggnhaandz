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
local AutoAttack = false
local NoclipEnabled = false

-- Thêm biến để lưu trạng thái noclip
local WasNoclipEnabledBeforeLoot = false
local IsLooting = false
local LootEndTime = 0

-- Noclip function
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

local Window = Fluent:CreateWindow({
    Title = "Mamaboy Hub - CDVN ",
    SubTitle = "Make By kedienyeuem27",
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

Tabs.framboss = Window:AddTab({
    Title = "Farm Boss",
    Icon = "sword"
})

-- Thêm Noclip
Tabs.framboss:AddToggle("NoclipToggle", {
    Title = "Noclip (Xuyên tường)",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
    end
})

-- Thêm Auto Attack
Tabs.framboss:AddToggle("AutoAttackToggle", {
    Title = "Auto Đánh",
    Default = false,
    Callback = function(state)
        AutoAttack = state
    end
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
    if val then 
        StartAutoFarm() 
    end
end)

local AutoLoot = false

Tabs.framboss:AddToggle("AutoLoot", { Title = "Auto Loot (Range 500)", Default = false }):OnChanged(function(val)
    AutoLoot = val
    if val then
        StartAutoLoot()
    else
        -- Khi tắt AutoLoot, khôi phục noclip nếu trước đó đang bật
        if WasNoclipEnabledBeforeLoot then
            NoclipEnabled = true
            WasNoclipEnabledBeforeLoot = false
        end
        IsLooting = false
    end
end)

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
                        
                        -- Tắt noclip nếu đang bật và lưu trạng thái
                        if NoclipEnabled and not IsLooting then
                            WasNoclipEnabledBeforeLoot = true
                            NoclipEnabled = false
                            IsLooting = true
                            LootEndTime = tick() + 30 -- Đặt thời gian kết thúc là 30s sau
                        end
                        
                        player.Character.HumanoidRootPart.CFrame = drop.CFrame
                        fireproximityprompt(prompt)
                        task.wait(0.1)
                    end
                end
            end
            
            -- Kiểm tra nếu đã hết 30s kể từ lần loot cuối
            if IsLooting and tick() >= LootEndTime then
                if WasNoclipEnabledBeforeLoot then
                    NoclipEnabled = true
                    WasNoclipEnabledBeforeLoot = false
                end
                IsLooting = false
            end
            
            -- Nếu không tìm thấy item và đang trong trạng thái loot, thì bật lại noclip
            if not foundItem and IsLooting then
                if WasNoclipEnabledBeforeLoot then
                    NoclipEnabled = true
                    WasNoclipEnabledBeforeLoot = false
                end
                IsLooting = false
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
                    -- Khi có boss, đảm bảo noclip được bật để tránh rơi xuống đất
                    if not NoclipEnabled then
                        NoclipEnabled = true
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

            -- Chỉ đánh khi bật Auto Attack
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
local selectedTarget, aiming = nil, false
local espEnabled = false
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

-- PvP VIP
PvPTab:AddButton({
    Title = "PvP VIP",
    Description = "Auto đánh + Băng gạc + Hitbox Tool + Thanh máu",
    Callback = function()
        Fluent:Notify({
            Title = "PvP VIP",
            Content = "Đang kích hoạt PvP VIP...",
            Duration = 3
        })
        
        local success, result = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/nhanproday/tronggnhaandz/refs/heads/main/CDVNVIP.lua"))()
        end)
        
        if success then
            Fluent:Notify({
                Title = "PvP VIP",
                Content = "Đã kích hoạt thành công!",
                Duration = 3
            })
        else
            Fluent:Notify({
                Title = "PvP VIP",
                Content = "Lỗi khi kích hoạt: " .. tostring(result),
                Duration = 5
            })
            warn("Lỗi PvP VIP:", result)
        end
    end
})

Window:SelectTab(1)