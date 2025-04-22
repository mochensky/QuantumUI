local QuantumUI = {}
QuantumUI.__index = QuantumUI

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local spacingScale = 0.02
local containerHeightScale = 0.6

function QuantumUI.new()
    local self = setmetatable({}, QuantumUI)
    self.categories = {}
    self.tabPanels = {}
    
    local player = Players.LocalPlayer
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "QuantumUI"
    self.gui.IgnoreGuiInset = true
    self.gui.ResetOnSpawn = false
    self.gui.Parent = player:WaitForChild("PlayerGui")

    -- Background
    self.background = Instance.new("Frame")
    self.background.Name = "Background"
    self.background.Size = UDim2.new(1, 0, 1, 0)
    self.background.BackgroundColor3 = Color3.new(0, 0, 0)
    self.background.BackgroundTransparency = 1
    self.background.ZIndex = 1
    self.background.Parent = self.gui
    TweenService:Create(self.background, TweenInfo.new(0.15), {BackgroundTransparency = 0.25}):Play()

    -- Close Button
    self.closeButton = Instance.new("ImageButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 24, 0, 24)
    self.closeButton.AnchorPoint = Vector2.new(1, 0)
    self.closeButton.Position = UDim2.new(1, -10, 0, 10)
    self.closeButton.BackgroundTransparency = 1
    self.closeButton.Image = "rbxassetid://9886659671"
    self.closeButton.ZIndex = 2
    self.closeButton.Parent = self.gui
    self.closeButton.MouseButton1Click:Connect(function() self.gui:Destroy() end)

    -- Tabs Container
    self.tabsFrame = Instance.new("Frame")
    self.tabsFrame.Name = "TabsFrame"
    self.tabsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    self.tabsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.tabsFrame.Size = UDim2.new(0, 0, 0, 0)
    self.tabsFrame.BackgroundTransparency = 1
    self.tabsFrame.Parent = self.gui

    self.tabsContainer = Instance.new("Frame")
    self.tabsContainer.Name = "TabsContainer"
    self.tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    self.tabsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    self.tabsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    self.tabsContainer.BackgroundTransparency = 1
    self.tabsContainer.Parent = self.tabsFrame

    TweenService:Create(self.tabsFrame, TweenInfo.new(0.15), {
        Size = UDim2.new(0.9, 0, containerHeightScale, 0)
    }):Play()

    return self
end

function QuantumUI:createCategory(name)
    table.insert(self.categories, name)
    
    local panel = Instance.new("Frame")
    panel.Name = name
    panel.AnchorPoint = Vector2.new(0, 0.5)
    panel.Size = UDim2.new(0, 0, 1, 0)
    panel.BackgroundColor3 = Color3.new(0, 0, 0)
    panel.BackgroundTransparency = 1
    panel.ZIndex = 1
    panel.Parent = self.tabsContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 24)
    corner.Parent = panel

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.new(0, 0, 0)
    stroke.Thickness = 1
    stroke.Parent = panel

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0.15, 0)
    header.BackgroundTransparency = 1
    header.Parent = panel

    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.Gotham
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 20
    label.BackgroundTransparency = 1
    label.Parent = header

    -- Content
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0.85, 0)
    content.Position = UDim2.new(0, 0, 0.15, 0)
    content.BackgroundTransparency = 1
    content.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = content

    table.insert(self.tabPanels, panel)
    self:_updateTabsLayout()
    
    TweenService:Create(panel, TweenInfo.new(0.15), {
        BackgroundTransparency = 0.25
    }):Play()
end

function QuantumUI:_updateTabsLayout()
    local numTabs = #self.categories
    local totalSpacing = spacingScale * (numTabs - 1)
    local tabWidthScale = (1 - totalSpacing) / numTabs

    for i, panel in ipairs(self.tabPanels) do
        panel.Size = UDim2.new(tabWidthScale, 0, 1, 0)
        panel.Position = UDim2.new((tabWidthScale + spacingScale) * (i - 1), 0, 0.5, 0)
    end
end

function QuantumUI:createButton(categoryName, buttonName, callback)
    for _, panel in ipairs(self.tabPanels) do
        if panel.Name == categoryName then
            local content = panel:FindFirstChild("Content")
            if content then
                local button = Instance.new("TextButton")
                button.Name = buttonName
                button.Size = UDim2.new(0.95, 0, 0, 40)
                button.Position = UDim2.new(0.025, 0, 0, 0)
                button.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
                button.TextColor3 = Color3.new(1, 1, 1)
                button.Text = buttonName
                button.Font = Enum.Font.Gotham
                button.TextSize = 16
                button.AutoButtonColor = false
                button.Parent = content

                local corner = Instance.new("UICorner")
                corner.CornerRadius = UDim.new(0, 8)
                corner.Parent = button

                button.MouseEnter:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
                    }):Play()
                end)

                button.MouseLeave:Connect(function()
                    TweenService:Create(button, TweenInfo.new(0.1), {
                        BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
                    }):Play()
                end)

                button.MouseButton1Click:Connect(callback)
                return button
            end
        end
    end
end

return QuantumUI
