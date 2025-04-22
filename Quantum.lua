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
        tabNames = {"Combat", "Misc", "Settings"},
        spacing = 0.02,
        containerSize = UDim2.new(0.9, 0, 0.6, 0),
        backgroundTransparency = 0.25,
        backgroundColor = Color3.new(0, 0, 0),
        tabBackgroundTransparency = 0.25,
        strokeColor = Color3.new(0, 0, 0),
        textColor = Color3.new(1, 1, 1),
        font = Font.new("rbxassetid://12187607287"),
        cornerRadius = UDim.new(0, 32)
    }
    
    for k, v in pairs(defaultConfig) do
        self[k] = config[k] or v
    end
    
    self.closeButtonImage = "rbxassetid://9886659671"
    self.closeButtonSize = UDim2.new(0, 24, 0, 24)
    self.closeButtonPosition = UDim2.new(1, -10, 0, 10)
    self.baseTextSize = 52
    
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
    self.background.Parent = self.gui
    
    self.closeButton = Instance.new("ImageButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = self.closeButtonSize
    self.closeButton.AnchorPoint = Vector2.new(1, 0)
    self.closeButton.Position = self.closeButtonPosition
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Image = self.closeButtonImage
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
    
    local numTabs = #self.tabNames
    local totalSpacing = self.spacing * (numTabs - 1)
    local tabWidth = (1 - totalSpacing) / numTabs
    
    for i, name in ipairs(self.tabNames) do
        local panel = Instance.new("Frame")
        panel.Name = name
        panel.AnchorPoint = Vector2.new(0, 0.5)
        panel.Position = UDim2.new((tabWidth + self.spacing) * (i - 1), 0, 0.5, 0)
        panel.Size = UDim2.new(tabWidth, 0, 1, 0)
        panel.BackgroundColor3 = self.backgroundColor
        panel.BackgroundTransparency = self.tabBackgroundTransparency
        panel.Parent = self.tabsContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = self.cornerRadius
        corner.Parent = panel
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.strokeColor
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
        label.TextColor3 = self.textColor
        label.TextSize = self:_calculateTextSize()
        label.FontFace = self.font
        label.Parent = header
        
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0.85, 0)
        content.Position = UDim2.new(0, 0, 0.15, 0)
        content.BackgroundTransparency = 1
        content.Parent = panel
    end
    
    self:_initializeAnimation()
    self.closeButton.MouseButton1Click:Connect(function() self:Close() end)
    
    self.background.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        end
    end)
    
    return self
end

function Quantum:_calculateTextSize()
    local containerHeight = self.containerSize.Y.Scale
    return self.baseTextSize * containerHeight
end

function Quantum:_initializeAnimation()
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

function Quantum:Open()
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

function Quantum:Close()
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

function Quantum:Destroy()
    self.gui:Destroy()
end

return Quantum
