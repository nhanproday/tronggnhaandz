-- Khi tôi nói Canser mọi người nói bero
local ScreenGui = Instance.new("ScreenGui")
local MiniToggle = Instance.new("TextButton")
local UICornerMini = Instance.new("UICorner")

ScreenGui.Parent = game.CoreGui

-- Nút siêu nhỏ bật/tắt autoclick
MiniToggle.Parent = ScreenGui
MiniToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
MiniToggle.Position = UDim2.new(0, 10, 0.5, 0)
MiniToggle.Size = UDim2.new(0, 35, 0, 35)
MiniToggle.Font = Enum.Font.GothamBold
MiniToggle.Text = "💀"
MiniToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniToggle.TextScaled = true
MiniToggle.Active = true
MiniToggle.Draggable = true
UICornerMini.Parent = MiniToggle
UICornerMini.CornerRadius = UDim.new(0, 17)

local player = game:GetService("Players").LocalPlayer
local autoClickSpeed = 0.1 -- Tốc độ chậm hơn để tránh lag (10 clicks/giây)
local autoClickEnabled = true
local connection
local isHealing = false -- Trạng thái đang hồi máu
local lastHealTime = 0 -- Thời gian hồi máu lần cuối

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
    if not humanoid or humanoid.Health > 57 then return end
    
    -- Tìm băng gạc trong backpack
    local bandage = findToolInBackpack("băng gạc")
    if not bandage then return end
    
    -- Lưu tool hiện tại
    local currentTool = character:FindFirstChildOfClass("Tool")
    
    isHealing = true
    
    -- Nhanh chóng trang bị băng gạc
    if currentTool then
        currentTool.Parent = player:FindFirstChildOfClass("Backpack")
    end
    bandage.Parent = character
    
    -- Chờ 0.3 giây để tool load
    task.wait(0.3)
    
    -- Quay lại tool cũ
    bandage.Parent = player:FindFirstChildOfClass("Backpack")
    if currentTool then
        currentTool.Parent = character
    end
    
    isHealing = false
    lastHealTime = tick() -- Ghi nhận thời gian hồi máu
end

-- Autoclick ổn định, tránh lag - CHỈ DỪNG KHI TẮT
local function stableAutoClick()
    while autoClickEnabled do
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Autoclick LIÊN TỤC bất kể tool gì (kể cả băng gạc)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Handle") then
                    tool:Activate()
                end
            end
        end
        task.wait(autoClickSpeed)
    end
end

-- Bắt đầu autoclick
connection = task.spawn(stableAutoClick)

-- Bật/tắt từ nút siêu nhỏ
MiniToggle.MouseButton1Click:Connect(function()
    autoClickEnabled = not autoClickEnabled
    
    if autoClickEnabled then
        MiniToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        MiniToggle.Text = "💀"
        -- Khởi động lại autoclick
        connection = task.spawn(stableAutoClick)
    else
        MiniToggle.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        MiniToggle.Text = "☠️"
    end
end)

-- Theo dõi máu để hồi máu nhanh
local function monitorHealth()
    while true do
        if autoClickEnabled and not isHealing then
            -- Chờ 1-2 giây sau lần hồi máu cuối trước khi check tiếp
            if tick() - lastHealTime > 1.5 then -- 1.5 giây = trung bình 1-2 giây
                quickHeal()
            end
        end
        task.wait(0.3) -- Kiểm tra nhanh mỗi 0.3 giây
    end
end

-- Bắt đầu theo dõi máu
task.spawn(monitorHealth)

-- Tự động bật lại khi respawn
player.CharacterAdded:Connect(function(character)
    task.wait(2) -- Chờ 2 giây sau khi respawn
    
    -- Reset biến khi respawn
    isHealing = false
    lastHealTime = 0
    
    if autoClickEnabled then
        MiniToggle.BackgroundColor3 = Color3.fromRGB(70, 130, 180)
        MiniToggle.Text = "💀"
    end
end)

-- Thông báo khi load script
pcall(function()
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "PVP Autoclick Loaded",
        Text = "Chiến Vương Code By: Trọng Nhân",
        Duration = 5
    })
end)