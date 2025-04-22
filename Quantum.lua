local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Quantum = {}
Quantum.__index = Quantum

function Quantum.new(options)
    local name = options.name or "QuantumWindow"
    local parentGui = options.parent or Players.LocalPlayer:WaitForChild("PlayerGui")
    local size = options.size or UDim2.new(0.5,0,0.5,0)
    local position = options.position or UDim2.new(0.5,0,0.5,0)
    local backgroundTransparency = options.backgroundTransparency or 0.25
    local cornerRadiusScale = options.cornerRadiusScale or 0.05
    local fontScale = options.fontScale or 0.05
    local modal = options.modal == false and false or true
    local topmost = options.topmost == false and false or true
    local animationType = options.animType or "scale"
    local slideDirection = options.slideDirection or "top"
    local animationTime = options.animTime or 0.15

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name
    screenGui.IgnoreGuiInset = true
    screenGui.ResetOnSpawn = false
    if screenGui.DisplayOrder then
        screenGui.DisplayOrder = topmost and 100 or 0
    else
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    end
    screenGui.Parent = parentGui

    local backgroundDim = Instance.new("Frame")
    backgroundDim.Name = "BackgroundDim"
    backgroundDim.BackgroundColor3 = Color3.new(0,0,0)
    backgroundDim.BackgroundTransparency = 1
    backgroundDim.Size = UDim2.new(1,0,1,0)
    backgroundDim.Position = UDim2.new(0,0,0,0)
    backgroundDim.ZIndex = 1
    backgroundDim.Parent = screenGui

    local inputCapture = Instance.new("Frame")
    inputCapture.Name = "InputCapture"
    inputCapture.BackgroundTransparency = 1
    inputCapture.Size = UDim2.new(1,0,1,0)
    inputCapture.Position = UDim2.new(0,0,0,0)
    inputCapture.ZIndex = 1
    inputCapture.Active = modal
    inputCapture.Parent = screenGui

    local windowFrame = Instance.new("Frame")
    windowFrame.Name = "WindowFrame"
    windowFrame.BackgroundColor3 = Color3.new(1,1,1)
    windowFrame.BackgroundTransparency = 1
    windowFrame.Size = size
    windowFrame.Position = position
    windowFrame.AnchorPoint = Vector2.new(0.5,0.5)
    windowFrame.ZIndex = 2
    windowFrame.Parent = screenGui

    local uicorner = Instance.new("UICorner")
    uicorner.CornerRadius = UDim.new(0,0)
    uicorner.Parent = windowFrame

    local defaultPosition = position
    local defaultSize = size

    windowFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local absSize = windowFrame.AbsoluteSize
        uicorner.CornerRadius = UDim.new(0,absSize.Y * cornerRadiusScale)
        for _, element in ipairs(windowFrame:GetDescendants()) do
            if element:IsA("TextLabel") or element:IsA("TextButton") then
                element.TextSize = math.max(1, absSize.Y * fontScale)
            end
        end
    end)

    local function playOpen()
        TweenService:Create(backgroundDim,TweenInfo.new(animationTime,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency = 1 - backgroundTransparency}):Play()
        if animationType == "scale" then
            windowFrame.Size = UDim2.new(0,0,0,0)
            TweenService:Create(windowFrame,TweenInfo.new(animationTime,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size = defaultSize}):Play()
        else
            if slideDirection == "top" then
                windowFrame.Position = UDim2.new(defaultPosition.X.Scale,defaultPosition.X.Offset,-defaultSize.Y,0)
            elseif slideDirection == "bottom" then
                windowFrame.Position = UDim2.new(defaultPosition.X.Scale,defaultPosition.X.Offset,1 + defaultSize.Y,0)
            elseif slideDirection == "left" then
                windowFrame.Position = UDim2.new(-defaultSize.X,0,defaultPosition.Y.Scale,defaultPosition.Y.Offset)
            elseif slideDirection == "right" then
                windowFrame.Position = UDim2.new(1 + defaultSize.X,0,defaultPosition.Y.Scale,defaultPosition.Y.Offset)
            end
            TweenService:Create(windowFrame,TweenInfo.new(animationTime,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position = defaultPosition}):Play()
        end
    end

    local function playClose()
        TweenService:Create(backgroundDim,TweenInfo.new(animationTime,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{BackgroundTransparency = 1}):Play()
        if animationType == "scale" then
            TweenService:Create(windowFrame,TweenInfo.new(animationTime,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size = UDim2.new(0,0,0,0)}):Play()
        else
            local target
            if slideDirection == "top" then
                target = UDim2.new(defaultPosition.X.Scale,defaultPosition.X.Offset,-defaultSize.Y,0)
            elseif slideDirection == "bottom" then
                target = UDim2.new(defaultPosition.X.Scale,defaultPosition.X.Offset,1 + defaultSize.Y,0)
            elseif slideDirection == "left" then
                target = UDim2.new(-defaultSize.X,0,defaultPosition.Y.Scale,defaultPosition.Y.Offset)
            elseif slideDirection == "right" then
                target = UDim2.new(1 + defaultSize.X,0,defaultPosition.Y.Scale,defaultPosition.Y.Offset)
            end
            TweenService:Create(windowFrame,TweenInfo.new(animationTime,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Position = target}):Play()
        end
        inputCapture.Active = false
    end

    local self = setmetatable({screenGui = screenGui,windowFrame = windowFrame},Quantum)
    function self:Open()
        playOpen()
    end
    function self:Close()
        playClose()
        self.Open = function() end
    end
    return self
end

return Quantum
