local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Quantum = {}
Quantum.__index = Quantum

function Quantum.new(config)
    local self = setmetatable({}, Quantum)
    local defaultConfig = {
        animationType = "scale",
        animationDuration = 0.15,
        tabNames = {"Test"},
        spacing = 0.02,
        containerSize = UDim2.new(0.9, 0, 0.6, 0),
        backgroundColor = Color3.new(0, 0, 0),
        backgroundTransparency = 0.25,
        tabBackgroundColor = Color3.new(0, 0, 0),
        tabBackgroundTransparency = 0.25,
        tabTextColor = Color3.new(1, 1, 1),
        tabStrokeColor = Color3.new(0, 0, 0),
        searchTabBackgroundColor = Color3.new(0, 0, 0),
        searchTabBackgroundTransparency = 0.25,
        searchTextColor = Color3.new(1, 1, 1),
        searchPlaceholderColor = Color3.new(0.7, 0.7, 0.7),
        searchStrokeColor = Color3.new(0, 0, 0),
        closeButtonColor = Color3.new(1, 1, 1),
        strokeColor = Color3.new(0, 0, 0),
        font = Font.new("rbxassetid://12187607287"),
        cornerRadiusScale = 0.08,
        textScaleCoefficient = 0.03
    }
    for k, v in pairs(defaultConfig) do
        self[k] = config[k] or v
    end
    self.closeButtonImage = "rbxassetid://9886659671"
    self.labels = {}
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "QuantumGUI"
    self.gui.IgnoreGuiInset = true
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.gui.Parent = CoreGui

    self.background = Instance.new("Frame")
    self.background.Name = "Background"
    self.background.Size = UDim2.new(1, 0, 1, 0)
    self.background.BackgroundColor3 = self.backgroundColor
    self.background.BackgroundTransparency = 1
    self.background.Active = true
    self.background.Parent = self.gui

    self.searchTab = Instance.new("Frame")
    self.searchTab.Name = "SearchTab"
    self.searchTab.AnchorPoint = Vector2.new(0.5, 0)
    self.searchTab.Position = UDim2.new(0.5, 0, 0.1, 0)
    self.searchTab.Size = UDim2.new(0.1, 0, 0.06, 0)
    self.searchTab.BackgroundColor3 = self.searchTabBackgroundColor
    self.searchTab.BackgroundTransparency = 1
    self.searchTab.Parent = self.gui

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(self.cornerRadiusScale * 10, 0)
    searchCorner.Parent = self.searchTab

    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = self.searchStrokeColor
    searchStroke.Thickness = 2
    searchStroke.Parent = self.searchTab

    self.searchBox = Instance.new("TextBox")
    self.searchBox.Name = "SearchBox"
    self.searchBox.Size = UDim2.new(1, 0, 1, 0)
    self.searchBox.Position = UDim2.new(0, 0, 0, 0)
    self.searchBox.BackgroundTransparency = 1
    self.searchBox.TextColor3 = self.searchTextColor
    self.searchBox.PlaceholderColor3 = self.searchPlaceholderColor
    self.searchBox.TextSize = self:_calculateTextSize()
    self.searchBox.FontFace = self.font
    self.searchBox.Text = ""
    self.searchBox.PlaceholderText = "SEARCH..."
    self.searchBox.Parent = self.searchTab
    table.insert(self.labels, self.searchBox)

    local btnSizeScale = self.searchTab.Size.Y.Scale
    self.closeButton = Instance.new("ImageButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.AnchorPoint = Vector2.new(0.5, 0.5)
    self.closeButton.Size = UDim2.new(0, 0, 0, 0)
    self.closeButton.Position = UDim2.new(self.searchTab.Position.X.Scale + self.searchTab.Size.X.Scale / 2 + btnSizeScale / 2 + self.spacing, 0, self.searchTab.Position.Y.Scale + btnSizeScale / 2, 0)
    self.closeButton.BackgroundColor3 = self.backgroundColor
    self.closeButton.BackgroundTransparency = self.backgroundTransparency
    self.closeButton.Image = self.closeButtonImage
    self.closeButton.ImageColor3 = self.closeButtonColor
    self.closeButton.Parent = self.gui

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(self.cornerRadiusScale * 10, 0)
    closeCorner.Parent = self.closeButton

    self.closeButton.MouseEnter:Connect(function()
        self.closeButton.ImageColor3 = Color3.new(1, 0, 0)
    end)
    self.closeButton.MouseLeave:Connect(function()
        self.closeButton.ImageColor3 = self.closeButtonColor
    end)

    self.tabsFrame = Instance.new("Frame")
    self.tabsFrame.Name = "TabsFrame"
    self.tabsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.tabsFrame.BackgroundTransparency = 1
    self.tabsFrame.Parent = self.gui

    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    self.tabsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    self.tabsContainer.BackgroundTransparency = 1
    self.tabsContainer.Parent = self.tabsFrame

    self.viewportHeight = workspace.CurrentCamera.ViewportSize.Y
    for _, label in ipairs(self.labels) do
        label.TextSize = self:_calculateTextSize()
    end
    self.viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.viewportHeight = workspace.CurrentCamera.ViewportSize.Y
        for _, label in ipairs(self.labels) do
            label.TextSize = self:_calculateTextSize()
        end
    end)

    self:_initializeAnimation()

    local function animateSearchTab(widthScale)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(self.searchTab, tweenInfo, {Size = UDim2.new(widthScale, 0, self.searchTab.Size.Y.Scale, 0)}):Play()
        local btnSize = self.searchTab.Size.Y.Scale
        local btnPos = UDim2.new(self.searchTab.Position.X.Scale + widthScale / 2 + btnSize / 2 + self.spacing, 0, self.searchTab.Position.Y.Scale + btnSize / 2, 0)
        TweenService:Create(self.closeButton, tweenInfo, {Size = UDim2.new(btnSize, 0, btnSize, 0), Position = btnPos}):Play()
    end

    self.searchBox.Focused:Connect(function()
        animateSearchTab(0.2)
    end)

    self.searchBox.FocusLost:Connect(function()
        if self.searchBox.Text == "" then
            animateSearchTab(0.1)
        else
            animateSearchTab(0.2)
        end
    end)

    return self
