local QuantumUI = {}
QuantumUI.__index = QuantumUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

function QuantumUI.new(config)
    local self = setmetatable({}, QuantumUI)
    
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = "QuantumUI"
    self.Gui.IgnoreGuiInset = true
    self.Gui.ResetOnSpawn = false
    self.Gui.Parent = player:WaitForChild("PlayerGui")

    self.Tabs = {}
    self.CurrentTab = nil
    self.Config = {
        BackgroundTransparency = config.BackgroundTransparency or 0.25,
        TabHeightScale = config.TabHeightScale or 0.6,
        AnimationDuration = config.AnimationDuration or 0.15,
        CloseButtonImage = config.CloseButtonImage or "rbxassetid://9886659671"
    }

    self:_createBackground()
    self:_createCloseButton()
    self:_createMainContainer()

    return self
end

function QuantumUI:_createBackground()
    self.Background = Instance.new("Frame")
    self.Background.Name = "Background"
    self.Background.Size = UDim2.new(1, 0, 1, 0)
    self.Background.Position = UDim2.new(0, 0, 0, 0)
    self.Background.BackgroundColor3 = Color3.new(0, 0, 0)
    self.Background.BackgroundTransparency = 1
    self.Background.ZIndex = 1
    self.Background.Parent = self.Gui

    TweenService:Create(self.Background, TweenInfo.new(self.Config.AnimationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        BackgroundTransparency = self.Config.BackgroundTransparency
    }):Play()
end

function QuantumUI:_createCloseButton()
    self.CloseButton = Instance.new("ImageButton")
    self.CloseButton.Name = "CloseButton"
    self.CloseButton.Size = UDim2.new(0, 24, 0, 24)
    self.CloseButton.AnchorPoint = Vector2.new(1, 0)
    self.CloseButton.Position = UDim2.new(1, -10, 0, 10)
    self.CloseButton.BackgroundTransparency = 1
    self.CloseButton.Image = self.Config.CloseButtonImage
    self.CloseButton.ZIndex = 2
    self.CloseButton.Parent = self.Gui

    self.CloseButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
end

function QuantumUI:_createMainContainer()
    self.MainContainer = Instance.new("Frame")
    self.MainContainer.Name = "MainContainer"
    self.MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    self.MainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.MainContainer.Size = UDim2.new(0, 0, 0, 0)
    self.MainContainer.BackgroundTransparency = 1
    self.MainContainer.Parent = self.Gui

    self.TabsContainer = Instance.new("Frame")
    self.TabsContainer.Name = "TabsContainer"
    self.TabsContainer.Size = UDim2.new(1, 0, 1, 0)
    self.TabsContainer.BackgroundTransparency = 1
    self.TabsContainer.Parent = self.MainContainer

    TweenService:Create(self.MainContainer, TweenInfo.new(self.Config.AnimationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.9, 0, self.Config.TabHeightScale, 0)
    }):Play()
end

function QuantumUI:AddTab(tabName)
    local tab = {
        Name = tabName,
        Container = Instance.new("ScrollingFrame"),
        Elements = {}
    }

    local tabFrame = Instance.new("Frame")
    tabFrame.Name = tabName
    tabFrame.Size = UDim2.new(1/#self.Tabs, 0, 1, 0)
    tabFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    tabFrame.BackgroundTransparency = 0.25
    tabFrame.ZIndex = 2
    tabFrame.Parent = self.TabsContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = tabFrame

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Thickness = 1
    stroke.Parent = tabFrame

    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.15, 0)
    header.Text = tabName
    header.TextColor3 = Color3.new(1, 1, 1)
    header.TextSize = 20
    header.Font = Enum.Font.Gotham
    header.BackgroundTransparency = 1
    header.Parent = tabFrame

    tab.Container.Name = "Content"
    tab.Container.Size = UDim2.new(1, 0, 0.85, 0)
    tab.Container.Position = UDim2.new(0, 0, 0.15, 0)
    tab.Container.BackgroundTransparency = 1
    tab.Container.ScrollBarThickness = 5
    tab.Container.Parent = tabFrame

    table.insert(self.Tabs, tab)
    self:_updateTabSizes()
    return tab
end

function QuantumUI:_updateTabSizes()
    local spacing = 0.02
    local totalSpacing = spacing * (#self.Tabs - 1)
    local tabWidth = (1 - totalSpacing) / #self.Tabs

    for i, tab in ipairs(self.Tabs) do
        tab.Container.Parent.Size = UDim2.new(tabWidth, 0, 1, 0)
        tab.Container.Parent.Position = UDim2.new((tabWidth + spacing) * (i - 1), 0, 0, 0)
    end
end

function QuantumUI:Destroy()
    TweenService:Create(self.Background, TweenInfo.new(self.Config.AnimationDuration), {
        BackgroundTransparency = 1
    }):Play()
    
    self.Gui:Destroy()
    setmetatable(self, nil)
end

return QuantumUI
