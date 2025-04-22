local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
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
        searchPlaceholderColor = Color3.new(0.85, 0.85, 0.85),
        searchStrokeColor = Color3.new(0, 0, 0),
        
        closeButtonColor = Color3.new(1, 1, 1),
        
        strokeColor = Color3.new(0, 0, 0),
        font = Font.new("rbxassetid://12187607287"),
        cornerRadiusScale = 0.07,
        textScaleCoefficient = 0.03
    }
    
    for k, v in pairs(defaultConfig) do
        self[k] = config[k] or v
    end
    
    self.closeButtonImage = "rbxassetid://9886659671"
    self.closeButtonSize = UDim2.new(0, 24, 0, 24)
    self.closeButtonPosition = UDim2.new(1, -10, 0, 10)
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
    
    self.closeButton = Instance.new("ImageButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = self.closeButtonSize
    self.closeButton.AnchorPoint = Vector2.new(1, 0)
    self.closeButton.Position = self.closeButtonPosition
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Image = self.closeButtonImage
    self.closeButton.ImageColor3 = self.closeButtonColor
    self.closeButton.Parent = self.gui
    
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

    self.searchTab = Instance.new("Frame")
    self.searchTab.Name = "SearchTab"
    self.searchTab.AnchorPoint = Vector2.new(0.5, 0)
    self.searchTab.Position = UDim2.new(0.5, 0, 0.1, 0)
    self.searchTab.Size = UDim2.new(0.3, 0, 0.06, 0)
    self.searchTab.BackgroundColor3 = self.searchTabBackgroundColor
    self.searchTab.BackgroundTransparency = self.searchTabBackgroundTransparency
    self.searchTab.Parent = self.gui

    local searchCorner = Instance.new("UICorner")
    searchCorner.CornerRadius = UDim.new(self.cornerRadiusScale * 2, 0)
    searchCorner.Parent = self.searchTab

    local searchStroke = Instance.new("UIStroke")
    searchStroke.Color = self.searchStrokeColor
    searchStroke.Thickness = 2
    searchStroke.Parent = self.searchTab

    self.searchBox = Instance.new("TextBox")
    self.searchBox.Name = "SearchBox"
    self.searchBox.Size = UDim2.new(0.9, 0, 0.8, 0)
    self.searchBox.Position = UDim2.new(0.05, 0, 0.1, 0)
    self.searchBox.BackgroundTransparency = 1
    self.searchBox.TextColor3 = self.searchTextColor
    self.searchBox.PlaceholderColor3 = self.searchPlaceholderColor
    self.searchBox.TextSize = self:_calculateTextSize()
    self.searchBox.FontFace = self.font
    self.searchBox.Text = "Search..."
    self.searchBox.PlaceholderText = "Search..."
    self.searchBox.Parent = self.searchTab

    table.insert(self.labels, self.searchBox)

    self.viewportHeight = workspace.CurrentCamera.ViewportSize.Y
    
    local numTabs = #self.tabNames
    local totalSpacing = self.spacing * (numTabs - 1)
    local tabWidth = (1 - totalSpacing) / numTabs
    
    for i, name in ipairs(self.tabNames) do
        local panel = Instance.new("Frame")
        panel.Name = name
        panel.AnchorPoint = Vector2.new(0, 0.5)
        panel.Position = UDim2.new((tabWidth + self.spacing) * (i - 1), 0, 0.5, 0)
        panel.Size = UDim2.new(tabWidth, 0, 1, 0)
        panel.BackgroundColor3 = self.tabBackgroundColor
        panel.BackgroundTransparency = self.tabBackgroundTransparency
        panel.Parent = self.tabsContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(self.cornerRadiusScale, 0)
        corner.Parent = panel
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.tabStrokeColor
        stroke.Thickness = 1
        stroke.Parent = panel
        
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0.15, 0)
        header.BackgroundTransparency = 1
        header.Parent = panel
        
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = self.tabTextColor
        label.TextSize = self:_calculateTextSize()
        label.FontFace = self.font
        label.Parent = header
        table.insert(self.labels, label)
        
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0.85, 0)
        content.Position = UDim2.new(0, 0, 0.15, 0)
        content.BackgroundTransparency = 1
        content.Parent = panel
    end

    self.viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.viewportHeight = workspace.CurrentCamera.ViewportSize.Y
        for _, label in ipairs(self.labels) do
            label.TextSize = self:_calculateTextSize()
        end
    end)
    
    self:_initializeAnimation()
    self.closeButton.MouseButton1Click:Connect(function() self:Close() end)
    
    local function animateSearchTab(width)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tween = TweenService:Create(self.searchTab, tweenInfo, {Size = UDim2.new(width, 0, 0.06, 0)})
        tween:Play()
    end

    self.searchBox.Focused:Connect(function()
        animateSearchTab(0.4)
    end)

    self.searchBox.FocusLost:Connect(function()
        if self.searchBox.Text == "" then
            animateSearchTab(0.3)
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
    
    if self.animationType == "scale" then
        self.tabsFrame.Size = UDim2.new(0, 0, 0, 0)
        self.tabsFrame.Position = self.targetPosition
    elseif self.animationType == "left" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(-self.targetSize.X.Scale / 2, 0, 0.5, 0)
    elseif self.animationType == "right" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(1 + self.targetSize.X.Scale / 2, 0, 0.5, 0)
    elseif self.animationType == "top" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(0.5, 0, -self.targetSize.Y.Scale / 2, 0)
    elseif self.animationType == "bottom" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(0.5, 0, 1 + self.targetSize.Y.Scale / 2, 0)
    end
end

Quantum.Open = function(self)
    local tweenInfo = TweenInfo.new(self.animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local bgTween = TweenService:Create(self.background, tweenInfo, {BackgroundTransparency = self.backgroundTransparency})
    
    if self.animationType == "scale" then
        local sizeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Size = self.targetSize})
        sizeTween:Play()
    else
        local positionTween = TweenService:Create(self.tabsFrame, tweenInfo, {Position = self.targetPosition})
        positionTween:Play()
    end
    
    bgTween:Play()
end

Quantum.Close = function(self)
    local tweenInfo = TweenInfo.new(self.animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local bgTween = TweenService:Create(self.background, tweenInfo, {BackgroundTransparency = 1})
    
    local closeTween
    if self.animationType == "scale" then
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)})
    elseif self.animationType == "left" then
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Position = UDim2.new(-self.targetSize.X.Scale / 2, 0, 0.5, 0)})
    elseif self.animationType == "right" then
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Position = UDim2.new(1 + self.targetSize.X.Scale / 2, 0, 0.5, 0)})
    elseif self.animationType == "top" then
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Position = UDim2.new(0.5, 0, -self.targetSize.Y.Scale / 2, 0)})
    elseif self.animationType == "bottom" then
        closeTween = TweenService:Create(self.tabsFrame, tweenInfo, {Position = UDim2.new(0.5, 0, 1 + self.targetSize.Y.Scale / 2, 0)})
    end
    
    if closeTween then
        closeTween:Play()
        closeTween.Completed:Connect(function()
            self.gui:Destroy()
        end)
    end
    bgTween:Play()
end

Quantum.Destroy = function(self)
    if self.viewportConnection then
        self.viewportConnection:Disconnect()
    end
    self.gui:Destroy()
end

return Quantum
