-- Khi tôi nói Canser mọi người nói bero
local ScreenGui = Instance.new("ScreenGui")
local MiniToggle = Instance.new("TextButton")
local UICornerMini = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui

-- Nút siêu nhỏ bật/tắt autoclick
MiniToggle.Parent = ScreenGui
MiniToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MiniToggle.Position = UDim2.new(0, 10, 0.5, 0)
MiniToggle.Size = UDim2.new(0, 35, 0, 35)
MiniToggle.Font = Enum.Font.GothamBold
MiniToggle.Text = "☠️"
MiniToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniToggle.TextScaled = true
MiniToggle.Active = true
MiniToggle.Draggable = true
UICornerMini.Parent = MiniToggle
UICornerMini.CornerRadius = UDim.new(0, 17)

local player = game:GetService("Players").LocalPlayer
local autoClickSpeed = 0.1
local autoClickEnabled = false
local connection
local isHealing = false
local lastHealTime = 0

-- Biến để quản lý tất cả kết nối
local allConnections = {}
local espObjects = {}
local toolEspObjects = {}

-- Biến cho ESP
local espEnabled, toolEspEnabled, healthEspEnabled = false, false, false
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "ESP"
ESPFolder.Parent = workspace

-- Hàm tìm tool trong backpack
local function findToolInBackpack(toolName)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        return backpack:FindFirstChild(toolName)
    end
    return nil
end

-- Hàm hồi máu nhanh PVP
local function quickHeal()
    if isHealing then return end
    
    local character = player.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health > 79 then return end
    
    local bandage = findToolInBackpack("băng gạc")
    if not bandage then return end
    
    local currentTool = character:FindFirstChildOfClass("Tool")
    
    isHealing = true
    
    if currentTool then
        currentTool.Parent = player:FindFirstChildOfClass("Backpack")
    end
    bandage.Parent = character
    
    task.wait(0.3)
    
    bandage.Parent = player:FindFirstChildOfClass("Backpack")
    if currentTool then
        currentTool.Parent = character
    end
    
    isHealing = false
    lastHealTime = tick()
end

-- Autoclick ổn định
local function stableAutoClick()
    while autoClickEnabled do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                end
            end
        end
        task.wait(autoClickSpeed)
    end
end

-- ========== THANH MÁU VÀ HITBOX VŨ KHÍ ==========

-- Tool ESP - Hiển thị hitbox vũ khí
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

-- Health ESP - Hiển thị thanh máu
local function addHealthESP(character, plr)
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
        hpText.Text = tostring(math.floor(humanoid.Health)) .. "/" .. tostring(math.floor(humanoid.MaxHealth))
        
        espObjects[character] = billboard
    end
end

-- Cập nhật thanh máu real-time
local function startHealthESP()
    local RunService = game:GetService("RunService")
    
    local healthUpdateConnection = RunService.RenderStepped:Connect(function()
        if healthEspEnabled then
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                if plr ~= player and plr.Character then
                    addHealthESP(plr.Character, plr)
                    local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
                    local head = plr.Character:FindFirstChild("Head")
                    if humanoid and head and head:FindFirstChild("HealthESP") then
                        local esp = head.HealthESP
                        local bar = esp:FindFirstChild("Frame") and esp.Frame:FindFirstChild("HealthBar")
                        local hpText = esp:FindFirstChild("HPText")
                        if bar and hpText then
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
        end
    end)
    
    table.insert(allConnections, healthUpdateConnection)
end

-- Cập nhật tool ESP real-time
local function startToolESP()
    local RunService = game:GetService("RunService")
    
    local toolUpdateConnection = RunService.RenderStepped:Connect(function()
        if toolEspEnabled then
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
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
    
    table.insert(allConnections, toolUpdateConnection)
end

-- Theo dõi máu để hồi máu nhanh
local function startHealthMonitor()
    local healthMonitor = task.spawn(function()
        while true do
            if autoClickEnabled and not isHealing then
                if tick() - lastHealTime > 1.5 then
                    quickHeal()
                end
            end
            task.wait(0.3)
        end
    end)
    table.insert(allConnections, healthMonitor)
end

-- Hàm BẬT TẤT CẢ
local function enableAllFeatures()
    autoClickEnabled = true
    healthEspEnabled = true
    toolEspEnabled = true
    
    -- Bật autoclick
    connection = task.spawn(stableAutoClick)
    table.insert(allConnections, connection)
    
    -- Bật health monitor
    startHealthMonitor()
    
    -- Bật ESP
    startHealthESP()
    startToolESP()
    
    -- Update UI
    MiniToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
    MiniToggle.Text = "🔴"
    
    print("✅ Đã bật TẤT CẢ tính năng: Autoclick + Thanh máu + Hitbox vũ khí")
end

-- Hàm TẮT TẤT CẢ
local function disableAllFeatures()
    -- Dừng autoclick
    autoClickEnabled = false
    healthEspEnabled = false
    toolEspEnabled = false
    
    -- Ngắt tất cả kết nối
    for _, conn in pairs(allConnections) do
        if conn then
            pcall(function() conn:Disconnect() end)
        end
    end
    allConnections = {}
    
    -- Xóa tất cả ESP objects
    for _, obj in pairs(espObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    espObjects = {}
    
    -- Xóa tất cả tool ESP objects
    for tool, obj in pairs(toolEspObjects) do
        if obj and obj.Parent then
            obj:Destroy()
        end
    end
    toolEspObjects = {}
    
    -- Xóa tất cả thanh máu
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            if head:FindFirstChild("HealthESP") then
                head.HealthESP:Destroy()
            end
        end
    end
    
    -- Update UI
    MiniToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    MiniToggle.Text = "☠️"
    
    print("❌ Đã tắt TẤT CẢ tính năng")
end

-- Bật/tắt từ nút siêu nhỏ
MiniToggle.MouseButton1Click:Connect(function()
    if autoClickEnabled then
        disableAllFeatures()
    else
        enableAllFeatures()
    end
end)

-- Tự động bật lại khi respawn (nếu đang bật)
player.CharacterAdded:Connect(function(character)
    task.wait(2)
    
    isHealing = false
    lastHealTime = 0
    
    if autoClickEnabled then
        MiniToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        MiniToggle.Text = "🔴"
    end
end)

-- Thêm tính năng tắt toàn bộ bằng phím F12
local UIS = game:GetService("UserInputService")
local disableConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.F12 then
        disableAllFeatures()
    end
end)
table.insert(allConnections, disableConnection)

-- Thông báo khi load script
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "PVP Hub Loaded",
        Text = "Click nút để bật/tắt tất cả\nF12 để tắt nhanh",
        Duration = 5
    })
end)

print("🎮 Script đã được load! Click nút để bật/tắt TẤT CẢ tính năng")