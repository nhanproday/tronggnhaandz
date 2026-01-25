local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ModernUI = {}
ModernUI.__index = ModernUI

local THEMES = {
    White = Color3.fromRGB(255, 255, 255),
    Red = Color3.fromRGB(255, 70, 70),
    Purple = Color3.fromRGB(170, 100, 255),
    Yellow = Color3.fromRGB(255, 220, 70),
    Green = Color3.fromRGB(70, 255, 150),
    Blue = Color3.fromRGB(70, 150, 255)
}

local COLORS = {
    Background = Color3.fromRGB(8, 8, 12),
    Surface = Color3.fromRGB(12, 12, 18),
    SurfaceLight = Color3.fromRGB(18, 18, 24),
    Border = Color3.fromRGB(30, 30, 40),
    White = Color3.fromRGB(255, 255, 255),
    Gray = Color3.fromRGB(140, 140, 150),
    DarkGray = Color3.fromRGB(80, 80, 90),
    Accent = Color3.fromRGB(255, 255, 255)
}

local TWEEN_INFO = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local FAST_TWEEN = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SLOW_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local function CreateImageBackground(parent, imageId, transparency)
    local bg = Instance.new("ImageLabel")
    bg.Name = "CustomBackground"
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.Position = UDim2.new(0, 0, 0, 0)
    bg.BackgroundTransparency = 1
    bg.Image = imageId or ""
    bg.ImageTransparency = transparency or 0.3
    bg.ScaleType = Enum.ScaleType.Crop
    bg.ZIndex = 0
    bg.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 16)
    corner.Parent = bg
    
    return bg
end

local function AnimateIcon(imageLabel, frames, fps)
    if type(frames) ~= "table" then
        imageLabel.Image = frames
        return
    end
    
    task.spawn(function()
        local currentFrame = 1
        while imageLabel and imageLabel.Parent do
            imageLabel.Image = frames[currentFrame]
            currentFrame = currentFrame + 1
            if currentFrame > #frames then
                currentFrame = 1
            end
            task.wait(fps or 0.1)
        end
    end)
end

function ModernUI.new(config)
    local self = setmetatable({}, ModernUI)
    
    config = config or {}
    self.Title = config.Title or "Modern UI"
    self.SubTitle = config.SubTitle or "Library"
    self.Icon = config.Icon or {"rbxassetid://138770682187300", "rbxassetid://110961158970233"}
    self.IconFPS = config.IconFPS or 0.1
    self.MinimizeKey = Enum.KeyCode.LeftControl
    self.SaveFolder = "ModernUIConfig"
    self.AcrylicEnabled = false
    self.CurrentTheme = "White"
    self.BackgroundImage = ""
    self.BackgroundTransparency = 0.3
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "ModernUILibrary"
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.DisplayOrder = 999
    
    local screenSize = workspace.CurrentCamera.ViewportSize
    local isMobile = screenSize.X < 600
    
    local width = isMobile and screenSize.X * 0.9 or 580
    local height = isMobile and screenSize.Y * 0.7 or 460
    
    self.MainFrame = Instance.new("Frame")
    self.MainFrame.Name = "MainFrame"
    self.MainFrame.Size = UDim2.new(0, width, 0, height)
    self.MainFrame.Position = UDim2.new(0.5, -width/2, 0.5, -height/2)
    self.MainFrame.BackgroundColor3 = COLORS.Background
    self.MainFrame.BorderSizePixel = 0
    self.MainFrame.Parent = self.ScreenGui
    self.MainFrame.Active = true
    self.MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = self.MainFrame
    
    self.CustomBg = CreateImageBackground(self.MainFrame, "", 1)
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 40, 1, 40)
    Shadow.Position = UDim2.new(0, -20, 0, -20)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = 0
    Shadow.Parent = self.MainFrame
    
    self:CreateHeader()
    self:CreateSidebar()
    self:CreateContentArea()
    self:MakeDraggable(self.MainFrame, self.MainFrame:FindFirstChild("Header"))
    self:MakeResizable()
    self:SetupMinimizeKey()
    
    self.Tabs = {}
    self.CurrentTab = nil
    self.ConfigData = {
        Toggles = {},
        Dropdowns = {},
        MultiDropdowns = {},
        Sliders = {},
        FloatingButton = {}
    }
    self.AccentElements = {}
    
    self.ScreenGui.Parent = game:GetService("CoreGui")
    
    self:LoadConfig()
    self:ApplyTheme(self.CurrentTheme)
    self:ApplyAcrylic(self.AcrylicEnabled)
    
    if self.BackgroundImage ~= "" then
        self:ApplyBackgroundImage(self.BackgroundImage, self.BackgroundTransparency)
    end
    
    if config.FloatingButton ~= false then
        self:CreateFloatingButton(config.FloatingButton or {})
    end
    
    return self
end

