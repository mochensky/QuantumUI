local Quantum = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

function Quantum.New(config)
    local self = {}
    config = config or {}
    
    local animationDuration = config.AnimationDuration or 0.15
    local containerHeight = config.ContainerHeight or 0.6
    local tabSpacing = config.TabSpacing or 0.02
    local mainColor = config.MainColor or Color3.new(0, 0, 0)
    local textColor = config.TextColor or Color3.new(1, 1, 1)
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "QuantumUI"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")
    
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = mainColor
    background.BackgroundTransparency = 1
    background.ZIndex = 1
    background.Parent = gui
    
    local closeButton = Instance.new("ImageButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 24, 0, 24)
    closeButton.AnchorPoint = Vector2.new(1, 0)
    closeButton.Position = UDim2.new(1, -10, 0, 10)
    closeButton.BackgroundTransparency = 1
    closeButton.Image = "rbxassetid://9886659671"
    closeButton.ZIndex = 2
    closeButton.Parent = gui
    
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Name = "TabsFrame"
    tabsFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    tabsFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    tabsFrame.Size = UDim2.new(0, 0, 0, 0)
    tabsFrame.BackgroundTransparency = 1
    tabsFrame.Parent = gui
    
    local tabsContainer = Instance.new("Frame")
    tabsContainer.Name = "TabsContainer"
    tabsContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    tabsContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    tabsContainer.Size = UDim2.new(1, 0, 1, 0)
    tabsContainer.BackgroundTransparency = 1
    tabsContainer.Parent = tabsFrame
    
    function self:Show()
        TweenService:Create(background, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.25
        }):Play()
        TweenService:Create(tabsFrame, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.9, 0, containerHeight, 0)
        }):Play()
    end
    
    function self:Hide()
        TweenService:Create(background, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 1
        }):Play()
        TweenService:Create(tabsFrame, TweenInfo.new(animationDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
    end
    
    function self:Destroy()
        gui:Destroy()
    end
    
    function self:AddTab(tabName)
        local tab = {}
        local panel = Instance.new("Frame")
        panel.Name = tabName
        panel.BackgroundColor3 = mainColor
        panel.BackgroundTransparency = 1
        panel.ZIndex = 1
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 24)
        corner.Parent = panel
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = mainColor
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
        label.Text = tabName
        label.TextColor3 = textColor
        label.TextSize = 20
        label.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
        label.Parent = header
        
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0.85, 0)
        content.Position = UDim2.new(0, 0, 0.15, 0)
        content.BackgroundTransparency = 1
        content.Parent = panel
        
        function tab:AddButton(buttonConfig)
            local button = Instance.new("TextButton")
            button.Name = buttonConfig.Name
            button.Size = UDim2.new(1, 0, 0, 40)
            button.BackgroundColor3 = mainColor
            button.BackgroundTransparency = 0.5
            button.TextColor3 = textColor
            button.Text = buttonConfig.Text
            button.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json")
            button.Parent = content
            
            local corner = Instance.new("UICorner")
            corner.CornerRadius = UDim.new(0, 8)
            corner.Parent = button
            
            if buttonConfig.Callback then
                button.MouseButton1Click:Connect(buttonConfig.Callback)
            end
            
            return button
        end
        
        panel.Parent = tabsContainer
        return tab
    end
    
    closeButton.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    
    setmetatable(self, {
        __index = Quantum,
        __tostring = function() return "QuantumUI" end
    })
    
    return self
end

return Quantum
