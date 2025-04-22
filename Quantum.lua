local Quantum = {}
Quantum.__index = Quantum

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Z_INDEX_OFFSET = 10000

function Quantum.new(config)
    local self = setmetatable({}, Quantum)
    
    self.config = {
        name = config.name or "QuantumWindow",
        tabs = config.tabs or {"Default"},
        animationType = config.animationType:lower() or "scale",
        animationSpeed = config.animationSpeed or 0.2,
        cornerRadius = config.cornerRadius or 24,
        backgroundTransparency = config.backgroundTransparency or 0.25,
        closeButtonImage = config.closeButtonImage or "rbxassetid://9886659671",
        containerHeight = config.containerHeight or 0.6,
        spacing = config.spacing or 20,
        accentColor = config.accentColor or Color3.new(1, 1, 1)
    }
    
    self.isOpen = false
    self.playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.gui = nil
    self.tweens = {}
    
    return self
end

function Quantum:CreateBaseGUI()
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = self.config.name
    self.gui.DisplayOrder = 999
    self.gui.IgnoreGuiInset = true
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    self.gui.ResetOnSpawn = false
    self.gui.Parent = CoreGui

    self.overlay = Instance.new("TextButton")
    self.overlay.Name = "Overlay"
    self.overlay.Size = UDim2.new(1, 0, 1, 0)
    self.overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    self.overlay.BackgroundTransparency = 1
    self.overlay.Text = ""
    self.overlay.ZIndex = Z_INDEX_OFFSET
    self.overlay.AutoButtonColor = false
    self.overlay.Parent = self.gui

    self.container = Instance.new("Frame")
    self.container.Name = "Container"
    self.container.AnchorPoint = Vector2.new(0.5, 0.5)
    self.container.BackgroundTransparency = 1
    self.container.ZIndex = Z_INDEX_OFFSET + 1
    self.container.Parent = self.gui

    self.closeButton = Instance.new("ImageButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 24, 0, 24)
    self.closeButton.AnchorPoint = Vector2.new(1, 0)
    self.closeButton.Position = UDim2.new(1, -10, 0, 10)
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Image = self.config.closeButtonImage
    self.closeButton.ZIndex = Z_INDEX_OFFSET + 2
    self.closeButton.Parent = self.container
end

function Quantum:CreateTabs()
    local tabSize = UDim.new((1 - (self.config.spacing * (#self.config.tabs - 1)) / #self.config.tabs), 0)
    
    self.tabs = {}
    for i, name in ipairs(self.config.tabs) do
        local tab = Instance.new("Frame")
        tab.Name = name
        tab.AnchorPoint = Vector2.new(0, 0.5)
        tab.Position = UDim2.new((tabSize.Scale + self.config.spacing/100) * (i - 1), 0, 0.5, 0)
        tab.Size = UDim2.new(tabSize.Scale, 0, 0.95, 0)
        tab.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
        tab.BackgroundTransparency = 0.25
        tab.ZIndex = Z_INDEX_OFFSET + 3
        tab.Parent = self.container

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, self.config.cornerRadius)
        corner.Parent = tab

        local stroke = Instance.new("UIStroke")
        stroke.Color = self.config.accentColor
        stroke.Thickness = 2
        stroke.Parent = tab

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0.15, 0)
        header.BackgroundTransparency = 1
        header.ZIndex = tab.ZIndex + 1
        header.Parent = tab

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -20, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = self.config.accentColor
        label.TextSize = 18
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.GothamSemibold
        label.ZIndex = header.ZIndex
        label.Parent = header

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0.85, 0)
        content.Position = UDim2.new(0, 0, 0.15, 0)
        content.BackgroundTransparency = 1
        content.ZIndex = tab.ZIndex
        content.Parent = tab

        table.insert(self.tabs, {
            Container = tab,
            Content = content
        })
    end
end

function Quantum:GetAnimationGoals(forward)
    local goals = {}
    local screenSize = workspace.CurrentCamera.ViewportSize

    if self.config.animationType == "scale" then
        goals.Size = forward and UDim2.new(0.9, 0, self.config.containerHeight, 0) or UDim2.new(0, 0, 0, 0)
        goals.Position = UDim2.new(0.5, 0, 0.5, 0)
    else
        local direction = self.config.animationType
        local offset = forward and 0 or screenSize.X * 1.5
        
        if direction == "left" then
            goals.Position = forward and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(-1.5, 0, 0.5, 0)
        elseif direction == "right" then
            goals.Position = forward and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(2.5, 0, 0.5, 0)
        elseif direction == "top" then
            goals.Position = forward and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, -1.5, 0)
        elseif direction == "bottom" then
            goals.Position = forward and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0.5, 0, 2.5, 0)
        end
        goals.Size = UDim2.new(0.9, 0, self.config.containerHeight, 0)
    end

    goals.BackgroundTransparency = forward and self.config.backgroundTransparency or 1
    return goals
end

function Quantum:Animate(forward)
    for _, tween in pairs(self.tweens) do
        tween:Cancel()
    end
    self.tweens = {}

    local tweenInfo = TweenInfo.new(
        self.config.animationSpeed,
        Enum.EasingStyle.Quad,
        forward and Enum.EasingDirection.Out or Enum.EasingDirection.In
    )

    local containerGoals = self:GetAnimationGoals(forward)
    local overlayGoal = {BackgroundTransparency = forward and self.config.backgroundTransparency or 1}

    table.insert(self.tweens, TweenService:Create(self.container, tweenInfo, containerGoals))
    table.insert(self.tweens, TweenService:Create(self.overlay, tweenInfo, overlayGoal))

    for _, tween in ipairs(self.tweens) do
        tween:Play()
    end
end

function Quantum:Open()
    if self.isOpen then return end
    self.isOpen = true
    
    self:CreateBaseGUI()
    self:CreateTabs()
    
    local screenSize = workspace.CurrentCamera.ViewportSize
    self.container.Size = UDim2.new(0.9, 0, self.config.containerHeight, 0)
    self.container.Position = self:GetAnimationGoals(false).Position
    
    self.overlay.BackgroundTransparency = 1
    self:Animate(true)
end

function Quantum:Close()
    if not self.isOpen then return end
    
    self:Animate(false)
    task.wait(self.config.animationSpeed)
    
    if self.gui then
        self.gui:Destroy()
        self.gui = nil
    end
    
    self.isOpen = false
end

function Quantum:Destroy()
    self:Close()
end

return Quantum