function ModernUI:ShowSettingsWindow()
    if self.SettingsWindow and self.SettingsWindow.Parent then
        self.SettingsWindow:Destroy()
    end
    
    local Overlay = Instance.new("Frame")
    Overlay.Name = "SettingsOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10
    Overlay.Parent = self.MainFrame
    
    TweenService:Create(Overlay, FAST_TWEEN, {BackgroundTransparency = 0.6}):Play()
    
    local Settings = Instance.new("Frame")
    Settings.Name = "Settings"
    Settings.Size = UDim2.new(0, 400, 0, 0)
    Settings.Position = UDim2.new(0.5, -200, 0.5, -250)
    Settings.BackgroundColor3 = COLORS.Surface
    Settings.BorderSizePixel = 0
    Settings.ZIndex = 11
    Settings.Parent = Overlay
    
    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 14)
    SettingsCorner.Parent = Settings
    
    self.SettingsWindow = Overlay
    
    TweenService:Create(Settings, TWEEN_INFO, {Size = UDim2.new(0, 400, 0, 500)}):Play()
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.ZIndex = 11
    Header.Parent = Settings
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 20, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Settings"
    Title.TextColor3 = COLORS.White
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 11
    Title.Parent = Header
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -15)
    CloseBtn.BackgroundColor3 = COLORS.Background
    CloseBtn.Text = ""
    CloseBtn.AutoButtonColor = false
    CloseBtn.ZIndex = 11
    CloseBtn.Parent = Header
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 8)
    CloseBtnCorner.Parent = CloseBtn
    
    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.new(0, 14, 0, 14)
    CloseIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://7734053426"
    CloseIcon.ImageColor3 = COLORS.Gray
    CloseIcon.ZIndex = 11
    CloseIcon.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        TweenService:Create(Settings, FAST_TWEEN, {Size = UDim2.new(0, 400, 0, 0)}):Play()
        TweenService:Create(Overlay, FAST_TWEEN, {BackgroundTransparency = 1}):Play()
        wait(0.2)
        Overlay:Destroy()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
        TweenService:Create(CloseIcon, FAST_TWEEN, {ImageColor3 = COLORS.White}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, FAST_TWEEN, {BackgroundColor3 = COLORS.Background}):Play()
        TweenService:Create(CloseIcon, FAST_TWEEN, {ImageColor3 = COLORS.Gray}):Play()
    end)
    
    local Divider = Instance.new("Frame")
    Divider.Size = UDim2.new(1, -40, 0, 1)
    Divider.Position = UDim2.new(0, 20, 0, 50)
    Divider.BackgroundColor3 = COLORS.Border
    Divider.BorderSizePixel = 0
    Divider.ZIndex = 11
    Divider.Parent = Settings
    
    local Content = Instance.new("ScrollingFrame")
    Content.Size = UDim2.new(1, -40, 1, -110)
    Content.Position = UDim2.new(0, 20, 0, 60)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 3
    Content.ScrollBarImageColor3 = COLORS.Border
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.ZIndex = 11
    Content.Parent = Settings
    
    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 15)
    ContentLayout.Parent = Content
    
    ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Content.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
    end)
    
    local ThemeLabel = Instance.new("TextLabel")
    ThemeLabel.Size = UDim2.new(1, 0, 0, 20)
    ThemeLabel.BackgroundTransparency = 1
    ThemeLabel.Text = "Theme"
    ThemeLabel.TextColor3 = COLORS.White
    ThemeLabel.TextSize = 13
    ThemeLabel.Font = Enum.Font.GothamBold
    ThemeLabel.TextXAlignment = Enum.TextXAlignment.Left
    ThemeLabel.ZIndex = 11
    ThemeLabel.LayoutOrder = 1
    ThemeLabel.Parent = Content
    
    local ThemeContainer = Instance.new("Frame")
    ThemeContainer.Size = UDim2.new(1, 0, 0, 80)
    ThemeContainer.BackgroundTransparency = 1
    ThemeContainer.ZIndex = 11
    ThemeContainer.LayoutOrder = 2
    ThemeContainer.Parent = Content
    
    local ThemeGrid = Instance.new("UIGridLayout")
    ThemeGrid.CellSize = UDim2.new(0, 50, 0, 50)
    ThemeGrid.CellPadding = UDim2.new(0, 10, 0, 10)
    ThemeGrid.SortOrder = Enum.SortOrder.LayoutOrder
    ThemeGrid.Parent = ThemeContainer
    
    local themeOrder = {"White", "Red", "Purple", "Yellow", "Green", "Blue"}
    
    for i, themeName in ipairs(themeOrder) do
        local ThemeButton = Instance.new("TextButton")
        ThemeButton.Size = UDim2.new(0, 50, 0, 50)
        ThemeButton.BackgroundColor3 = THEMES[themeName]
        ThemeButton.Text = ""
        ThemeButton.AutoButtonColor = false
        ThemeButton.ZIndex = 11
        ThemeButton.LayoutOrder = i
        ThemeButton.Parent = ThemeContainer
        
        local ThemeCorner = Instance.new("UICorner")
        ThemeCorner.CornerRadius = UDim.new(0, 10)
        ThemeCorner.Parent = ThemeButton
        
        local Selected = Instance.new("ImageLabel")
        Selected.Size = UDim2.new(0, 20, 0, 20)
        Selected.Position = UDim2.new(0.5, -10, 0.5, -10)
        Selected.BackgroundTransparency = 1
        Selected.Image = "rbxassetid://7733964126"
        Selected.ImageColor3 = Color3.fromRGB(8, 8, 12)
        Selected.Visible = self.CurrentTheme == themeName
        Selected.ZIndex = 12
        Selected.Parent = ThemeButton
        
        ThemeButton.MouseButton1Click:Connect(function()
            self:ApplyTheme(themeName)
            for _, child in pairs(ThemeContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    local sel = child:FindFirstChildOfClass("ImageLabel")
                    if sel then
                        sel.Visible = false
                    end
                end
            end
            Selected.Visible = true
        end)
        
        ThemeButton.MouseEnter:Connect(function()
            TweenService:Create(ThemeButton, FAST_TWEEN, {Size = UDim2.new(0, 55, 0, 55)}):Play()
        end)
        
        ThemeButton.MouseLeave:Connect(function()
            TweenService:Create(ThemeButton, FAST_TWEEN, {Size = UDim2.new(0, 50, 0, 50)}):Play()
        end)
    end
    
    local AcrylicLabel = Instance.new("TextLabel")
    AcrylicLabel.Size = UDim2.new(1, 0, 0, 20)
    AcrylicLabel.BackgroundTransparency = 1
    AcrylicLabel.Text = "Acrylic Effect"
    AcrylicLabel.TextColor3 = COLORS.White
    AcrylicLabel.TextSize = 13
    AcrylicLabel.Font = Enum.Font.GothamBold
    AcrylicLabel.TextXAlignment = Enum.TextXAlignment.Left
    AcrylicLabel.ZIndex = 11
    AcrylicLabel.LayoutOrder = 3
    AcrylicLabel.Parent = Content
    
    local AcrylicToggle = Instance.new("Frame")
    AcrylicToggle.Size = UDim2.new(1, 0, 0, 40)
    AcrylicToggle.BackgroundColor3 = COLORS.Background
    AcrylicToggle.BorderSizePixel = 0
    AcrylicToggle.ZIndex = 11
    AcrylicToggle.LayoutOrder = 4
    AcrylicToggle.Parent = Content
    
    local AcrylicCorner = Instance.new("UICorner")
    AcrylicCorner.CornerRadius = UDim.new(0, 10)
    AcrylicCorner.Parent = AcrylicToggle
    
    local AcrylicText = Instance.new("TextLabel")
    AcrylicText.Size = UDim2.new(0.7, 0, 1, 0)
    AcrylicText.Position = UDim2.new(0, 14, 0, 0)
    AcrylicText.BackgroundTransparency = 1
    AcrylicText.Text = "Enable Transparency"
    AcrylicText.TextColor3 = COLORS.White
    AcrylicText.TextSize = 12
    AcrylicText.Font = Enum.Font.GothamMedium
    AcrylicText.TextXAlignment = Enum.TextXAlignment.Left
    AcrylicText.ZIndex = 11
    AcrylicText.Parent = AcrylicToggle
    
    local AcrylicButton = Instance.new("TextButton")
    AcrylicButton.Size = UDim2.new(0, 42, 0, 22)
    AcrylicButton.Position = UDim2.new(1, -56, 0.5, -11)
    AcrylicButton.BackgroundColor3 = self.AcrylicEnabled and COLORS.Accent or COLORS.SurfaceLight
    AcrylicButton.BorderSizePixel = 0
    AcrylicButton.Text = ""
    AcrylicButton.AutoButtonColor = false
    AcrylicButton.ZIndex = 11
    AcrylicButton.Parent = AcrylicToggle
    
    local AcrylicBtnCorner = Instance.new("UICorner")
    AcrylicBtnCorner.CornerRadius = UDim.new(1, 0)
    AcrylicBtnCorner.Parent = AcrylicButton
    
    local AcrylicCircle = Instance.new("Frame")
    AcrylicCircle.Size = UDim2.new(0, 18, 0, 18)
    AcrylicCircle.Position = self.AcrylicEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    AcrylicCircle.BackgroundColor3 = self.AcrylicEnabled and Color3.fromRGB(8, 8, 12) or COLORS.Gray
    AcrylicCircle.BorderSizePixel = 0
    AcrylicCircle.ZIndex = 11
    AcrylicCircle.Parent = AcrylicButton
    
    local AcrylicCircleCorner = Instance.new("UICorner")
    AcrylicCircleCorner.CornerRadius = UDim.new(1, 0)
    AcrylicCircleCorner.Parent = AcrylicCircle
    
    AcrylicButton.MouseButton1Click:Connect(function()
        self.AcrylicEnabled = not self.AcrylicEnabled
        self:ApplyAcrylic(self.AcrylicEnabled)
        
        if self.AcrylicEnabled then
            TweenService:Create(AcrylicButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Accent}):Play()
            TweenService:Create(AcrylicCircle, FAST_TWEEN, {
                BackgroundColor3 = Color3.fromRGB(8, 8, 12),
                Position = UDim2.new(1, -20, 0.5, -9)
            }):Play()
        else
            TweenService:Create(AcrylicButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
            TweenService:Create(AcrylicCircle, FAST_TWEEN, {
                BackgroundColor3 = COLORS.Gray,
                Position = UDim2.new(0, 2, 0.5, -9)
            }):Play()
        end
    end)
    
    local KeybindLabel = Instance.new("TextLabel")
    KeybindLabel.Size = UDim2.new(1, 0, 0, 20)
    KeybindLabel.BackgroundTransparency = 1
    KeybindLabel.Text = "Toggle Keybind"
    KeybindLabel.TextColor3 = COLORS.White
    KeybindLabel.TextSize = 13
    KeybindLabel.Font = Enum.Font.GothamBold
    KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    KeybindLabel.ZIndex = 11
    KeybindLabel.LayoutOrder = 5
    KeybindLabel.Parent = Content
    
    local KeybindContainer = Instance.new("Frame")
    KeybindContainer.Size = UDim2.new(1, 0, 0, 40)
    KeybindContainer.BackgroundColor3 = COLORS.Background
    KeybindContainer.BorderSizePixel = 0
    KeybindContainer.ZIndex = 11
    KeybindContainer.LayoutOrder = 6
    KeybindContainer.Parent = Content
    
    local KeybindCorner = Instance.new("UICorner")
    KeybindCorner.CornerRadius = UDim.new(0, 10)
    KeybindCorner.Parent = KeybindContainer
    
    local KeybindText = Instance.new("TextLabel")
    KeybindText.Size = UDim2.new(0.5, 0, 1, 0)
    KeybindText.Position = UDim2.new(0, 14, 0, 0)
    KeybindText.BackgroundTransparency = 1
    KeybindText.Text = "Current Key"
    KeybindText.TextColor3 = COLORS.White
    KeybindText.TextSize = 12
    KeybindText.Font = Enum.Font.GothamMedium
    KeybindText.TextXAlignment = Enum.TextXAlignment.Left
    KeybindText.ZIndex = 11
    KeybindText.Parent = KeybindContainer
    
    local KeybindButton = Instance.new("TextButton")
    KeybindButton.Size = UDim2.new(0, 120, 0, 30)
    KeybindButton.Position = UDim2.new(1, -134, 0.5, -15)
    KeybindButton.BackgroundColor3 = COLORS.SurfaceLight
    KeybindButton.Text = self.MinimizeKey.Name
    KeybindButton.TextColor3 = COLORS.White
    KeybindButton.TextSize = 11
    KeybindButton.Font = Enum.Font.GothamBold
    KeybindButton.AutoButtonColor = false
    KeybindButton.ZIndex = 11
    KeybindButton.Parent = KeybindContainer
    
    local KeybindBtnCorner = Instance.new("UICorner")
    KeybindBtnCorner.CornerRadius = UDim.new(0, 8)
    KeybindBtnCorner.Parent = KeybindButton
    
    local isBinding = false
    
    KeybindButton.MouseButton1Click:Connect(function()
        if isBinding then return end
        isBinding = true
        KeybindButton.Text = "Press a key..."
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self.MinimizeKey = input.KeyCode
                KeybindButton.Text = input.KeyCode.Name
                isBinding = false
                connection:Disconnect()
            end
        end)
    end)
    
    KeybindButton.MouseEnter:Connect(function()
        TweenService:Create(KeybindButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
    end)
    
    KeybindButton.MouseLeave:Connect(function()
        TweenService:Create(KeybindButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    local BgImageLabel = Instance.new("TextLabel")
    BgImageLabel.Size = UDim2.new(1, 0, 0, 20)
    BgImageLabel.BackgroundTransparency = 1
    BgImageLabel.Text = "Background Image"
    BgImageLabel.TextColor3 = COLORS.White
    BgImageLabel.TextSize = 13
    BgImageLabel.Font = Enum.Font.GothamBold
    BgImageLabel.TextXAlignment = Enum.TextXAlignment.Left
    BgImageLabel.ZIndex = 11
    BgImageLabel.LayoutOrder = 7
    BgImageLabel.Parent = Content
    
    local BgImageContainer = Instance.new("Frame")
    BgImageContainer.Size = UDim2.new(1, 0, 0, 70)
    BgImageContainer.BackgroundColor3 = COLORS.Background
    BgImageContainer.BorderSizePixel = 0
    BgImageContainer.ZIndex = 11
    BgImageContainer.LayoutOrder = 8
    BgImageContainer.Parent = Content
    
    local BgImageCorner = Instance.new("UICorner")
    BgImageCorner.CornerRadius = UDim.new(0, 10)
    BgImageCorner.Parent = BgImageContainer
    
    local BgImageText = Instance.new("TextLabel")
    BgImageText.Size = UDim2.new(1, -28, 0, 18)
    BgImageText.Position = UDim2.new(0, 14, 0, 8)
    BgImageText.BackgroundTransparency = 1
    BgImageText.Text = "Image ID"
    BgImageText.TextColor3 = COLORS.Gray
    BgImageText.TextSize = 11
    BgImageText.Font = Enum.Font.GothamMedium
    BgImageText.TextXAlignment = Enum.TextXAlignment.Left
    BgImageText.ZIndex = 11
    BgImageText.Parent = BgImageContainer
    
    local BgImageInput = Instance.new("TextBox")
    BgImageInput.Size = UDim2.new(1, -28, 0, 32)
    BgImageInput.Position = UDim2.new(0, 14, 0, 30)
    BgImageInput.BackgroundColor3 = COLORS.SurfaceLight
    BgImageInput.BorderSizePixel = 0
    BgImageInput.Text = self.BackgroundImage
    BgImageInput.PlaceholderText = "rbxassetid://123456789"
    BgImageInput.TextColor3 = COLORS.White
    BgImageInput.TextSize = 11
    BgImageInput.Font = Enum.Font.Gotham
    BgImageInput.ClearTextOnFocus = false
    BgImageInput.ZIndex = 11
    BgImageInput.Parent = BgImageContainer
    
    local BgInputCorner = Instance.new("UICorner")
    BgInputCorner.CornerRadius = UDim.new(0, 8)
    BgInputCorner.Parent = BgImageInput
    
    local BgImagePadding = Instance.new("UIPadding")
    BgImagePadding.PaddingLeft = UDim.new(0, 10)
    BgImagePadding.PaddingRight = UDim.new(0, 10)
    BgImagePadding.Parent = BgImageInput
    
    local BgTransLabel = Instance.new("TextLabel")
    BgTransLabel.Size = UDim2.new(1, 0, 0, 20)
    BgTransLabel.BackgroundTransparency = 1
    BgTransLabel.Text = "Background Opacity"
    BgTransLabel.TextColor3 = COLORS.White
    BgTransLabel.TextSize = 13
    BgTransLabel.Font = Enum.Font.GothamBold
    BgTransLabel.TextXAlignment = Enum.TextXAlignment.Left
    BgTransLabel.ZIndex = 11
    BgTransLabel.LayoutOrder = 9
    BgTransLabel.Parent = Content
    
    local BgTransSlider = Instance.new("Frame")
    BgTransSlider.Size = UDim2.new(1, 0, 0, 60)
    BgTransSlider.BackgroundColor3 = COLORS.Background
    BgTransSlider.BorderSizePixel = 0
    BgTransSlider.ZIndex = 11
    BgTransSlider.LayoutOrder = 10
    BgTransSlider.Parent = Content
    
    local BgTransCorner = Instance.new("UICorner")
    BgTransCorner.CornerRadius = UDim.new(0, 10)
    BgTransCorner.Parent = BgTransSlider
    
    local BgTransValue = Instance.new("TextLabel")
    BgTransValue.Size = UDim2.new(0, 60, 0, 20)
    BgTransValue.Position = UDim2.new(1, -74, 0, 12)
    BgTransValue.BackgroundTransparency = 1
    BgTransValue.Text = string.format("%.0f%%", (1 - self.BackgroundTransparency) * 100)
    BgTransValue.TextColor3 = COLORS.Accent
    BgTransValue.TextSize = 13
    BgTransValue.Font = Enum.Font.GothamBold
    BgTransValue.TextXAlignment = Enum.TextXAlignment.Right
    BgTransValue.ZIndex = 11
    BgTransValue.Parent = BgTransSlider
    
    local BgTransTrack = Instance.new("Frame")
    BgTransTrack.Size = UDim2.new(1, -28, 0, 6)
    BgTransTrack.Position = UDim2.new(0, 14, 1, -20)
    BgTransTrack.BackgroundColor3 = COLORS.SurfaceLight
    BgTransTrack.BorderSizePixel = 0
    BgTransTrack.ZIndex = 11
    BgTransTrack.Parent = BgTransSlider
    
    local BgTransTrackCorner = Instance.new("UICorner")
    BgTransTrackCorner.CornerRadius = UDim.new(1, 0)
    BgTransTrackCorner.Parent = BgTransTrack
    
    local BgTransFill = Instance.new("Frame")
    BgTransFill.Size = UDim2.new(1 - self.BackgroundTransparency, 0, 1, 0)
    BgTransFill.BackgroundColor3 = COLORS.Accent
    BgTransFill.BorderSizePixel = 0
    BgTransFill.ZIndex = 11
    BgTransFill.Parent = BgTransTrack
    
    local BgTransFillCorner = Instance.new("UICorner")
    BgTransFillCorner.CornerRadius = UDim.new(1, 0)
    BgTransFillCorner.Parent = BgTransFill
    
    local BgTransHandle = Instance.new("Frame")
    BgTransHandle.Size = UDim2.new(0, 16, 0, 16)
    BgTransHandle.Position = UDim2.new(1 - self.BackgroundTransparency, -8, 0.5, -8)
    BgTransHandle.BackgroundColor3 = COLORS.White
    BgTransHandle.BorderSizePixel = 0
    BgTransHandle.ZIndex = 11
    BgTransHandle.Parent = BgTransTrack
    
    local BgTransHandleCorner = Instance.new("UICorner")
    BgTransHandleCorner.CornerRadius = UDim.new(1, 0)
    BgTransHandleCorner.Parent = BgTransHandle
    
    local draggingBgTrans = false
    
    local function updateBgTransparency(value)
        value = math.clamp(value, 0, 1)
        self.BackgroundTransparency = value
        
        BgTransValue.Text = string.format("%.0f%%", (1 - value) * 100)
        BgTransFill.Size = UDim2.new(1 - value, 0, 1, 0)
        BgTransHandle.Position = UDim2.new(1 - value, -8, 0.5, -8)
        
        if self.CustomBg then
            self.CustomBg.ImageTransparency = value
        end
    end
    
    BgTransTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingBgTrans = true
            local relativeX = math.clamp(input.Position.X - BgTransTrack.AbsolutePosition.X, 0, BgTransTrack.AbsoluteSize.X)
            local percent = relativeX / BgTransTrack.AbsoluteSize.X
            updateBgTransparency(1 - percent)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if draggingBgTrans and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp(input.Position.X - BgTransTrack.AbsolutePosition.X, 0, BgTransTrack.AbsoluteSize.X)
            local percent = relativeX / BgTransTrack.AbsoluteSize.X
            updateBgTransparency(1 - percent)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingBgTrans = false
        end
    end)
    
    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(1, 0, 0, 40)
    SaveButton.BackgroundColor3 = COLORS.Accent
    SaveButton.Text = "Save Configuration"
    SaveButton.TextColor3 = Color3.fromRGB(8, 8, 12)
    SaveButton.TextSize = 13
    SaveButton.Font = Enum.Font.GothamBold
    SaveButton.AutoButtonColor = false
    SaveButton.ZIndex = 11
    SaveButton.LayoutOrder = 11
    SaveButton.Parent = Content
    
    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 10)
    SaveCorner.Parent = SaveButton
    
    SaveButton.MouseButton1Click:Connect(function()
        local bgImageId = BgImageInput.Text
        if bgImageId ~= "" then
            self:ApplyBackgroundImage(bgImageId, self.BackgroundTransparency)
        else
            self:ApplyBackgroundImage("", 1)
        end
        
        self:SaveConfig()
        SaveButton.Text = "Saved!"
        wait(1)
        SaveButton.Text = "Save Configuration"
    end)
    
    SaveButton.MouseEnter:Connect(function()
        TweenService:Create(SaveButton, FAST_TWEEN, {BackgroundColor3 = Color3.new(
            COLORS.Accent.R * 0.9,
            COLORS.Accent.G * 0.9,
            COLORS.Accent.B * 0.9
        )}):Play()
    end)
    
    SaveButton.MouseLeave:Connect(function()
        TweenService:Create(SaveButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Accent}):Play()
    end)
