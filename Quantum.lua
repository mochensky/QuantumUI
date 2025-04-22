local Quantum = {}
Quantum.__index = Quantum

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local DEFAULT_SETTINGS = {
    animationType = "Scale", -- Scale, Top, Bottom, Left, Right
    animationSpeed = 0.15,
    backgroundTransparency = 0.25,
    tabNames = {"Combat", "Misc", "Debug", "Test", "Settings"},
    containerHeight = 0.6,
    spacingScale = 0.02
}

function Quantum.new(options)
    local self = setmetatable({}, Quantum)
    self.settings = table.clone(DEFAULT_SETTINGS)
    for k,v in pairs(options or {}) do
        self.settings[k] = v
    end
    
    self.gui = self:_createGui()
    self:_setupAnimations()
    return self
end

function Quantum:_createGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = "QuantumUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.Enabled = true

    self.background = self:_createBackground(gui)
    self.closeButton = self:_createCloseButton(gui)
    self.tabsFrame = self:_createTabsFrame(gui)
    
    return gui
end

function Quantum:_createBackground(parent)
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.new(0, 0, 0)
    background.BackgroundTransparency = 1
    background.ZIndex = 1
    background.Parent = parent
    
    return background
end

function Quantum:_createCloseButton(parent)
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Position = UDim2.new(1, -10, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://9886659671"
    closeButton.ZIndex = 2
    closeButton.Parent = parent
    
    closeButton.MouseButton1Click:Connect(function()
        self:destroy()
    end)
    
    return closeButton
end

function Quantum:_createTabsFrame(parent)
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "TabsFrame"
    tabsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = parent

    local numTabs = #self.settings.tabNames
    local totalSpacing = self.settings.spacingScale * (numTabs - 1)
    local tabWidthScale = (1 - totalSpacing) / numTabs

    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    tabsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = tabsFrame

    for i, name in ipairs(self.settings.tabNames) do
        local panel = Instance.new("Frame")
        panel.Name = name
        panel.AnchorPoint = Vector2.new(0, 0.5)
        panel.Position = UDim2.new((tabWidthScale + self.settings.spacingScale) * (i - 1), 0, 0.5, 0)
        panel.Size = UDim2.new(tabWidthScale, 0, 1, 0)
        panel.BackgroundColor3 = Color3.new(0, 0, 0)
        panel.BackgroundTransparency = 1
        panel.ZIndex = 1
        panel.Parent = tabsContainer

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 24)
        corner.Parent = panel

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.new(0, 0, 0)
        stroke.Thickness = 1
        stroke.Parent = panel

        -- Add header and content (similar to original code)
    end

    return tabsFrame
end

function Quantum:_setupAnimations()
    -- Initial positions and sizes
    self.original = {
        backgroundTransparency = self.settings.backgroundTransparency,
        tabsSize = UDim2.new(0.9, 0, self.settings.containerHeight, 0),
        tabsPosition = UDim2.new(0.5, 0, 0.5, 0)
    }

    -- Set initial state based on animation type
    local animationType = self.settings.animationType
    local startState = {
        BackgroundTransparency = 1
    }

    if animationType == "Scale" then
        self.tabsFrame.Size = UDim2.new(0, 0, 0, 0)
    elseif animationType == "Top" then
        self.tabsFrame.Position = UDim2.new(0.5, 0, 0, -self.tabsFrame.AbsoluteSize.Y)
    elseif animationType == "Bottom" then
        self.tabsFrame.Position = UDim2.new(0.5, 0, 1, self.tabsFrame.AbsoluteSize.Y)
    elseif animationType == "Left" then
        self.tabsFrame.Position = UDim2.new(-0.5, -self.tabsFrame.AbsoluteSize.X, 0.5, 0)
    elseif animationType == "Right" then
        self.tabsFrame.Position = UDim2.new(1.5, self.tabsFrame.AbsoluteSize.X, 0.5, 0)
    end

    -- Animate in
    local tweenInfo = TweenInfo.new(
        self.settings.animationSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )

    local backgroundTween = TweenService:Create(self.background, tweenInfo, {
        BackgroundTransparency = self.settings.backgroundTransparency
    })
    
    local tabsTween = TweenService:Create(self.tabsFrame, tweenInfo, {
        Size = self.original.tabsSize,
        Position = self.original.tabsPosition
    })

    backgroundTween:Play()
    tabsTween:Play()
end

function Quantum:destroy()
    local animationType = self.settings.animationType
    local tweenInfo = TweenInfo.new(
        self.settings.animationSpeed,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.In
    )

    -- Reverse animations
    local backgroundTween = TweenService:Create(self.background, tweenInfo, {
        BackgroundTransparency = 1
    })

    local tabsTween = TweenService:Create(self.tabsFrame, tweenInfo, {
        Size = UDim2.new(0, 0, 0, 0),
        Position = if animationType == "Scale" then self.original.tabsPosition
            elseif animationType == "Top" then UDim2.new(0.5, 0, 0, -self.tabsFrame.AbsoluteSize.Y)
            elseif animationType == "Bottom" then UDim2.new(0.5, 0, 1, self.tabsFrame.AbsoluteSize.Y)
            elseif animationType == "Left" then UDim2.new(-0.5, -self.tabsFrame.AbsoluteSize.X, 0.5, 0)
            else UDim2.new(1.5, self.tabsFrame.AbsoluteSize.X, 0.5, 0)
    })

    backgroundTween:Play()
    tabsTween:Play()

    -- Destroy after animation
    tabsTween.Completed:Wait()
    self.gui:Destroy()
end

return Quantum