end

Quantum._calculateTextSize = function(self)
    if not self.viewportHeight then
        self.viewportHeight = workspace.CurrentCamera.ViewportSize.Y
    end
    return self.textScaleCoefficient * self.viewportHeight
end

Quantum._initializeAnimation = function(self)
    self.targetSize = self.containerSize
    self.targetPosition = UDim2.new(0.5, 0, 0.5, 0)
    self.searchTargetSize = UDim2.new(0.1, 0, 0.06, 0)
    self.searchTargetPosition = UDim2.new(0.5, 0, 0.1, 0)
    self.tabsFrame.Size = (self.animationType == "scale") and UDim2.new(0, 0, 0, 0) or self.targetSize
    self.tabsFrame.Position = self.targetPosition
    self.searchTab.Size = (self.animationType == "scale") and UDim2.new(0, 0, 0, 0) or self.searchTargetSize
    self.searchTab.Position = self.searchTargetPosition
    self.closeButton.Size = UDim2.new(0, 0, 0, 0)
    local btnSize = self.searchTargetSize.Y.Scale
    self.closeButton.Position = UDim2.new(self.searchTargetPosition.X.Scale + self.searchTargetSize.X.Scale / 2 + btnSize / 2 + self.spacing, 0, self.searchTargetPosition.Y.Scale + btnSize / 2, 0)
end

Quantum.Open = function(self)
    local tweenInfo = TweenInfo.new(self.animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(self.background, tweenInfo, {BackgroundTransparency = self.backgroundTransparency}):Play()
    if self.animationType == "scale" then
        TweenService:Create(self.tabsFrame, tweenInfo, {Size = self.targetSize}):Play()
    else
        TweenService:Create(self.tabsFrame, tweenInfo, {Position = self.targetPosition}):Play()
    end
    local searchTweens = {}
    if self.animationType == "scale" then
        table.insert(searchTweens, TweenService:Create(self.searchTab, tweenInfo, {Size = self.searchTargetSize}))
    else
        table.insert(searchTweens, TweenService:Create(self.searchTab, tweenInfo, {Position = self.searchTargetPosition}))
    end
    table.insert(searchTweens, TweenService:Create(self.searchTab, tweenInfo, {BackgroundTransparency = self.searchTabBackgroundTransparency}))
    for _, tween in ipairs(searchTweens) do tween:Play() end
    local btnSize = self.searchTargetSize.Y.Scale
    local btnPos = UDim2.new(self.searchTargetPosition.X.Scale + self.searchTargetSize.X.Scale / 2 + btnSize / 2 + self.spacing, 0, self.searchTargetPosition.Y.Scale + btnSize / 2, 0)
    TweenService:Create(self.closeButton, tweenInfo, {Size = UDim2.new(btnSize, 0, btnSize, 0), Position = btnPos}):Play()
end

Quantum.Close = function(self)
    local tweenInfo = TweenInfo.new(self.animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    TweenService:Create(self.background, tweenInfo, {BackgroundTransparency = 1}):Play()
    local closeTween
    if self.animationType == "scale" then
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
    else
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Position = self.targetPosition})
    end
    closeTween:Play()
    TweenService:Create(self.searchTab, tweenInfo, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    TweenService:Create(self.closeButton, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}):Play()
    closeTween.Completed:Connect(function() self.gui:Destroy() end)
end

Quantum.Destroy = function(self)
    if self.viewportConnection then self.viewportConnection:Disconnect() end
    self.gui:Destroy()
end

return Quantum