end

function ModernUI:CreateHeader()
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 55)
    Header.BackgroundTransparency = 1
    Header.BorderSizePixel = 0
    Header.Parent = self.MainFrame
    
    local IconContainer = Instance.new("Frame")
    IconContainer.Name = "IconContainer"
    IconContainer.Size = UDim2.new(0, 38, 0, 38)
    IconContainer.Position = UDim2.new(0, 18, 0.5, -19)
    IconContainer.BackgroundColor3 = COLORS.Surface
    IconContainer.BorderSizePixel = 0
    IconContainer.Parent = Header
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 10)
    IconCorner.Parent = IconContainer
    
    local IconFrame = Instance.new("ImageLabel")
    IconFrame.Name = "Icon"
    IconFrame.Size = UDim2.new(0, 22, 0, 22)
    IconFrame.Position = UDim2.new(0.5, -11, 0.5, -11)
    IconFrame.BackgroundTransparency = 1
    IconFrame.ImageColor3 = COLORS.White
    IconFrame.Parent = IconContainer

    self.IconFrame = IconFrame
    AnimateIcon(IconFrame, self.Icon, self.IconFPS)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 300, 0, 20)
    TitleLabel.Position = UDim2.new(0, 64, 0, 12)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = self.Title
    TitleLabel.TextColor3 = COLORS.White
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    
    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "Subtitle"
    SubtitleLabel.Size = UDim2.new(0, 300, 0, 16)
    SubtitleLabel.Position = UDim2.new(0, 64, 0, 32)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Text = self.SubTitle
    SubtitleLabel.TextColor3 = COLORS.Gray
    SubtitleLabel.TextSize = 11
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = Header
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "Close"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -42, 0.5, -15)
    CloseButton.BackgroundColor3 = COLORS.Surface
    CloseButton.Text = ""
    CloseButton.AutoButtonColor = false
    CloseButton.Parent = Header
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseButton
    
    local CloseIcon = Instance.new("ImageLabel")
    CloseIcon.Size = UDim2.new(0, 14, 0, 14)
    CloseIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    CloseIcon.BackgroundTransparency = 1
    CloseIcon.Image = "rbxassetid://7734053426"
    CloseIcon.ImageColor3 = COLORS.Gray
    CloseIcon.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        self:ShowConfirmDialog()
    end)
    
    CloseButton.MouseEnter:Connect(function()
        TweenService:Create(CloseButton, FAST_TWEEN, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
        TweenService:Create(CloseIcon, FAST_TWEEN, {ImageColor3 = COLORS.White}):Play()
    end)
    
    CloseButton.MouseLeave:Connect(function()
        TweenService:Create(CloseButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
        TweenService:Create(CloseIcon, FAST_TWEEN, {ImageColor3 = COLORS.Gray}):Play()
    end)
    
    local SettingsButton = Instance.new("TextButton")
    SettingsButton.Name = "Settings"
    SettingsButton.Size = UDim2.new(0, 30, 0, 30)
    SettingsButton.Position = UDim2.new(1, -78, 0.5, -15)
    SettingsButton.BackgroundColor3 = COLORS.Surface
    SettingsButton.Text = ""
    SettingsButton.AutoButtonColor = false
    SettingsButton.Parent = Header
    
    local SettingsCorner = Instance.new("UICorner")
    SettingsCorner.CornerRadius = UDim.new(0, 8)
    SettingsCorner.Parent = SettingsButton
    
    local SettingsIcon = Instance.new("ImageLabel")
    SettingsIcon.Size = UDim2.new(0, 14, 0, 14)
    SettingsIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    SettingsIcon.BackgroundTransparency = 1
    SettingsIcon.Image = "rbxassetid://7734053495"
    SettingsIcon.ImageColor3 = COLORS.Gray
    SettingsIcon.Parent = SettingsButton
    
    SettingsButton.MouseButton1Click:Connect(function()
        self:ShowSettingsWindow()
    end)
    
    SettingsButton.MouseEnter:Connect(function()
        TweenService:Create(SettingsButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
        TweenService:Create(SettingsIcon, FAST_TWEEN, {ImageColor3 = COLORS.White, Rotation = 90}):Play()
    end)
    
    SettingsButton.MouseLeave:Connect(function()
        TweenService:Create(SettingsButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
        TweenService:Create(SettingsIcon, FAST_TWEEN, {ImageColor3 = COLORS.Gray, Rotation = 0}):Play()
    end)
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "Minimize"
    MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
    MinimizeButton.Position = UDim2.new(1, -114, 0.5, -15)
    MinimizeButton.BackgroundColor3 = COLORS.Surface
    MinimizeButton.Text = ""
    MinimizeButton.AutoButtonColor = false
    MinimizeButton.Parent = Header
    
    local MinCorner = Instance.new("UICorner")
    MinCorner.CornerRadius = UDim.new(0, 8)
    MinCorner.Parent = MinimizeButton
    
    local MinIcon = Instance.new("ImageLabel")
    MinIcon.Size = UDim2.new(0, 14, 0, 14)
    MinIcon.Position = UDim2.new(0.5, -7, 0.5, -7)
    MinIcon.BackgroundTransparency = 1
    MinIcon.Image = "rbxassetid://7734000129"
    MinIcon.ImageColor3 = COLORS.Gray
    MinIcon.Parent = MinimizeButton
    
    MinimizeButton.MouseButton1Click:Connect(function()
        self:ToggleUI()
    end)
    
    MinimizeButton.MouseEnter:Connect(function()
        TweenService:Create(MinimizeButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
        TweenService:Create(MinIcon, FAST_TWEEN, {ImageColor3 = COLORS.White}):Play()
    end)
    
    MinimizeButton.MouseLeave:Connect(function()
        TweenService:Create(MinimizeButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
        TweenService:Create(MinIcon, FAST_TWEEN, {ImageColor3 = COLORS.Gray}):Play()
    end)
    
    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(1, -32, 0, 1)
    Divider.Position = UDim2.new(0, 16, 1, -1)
    Divider.BackgroundColor3 = COLORS.Border
    Divider.BorderSizePixel = 0
    Divider.Parent = Header
end

function ModernUI:CreateSidebar()
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -70)
    Sidebar.Position = UDim2.new(0, 16, 0, 62)
    Sidebar.BackgroundTransparency = 1
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = self.MainFrame
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Name = "TabList"
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ScrollBarThickness = 0
    TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabList.ScrollingDirection = Enum.ScrollingDirection.Y
    TabList.Parent = Sidebar
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 6)
    ListLayout.Parent = TabList
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 8)
    end)
    
    self.TabList = TabList
end

function ModernUI:CreateContentArea()
    local ContentArea = Instance.new("ScrollingFrame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -188, 1, -82)
    ContentArea.Position = UDim2.new(0, 172, 0, 62)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ScrollBarThickness = 3
    ContentArea.ScrollBarImageColor3 = COLORS.Border
    ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
    ContentArea.ScrollingDirection = Enum.ScrollingDirection.Y
    ContentArea.Parent = self.MainFrame
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = ContentArea
    
    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 0)
    Padding.PaddingRight = UDim.new(0, 16)
    Padding.PaddingTop = UDim.new(0, 0)
    Padding.PaddingBottom = UDim.new(0, 16)
    Padding.Parent = ContentArea
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ContentArea.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 32)
    end)
    
    self.ContentArea = ContentArea
