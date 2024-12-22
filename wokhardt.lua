local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Vehicles = workspace:WaitForChild("Vehicles")
local CollectionService = game:GetService("CollectionService")

if getexecutorname() ~= 'xeno' then
else
    warn("xeno disabled")
    kick(getexecutorname(), "xeno disabled")
    return
end

function generateRandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for i = 1, length do
        local randIndex = math.random(1, #chars)
        result = result .. chars:sub(randIndex, randIndex)
    end
    return result
end

local function getPlayerAvatarImage()
	return Players:GetUserThumbnailAsync(Players:GetUserIdFromNameAsync("mr_slebd"), Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end

local Menu = {}
Menu.__index = Menu
 
local COLORS = {
	BACKGROUND = Color3.fromRGB(17, 17, 17),
	TAB_BACKGROUND = Color3.fromRGB(24, 24, 24),
	TAB_ACTIVE = Color3.fromRGB(32, 32, 32),
	TEXT = Color3.fromRGB(220, 220, 220),
	ACCENT = Color3.fromRGB(124, 193, 21),
	TOGGLE_BG = Color3.fromRGB(35, 35, 35),
	BORDER = Color3.fromRGB(60, 60, 60),
	HOVER = Color3.fromRGB(40, 40, 40),
	SHADOW = Color3.fromRGB(10, 10, 10),
	AVATAR_BACKGROUND = Color3.fromRGB(30, 30, 30),
	PLAYER_INFO_BACKGROUND = Color3.fromRGB(24, 24, 24),
	PLAYER_BOX_BACKGROUND = Color3.fromRGB(0, 0, 0),
	GLOW_ACCENT = Color3.fromRGB(100, 200, 100) 
}

function Menu.new()
	local self = setmetatable({}, Menu)
	self.visible = false
	self.tabs = {}
	self.currentTab = nil
	self.gui = nil
	self.dragging = false
	self.dragStart = nil
	self.startPos = nil
	self.notifications = {} 
	self.notificationQueue = {} 
	self.activeNotifications = 0 
	self.espEnabled = false
	self.hellEnabled = false
	self.originalValues = {} 
	return self
end

function Menu:CreateGUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = generateRandomString(12)
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = 100 
	screenGui.ResetOnSpawn = false
	screenGui.Parent = game:GetService("CoreGui") 

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 700, 0, 500)
	frame.Position = UDim2.new(0.5, -350, 0.5, -250)
	frame.BackgroundColor3 = COLORS.BACKGROUND
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.dragging = true
			self.dragStart = input.Position
			self.startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if self.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - self.dragStart
			frame.Position = UDim2.new(self.startPos.X.Scale, self.startPos.X.Offset + delta.X, self.startPos.Y.Scale, self.startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.dragging = false
		end
	end)

	
	local shadow = Instance.new("ImageLabel")
	shadow.Size = UDim2.new(1, 20, 1, 20)
	shadow.Position = UDim2.new(0, -10, 0, -10)
	shadow.BackgroundTransparency = 1
	shadow.Image = "rbxassetid://1316045217"
	shadow.ImageColor3 = COLORS.SHADOW
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)
	shadow.Parent = frame

	local tabContainer = Instance.new("Frame")
	tabContainer.Size = UDim2.new(0, 220, 1, 0)
	tabContainer.BackgroundColor3 = COLORS.TAB_BACKGROUND
	tabContainer.BorderSizePixel = 1
	tabContainer.BorderColor3 = COLORS.ACCENT
	tabContainer.Parent = frame

	
	local tabContainerGlow = Instance.new("UIStroke")
	tabContainerGlow.Color = COLORS.ACCENT
	tabContainerGlow.Thickness = 3
	tabContainerGlow.Transparency = 0.5
	tabContainerGlow.Parent = tabContainer

	
	local playerBox = Instance.new("Frame")
	playerBox.Size = UDim2.new(1, -20, 0, 80)
	playerBox.Position = UDim2.new(0, 10, 1, -100)
	playerBox.BackgroundColor3 = COLORS.PLAYER_BOX_BACKGROUND
	playerBox.BorderSizePixel = 0
	playerBox.Parent = tabContainer

	local playerBoxCorner = Instance.new("UICorner")
	playerBoxCorner.CornerRadius = UDim.new(0, 10)
	playerBoxCorner.Parent = playerBox

	
	local playerBoxShadow = Instance.new("ImageLabel")
	playerBoxShadow.Size = UDim2.new(1, 20, 1, 20)
	playerBoxShadow.Position = UDim2.new(0, -10, 0, -10)
	playerBoxShadow.BackgroundTransparency = 1
	playerBoxShadow.Image = "rbxassetid://1316045217"
	playerBoxShadow.ImageColor3 = COLORS.SHADOW
	playerBoxShadow.ScaleType = Enum.ScaleType.Slice
	playerBoxShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	playerBoxShadow.Parent = playerBox

	
	local avatarBackground = Instance.new("Frame")
	avatarBackground.Size = UDim2.new(0, 60, 0, 60)
	avatarBackground.Position = UDim2.new(0, 10, 0, 10)
	avatarBackground.BackgroundColor3 = COLORS.AVATAR_BACKGROUND
	avatarBackground.BorderSizePixel = 1
	avatarBackground.BorderColor3 = COLORS.BORDER
	avatarBackground.Parent = playerBox

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, 30)
	avatarCorner.Parent = avatarBackground

	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Size = UDim2.new(1, -4, 1, -4)
	avatarImage.Position = UDim2.new(0, 2, 0, 2)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Image = getPlayerAvatarImage()
	avatarImage.Parent = avatarBackground

	local avatarImageCorner = Instance.new("UICorner")
	avatarImageCorner.CornerRadius = UDim.new(0, 28)
	avatarImageCorner.Parent = avatarImage

	local playerNameLabel = Instance.new("TextLabel")
	playerNameLabel.Size = UDim2.new(1, -90, 0, 25)
	playerNameLabel.Position = UDim2.new(0, 80, 0, 15)
	playerNameLabel.BackgroundTransparency = 1
	playerNameLabel.Font = Enum.Font.GothamMedium
	playerNameLabel.TextColor3 = COLORS.TEXT
	playerNameLabel.TextSize = 18
	playerNameLabel.Text = "FakeAngles"
	playerNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerNameLabel.Parent = playerBox

	local playerRoleLabel = Instance.new("TextLabel")
	playerRoleLabel.Size = UDim2.new(1, -90, 0, 20)
	playerRoleLabel.Position = UDim2.new(0, 80, 0, 40)
	playerRoleLabel.BackgroundTransparency = 1
	playerRoleLabel.Font = Enum.Font.GothamMedium
	playerRoleLabel.TextColor3 = COLORS.ACCENT
	playerRoleLabel.TextSize = 16
	playerRoleLabel.Text = "dev"
	playerRoleLabel.TextXAlignment = Enum.TextXAlignment.Left
	playerRoleLabel.Parent = playerBox

	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, -220, 1, 0)
	contentContainer.Position = UDim2.new(0, 220, 0, 0)
	contentContainer.BackgroundTransparency = 1
	contentContainer.BorderSizePixel = 1
	contentContainer.BorderColor3 = COLORS.BORDER
	contentContainer.Parent = frame

	self.gui = {
		screenGui = screenGui,
		frame = frame,
		tabContainer = tabContainer,
		contentContainer = contentContainer
	}

	
	local watermark = Instance.new("Frame")
	watermark.Size = UDim2.new(0, 280, 0, 30)
	watermark.Position = UDim2.new(0, 10, 0, 30)
	watermark.BackgroundColor3 = COLORS.BACKGROUND
	watermark.BorderColor3 = COLORS.BORDER
	watermark.BorderSizePixel = 1
	watermark.Parent = screenGui
	watermark.ZIndex = 1001 
	watermark.Visible = true

	local watermarkShadow = Instance.new("ImageLabel")
	watermarkShadow.Size = UDim2.new(1, 20, 1, 20)
	watermarkShadow.Position = UDim2.new(0, -10, 0, -10)
	watermarkShadow.BackgroundTransparency = 1
	watermarkShadow.Image = "rbxassetid://1316045217"
	watermarkShadow.ImageColor3 = COLORS.SHADOW
	watermarkShadow.ScaleType = Enum.ScaleType.Slice
	watermarkShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	watermarkShadow.Parent = watermark

	local watermarkUnderline = Instance.new("Frame")
	watermarkUnderline.Size = UDim2.new(0.8, 0, 0, 2)
	watermarkUnderline.Position = UDim2.new(0.1, 0, 1, -2)
	watermarkUnderline.BackgroundColor3 = COLORS.ACCENT
	watermarkUnderline.BorderSizePixel = 0
	watermarkUnderline.ZIndex = 1002
	watermarkUnderline.Parent = watermark

	local watermarkText1 = Instance.new("TextLabel")
	watermarkText1.Size = UDim2.new(0, 100, 1, 0)
	watermarkText1.Position = UDim2.new(0, 5, 0, 0)
	watermarkText1.BackgroundTransparency = 1
	watermarkText1.Text = "wokhardt.xyz [free]"
	watermarkText1.TextColor3 = COLORS.TEXT
	watermarkText1.TextSize = 14
	watermarkText1.Font = Enum.Font.GothamMedium
	watermarkText1.TextXAlignment = Enum.TextXAlignment.Left
	watermarkText1.TextYAlignment = Enum.TextYAlignment.Center
	watermarkText1.ZIndex = 1002
	watermarkText1.Parent = watermark

	local watermarkText2 = Instance.new("TextLabel")
	watermarkText2.Size = UDim2.new(0, 60, 1, 0)
	watermarkText2.Position = UDim2.new(0, 130, 0, 0)
	watermarkText2.BackgroundTransparency = 1
	watermarkText2.Text = "FPS: 000"
	watermarkText2.TextColor3 = COLORS.TEXT
	watermarkText2.TextSize = 14
	watermarkText2.Font = Enum.Font.GothamMedium
	watermarkText2.TextXAlignment = Enum.TextXAlignment.Left
	watermarkText2.TextYAlignment = Enum.TextYAlignment.Center
	watermarkText2.ZIndex = 1002
	watermarkText2.Parent = watermark

	local watermarkText3 = Instance.new("TextLabel")
	watermarkText3.Size = UDim2.new(0, 70, 1, 0)
	watermarkText3.Position = UDim2.new(0, 190, 0, 0)
	watermarkText3.BackgroundTransparency = 1
	watermarkText3.Text = "time: --:--:--"
	watermarkText3.TextColor3 = COLORS.TEXT
	watermarkText3.TextSize = 14
	watermarkText3.Font = Enum.Font.GothamMedium
	watermarkText3.TextXAlignment = Enum.TextXAlignment.Left
	watermarkText3.TextYAlignment = Enum.TextYAlignment.Center
	watermarkText3.ZIndex = 1002
	watermarkText3.Parent = watermark

	local logo = Instance.new("TextLabel")
	logo.Size = UDim2.new(1, 0, 0, 50)
	logo.BackgroundTransparency = 1
	logo.Text = "wokhardt"
	logo.TextColor3 = COLORS.ACCENT
	logo.TextSize = 28
	logo.Font = Enum.Font.GothamBold
	logo.Parent = tabContainer

	
	local underline = Instance.new("Frame")
	underline.Size = UDim2.new(0.8, 0, 0, 2)
	underline.Position = UDim2.new(0.1, 0, 0, 50)
	underline.BackgroundColor3 = COLORS.ACCENT
	underline.BorderSizePixel = 0
	underline.Parent = tabContainer

	
	local espTab = Instance.new("TextButton")
	espTab.Size = UDim2.new(1, -10, 0, 30)
	espTab.Position = UDim2.new(0, 5, 0, 80)
	espTab.BackgroundColor3 = COLORS.TAB_BACKGROUND
	espTab.BorderSizePixel = 1
	espTab.BorderColor3 = COLORS.BORDER
	espTab.Text = "ESP"
	espTab.TextColor3 = COLORS.TEXT
	espTab.TextSize = 18
	espTab.Font = Enum.Font.GothamMedium
	espTab.Parent = tabContainer

	local miscTab = Instance.new("TextButton")
	miscTab.Size = UDim2.new(1, -10, 0, 30)
	miscTab.Position = UDim2.new(0, 5, 0, 120)
	miscTab.BackgroundColor3 = COLORS.TAB_BACKGROUND
	miscTab.BorderSizePixel = 1
	miscTab.BorderColor3 = COLORS.BORDER
	miscTab.Text = "MISC"
	miscTab.TextColor3 = COLORS.TEXT
	miscTab.TextSize = 18
	miscTab.Font = Enum.Font.GothamMedium
	miscTab.Parent = tabContainer

	espTab.MouseButton1Click:Connect(function()
		self.currentTab = "ESP"
		self:SwitchTab("ESP")
	end)

	miscTab.MouseButton1Click:Connect(function()
		self.currentTab = "MISC"
		self:SwitchTab("MISC")
	end)

	
	local espToggle = Instance.new("Frame")
	espToggle.Size = UDim2.new(1, -40, 0, 30)
	espToggle.Position = UDim2.new(0, 20, 0, 40)
	espToggle.BackgroundTransparency = 1
	espToggle.Visible = false
	espToggle.Name = "ESP_Toggle"
	espToggle.Parent = contentContainer

	local espLabel = Instance.new("TextLabel")
	espLabel.Size = UDim2.new(1, -50, 1, 0)
	espLabel.Position = UDim2.new(0.1, 0, 0, 0)
	espLabel.BackgroundTransparency = 1
	espLabel.Text = "ESP"
	espLabel.TextColor3 = COLORS.TEXT
	espLabel.TextSize = 14
	espLabel.Font = Enum.Font.GothamSemibold
	espLabel.TextXAlignment = Enum.TextXAlignment.Left
	espLabel.Parent = espToggle

	local espButton = Instance.new("TextButton")
	espButton.Size = UDim2.new(0, 40, 0, 20)
	espButton.Position = UDim2.new(1, -40, 0.5, -10)
	espButton.BackgroundColor3 = COLORS.HOVER
	espButton.BorderSizePixel = 0
	espButton.Text = ""
	espButton.Parent = espToggle

	local espIndicator = Instance.new("Frame")
	espIndicator.Size = UDim2.new(0, 16, 0, 16)
	espIndicator.Position = UDim2.new(0, 2, 0.5, -8)
	espIndicator.BackgroundColor3 = COLORS.HOVER
	espIndicator.BorderSizePixel = 0
	espIndicator.Parent = espButton

	local espState = false
	espButton.MouseButton1Click:Connect(function()
		espState = not espState
		self.espEnabled = espState
		local goal = {Position = espState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
		local tween = TweenService:Create(espIndicator, TweenInfo.new(0.1), goal)
		tween:Play()
		espIndicator.BackgroundColor3 = espState and COLORS.ACCENT or COLORS.HOVER
		if espState then
			self:EnableESP()
		else
			self:DisableESP()
		end
		self:CreateNotification("ESP", espState)
	end)

	local hellToggle = Instance.new("Frame")
	hellToggle.Size = UDim2.new(1, -40, 0, 30)
	hellToggle.Position = UDim2.new(0, 20, 0, 80)
	hellToggle.BackgroundTransparency = 1
	hellToggle.Visible = false
	hellToggle.Name = "HELL_Toggle"
	hellToggle.Parent = contentContainer

	local hellLabel = Instance.new("TextLabel")
	hellLabel.Size = UDim2.new(1, -50, 1, 0)
	hellLabel.Position = UDim2.new(0.1, 0, 0, 0)
	hellLabel.BackgroundTransparency = 1
	hellLabel.Text = "HELL"
	hellLabel.TextColor3 = COLORS.TEXT
	hellLabel.TextSize = 14
	hellLabel.Font = Enum.Font.GothamSemibold
	hellLabel.TextXAlignment = Enum.TextXAlignment.Left
	hellLabel.Parent = hellToggle

	local hellButton = Instance.new("TextButton")
	hellButton.Size = UDim2.new(0, 40, 0, 20)
	hellButton.Position = UDim2.new(1, -40, 0.5, -10)
	hellButton.BackgroundColor3 = COLORS.HOVER
	hellButton.BorderSizePixel = 0
	hellButton.Text = ""
	hellButton.Parent = hellToggle

	local hellIndicator = Instance.new("Frame")
	hellIndicator.Size = UDim2.new(0, 16, 0, 16)
	hellIndicator.Position = UDim2.new(0, 2, 0.5, -8)
	hellIndicator.BackgroundColor3 = COLORS.HOVER
	hellIndicator.BorderSizePixel = 0
	hellIndicator.Parent = hellButton

	local hellState = false
	hellButton.MouseButton1Click:Connect(function()
		hellState = not hellState
		self.hellEnabled = hellState
		local goal = {Position = hellState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}
		local tween = TweenService:Create(hellIndicator, TweenInfo.new(0.1), goal)
		tween:Play()
		hellIndicator.BackgroundColor3 = hellState and COLORS.ACCENT or COLORS.HOVER
		if hellState then
			self:EnableHELL()
		else
			self:DisableHELL()
		end
		self:CreateNotification("HELL", hellState)
	end)

	local function updateWatermark()
		local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
		local time = os.date("%H:%M:%S")
		watermarkText2.Text = string.format("FPS: %03d", fps)
		watermarkText3.Text = "time: " .. time
	end

	self.watermarkConnection = game:GetService("RunService").RenderStepped:Connect(updateWatermark)
end

function Menu:SwitchTab(tabName)
	if tabName == "ESP" then
		self.gui.contentContainer:FindFirstChild("ESP_Toggle").Visible = true
		self.gui.contentContainer:FindFirstChild("HELL_Toggle").Visible = false
	elseif tabName == "MISC" then
		self.gui.contentContainer:FindFirstChild("ESP_Toggle").Visible = false
		self.gui.contentContainer:FindFirstChild("HELL_Toggle").Visible = true
	end
end

function Menu:EnableESP()
    self.espEnabled = true
    self.espLabels = {}
    self.originalMaterials = {}

    local function createBillboardGuiESP(vehicle, playerName)
        local randomLabelName = generateRandomString(12)
        if vehicle:FindFirstChild(randomLabelName) then
            return
        end

        local billboardGui = Instance.new("BillboardGui")
        local textLabel = Instance.new("TextLabel")

        billboardGui.Name = randomLabelName
        billboardGui.AlwaysOnTop = true
        billboardGui.Size = UDim2.new(0, 100, 0, 25)
        billboardGui.StudsOffset = Vector3.new(0, 5, 0)
        billboardGui.Adornee = vehicle.PrimaryPart or vehicle:FindFirstChildWhichIsA("BasePart")

        textLabel.Parent = billboardGui
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.TextSize = 9
        textLabel.BackgroundTransparency = 1
        textLabel.Text = playerName
        textLabel.TextColor3 = Color3.new(1, 0, 0)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.TextScaled = false

        billboardGui.Parent = vehicle
        table.insert(self.espLabels, randomLabelName)
    end

    local function changeVehiclePartsToNeon(vehicle, player)
        if player.Team == Players.LocalPlayer.Team then
            return
        end

        if vehicle:GetAttribute("MaterialChanged") then
            return
        end

        self.originalMaterials[vehicle] = {}

        for _, part in ipairs(vehicle:GetDescendants()) do
            if part:IsA("BasePart") then
                self.originalMaterials[vehicle][part] = {
                    Material = part.Material,
                    Color = part.Color
                }
                part.Material = Enum.Material.Neon
                part.Color = Color3.new(1, 0, 0)
            end
        end

        vehicle:SetAttribute("MaterialChanged", true)

        vehicle.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") and not descendant:GetAttribute("MaterialChanged") then
                self.originalMaterials[vehicle][descendant] = {
                    Material = descendant.Material,
                    Color = descendant.Color
                }
                descendant.Material = Enum.Material.Neon
                descendant.Color = Color3.new(1, 0, 0)
                descendant:SetAttribute("MaterialChanged", true)
            end
        end)
    end

    local function addESPToVehicle(vehicle)
        local vehicleName = string.gsub(vehicle.Name, "^Chassis", "")
        local player = Players:FindFirstChild(vehicleName)

        if not player or not player:IsA("Player") then
            return
        end

        if player.Team == Players.LocalPlayer.Team then
            return
        end

        createBillboardGuiESP(vehicle, player.Name)
        changeVehiclePartsToNeon(vehicle, player)

        if not CollectionService:HasTag(vehicle, "MonitoredVehicle") then
            CollectionService:AddTag(vehicle, "MonitoredVehicle")
        end
    end

    local randomFunctionName = generateRandomString(10)
    self[randomFunctionName] = function()
        for _, vehicle in pairs(Vehicles:GetChildren()) do
            addESPToVehicle(vehicle)
        end

        self.vehicleAddedConnection = Vehicles.ChildAdded:Connect(function(vehicle)
            if self.espEnabled then
                task.defer(function()
                    addESPToVehicle(vehicle)
                end)
            end
        end)

        Vehicles.ChildAdded:Connect(function(vehicle)
            if vehicle:IsA("Model") then
                vehicle.DescendantAdded:Connect(function(part)
                    if part:IsA("BasePart") then
                        changeVehiclePartsToNeon(vehicle, player)
                    end
                end)
            end
        end)
    end

    self[randomFunctionName]()
