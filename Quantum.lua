local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Quantum = {}
Quantum.__index = Quantum

local camera = Workspace.CurrentCamera
local BLUR_SIZE = Vector2.new(10, 10)
local PART_SIZE = 0.01
local PART_TRANSPARENCY = 1 - 1e-7
local BLUR_OBJ = Instance.new("DepthOfFieldEffect")
BLUR_OBJ.FarIntensity = 0
BLUR_OBJ.NearIntensity = 0.25
BLUR_OBJ.FocusDistance = 0.25
BLUR_OBJ.InFocusRadius = 0
BLUR_OBJ.Parent = Lighting

local PartsList = {}
local BlurObjects = {}

local function applyBlur(frame, intensity)
    local blurPart = Instance.new("Part")
    blurPart.Size = Vector3.new(1, 1, 1) * PART_SIZE
    blurPart.Anchored = true
    blurPart.CanCollide = false
    blurPart.CanTouch = false
    blurPart.Material = Enum.Material.Glass
    blurPart.Transparency = PART_TRANSPARENCY
    blurPart.Parent = camera

    local mesh = Instance.new("BlockMesh")
    mesh.Parent = blurPart

    local ignoreInset = false
    local currentObj = frame
    while currentObj do
        if currentObj:IsA("ScreenGui") then
            ignoreInset = currentObj.IgnoreGuiInset
            break
        end
        currentObj = currentObj.Parent
    end

    local function update()
        if not frame.Visible then
            blurPart.Transparency = 1
            return
        end
        blurPart.Transparency = PART_TRANSPARENCY

        local corner0 = frame.AbsolutePosition + BLUR_SIZE
        local corner1 = corner0 + frame.AbsoluteSize - BLUR_SIZE * 2

        local ray0, ray1
        if ignoreInset then
            ray0 = camera:ViewportPointToRay(corner0.X, corner0.Y, 1)
            ray1 = camera:ViewportPointToRay(corner1.X, corner1.Y, 1)
        else
            ray0 = camera:ScreenPointToRay(corner0.X, corner0.Y, 1)
            ray1 = camera:ScreenPointToRay(corner1.X, corner1.Y, 1)
        end

        local planeOrigin = camera.CFrame.Position + camera.CFrame.LookVector * (0.05 - camera.NearPlaneZ)
        local planeNormal = camera.CFrame.LookVector

        local function rayPlaneIntersect(rayOrigin, rayDirection)
            local v = rayOrigin - planeOrigin
            local den = planeNormal:Dot(rayDirection)
            return rayOrigin + rayDirection * (-planeNormal:Dot(v) / den)
        end

        local pos0 = rayPlaneIntersect(ray0.Origin, ray0.Direction)
        local pos1 = rayPlaneIntersect(ray1.Origin, ray1.Direction)

        pos0 = camera.CFrame:PointToObjectSpace(pos0)
        pos1 = camera.CFrame:PointToObjectSpace(pos1)

        local size = pos1 - pos0
        local center = (pos0 + pos1)/2

        mesh.Offset = center
        mesh.Scale = size / PART_SIZE
    end

    table.insert(PartsList, blurPart)
    table.insert(BlurObjects, {update = update})

    RunService:BindToRenderStep("QuantumBlurUpdate", Enum.RenderPriority.Camera.Value + 1, function()
        BLUR_OBJ.NearIntensity = intensity
        for _, blurData in ipairs(BlurObjects) do
            blurData.update()
        end
        local cframes = table.create(#PartsList, camera.CFrame)
        Workspace:BulkMoveTo(PartsList, cframes, Enum.BulkMoveMode.FireCFrameChanged)
        BLUR_OBJ.FocusDistance = 0.25 - camera.NearPlaneZ
    end)

    return {
        Destroy = function()
            blurPart:Destroy()
            for i, part in ipairs(PartsList) do
                if part == blurPart then
                    table.remove(PartsList, i)
                    break
                end
            end
            for i, blurData in ipairs(BlurObjects) do
                if blurData.update == update then
                    table.remove(BlurObjects, i)
                    break
                end
            end
        end
    }
end

function Quantum.new(config)
    local self = setmetatable({}, Quantum)
    
    local defaultConfig = {
        animationType = "scale",
        animationDuration = 0.15,
        tabNames = {"Test"},
        spacing = 0.02,
        containerSize = UDim2.new(0.9, 0, 0.6, 0),
        
        enableSearchBar = true,
        tabBlurEnabled = true,
        searchBlurEnabled = true,
        tabBlurIntensity = 0.5,
        searchBlurIntensity = 0.5,
        
        backgroundColor = Color3.new(0, 0, 0),
        backgroundTransparency = 0.75,
        
        tabBackgroundColor = Color3.new(0, 0, 0),
        tabBackgroundTransparency = 0.5,
        tabTextColor = Color3.new(1, 1, 1),
        tabStrokeColor = Color3.new(0, 0, 0),
        
        searchTabBackgroundColor = Color3.new(0, 0, 0),
        searchTabBackgroundTransparency = 0.5,
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

    if self.enableSearchBar then
        self.searchTab = Instance.new("Frame")
        self.searchTab.Name = "SearchTab"
        self.searchTab.AnchorPoint = Vector2.new(0.5, 0.5)
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

        if self.searchBlurEnabled then
            self.searchBlur = applyBlur(self.searchTab, self.searchBlurIntensity)
        end
    end

    self.viewportHeight = Workspace.CurrentCamera.ViewportSize.Y
    
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
        
        if self.tabBlurEnabled then
            self.tabBlurs = self.tabBlurs or {}
            self.tabBlurs[name] = applyBlur(panel, self.tabBlurIntensity)
        end
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(self.cornerRadiusScale, 0)
        corner.Parent = panel
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = self.tabStrokeColor
        stroke.Thickness = 1
        stroke.Parent = panel
        
        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(0.9, 0, 0.08, 0)
        header.Position = UDim2.new(0.055, 0, 0.02, 0)
        header.BackgroundColor3 = self.tabBackgroundColor
        header.BackgroundTransparency = 0.5
        header.Parent = panel
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(self.cornerRadiusScale * 5, 0)
        corner.Parent = header
        
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
        content.Size = UDim2.new(0.9, 0, 0.865, 0)
        content.Position = UDim2.new(0.055, 0, 0.115, 0)
        content.BackgroundColor3 = self.tabBackgroundColor
        content.BackgroundTransparency = 0.5
        content.Parent = panel

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(self.cornerRadiusScale, 0)
        corner.Parent = content
    end

    self.viewportConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        self.viewportHeight = Workspace.CurrentCamera.ViewportSize.Y
        for _, label in ipairs(self.labels) do
            label.TextSize = self:_calculateTextSize()
        end
    end)
    
    self:_initializeAnimation()
    self.closeButton.MouseButton1Click:Connect(function() self:Close() end)
    
    if self.enableSearchBar then
        local function animateSearchTab(width)
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = TweenService:Create(self.searchTab, tweenInfo, {Size = UDim2.new(width, 0, 0.06, 0)})
            tween:Play()
        end

        self.searchBox.Focused:Connect(function()
            animateSearchTab(0.2)
        end)

        self.searchBox.FocusLost:Connect(function()
            if self.searchBox.Text == "" then
                animateSearchTab(0.1)
            end
        end)
    end
    
    return self
end

Quantum._calculateTextSize = function(self)
    if not self.viewportHeight then
        self.viewportHeight = Workspace.CurrentCamera.ViewportSize.Y
    end
    return self.textScaleCoefficient * self.viewportHeight
end

Quantum._initializeAnimation = function(self)
    self.targetSize = self.containerSize
    self.targetPosition = UDim2.new(0.5, 0, 0.5, 0)
    self.searchTargetSize = UDim2.new(0.1, 0, 0.06, 0)
    self.searchTargetPosition = UDim2.new(0.5, 0, 0.1, 0)
    
    if self.animationType == "scale" then
        self.tabsFrame.Size = UDim2.new(0, 0, 0, 0)
        self.tabsFrame.Position = self.targetPosition
        if self.enableSearchBar then
            self.searchTab.Size = UDim2.new(0, 0, 0, 0)
            self.searchTab.Position = self.searchTargetPosition
        end
    elseif self.animationType == "left" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(-self.targetSize.X.Scale / 2, 0, 0.5, 0)
        if self.enableSearchBar then
            self.searchTab.Size = self.searchTargetSize
            self.searchTab.Position = UDim2.new(-self.searchTargetSize.X.Scale, 0, self.searchTargetPosition.Y.Scale, 0)
        end
    elseif self.animationType == "right" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(1 + self.targetSize.X.Scale / 2, 0, 0.5, 0)
        if self.enableSearchBar then
            self.searchTab.Size = self.searchTargetSize
            self.searchTab.Position = UDim2.new(1 + self.searchTargetSize.X.Scale, 0, self.searchTargetPosition.Y.Scale, 0)
        end
    elseif self.animationType == "top" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(0.5, 0, -self.targetSize.Y.Scale / 2, 0)
        if self.enableSearchBar then
            self.searchTab.Size = self.searchTargetSize
            self.searchTab.Position = UDim2.new(self.searchTargetPosition.X.Scale, 0, -self.searchTargetSize.Y.Scale * 2, 0)
        end
    elseif self.animationType == "bottom" then
        self.tabsFrame.Size = self.targetSize
        self.tabsFrame.Position = UDim2.new(0.5, 0, 1 + self.targetSize.Y.Scale / 2, 0)
        if self.enableSearchBar then
            self.searchTab.Size = self.searchTargetSize
            self.searchTab.Position = UDim2.new(self.searchTargetPosition.X.Scale, 0, 1 + self.searchTargetSize.Y.Scale * 2, 0)
        end
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
    
    if self.enableSearchBar then
        local searchTweens = {}
        if self.animationType == "scale" then
            table.insert(searchTweens, TweenService:Create(self.searchTab, tweenInfo, {Size = self.searchTargetSize}))
        else
            table.insert(searchTweens, TweenService:Create(self.searchTab, tweenInfo, {Position = self.searchTargetPosition}))
        end
        table.insert(searchTweens, TweenService:Create(self.searchTab, tweenInfo, {BackgroundTransparency = self.searchTabBackgroundTransparency}))
        
        for _, tween in ipairs(searchTweens) do
            tween:Play()
        end
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
    
    if self.enableSearchBar then
        local searchCloseTweens = {}
        if self.animationType == "scale" then
            table.insert(searchCloseTweens, TweenService:Create(self.searchTab, tweenInfo, {Size = UDim2.new(0, 0, 0, 0)}))
        elseif self.animationType == "left" then
            table.insert(searchCloseTweens, TweenService:Create(self.searchTab, tweenInfo, {Position = UDim2.new(-self.searchTargetSize.X.Scale, 0, self.searchTargetPosition.Y.Scale, 0)}))
        elseif self.animationType == "right" then
            table.insert(searchCloseTweens, TweenService:Create(self.searchTab, tweenInfo, {Position = UDim2.new(1 + self.searchTargetSize.X.Scale, 0, self.searchTargetPosition.Y.Scale, 0)}))
        elseif self.animationType == "top" then
            table.insert(searchCloseTweens, TweenService:Create(self.searchTab, tweenInfo, {Position = UDim2.new(self.searchTargetPosition.X.Scale, 0, -self.searchTargetSize.Y.Scale, 0)}))
        elseif self.animationType == "bottom" then
            table.insert(searchCloseTweens, TweenService:Create(self.searchTab, tweenInfo, {Position = UDim2.new(self.searchTargetPosition.X.Scale, 0, 1 + self.searchTargetSize.Y.Scale, 0)}))
        end
        table.insert(searchCloseTweens, TweenService:Create(self.searchTab, tweenInfo, {BackgroundTransparency = 1}))
        
        for _, tween in ipairs(searchCloseTweens) do
            tween:Play()
        end
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
    if self.tabBlurs then
        for _, blur in pairs(self.tabBlurs) do
            blur:Destroy()
        end
    end
    if self.searchBlur then
        self.searchBlur:Destroy()
    end
    self.gui:Destroy()
end

return Quantum