end

function ModernUI:MakeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    local function onInputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end
    
    handle.InputBegan:Connect(onInputBegan)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

function ModernUI:MakeResizable()
    local resizing = false
    local resizeStart = nil
    local startSize = nil
    
    local ResizeHandle = Instance.new("Frame")
    ResizeHandle.Name = "ResizeHandle"
    ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
    ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Parent = self.MainFrame
    
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true
            resizeStart = input.Position
            startSize = self.MainFrame.Size
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            local newWidth = math.max(400, startSize.X.Offset + delta.X)
            local newHeight = math.max(300, startSize.Y.Offset + delta.Y)
            self.MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = false
        end
    end)
end

function ModernUI:SetupMinimizeKey()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.MinimizeKey then
            self:ToggleUI()
        end
    end)
end

function ModernUI:ToggleUI()
    self.MainFrame.Visible = not self.MainFrame.Visible
end

function ModernUI:ShowConfirmDialog()
    local Overlay = Instance.new("Frame")
    Overlay.Name = "ConfirmOverlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0
    Overlay.ZIndex = 10
    Overlay.Parent = self.MainFrame
    
    TweenService:Create(Overlay, FAST_TWEEN, {BackgroundTransparency = 0.6}):Play()
    
    local Dialog = Instance.new("Frame")
    Dialog.Name = "Dialog"
    Dialog.Size = UDim2.new(0, 300, 0, 0)
    Dialog.Position = UDim2.new(0.5, -150, 0.5, -75)
    Dialog.BackgroundColor3 = COLORS.Surface
    Dialog.BorderSizePixel = 0
    Dialog.ZIndex = 11
    Dialog.Parent = Overlay
    
    local DialogCorner = Instance.new("UICorner")
    DialogCorner.CornerRadius = UDim.new(0, 14)
    DialogCorner.Parent = Dialog
    
    TweenService:Create(Dialog, TWEEN_INFO, {Size = UDim2.new(0, 300, 0, 150)}):Play()
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -32, 0, 24)
    Title.Position = UDim2.new(0, 16, 0, 16)
    Title.BackgroundTransparency = 1
    Title.Text = "Confirm Close"
    Title.TextColor3 = COLORS.White
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 11
    Title.Parent = Dialog
    
    local Message = Instance.new("TextLabel")
    Message.Size = UDim2.new(1, -32, 0, 40)
    Message.Position = UDim2.new(0, 16, 0, 45)
    Message.BackgroundTransparency = 1
    Message.Text = "Are you sure you want to close?"
    Message.TextColor3 = COLORS.Gray
    Message.TextSize = 12
    Message.Font = Enum.Font.Gotham
    Message.TextWrapped = true
    Message.TextXAlignment = Enum.TextXAlignment.Left
    Message.TextYAlignment = Enum.TextYAlignment.Top
    Message.ZIndex = 11
    Message.Parent = Dialog
    
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(1, -32, 0, 38)
    ButtonContainer.Position = UDim2.new(0, 16, 1, -54)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.ZIndex = 11
    ButtonContainer.Parent = Dialog
    
    local ButtonLayout = Instance.new("UIListLayout")
    ButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    ButtonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    ButtonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ButtonLayout.Padding = UDim.new(0, 8)
    ButtonLayout.Parent = ButtonContainer
    
    local CancelButton = Instance.new("TextButton")
    CancelButton.Name = "Cancel"
    CancelButton.Size = UDim2.new(0, 120, 1, 0)
    CancelButton.BackgroundColor3 = COLORS.SurfaceLight
    CancelButton.Text = "Cancel"
    CancelButton.TextColor3 = COLORS.White
    CancelButton.TextSize = 13
    CancelButton.Font = Enum.Font.GothamMedium
    CancelButton.AutoButtonColor = false
    CancelButton.ZIndex = 11
    CancelButton.LayoutOrder = 1
    CancelButton.Parent = ButtonContainer
    
    local CancelCorner = Instance.new("UICorner")
    CancelCorner.CornerRadius = UDim.new(0, 8)
    CancelCorner.Parent = CancelButton
    
    local ConfirmButton = Instance.new("TextButton")
    ConfirmButton.Name = "Confirm"
    ConfirmButton.Size = UDim2.new(0, 120, 1, 0)
    ConfirmButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    ConfirmButton.Text = "Close"
    ConfirmButton.TextColor3 = COLORS.White
    ConfirmButton.TextSize = 13
    ConfirmButton.Font = Enum.Font.GothamBold
    ConfirmButton.AutoButtonColor = false
    ConfirmButton.ZIndex = 11
    ConfirmButton.LayoutOrder = 2
    ConfirmButton.Parent = ButtonContainer
    
    local ConfirmCorner = Instance.new("UICorner")
    ConfirmCorner.CornerRadius = UDim.new(0, 8)
    ConfirmCorner.Parent = ConfirmButton
    
    ConfirmButton.MouseButton1Click:Connect(function()
        self:SaveConfig()
        TweenService:Create(Dialog, FAST_TWEEN, {Size = UDim2.new(0, 300, 0, 0)}):Play()
        TweenService:Create(Overlay, FAST_TWEEN, {BackgroundTransparency = 1}):Play()
        wait(0.2)
        self.ScreenGui:Destroy()
    end)
    
    CancelButton.MouseButton1Click:Connect(function()
        TweenService:Create(Dialog, FAST_TWEEN, {Size = UDim2.new(0, 300, 0, 0)}):Play()
        TweenService:Create(Overlay, FAST_TWEEN, {BackgroundTransparency = 1}):Play()
        wait(0.2)
        Overlay:Destroy()
    end)
    
    CancelButton.MouseEnter:Connect(function()
        TweenService:Create(CancelButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
    end)
    
    CancelButton.MouseLeave:Connect(function()
        TweenService:Create(CancelButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    ConfirmButton.MouseEnter:Connect(function()
        TweenService:Create(ConfirmButton, FAST_TWEEN, {BackgroundColor3 = Color3.fromRGB(220, 60, 60)}):Play()
    end)
    
    ConfirmButton.MouseLeave:Connect(function()
        TweenService:Create(ConfirmButton, FAST_TWEEN, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
    end)
end



function ModernUI:ApplyTheme(themeName)
    if not THEMES[themeName] then return end
    
    self.CurrentTheme = themeName
    COLORS.Accent = THEMES[themeName]
    
    for _, element in pairs(self.AccentElements) do
        if element and element.Parent then
            if element:IsA("ImageLabel") or element:IsA("ImageButton") then
                TweenService:Create(element, FAST_TWEEN, {ImageColor3 = COLORS.Accent}):Play()
            elseif element:IsA("TextLabel") or element:IsA("TextButton") then
                TweenService:Create(element, FAST_TWEEN, {TextColor3 = COLORS.Accent}):Play()
            else
                TweenService:Create(element, FAST_TWEEN, {BackgroundColor3 = COLORS.Accent}):Play()
            end
        end
    end
    
    self.ConfigData.Theme = themeName
    self:SaveConfig()
end

function ModernUI:ApplyAcrylic(enabled)
    local transparency = enabled and 0.3 or 0
    TweenService:Create(self.MainFrame, SLOW_TWEEN, {BackgroundTransparency = transparency}):Play()
    
    self.ConfigData.Acrylic = enabled
    self:SaveConfig()
end

function ModernUI:ApplyBackgroundImage(imageId, transparency)
    self.BackgroundImage = imageId or ""
    self.BackgroundTransparency = transparency or 0.3
    
    if self.CustomBg then
        self.CustomBg.Image = imageId
        TweenService:Create(self.CustomBg, SLOW_TWEEN, {ImageTransparency = transparency}):Play()
    end
    
    self.ConfigData.BackgroundImage = imageId
    self.ConfigData.BackgroundTransparency = transparency
    self:SaveConfig()
end

function ModernUI:CreateTab(config)
    local Tab = {}
    
    config = config or {}
    local name = config.Name or "Tab"
    local icon = config.Icon or {"rbxassetid://138770682187300", "rbxassetid://110961158970233"}
    
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name
    TabButton.Size = UDim2.new(1, 0, 0, 38)
    TabButton.BackgroundColor3 = COLORS.Background
    TabButton.BorderSizePixel = 0
    TabButton.Text = ""
    TabButton.AutoButtonColor = false
    TabButton.Parent = self.TabList
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 10)
    TabCorner.Parent = TabButton
     
    local Indicator = Instance.new("Frame")
    Indicator.Name = "Indicator"
    Indicator.Size = UDim2.new(0, 2, 0, 18)
    Indicator.Position = UDim2.new(0, 0, 0.5, -9)
    Indicator.BackgroundColor3 = COLORS.Accent
    Indicator.BorderSizePixel = 0
    Indicator.Visible = false
    Indicator.Parent = TabButton
    
    table.insert(self.AccentElements, Indicator)
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    local IconLabel = Instance.new("ImageLabel")
    IconLabel.Size = UDim2.new(0, 16, 0, 16)
    IconLabel.Position = UDim2.new(0, 12, 0.5, -8)
    IconLabel.BackgroundTransparency = 1
    IconLabel.ImageColor3 = COLORS.Gray
    IconLabel.ImageColor3 = COLORS.Gray
    IconLabel.Parent = TabButton
    
    AnimateIcon(IconLabel, icon, 0.1)
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -38, 1, 0)
    Label.Position = UDim2.new(0, 36, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = COLORS.Gray
    Label.TextSize = 12
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = TabButton
    
    local Container = Instance.new("Frame")
    Container.Name = name .. "Container"
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.BackgroundTransparency = 1
    Container.Visible = false
    Container.Parent = self.ContentArea
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 10)
    ListLayout.Parent = Container
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Container.Size = UDim2.new(1, 0, 0, ListLayout.AbsoluteContentSize.Y)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        self:SelectTab(Tab)
    end)
    
    TabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= Tab then
            TweenService:Create(TabButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
        end
    end)
    
    TabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= Tab then
            TweenService:Create(TabButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Background}):Play()
        end
    end)
    
    Tab.Button = TabButton
    Tab.Container = Container
    Tab.Indicator = Indicator
    Tab.IconLabel = IconLabel
    Tab.Label = Label
    Tab.Name = name
    
    table.insert(self.Tabs, Tab)
    
    if not self.CurrentTab then
        self:SelectTab(Tab)
    end
    
    return Tab