end

function Menu:DisableESP()
    self.espEnabled = false

    if self.vehicleAddedConnection then
        self.vehicleAddedConnection:Disconnect()
        self.vehicleAddedConnection = nil
    end

    for _, vehicle in pairs(Vehicles:GetChildren()) do
        for _, labelName in ipairs(self.espLabels) do
            local label = vehicle:FindFirstChild(labelName)
            if label then
                label:Destroy()
            end
        end

        if self.originalMaterials[vehicle] then
            for part, original in pairs(self.originalMaterials[vehicle]) do
                if part and original then
                    part.Material = original.Material
                    part.Color = original.Color
                end
            end
        end
    end
    self.espLabels = {}
    self.originalMaterials = {}
end

local Players = game:GetService("Players")
local Vehicles = workspace:WaitForChild("Vehicles")

function Menu:EnableHELL()
    local function isVehicleOwnedByLocalPlayer(vehicle)
        local vehicleName = string.gsub(vehicle.Name, "^Chassis", "")
        local player = Players:FindFirstChild(vehicleName)
        return player == Players.LocalPlayer
    end

    local function modifyLocalPlayerVehicle(vehicle)
        if not isVehicleOwnedByLocalPlayer(vehicle) then return end

        local shells = vehicle:FindFirstChild("Shells", true)
        if not shells then return end

        self.originalValues[vehicle] = self.originalValues[vehicle] or {}
        self.originalValues[vehicle].shells = self.originalValues[vehicle].shells or {}

        for _, shellType in pairs(shells:GetChildren()) do
            self.originalValues[vehicle].shells[shellType] = self.originalValues[vehicle].shells[shellType] or {
                Penetration60 = shellType:FindFirstChild("Penetration60") and shellType.Penetration60.Value,
                explosiveMult = shellType:FindFirstChild("ExplosiveMult") and shellType.ExplosiveMult.Value,
                penetration = shellType:FindFirstChild("Penetration") and shellType.Penetration.Value,
                ricochetAngle = shellType:FindFirstChild("RicochetAngle") and shellType.RicochetAngle.Value,
                shellSpeed = shellType:FindFirstChild("ShellSpeed") and shellType.ShellSpeed.Value,
                bulletGravity = shellType:FindFirstChild("BulletGravity") and shellType.BulletGravity.Value
            }

            local penetration60 = shellType:FindFirstChild("Penetration60")
            if penetration60 then
                penetration60.Value = 900
            end

            local explosiveMult = shellType:FindFirstChild("ExplosiveMult")
            if explosiveMult then
                explosiveMult.Value = 900
            end

            local penetration = shellType:FindFirstChild("Penetration")
            if penetration then
                penetration.Value = 900
            end

            local ricochetAngle = shellType:FindFirstChild("RicochetAngle")
            if ricochetAngle then
                ricochetAngle.Value = 90
            end

            local shellSpeed = shellType:FindFirstChild("ShellSpeed")
            if shellSpeed then
                shellSpeed.Value = 900000
            end

            local bulletGravity = shellType:FindFirstChild("BulletGravity")
            if bulletGravity then
                bulletGravity.Value = 0
            end
        end
    end

    local randomFunctionName = generateRandomString(10)
    self[randomFunctionName] = function()
        for _, vehicle in pairs(Vehicles:GetChildren()) do
            modifyLocalPlayerVehicle(vehicle)
        end

        self.hellConnection = Vehicles.ChildAdded:Connect(function(vehicle)
            if self.hellEnabled then
                vehicle.ChildAdded:Connect(function()
                    modifyLocalPlayerVehicle(vehicle)
                end)
                modifyLocalPlayerVehicle(vehicle)
            end
        end)
    end
    self[randomFunctionName]()
