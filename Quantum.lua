local Quantum = {}
Quantum.__index = Quantum

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

function Quantum.new(config)
    local self = setmetatable({}, Quantum)
    
    self.config = {
        name = config.name or "QuantumWindow",
        tabs = config.tabs or {"Default"},
        animationType = config.animationType or "scale",
        animationSpeed = config.animationSpeed or 0.15,
        cornerRadiusScale = config.cornerRadiusScale or 0.04,
        backgroundTransparency = config.backgroundTransparency or 0.25,
        closeButtonImage = config.closeButtonImage or "rbxassetid://9886659671",
        containerHeight = config.containerHeight or 0.6,
        spacingScale = config.spacingScale or 0.02
    }
    
    self.isOpen = false
    self.playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.gui = nil
    self.originalPosition = nil
    self.originalSize = nil
    
    return self
end

function Quantum:CreateGUI()
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = self.config.name
    self.gui.IgnoreGuiInset = true
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.gui.Parent = self.playerGui
    
    self.background = Instance.new("Frame")
    self.background.Name = "Background"
    self.background.Size = UDim2.new(1, 0, 1, 0)
    self.background.Position = UDim2.new(0, 0, 0, 0)
    self.background.BackgroundColor3 = Color3.new(0, 0, 0)
    self.background.BackgroundTransparency = 1
    self.background.ZIndex = 1000
    self.background.Active = true
    self.background.Selectable = true
    self.background.Parent = self.gui
    
    self.closeButton = Instance.new("ImageButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 24, 0, 24)
    self.closeButton.AnchorPoint = Vector2.new(1, 0)
    self.closeButton.Position = UDim2.new(1, -10, 0, 10)
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Image = self.config.closeButtonImage
    self.closeButton.ZIndex = 1001
    self.closeButton.Parent = self.gui
    
    self.tabsFrame = Instance.new("Frame")
    self.tabsFrame.Name = "TabsFrame"
    self.tabsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.tabsFrame.BackgroundTransparency = 1
    self.tabsFrame.ZIndex = 1001
    self.tabsFrame.Parent = self.gui
    
    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    self.tabsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    self.tabsContainer.BackgroundTransparency = 1
    self.tabsContainer.Parent = self.tabsFrame
    
    self:CreateTabs()
    self:SetupAnimations()
end

function Quantum:CreateTabs()
    local numTabs = #self.config.tabs
    local tabWidthScale = (1 - self.config.spacingScale * (numTabs - 1)) / numTabs
    
    for i, name in ipairs(self.config.tabs) do
        local panel = Instance.new("Frame")
        panel.Name = name
        panel.AnchorPoint = Vector2.new(0, 0.5)
        panel.Position = UDim2.new((tabWidthScale + self.config.spacingScale) * (i - 1), 0, 0.5, 0)
        panel.Size = UDim2.new(tabWidthScale, 0, 1, 0)
        panel.BackgroundColor3 = Color3.new(0, 0, 0)
        panel.BackgroundTransparency = 0.25
        panel.ZIndex = 1002
        panel.Parent = self.tabsContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = self:CalculateCornerRadius()
        corner.Parent = panel
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 1
        stroke.Parent = panel
        
        local header = self:CreateHeader(name, panel)
        local content = self:CreateContent(panel)
    end
end

function Quantum:CalculateCornerRadius()
    return UDim.new(self.config.cornerRadiusScale, 0)
end

function Quantum:UpdateCorners()
    for _, panel in ipairs(self.tabsContainer:GetChildren()) do
        if panel:IsA("Frame") then
            panel.UICorner.CornerRadius = self:CalculateCornerRadius()
        end
    end
end

function Quantum:CreateHeader(name, parent)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.15, 0)
    header.BackgroundTransparency = 1
    header.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 20
    label.Font = Enum.Font.Gotham
    label.Parent = header
    
    return header
end

function Quantum:CreateContent(parent)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0.85, 0)
    content.Position = UDim2.new(0, 0, 0.15, 0)
    content.BackgroundTransparency = 1
    content.Parent = parent
    return content
end

function Quantum:SetupAnimations()
    self.closeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    self.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        self:UpdateCorners()
    end)
end

function Quantum:PlayAnimation(forward)
    local tweenInfo = TweenInfo.new(self.config.animationSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local backgroundGoal = {BackgroundTransparency = forward and self.config.backgroundTransparency or 1}
    
    if self.config.animationType == "scale" then
        local targetSize = forward and UDim2.new(0.9, 0, self.config.containerHeight, 0) or UDim2.new(0, 0, 0, 0)
        TweenService:Create(self.tabsFrame, tweenInfo, {Size = targetSize}):Play()
    else
        local direction = self.config.animationType
        local screenSize = self.gui.AbsoluteSize
        local targetPosition = UDim2.new(0.5, 0, 0.5, 0)
        
        if not forward then
            if direction == "left" then targetPosition = UDim2.new(-0.5, 0, 0.5, 0)
            elseif direction == "right" then targetPosition = UDim2.new(1.5, 0, 0.5, 0)
            elseif direction == "top" then targetPosition = UDim2.new(0.5, 0, -0.5, 0)
            elseif direction == "bottom" then targetPosition = UDim2.new(0.5, 0, 1.5, 0) end
        end
        
        TweenService:Create(self.tabsFrame, tweenInfo, {Position = targetPosition}):Play()
    end
    
    TweenService:Create(self.background, tweenInfo, backgroundGoal):Play()
end

function Quantum:Open()
    if self.isOpen then return end
    self.isOpen = true
    self:CreateGUI()
    
    if self.config.animationType ~= "scale" then
        local screenSize = self.gui.AbsoluteSize
        local initPosition = UDim2.new(0.5, 0, 0.5, 0)
        
        if self.config.animationType == "left" then initPosition = UDim2.new(-0.5, 0, 0.5, 0)
        elseif self.config.animationType == "right" then initPosition = UDim2.new(1.5, 0, 0.5, 0)
        elseif self.config.animationType == "top" then initPosition = UDim2.new(0.5, 0, -0.5, 0)
        elseif self.config.animationType == "bottom" then initPosition = UDim2.new(0.5, 0, 1.5, 0) end
        
        self.tabsFrame.Position = initPosition
        self.tabsFrame.Size = UDim2.new(0.9, 0, self.config.containerHeight, 0)
    else
        self.tabsFrame.Size = UDim2.new(0, 0, 0, 0)
    end
    
    self:PlayAnimation(true)
end

function Quantum:Close()
    if not self.isOpen then return end
    self:PlayAnimation(false)
    task.wait(self.config.animationSpeed)
    self.gui:Destroy()
    self.isOpen = false
end

function Quantum:Destroy()
    if self.gui then
        self.gui:Destroy()
    end
end

return Quantum