end

function ModernUI:SelectTab(tab)
    for _, t in ipairs(self.Tabs) do
        t.Container.Visible = false
        t.Indicator.Visible = false
        TweenService:Create(t.Button, FAST_TWEEN, {BackgroundColor3 = COLORS.Background}):Play()
        TweenService:Create(t.IconLabel, FAST_TWEEN, {ImageColor3 = COLORS.Gray}):Play()
        TweenService:Create(t.Label, FAST_TWEEN, {TextColor3 = COLORS.Gray}):Play()
    end
    
    tab.Container.Visible = true
    tab.Indicator.Visible = true
    TweenService:Create(tab.Button, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    TweenService:Create(tab.IconLabel, FAST_TWEEN, {ImageColor3 = COLORS.Accent}):Play()
    TweenService:Create(tab.Label, FAST_TWEEN, {TextColor3 = COLORS.White}):Play()
    
    self.CurrentTab = tab
end

function ModernUI:AddSection(tab, config)
    config = config or {}
    local name = config.Name or "Section"
    
    local Section = Instance.new("Frame")
    Section.Name = "Section"
    Section.Size = UDim2.new(1, 0, 0, 36)
    Section.BackgroundTransparency = 1
    Section.Parent = tab.Container
    
    local TempLabel = Instance.new("TextLabel")
    TempLabel.Text = "  " .. name .. "  "
    TempLabel.TextSize = 12
    TempLabel.Font = Enum.Font.GothamBold
    TempLabel.Parent = Section
    local textWidth = TempLabel.TextBounds.X
    TempLabel:Destroy()
    
    local totalWidth = Section.AbsoluteSize.X
    if totalWidth == 0 then
        totalWidth = 380
    end
    
    local leftLineWidth = (totalWidth - textWidth) / 2
    local rightLineWidth = (totalWidth - textWidth) / 2
    
    local LeftLine = Instance.new("Frame")
    LeftLine.Name = "LeftLine"
    LeftLine.Size = UDim2.new(0, leftLineWidth, 0, 2)
    LeftLine.Position = UDim2.new(0, 0, 0.5, -1)
    LeftLine.BackgroundColor3 = COLORS.Accent
    LeftLine.BorderSizePixel = 0
    LeftLine.Parent = Section
    
    table.insert(self.AccentElements, LeftLine)
    
    local LeftGradient = Instance.new("UIGradient")
    LeftGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Background),
        ColorSequenceKeypoint.new(0.5, COLORS.Accent),
        ColorSequenceKeypoint.new(1, COLORS.Accent)
    })
    LeftGradient.Rotation = 0
    LeftGradient.Parent = LeftLine
    
    local LeftCorner = Instance.new("UICorner")
    LeftCorner.CornerRadius = UDim.new(1, 0)
    LeftCorner.Parent = LeftLine
    
    local RightLine = Instance.new("Frame")
    RightLine.Name = "RightLine"
    RightLine.Size = UDim2.new(0, rightLineWidth, 0, 2)
    RightLine.Position = UDim2.new(1, -rightLineWidth, 0.5, -1)
    RightLine.BackgroundColor3 = COLORS.Accent
    RightLine.BorderSizePixel = 0
    RightLine.Parent = Section
    
    table.insert(self.AccentElements, RightLine)
    
    local RightGradient = Instance.new("UIGradient")
    RightGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, COLORS.Accent),
        ColorSequenceKeypoint.new(0.5, COLORS.Accent),
        ColorSequenceKeypoint.new(1, COLORS.Background)
    })
    RightGradient.Rotation = 0
    RightGradient.Parent = RightLine
    
    local RightCorner = Instance.new("UICorner")
    RightCorner.CornerRadius = UDim.new(1, 0)
    RightCorner.Parent = RightLine
    
    local SectionLabel = Instance.new("TextLabel")
    SectionLabel.Size = UDim2.new(0, textWidth, 1, 0)
    SectionLabel.Position = UDim2.new(0.5, -textWidth / 2, 0, 0)
    SectionLabel.BackgroundTransparency = 1
    SectionLabel.Text = name
    SectionLabel.TextColor3 = COLORS.Accent
    SectionLabel.TextSize = 12
    SectionLabel.Font = Enum.Font.GothamBold
    SectionLabel.Parent = Section
    
    table.insert(self.AccentElements, SectionLabel)
    
    Section:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local newTotalWidth = Section.AbsoluteSize.X
        if newTotalWidth > 0 then
            local newLeftWidth = (newTotalWidth - textWidth) / 2
            local newRightWidth = (newTotalWidth - textWidth) / 2
            
            LeftLine.Size = UDim2.new(0, newLeftWidth, 0, 2)
            RightLine.Size = UDim2.new(0, newRightWidth, 0, 2)
            RightLine.Position = UDim2.new(1, -newRightWidth, 0.5, -1)
            SectionLabel.Position = UDim2.new(0.5, -textWidth / 2, 0, 0)
        end
    end)
    
    return Section
end