end

function Menu:DisableHELL()
    self.hellEnabled = false

    if self.hellConnection then
        self.hellConnection:Disconnect()
        self.hellConnection = nil
    end

    local function restoreValue(shellType, propName, originalValue)
        local property = shellType:FindFirstChild(propName)
        if property then
            property.Value = originalValue
        end
    end

    for vehicle, originalValues in pairs(self.originalValues) do
        if vehicle.Parent == Vehicles then
            local shells = vehicle:FindFirstChild("Shells", true)
            if shells then
                for _, shellType in pairs(shells:GetChildren()) do
                    local originalShellValues = originalValues.shells[shellType]
                    if originalShellValues then
                        restoreValue(shellType, "Penetration60", originalShellValues.penetration60)
                        restoreValue(shellType, "ExplosiveMult", originalShellValues.explosiveMult)
                        restoreValue(shellType, "Penetration", originalShellValues.penetration)
                        restoreValue(shellType, "RicochetAngle", originalShellValues.ricochetAngle)
                        restoreValue(shellType, "ShellSpeed", originalShellValues.shellSpeed)
                        restoreValue(shellType, "BulletGravity", originalShellValues.bulletGravity)
                    end
                end
            end
        end
    end

    self.originalValues = {}
end

function Menu:Toggle()
	self.visible = not self.visible
	if self.gui and self.gui.frame then
		self.gui.frame.Visible = self.visible
	end