function ModernUI:AddToggle(tab, config)
    config = config or {}
    local name = config.Name or "Toggle"
    local default = config.Default or false
    local callback = config.Callback or function() end
    
    local Toggle = Instance.new("Frame")
    Toggle.Name = "Toggle"
    Toggle.Size = UDim2.new(1, 0, 0, 40)
    Toggle.BackgroundColor3 = COLORS.Surface
    Toggle.BorderSizePixel = 0
    Toggle.Parent = tab.Container
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 10)
    ToggleCorner.Parent = Toggle
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.7, 0, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = COLORS.White
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Toggle
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 42, 0, 22)
    ToggleButton.Position = UDim2.new(1, -56, 0.5, -11)
    ToggleButton.BackgroundColor3 = COLORS.SurfaceLight
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = Toggle
    
    local ToggleCorner2 = Instance.new("UICorner")
    ToggleCorner2.CornerRadius = UDim.new(1, 0)
    ToggleCorner2.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 18, 0, 18)
    ToggleCircle.Position = UDim2.new(0, 2, 0.5, -9)
    ToggleCircle.BackgroundColor3 = COLORS.Gray
    ToggleCircle.BorderSizePixel = 0
    ToggleCircle.Parent = ToggleButton
    
    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = ToggleCircle
    
    local toggled = default or false
    
    if toggled then
        ToggleButton.BackgroundColor3 = COLORS.Accent
        ToggleCircle.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        ToggleCircle.Position = UDim2.new(1, -20, 0.5, -9)
    end
    
    if self.ConfigData.Toggles[name] ~= nil then
        toggled = self.ConfigData.Toggles[name]
        if toggled then
            ToggleButton.BackgroundColor3 = COLORS.Accent
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
            ToggleCircle.Position = UDim2.new(1, -20, 0.5, -9)
        end
    end
    
    table.insert(self.AccentElements, ToggleButton)
    
    local function updateToggle()
        if toggled then
            TweenService:Create(ToggleButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Accent}):Play()
            TweenService:Create(ToggleCircle, FAST_TWEEN, {
                BackgroundColor3 = Color3.fromRGB(8, 8, 12),
                Position = UDim2.new(1, -20, 0.5, -9)
            }):Play()
        else
            TweenService:Create(ToggleButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
            TweenService:Create(ToggleCircle, FAST_TWEEN, {
                BackgroundColor3 = COLORS.Gray,
                Position = UDim2.new(0, 2, 0.5, -9)
            }):Play()
        end
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        updateToggle()
        
        self.ConfigData.Toggles[name] = toggled
        self:SaveConfig()
        
        if callback then
            callback(toggled)
        end
    end)
    
    Toggle.MouseEnter:Connect(function()
        TweenService:Create(Toggle, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    Toggle.MouseLeave:Connect(function()
        TweenService:Create(Toggle, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
    end)
    
    return Toggle
end

function ModernUI:AddDropdown(tab, config)
    config = config or {}
    local name = config.Name or "Dropdown"
    local options = config.Options or {"Option 1", "Option 2"}
    local default = config.Default or options[1]
    local callback = config.Callback or function() end
    
    local Dropdown = Instance.new("Frame")
    Dropdown.Name = "Dropdown"
    Dropdown.Size = UDim2.new(1, 0, 0, 66)
    Dropdown.BackgroundTransparency = 1
    Dropdown.Parent = tab.Container
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.Position = UDim2.new(0, 0, 0, 26)
    Container.BackgroundColor3 = COLORS.Surface
    Container.BorderSizePixel = 0
    Container.Parent = Dropdown
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 10)
    ContainerCorner.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = COLORS.Gray
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Dropdown
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = ""
    DropdownButton.AutoButtonColor = false
    DropdownButton.Parent = Container
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, -45, 1, 0)
    SelectedLabel.Position = UDim2.new(0, 14, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = default or options[1] or ""
    SelectedLabel.TextColor3 = COLORS.White
    SelectedLabel.TextSize = 13
    SelectedLabel.Font = Enum.Font.GothamMedium
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.Parent = DropdownButton
    
    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 14, 0, 14)
    Arrow.Position = UDim2.new(1, -28, 0.5, -7)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://7733717447"
    Arrow.ImageColor3 = COLORS.Gray
    Arrow.Rotation = 0
    Arrow.Parent = DropdownButton
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 72)
    DropdownList.BackgroundColor3 = COLORS.Surface
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.ZIndex = 5
    DropdownList.ClipsDescendants = true
    DropdownList.Parent = Dropdown
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 10)
    ListCorner.Parent = DropdownList
    
    local ListContainer = Instance.new("ScrollingFrame")
    ListContainer.Size = UDim2.new(1, 0, 1, 0)
    ListContainer.BackgroundTransparency = 1
    ListContainer.BorderSizePixel = 0
    ListContainer.ScrollBarThickness = 0
    ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListContainer.ZIndex = 6
    ListContainer.Parent = DropdownList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = ListContainer
    
    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingLeft = UDim.new(0, 6)
    ListPadding.PaddingRight = UDim.new(0, 6)
    ListPadding.PaddingTop = UDim.new(0, 6)
    ListPadding.PaddingBottom = UDim.new(0, 6)
    ListPadding.Parent = ListContainer
    
    local isOpen = false
    local selectedOption = default or options[1]
    
    if self.ConfigData.Dropdowns[name] ~= nil then
        selectedOption = self.ConfigData.Dropdowns[name]
        SelectedLabel.Text = selectedOption
    end
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 32)
        OptionButton.BackgroundColor3 = COLORS.Background
        OptionButton.BorderSizePixel = 0
        OptionButton.Text = ""
        OptionButton.AutoButtonColor = false
        OptionButton.ZIndex = 6
        OptionButton.Parent = ListContainer
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 8)
        OptionCorner.Parent = OptionButton
        
        local OptionLabel = Instance.new("TextLabel")
        OptionLabel.Size = UDim2.new(1, -32, 1, 0)
        OptionLabel.Position = UDim2.new(0, 12, 0, 0)
        OptionLabel.BackgroundTransparency = 1
        OptionLabel.Text = option
        OptionLabel.TextColor3 = COLORS.White
        OptionLabel.TextSize = 12
        OptionLabel.Font = Enum.Font.GothamMedium
        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptionLabel.ZIndex = 6
        OptionLabel.Parent = OptionButton
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(1, -12, 0.5, -8)
        Indicator.BackgroundColor3 = COLORS.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Visible = option == selectedOption
        Indicator.ZIndex = 6
        Indicator.Parent = OptionButton
        
        table.insert(self.AccentElements, Indicator)
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = Indicator
        
        OptionButton.MouseButton1Click:Connect(function()
            selectedOption = option
            SelectedLabel.Text = option
            
            for _, child in ipairs(ListContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    local ind = child:FindFirstChild("Frame")
                    if ind then
                        ind.Visible = false
                    end
                end
            end
            
            Indicator.Visible = true
            Indicator.Size = UDim2.new(0, 0, 0, 16)
            TweenService:Create(Indicator, FAST_TWEEN, {Size = UDim2.new(0, 3, 0, 16)}):Play()
            
            self.ConfigData.Dropdowns[name] = selectedOption
            self:SaveConfig()
            
            if callback then
                callback(option)
            end
        end)
        
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Background}):Play()
        end)
    end
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
    end)
    
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownList.Visible = true
        
        if isOpen then
            TweenService:Create(Arrow, FAST_TWEEN, {Rotation = 180, ImageColor3 = COLORS.Accent}):Play()
            local targetHeight = math.min(180, ListLayout.AbsoluteContentSize.Y + 12)
            TweenService:Create(DropdownList, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            TweenService:Create(Dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 82 + targetHeight)}):Play()
        else
            TweenService:Create(Arrow, FAST_TWEEN, {Rotation = 0, ImageColor3 = COLORS.Gray}):Play()
            TweenService:Create(DropdownList, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            TweenService:Create(Dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 66)}):Play()
            wait(0.4)
            if not isOpen then
                DropdownList.Visible = false
            end
        end
    end)
    
    Container.MouseEnter:Connect(function()
        TweenService:Create(Container, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    Container.MouseLeave:Connect(function()
        TweenService:Create(Container, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
    end)
    
    return Dropdown
end

function ModernUI:AddMultiDropdown(tab, config)
    config = config or {}
    local name = config.Name or "Multi Dropdown"
    local options = config.Options or {"Option 1", "Option 2"}
    local defaults = config.Default or {}
    local callback = config.Callback or function() end
    
    local Dropdown = Instance.new("Frame")
    Dropdown.Name = "MultiDropdown"
    Dropdown.Size = UDim2.new(1, 0, 0, 66)
    Dropdown.BackgroundTransparency = 1
    Dropdown.Parent = tab.Container
    
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 40)
    Container.Position = UDim2.new(0, 0, 0, 26)
    Container.BackgroundColor3 = COLORS.Surface
    Container.BorderSizePixel = 0
    Container.Parent = Dropdown
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 10)
    ContainerCorner.Parent = Container
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 18)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = COLORS.Gray
    Label.TextSize = 11
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Dropdown
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 1, 0)
    DropdownButton.BackgroundTransparency = 1
    DropdownButton.Text = ""
    DropdownButton.AutoButtonColor = false
    DropdownButton.Parent = Container
    
    local selectedOptions = defaults or {}
    
    if self.ConfigData.MultiDropdowns[name] ~= nil then
        selectedOptions = self.ConfigData.MultiDropdowns[name]
    end
    
    local SelectedLabel = Instance.new("TextLabel")
    SelectedLabel.Size = UDim2.new(1, -45, 1, 0)
    SelectedLabel.Position = UDim2.new(0, 14, 0, 0)
    SelectedLabel.BackgroundTransparency = 1
    SelectedLabel.Text = "None selected"
    SelectedLabel.TextColor3 = COLORS.Gray
    SelectedLabel.TextSize = 13
    SelectedLabel.Font = Enum.Font.GothamMedium
    SelectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    SelectedLabel.Parent = DropdownButton
    
    local function updateLabel()
        if #selectedOptions == 0 then
            SelectedLabel.Text = "None selected"
            SelectedLabel.TextColor3 = COLORS.Gray
        elseif #selectedOptions == 1 then
            SelectedLabel.Text = selectedOptions[1]
            SelectedLabel.TextColor3 = COLORS.White
        else
            SelectedLabel.Text = #selectedOptions .. " selected"
            SelectedLabel.TextColor3 = COLORS.Accent
        end
    end
    
    updateLabel()
    
    table.insert(self.AccentElements, SelectedLabel)
    
    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 14, 0, 14)
    Arrow.Position = UDim2.new(1, -28, 0.5, -7)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://7733717447"
    Arrow.ImageColor3 = COLORS.Gray
    Arrow.Rotation = 0
    Arrow.Parent = DropdownButton
    
    local DropdownList = Instance.new("Frame")
    DropdownList.Size = UDim2.new(1, 0, 0, 0)
    DropdownList.Position = UDim2.new(0, 0, 0, 72)
    DropdownList.BackgroundColor3 = COLORS.Surface
    DropdownList.BorderSizePixel = 0
    DropdownList.Visible = false
    DropdownList.ZIndex = 5
    DropdownList.ClipsDescendants = true
    DropdownList.Parent = Dropdown
    
    local ListCorner = Instance.new("UICorner")
    ListCorner.CornerRadius = UDim.new(0, 10)
    ListCorner.Parent = DropdownList
    
    local ListContainer = Instance.new("ScrollingFrame")
    ListContainer.Size = UDim2.new(1, 0, 1, 0)
    ListContainer.BackgroundTransparency = 1
    ListContainer.BorderSizePixel = 0
    ListContainer.ScrollBarThickness = 0
    ListContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListContainer.ZIndex = 6
    ListContainer.Parent = DropdownList
    
    local ListLayout = Instance.new("UIListLayout")
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Padding = UDim.new(0, 2)
    ListLayout.Parent = ListContainer
    
    local ListPadding = Instance.new("UIPadding")
    ListPadding.PaddingLeft = UDim.new(0, 6)
    ListPadding.PaddingRight = UDim.new(0, 6)
    ListPadding.PaddingTop = UDim.new(0, 6)
    ListPadding.PaddingBottom = UDim.new(0, 6)
    ListPadding.Parent = ListContainer
    
    local isOpen = false
    
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 32)
        OptionButton.BackgroundColor3 = COLORS.Background
        OptionButton.BorderSizePixel = 0
        OptionButton.Text = ""
        OptionButton.AutoButtonColor = false
        OptionButton.ZIndex = 6
        OptionButton.Parent = ListContainer
        
        local OptionCorner = Instance.new("UICorner")
        OptionCorner.CornerRadius = UDim.new(0, 8)
        OptionCorner.Parent = OptionButton
        
        local OptionLabel = Instance.new("TextLabel")
        OptionLabel.Size = UDim2.new(1, -32, 1, 0)
        OptionLabel.Position = UDim2.new(0, 12, 0, 0)
        OptionLabel.BackgroundTransparency = 1
        OptionLabel.Text = option
        OptionLabel.TextColor3 = COLORS.White
        OptionLabel.TextSize = 12
        OptionLabel.Font = Enum.Font.GothamMedium
        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
        OptionLabel.ZIndex = 6
        OptionLabel.Parent = OptionButton
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(1, -12, 0.5, -8)
        Indicator.BackgroundColor3 = COLORS.Accent
        Indicator.BorderSizePixel = 0
        Indicator.Visible = table.find(selectedOptions, option) ~= nil
        Indicator.ZIndex = 6
        Indicator.Parent = OptionButton
        
        table.insert(self.AccentElements, Indicator)
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(1, 0)
        IndicatorCorner.Parent = Indicator
        
        OptionButton.MouseButton1Click:Connect(function()
            local index = table.find(selectedOptions, option)
            
            if index then
                table.remove(selectedOptions, index)
                Indicator.Visible = false
            else
                table.insert(selectedOptions, option)
                Indicator.Visible = true
                Indicator.Size = UDim2.new(0, 0, 0, 16)
                TweenService:Create(Indicator, FAST_TWEEN, {Size = UDim2.new(0, 3, 0, 16)}):Play()
            end
            
            updateLabel()
            
            self.ConfigData.MultiDropdowns[name] = selectedOptions
            self:SaveConfig()
            
            if callback then
                callback(selectedOptions)
            end
        end)
        
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, FAST_TWEEN, {BackgroundColor3 = COLORS.Background}):Play()
        end)
    end
    
    ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ListContainer.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 12)
    end)
    
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        DropdownList.Visible = true
        
        if isOpen then
            TweenService:Create(Arrow, FAST_TWEEN, {Rotation = 180, ImageColor3 = COLORS.Accent}):Play()
            local targetHeight = math.min(180, ListLayout.AbsoluteContentSize.Y + 12)
            TweenService:Create(DropdownList, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            TweenService:Create(Dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 82 + targetHeight)}):Play()
        else
            TweenService:Create(Arrow, FAST_TWEEN, {Rotation = 0, ImageColor3 = COLORS.Gray}):Play()
            TweenService:Create(DropdownList, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 0)}):Play()
            TweenService:Create(Dropdown, TWEEN_INFO, {Size = UDim2.new(1, 0, 0, 66)}):Play()
            wait(0.4)
            if not isOpen then
                DropdownList.Visible = false
            end
        end
    end)
    
    Container.MouseEnter:Connect(function()
        TweenService:Create(Container, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    Container.MouseLeave:Connect(function()
        TweenService:Create(Container, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
    end)
    
    return Dropdown
end

function ModernUI:AddButton(tab, config)
    config = config or {}
    local name = config.Name or "Button"
    local callback = config.Callback or function() end
    
    local Button = Instance.new("Frame")
    Button.Name = "Button"
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundTransparency = 1
    Button.Parent = tab.Container
    
    local ButtonFrame = Instance.new("TextButton")
    ButtonFrame.Size = UDim2.new(1, 0, 1, 0)
    ButtonFrame.BackgroundColor3 = COLORS.Surface
    ButtonFrame.BorderSizePixel = 0
    ButtonFrame.Text = ""
    ButtonFrame.AutoButtonColor = false
    ButtonFrame.Parent = Button
    
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 10)
    ButtonCorner.Parent = ButtonFrame
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -45, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = COLORS.White
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ButtonFrame
    
    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 14, 0, 14)
    Arrow.Position = UDim2.new(1, -28, 0.5, -7)
    Arrow.BackgroundTransparency = 1
    Arrow.Image = "rbxassetid://7733717447"
    Arrow.ImageColor3 = COLORS.Gray
    Arrow.Rotation = -90
    Arrow.Parent = ButtonFrame
    
    ButtonFrame.MouseButton1Click:Connect(function()
        TweenService:Create(ButtonFrame, TweenInfo.new(0.08), {Size = UDim2.new(0.98, 0, 0.92, 0)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.08), {Position = UDim2.new(1, -26, 0.5, -7)}):Play()
        wait(0.08)
        TweenService:Create(ButtonFrame, TweenInfo.new(0.08), {Size = UDim2.new(1, 0, 1, 0)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.08), {Position = UDim2.new(1, -28, 0.5, -7)}):Play()
        
        if callback then
            callback()
        end
    end)
    
    ButtonFrame.MouseEnter:Connect(function()
        TweenService:Create(ButtonFrame, FAST_TWEEN, {BackgroundColor3 = COLORS.Accent}):Play()
        TweenService:Create(Arrow, FAST_TWEEN, {ImageColor3 = Color3.fromRGB(8, 8, 12)}):Play()
        TweenService:Create(Label, FAST_TWEEN, {TextColor3 = Color3.fromRGB(8, 8, 12)}):Play()
    end)
    
    ButtonFrame.MouseLeave:Connect(function()
        TweenService:Create(ButtonFrame, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
        TweenService:Create(Arrow, FAST_TWEEN, {ImageColor3 = COLORS.Gray}):Play()
        TweenService:Create(Label, FAST_TWEEN, {TextColor3 = COLORS.White}):Play()
    end)
    
    table.insert(self.AccentElements, ButtonFrame)
    
    return Button
end

function ModernUI:AddSlider(tab, config)
    config = config or {}
    local name = config.Name or "Slider"
    local min = config.Min or 0
    local max = config.Max or 100
    local default = config.Default or min
    local callback = config.Callback or function() end
    
    local Slider = Instance.new("Frame")
    Slider.Name = "Slider"
    Slider.Size = UDim2.new(1, 0, 0, 76)
    Slider.BackgroundColor3 = COLORS.Surface
    Slider.BorderSizePixel = 0
    Slider.Parent = tab.Container
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 10)
    SliderCorner.Parent = Slider
    
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.6, 0, 0, 20)
    Label.Position = UDim2.new(0, 14, 0, 12)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = COLORS.White
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Slider
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 70, 0, 20)
    ValueLabel.Position = UDim2.new(1, -84, 0, 12)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default or min)
    ValueLabel.TextColor3 = COLORS.Accent
    ValueLabel.TextSize = 14
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = Slider
    
    table.insert(self.AccentElements, ValueLabel)
    
    local InputContainer = Instance.new("Frame")
    InputContainer.Size = UDim2.new(0, 80, 0, 26)
    InputContainer.Position = UDim2.new(0, 14, 0, 40)
    InputContainer.BackgroundColor3 = COLORS.Background
    InputContainer.BorderSizePixel = 0
    InputContainer.Parent = Slider
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 7)
    InputCorner.Parent = InputContainer
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -10, 1, 0)
    TextBox.Position = UDim2.new(0, 5, 0, 0)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = tostring(default or min)
    TextBox.TextColor3 = COLORS.White
    TextBox.TextSize = 12
    TextBox.Font = Enum.Font.GothamMedium
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = InputContainer
    
    local SliderTrack = Instance.new("Frame")
    SliderTrack.Size = UDim2.new(1, -120, 0, 6)
    SliderTrack.Position = UDim2.new(0, 104, 0, 50)
    SliderTrack.BackgroundColor3 = COLORS.Background
    SliderTrack.BorderSizePixel = 0
    SliderTrack.Parent = Slider
    
    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = SliderTrack
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new(0, 0, 1, 0)
    SliderFill.BackgroundColor3 = COLORS.Accent
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderTrack
    
    table.insert(self.AccentElements, SliderFill)
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local SliderHandle = Instance.new("Frame")
    SliderHandle.Size = UDim2.new(0, 16, 0, 16)
    SliderHandle.Position = UDim2.new(0, -8, 0.5, -8)
    SliderHandle.BackgroundColor3 = COLORS.White
    SliderHandle.BorderSizePixel = 0
    SliderHandle.Parent = SliderTrack
    
    local HandleCorner = Instance.new("UICorner")
    HandleCorner.CornerRadius = UDim.new(1, 0)
    HandleCorner.Parent = SliderHandle
    
    local HandleShadow = Instance.new("ImageLabel")
    HandleShadow.Size = UDim2.new(1, 16, 1, 16)
    HandleShadow.Position = UDim2.new(0, -8, 0, -8)
    HandleShadow.BackgroundTransparency = 1
    HandleShadow.Image = "rbxassetid://5554236805"
    HandleShadow.ImageColor3 = COLORS.Accent
    HandleShadow.ImageTransparency = 0.5
    HandleShadow.ScaleType = Enum.ScaleType.Slice
    HandleShadow.SliceCenter = Rect.new(23, 23, 277, 277)
    HandleShadow.ZIndex = 0
    HandleShadow.Parent = SliderHandle
    
    table.insert(self.AccentElements, HandleShadow)
    
    local currentValue = default or min
    local dragging = false
    local activeInput = nil
    
    if self.ConfigData.Sliders[name] ~= nil then
        currentValue = self.ConfigData.Sliders[name]
    end
    
    local function updateSlider(value)
        value = math.clamp(value, min, max)
        currentValue = value
        
        local useDecimals = (min % 1 ~= 0 or max % 1 ~= 0)
        local displayValue = useDecimals and string.format("%.2f", value) or tostring(math.floor(value))
        
        ValueLabel.Text = displayValue
        TextBox.Text = displayValue
        
        local percent = (value - min) / (max - min)
        local xPos = percent * SliderTrack.AbsoluteSize.X
        
        SliderFill.Size = UDim2.new(0, xPos, 1, 0)
        SliderHandle.Position = UDim2.new(0, xPos - 8, 0.5, -8)
        
        self.ConfigData.Sliders[name] = currentValue
        self:SaveConfig()
        
        if callback then
            callback(value)
        end
    end
    
    updateSlider(currentValue)
    
    local function handleInput(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp(input.Position.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
            local percent = relativeX / SliderTrack.AbsoluteSize.X
            local value = min + (max - min) * percent
            updateSlider(value)
            
            SliderHandle.Size = UDim2.new(0, 20, 0, 20)
            SliderHandle.Position = UDim2.new(0, relativeX - 10, 0.5, -10)
        end
    end
    
    SliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            activeInput = input
            local relativeX = math.clamp(input.Position.X - SliderTrack.AbsolutePosition.X, 0, SliderTrack.AbsoluteSize.X)
            local percent = relativeX / SliderTrack.AbsoluteSize.X
            local value = min + (max - min) * percent
            updateSlider(value)
            
            SliderHandle.Size = UDim2.new(0, 20, 0, 20)
            SliderHandle.Position = UDim2.new(0, relativeX - 10, 0.5, -10)
        end
    end)
    
    SliderTrack.InputChanged:Connect(handleInput)
    UserInputService.InputChanged:Connect(handleInput)
    
    SliderTrack.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                activeInput = nil
                local percent = (currentValue - min) / (max - min)
                local xPos = percent * SliderTrack.AbsoluteSize.X
                TweenService:Create(SliderHandle, FAST_TWEEN, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, xPos - 8, 0.5, -8)}):Play()
            end
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                activeInput = nil
                local percent = (currentValue - min) / (max - min)
                local xPos = percent * SliderTrack.AbsoluteSize.X
                TweenService:Create(SliderHandle, FAST_TWEEN, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, xPos - 8, 0.5, -8)}):Play()
            end
        end
    end)
    
    TextBox:GetPropertyChangedSignal("Text"):Connect(function()
        local value = tonumber(TextBox.Text)
        if value then
            value = math.clamp(value, min, max)
            updateSlider(value)
        end
    end)
    
    TextBox.FocusLost:Connect(function()
        local value = tonumber(TextBox.Text)
        if value then
            if value > max then
                value = max
            elseif value < min then
                value = min
            end
            updateSlider(value)
        else
            TextBox.Text = tostring(currentValue)
        end
    end)
    
    InputContainer.MouseEnter:Connect(function()
        TweenService:Create(InputContainer, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    InputContainer.MouseLeave:Connect(function()
        TweenService:Create(InputContainer, FAST_TWEEN, {BackgroundColor3 = COLORS.Background}):Play()
    end)
    
    Slider.MouseEnter:Connect(function()
        TweenService:Create(Slider, FAST_TWEEN, {BackgroundColor3 = COLORS.SurfaceLight}):Play()
    end)
    
    Slider.MouseLeave:Connect(function()
        TweenService:Create(Slider, FAST_TWEEN, {BackgroundColor3 = COLORS.Surface}):Play()
    end)
    
    return Slider
end

function ModernUI:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local body = config.Body or "Message"
    local icon = config.Icon or {"rbxassetid://138770682187300", "rbxassetid://110961158970233"}
    local duration = config.Duration or 5
    
    local Notification = Instance.new("Frame")
    Notification.Name = "Notification"
    Notification.Size = UDim2.new(0, 320, 0, 80)
    Notification.Position = UDim2.new(1, 0, 1, -90)
    Notification.BackgroundColor3 = COLORS.Surface
    Notification.BorderSizePixel = 0
    Notification.Parent = self.ScreenGui
    
    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 12)
    NotifCorner.Parent = Notification
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 24, 1, 24)
    Shadow.Position = UDim2.new(0, -12, 0, -12)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://5554236805"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.6
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = 0
    Shadow.Parent = Notification
    
    local Accent = Instance.new("Frame")
    Accent.Size = UDim2.new(1, -8, 0, 2)
    Accent.Position = UDim2.new(0, 4, 0, 4)
    Accent.BackgroundColor3 = COLORS.Accent
    Accent.BorderSizePixel = 0
    Accent.Parent = Notification
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(1, 0)
    AccentCorner.Parent = Accent
    
    local IconContainer = Instance.new("Frame")
    IconContainer.Size = UDim2.new(0, 42, 0, 42)
    IconContainer.Position = UDim2.new(0, 16, 0.5, -21)
    IconContainer.BackgroundColor3 = COLORS.Background
    IconContainer.BorderSizePixel = 0
    IconContainer.Parent = Notification
    
    local IconCorner = Instance.new("UICorner")
    IconCorner.CornerRadius = UDim.new(0, 10)
    IconCorner.Parent = IconContainer
    
    local IconLabel = Instance.new("ImageLabel")
    IconLabel.Size = UDim2.new(0, 24, 0, 24)
    IconLabel.Position = UDim2.new(0.5, -12, 0.5, -12)
    IconLabel.BackgroundTransparency = 1
    IconLabel.ImageColor3 = COLORS.Gray
    IconLabel.ImageColor3 = COLORS.Accent
    IconLabel.Parent = IconContainer
    
    AnimateIcon(IconLabel, icon, 0.1)
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -76, 0, 20)
    TitleLabel.Position = UDim2.new(0, 68, 0, 22)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = COLORS.White
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextWrapped = true
    TitleLabel.Parent = Notification
    
    local BodyLabel = Instance.new("TextLabel")
    BodyLabel.Size = UDim2.new(1, -76, 0, 24)
    BodyLabel.Position = UDim2.new(0, 68, 0, 42)
    BodyLabel.BackgroundTransparency = 1
    BodyLabel.Text = body
    BodyLabel.TextColor3 = COLORS.Gray
    BodyLabel.TextSize = 11
    BodyLabel.Font = Enum.Font.Gotham
    BodyLabel.TextXAlignment = Enum.TextXAlignment.Left
    BodyLabel.TextYAlignment = Enum.TextYAlignment.Top
    BodyLabel.TextWrapped = true
    BodyLabel.Parent = Notification
    
    local tweenIn = TweenService:Create(Notification, TWEEN_INFO, {Position = UDim2.new(1, -340, 1, -90)})
    tweenIn:Play()
    
    task.delay(duration, function()
        local tweenOut = TweenService:Create(Notification, TWEEN_INFO, {Position = UDim2.new(1, 0, 1, -90)})
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            Notification:Destroy()
        end)
    end)
end

function ModernUI:CreateFloatingButton(config)
    config = config or {}
    
    local size = config.Size or 52
    local icon = config.Icon or self.Icon
    local position = config.Position or UDim2.new(1, -70, 0.5, -26)
    
    local Button = Instance.new("ImageButton")
    Button.Name = "FloatingButton"
    Button.Size = UDim2.new(0, size, 0, size)
    Button.Position = position
    Button.BackgroundColor3 = COLORS.Surface
    Button.ImageColor3 = COLORS.White
    Button.ImageColor3 = COLORS.White
    Button.AutoButtonColor = false
    Button.ZIndex = 9999
    Button.Parent = self.ScreenGui
    
    AnimateIcon(Button, icon, 0.1)
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Button
    
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size = UDim2.new(1, 20, 1, 20)
    Shadow.Position = UDim2.new(0, -10, 0, -10)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://104991709120908"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.7
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
    Shadow.ZIndex = 9998
    Shadow.Parent = Button
    
    self.FloatingButton = Button
    
    if self.ConfigData.FloatingButton.Position then
        Button.Position = self.ConfigData.FloatingButton.Position
    end
    
    self:MakeDraggable(Button, Button)
    
    Button.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end)
    
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, FAST_TWEEN, {
            BackgroundColor3 = COLORS.Accent,
            Size = UDim2.new(0, size + 4, 0, size + 4)
        }):Play()
        TweenService:Create(Button, FAST_TWEEN, {ImageColor3 = Color3.fromRGB(8, 8, 12)}):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, FAST_TWEEN, {
            BackgroundColor3 = COLORS.Surface,
            Size = UDim2.new(0, size, 0, size)
        }):Play()
        TweenService:Create(Button, FAST_TWEEN, {ImageColor3 = COLORS.White}):Play()
    end)
    
    Button:GetPropertyChangedSignal("Position"):Connect(function()
        self.ConfigData.FloatingButton.Position = Button.Position
        self:SaveConfig()
    end)
    
    return Button