end

function Menu:CreateNotification(message, isEnabled)
	local notification = Instance.new("Frame")
	notification.Size = UDim2.new(0, 300, 0, 50)
	notification.Position = UDim2.new(1, 10, 1, -60 - (#self.notifications * 60))
	notification.AnchorPoint = Vector2.new(1, 1)
	notification.BackgroundColor3 = COLORS.BACKGROUND
	notification.BorderSizePixel = 1
	notification.BorderColor3 = COLORS.BORDER
	notification.ZIndex = 1001 
	notification.Parent = self.gui.screenGui

	table.insert(self.notifications, notification)
	table.insert(self.notificationQueue, {notification = notification, message = message, isEnabled = isEnabled})
	self:ProcessNotificationQueue()
end

function Menu:ProcessNotificationQueue()
	if #self.notificationQueue == 0 then
		return
	end

	local notificationData = table.remove(self.notificationQueue, 1)
	local notification = notificationData.notification
	local message = notificationData.message
	local isEnabled = notificationData.isEnabled

	local notificationShadow = Instance.new("ImageLabel")
	notificationShadow.Size = UDim2.new(1, 20, 1, 20)
	notificationShadow.Position = UDim2.new(0, -10, 0, -10)
	notificationShadow.BackgroundTransparency = 1
	notificationShadow.Image = "rbxassetid://1316045217"
	notificationShadow.ImageColor3 = COLORS.SHADOW
	notificationShadow.ScaleType = Enum.ScaleType.Slice
	notificationShadow.SliceCenter = Rect.new(10, 10, 118, 118)
	notificationShadow.Parent = notification

	local notificationUnderline = Instance.new("Frame")
	notificationUnderline.Size = UDim2.new(0.8, 0, 0, 2)
	notificationUnderline.Position = UDim2.new(0.1, 0, 1, -2)
	notificationUnderline.BackgroundColor3 = COLORS.ACCENT
	notificationUnderline.BorderSizePixel = 0
	notificationUnderline.Parent = notification

	local notificationText = Instance.new("TextLabel")
	notificationText.Size = UDim2.new(1, -20, 1, 0)
	notificationText.Position = UDim2.new(0.5, 0, 0.5, 0)
	notificationText.AnchorPoint = Vector2.new(0.5, 0.5)
	notificationText.BackgroundTransparency = 1
	notificationText.Text = message .. " " .. (isEnabled and "enabled" or "disabled")
	notificationText.TextColor3 = isEnabled and COLORS.ACCENT or Color3.fromRGB(180, 50, 50)
	notificationText.TextSize = 18
	notificationText.Font = Enum.Font.GothamMedium
	notificationText.TextXAlignment = Enum.TextXAlignment.Center
	notificationText.TextYAlignment = Enum.TextYAlignment.Center
	notificationText.ZIndex = 1002
	notificationText.Parent = notification

	local moveInTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(1, 10, 1, -60 - (#self.notifications * 60))})
	moveInTween:Play()

	moveInTween.Completed:Connect(function()
		task.wait(0.1)
		self.activeNotifications = self.activeNotifications + 1
		task.delay(2, function()
			local moveOutTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(1.5, 0, 1, -60)})
			moveOutTween:Play()
			moveOutTween.Completed:Connect(function()
				notification:Destroy()
				table.remove(self.notifications, table.find(self.notifications, notification))
				self.activeNotifications = self.activeNotifications - 1
				for i, notif in ipairs(self.notifications) do
					local newPos = UDim2.new(1, 10, 1, -60 - ((i - 1) * 60))
					TweenService:Create(notif, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = newPos}):Play()
				end
				task.wait(0.1)
				self:ProcessNotificationQueue()
			end)
		end)
	end)
end

local menu = Menu.new()
menu:CreateGUI()
_G.menu = menu

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.RightShift then
		menu:Toggle()
	end
end)

return Menu