end

function ModernUI:SetIcon(iconId)
    self.Icon = iconId
    if self.IconFrame then
        AnimateIcon(self.IconFrame, iconId, self.IconFPS)
    end
    if self.FloatingButton then
        AnimateIcon(self.FloatingButton, iconId, self.IconFPS)
    end
end

function ModernUI:SaveConfig()
    if not self.SaveFolder then return end
    
    self.ConfigData.Theme = self.CurrentTheme
    self.ConfigData.Acrylic = self.AcrylicEnabled
    self.ConfigData.MinimizeKey = self.MinimizeKey.Name
    self.ConfigData.BackgroundImage = self.BackgroundImage
    self.ConfigData.BackgroundTransparency = self.BackgroundTransparency
    
    local success, err = pcall(function()
        local json = game:GetService("HttpService"):JSONEncode(self.ConfigData)
        writefile(self.SaveFolder .. ".json", json)
    end)
end

function ModernUI:LoadConfig()
    if not self.SaveFolder then return end
    
    local success, err = pcall(function()
        if isfile(self.SaveFolder .. ".json") then
            local json = readfile(self.SaveFolder .. ".json")
            self.ConfigData = game:GetService("HttpService"):JSONDecode(json)
            
            if not self.ConfigData.Toggles then self.ConfigData.Toggles = {} end
            if not self.ConfigData.Dropdowns then self.ConfigData.Dropdowns = {} end
            if not self.ConfigData.MultiDropdowns then self.ConfigData.MultiDropdowns = {} end
            if not self.ConfigData.Sliders then self.ConfigData.Sliders = {} end
            if not self.ConfigData.FloatingButton then self.ConfigData.FloatingButton = {} end
            
            if self.ConfigData.Theme then
                self.CurrentTheme = self.ConfigData.Theme
            end
            
            if self.ConfigData.Acrylic ~= nil then
                self.AcrylicEnabled = self.ConfigData.Acrylic
            end
            
            if self.ConfigData.MinimizeKey then
                local keyName = self.ConfigData.MinimizeKey
                for _, key in pairs(Enum.KeyCode:GetEnumItems()) do
                    if key.Name == keyName then
                        self.MinimizeKey = key
                        break
                    end
                end
            end
            
            if self.ConfigData.BackgroundImage then
                self.BackgroundImage = self.ConfigData.BackgroundImage
            end
            
            if self.ConfigData.BackgroundTransparency then
                self.BackgroundTransparency = self.ConfigData.BackgroundTransparency
            end
        end
    end)
end

return ModernUI
