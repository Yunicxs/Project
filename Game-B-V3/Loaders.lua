if game.PlaceId ~= 6348640020 then return end

-- Image Preload ===============================================

task.spawn(function()
	local ExistingPreload = CoreGui:FindFirstChild("ImagePreload")
	if ExistingPreload then
		ExistingPreload:Destroy()
	end

	local PreloadGui = Instance.new("ScreenGui")
	PreloadGui.Name = "ImagePreload"
	PreloadGui.IgnoreGuiInset = true
	PreloadGui.ResetOnSpawn = false
	PreloadGui.Parent = CoreGui

	local Holder = Instance.new("Frame")
	Holder.Parent = PreloadGui
	Holder.Visible = false
	Holder.BackgroundTransparency = 1
	Holder.Size = UDim2.new(0,0,0,0)

	local Images = {
		"rbxassetid://6034295711",
		"rbxassetid://6031075929",
		"rbxassetid://6035161563",
		"rbxassetid://6031067241",
		"rbxassetid://6031471491",
		"rbxassetid://6034754445"
	}

	for Index,Asset in ipairs(Images) do
		local Image = Instance.new("ImageLabel")
		Image.Name = "Preload_"..Index
		Image.Parent = Holder
		Image.BackgroundTransparency = 1
		Image.ImageTransparency = 1
		Image.Size = UDim2.new(0,1,0,1)
		Image.Image = Asset
	end
end)

-- End of Image Preload


-- minisc

-- TeleportItems (Upgraded - Single Script)
-- Fixed to work with server-owned parts

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local itemsFolder = workspace:WaitForChild("Map"):WaitForChild("Items")

local targetNames = {
    Briefcase = true,
    Soap = true,
    Plate = true
}

local running = false
local cooldown = false
local COOLDOWN_TIME = 2

-- Improved teleportation function that fights server-side issues
local function TeleportPart()
    if running or cooldown then
        return
    end

    running = true
    cooldown = true
    
    local character = player.Character
    if not character then
        running = false
        cooldown = false
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        running = false
        cooldown = false
        return
    end

    -- Cache itemsFolder:GetChildren() for efficiency
    local items = itemsFolder:GetChildren()
    
    -- Collect target items with handles
    local targetItems = {}
    for _, item in ipairs(items) do
        if targetNames[item.Name] then
            local handle = item:FindFirstChild("Handle")
            if handle then
                table.insert(targetItems, handle)
            end
        end
    end
    
    -- Fight server-side issues with multiple techniques:
    
    -- Technique 1: Try direct CFrame setting first (works sometimes)
    for _, handle in ipairs(targetItems) do
        if handle and handle.Parent then
            handle.Anchored = false -- Unanchor for physics
            
            -- Use CFrame multiplication instead of addition
            local targetCFrame = hrp.CFrame * CFrame.new(
                math.random(-5, 5),
                3,
                math.random(-5, 5)
            )
            
            -- Try setting CFrame directly
            handle.CFrame = targetCFrame
        end
    end
    
    -- Technique 2: If direct setting didn't work, use BodyMovers as fallback
    task.spawn(function()
        task.wait(0.1) -- Give server a moment to process
        
        for _, handle in ipairs(targetItems) do
            if handle and handle.Parent then
                -- Add BodyPosition to force movement
                local bodyPos = handle:FindFirstChild("TeleportBodyPos") or Instance.new("BodyPosition")
                bodyPos.Name = "TeleportBodyPos"
                bodyPos.Position = (hrp.CFrame * CFrame.new(
                    math.random(-5, 5),
                    3,
                    math.random(-5, 5)
                )).Position
                bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
                bodyPos.D = 100
                bodyPos.P = 1000
                bodyPos.Parent = handle
                
                -- Remove BodyPosition after a moment
                task.spawn(function()
                    task.wait(0.5)
                    if bodyPos.Parent then
                        bodyPos:Destroy()
                    end
                end)
            end
        end
    end)
    
    -- Technique 3: Network ownership workaround
    task.spawn(function()
        task.wait(0.2)
        for _, handle in ipairs(targetItems) do
            if handle and handle.Parent then
                -- Try to get network ownership
                pcall(function()
                    handle:SetNetworkOwner(player)
                end)
            end
        end
    end)

    -- Cooldown timer
    task.spawn(function()
        task.wait(COOLDOWN_TIME)
        cooldown = false
    end)
    
    running = false
end

-- PC KEYBIND (,)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.Comma then
        TeleportPart()
    end
end)





-- Bring UsedCrucifix (Upgraded - Matching TeleportItems style)
-- Fixed to work with server-owned parts

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local itemsFolder = workspace:WaitForChild("Map"):WaitForChild("Items")

local crucifixRunning = false
local crucifixCooldown = false
local COOLDOWN_TIME = 2

local function BringCrucifix()
    if crucifixRunning or crucifixCooldown then
        return
    end

    crucifixRunning = true
    crucifixCooldown = true

    local character = player.Character
    if not character then
        crucifixRunning = false
        crucifixCooldown = false
        return
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then
        crucifixRunning = false
        crucifixCooldown = false
        return
    end

    local item = itemsFolder:FindFirstChild("UsedCrucifix")
    if not item then
        print("UsedCrucifix not found in Items")
        crucifixRunning = false
        crucifixCooldown = false
        return
    end

    local handle = item:FindFirstChild("Handle")
    if not handle then
        crucifixRunning = false
        crucifixCooldown = false
        return
    end

    -- Technique 1: Direct CFrame setting with anchoring loop
    for i = 1, 50 do
        if handle and handle.Parent then
            handle.Anchored = true
            handle.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
        end
        task.wait(0.03)
    end

    -- Technique 2: BodyPosition fallback to force movement
    task.spawn(function()
        task.wait(0.1)

        if handle and handle.Parent then
            local bodyPos = handle:FindFirstChild("TeleportBodyPos") or Instance.new("BodyPosition")
            bodyPos.Name = "TeleportBodyPos"
            bodyPos.Position = (hrp.CFrame * CFrame.new(0, 3, 0)).Position
            bodyPos.MaxForce = Vector3.new(4000, 4000, 4000)
            bodyPos.D = 100
            bodyPos.P = 1000
            bodyPos.Parent = handle

            task.spawn(function()
                task.wait(0.5)
                if bodyPos.Parent then
                    bodyPos:Destroy()
                end
            end)
        end
    end)

    -- Technique 3: Network ownership workaround
    task.spawn(function()
        task.wait(0.2)
        if handle and handle.Parent then
            pcall(function()
                handle:SetNetworkOwner(player)
            end)
        end
    end)

    task.wait(0.5)
    if handle and handle.Parent then
        handle.Anchored = false
    end

    -- Cooldown timer
    task.spawn(function()
        task.wait(COOLDOWN_TIME)
        crucifixCooldown = false
    end)

    crucifixRunning = false
end

-- PC KEYBIND (L)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end
    if input.KeyCode == Enum.KeyCode.L then
        BringCrucifix()
    end
end)

-- end mini sc

















local urls = {
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V3/sc1",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V3/sc2",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V3/sc3",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V3/sc4",
    "https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V2/SlotUI"
}

local maxRetries = 10

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- =========================================================
-- GUI
-- =========================================================

-- GANTI BAGIAN GUI YANG LAMA MENJADI INI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RunConfirmGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 190, 0, 105)
Frame.Position = UDim2.new(1, -205, 1, -120) -- kanan bawah
Frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0,8)
UICorner.Parent = Frame

local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Thickness = 1
Stroke.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,24)
Title.Position = UDim2.new(0,0,0,3)
Title.BackgroundTransparency = 1
Title.Text = "Run This?"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local CountdownText = Instance.new("TextLabel")
CountdownText.Size = UDim2.new(1,0,0,18)
CountdownText.Position = UDim2.new(0,0,0,28)
CountdownText.BackgroundTransparency = 1
CountdownText.Text = "Cooldown: 5"
CountdownText.TextColor3 = Color3.fromRGB(180,180,180)
CountdownText.Font = Enum.Font.Gotham
CountdownText.TextSize = 11
CountdownText.Parent = Frame

local Info = Instance.new("TextLabel")
Info.Size = UDim2.new(1,-10,0,16)
Info.Position = UDim2.new(0,5,0,46)
Info.BackgroundTransparency = 1
Info.Text = "[Y] Yes  |  [N] No"
Info.TextColor3 = Color3.fromRGB(140,140,140)
Info.Font = Enum.Font.Gotham
Info.TextSize = 10
Info.Parent = Frame

local YesButton = Instance.new("TextButton")
YesButton.Size = UDim2.new(0,75,0,28)
YesButton.Position = UDim2.new(0,10,1,-38)
YesButton.BackgroundColor3 = Color3.fromRGB(40,170,90)
YesButton.Text = "YES"
YesButton.TextColor3 = Color3.fromRGB(255,255,255)
YesButton.Font = Enum.Font.GothamBold
YesButton.TextSize = 12
YesButton.AutoButtonColor = true
YesButton.Active = false
YesButton.Parent = Frame

local YesCorner = Instance.new("UICorner")
YesCorner.CornerRadius = UDim.new(0,6)
YesCorner.Parent = YesButton

local NoButton = Instance.new("TextButton")
NoButton.Size = UDim2.new(0,75,0,28)
NoButton.Position = UDim2.new(1,-85,1,-38)
NoButton.BackgroundColor3 = Color3.fromRGB(170,50,50)
NoButton.Text = "NO"
NoButton.TextColor3 = Color3.fromRGB(255,255,255)
NoButton.Font = Enum.Font.GothamBold
NoButton.TextSize = 12
NoButton.Parent = Frame

local NoCorner = Instance.new("UICorner")
NoCorner.CornerRadius = UDim.new(0,6)
NoCorner.Parent = NoButton

-- =========================================================
-- COOLDOWN SYSTEM
-- =========================================================

local canRun = false
local decided = false

task.spawn(function()
    for i = 1,1,-1 do
        CountdownText.Text = "Cooldown: "..i
        task.wait(1)
    end

    CountdownText.Text = "You can now choose"
    canRun = true
    YesButton.Active = true
end)

-- =========================================================
-- SCRIPT FUNCTIONS
-- =========================================================

local function getShortName(url)
	local name = url:match(".*/([^/]+)$")
	return "/" .. (name or "Unknown")
end

local function loadScript(url)
	local numRetries = 0
	local success = false
	local result = nil

	repeat
		numRetries += 1

		success, result = pcall(function()
			return game:HttpGet(url)
		end)

		if not success then
			warn(
				"Failed to fetch "
				.. getShortName(url)
				.. ", retrying... ("
				.. numRetries
				.. "/"
				.. maxRetries
				.. ")"
			)

			task.wait(0.5)
		end

	until success or numRetries >= maxRetries

	return success, result
end

local function executeScriptsSequentially(urls)
	for _, url in ipairs(urls) do

		local success, scriptContent = loadScript(url)

		if success then

			print("URL: " .. getShortName(url) .. " ✅")

			local executeSuccess, executeError = pcall(function()
				loadstring(scriptContent)()
			end)

			if executeSuccess then
				print("Executed: " .. getShortName(url))
			else
				warn(
					"Failed to execute "
					.. getShortName(url)
					.. " - "
					.. tostring(executeError)
				)
			end

		else

			warn(
				"Failed to fetch "
				.. getShortName(url)
				.. " ❌"
			)

		end

		task.wait(0.01)
	end
end

-- =========================================================
-- BUTTON ACTIONS
-- =========================================================

local function runScripts()
    if decided then
        return
    end

    if not canRun then
        warn("Please wait for cooldown.")
        return
    end

    decided = true
    ScreenGui:Destroy()

    executeScriptsSequentially(urls)
end

local function cancelScripts()
    if decided then
        return
    end

    decided = true
    ScreenGui:Destroy()

    warn("Script execution cancelled.")
end

YesButton.MouseButton1Click:Connect(runScripts)

NoButton.MouseButton1Click:Connect(cancelScripts)

-- =========================================================
-- KEYBOARD SHORTCUTS
-- =========================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.Y then
        runScripts()

    elseif input.KeyCode == Enum.KeyCode.N then
        cancelScripts()
    end
end)


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- NightVision setup (same as mobile version)
local function setupNightVision()
    -- Set NightVision ownership to true
    local NV = Player:FindFirstChild("NightVision")
    if NV then
        NV.Value = true
    else
        local newNV = Instance.new("BoolValue")
        newNV.Name = "NightVision"
        newNV.Value = true
        newNV.Parent = Player
    end

    -- Remove the noLights challenge that blocks NV
    local challenges = ReplicatedStorage:FindFirstChild("ActiveChallenges")
    if challenges then
        local noLights = challenges:FindFirstChild("noLights")
        if noLights then
            noLights:Destroy()
        end
    end

    -- Enable the NVG battery GUI
    local NVGBattery = PlayerGui:FindFirstChild("NVGBattery")
    if NVGBattery then
        NVGBattery.Enabled = true
    end

    -- Toggle NightVision value to force .Changed event
    task.defer(function()
        local nv = Player:FindFirstChild("NightVision")
        if nv and nv.Value == true then
            nv.Value = false
            task.wait(0.1)
            nv.Value = true
        end
    end)
end

-- Prevent Atmosphere from ever being fully removed.
-- saveOriginalSettings() in LightingManager reads Lighting.Atmosphere.Density
-- with no nil check. If Fullbright destroys Atmosphere, the next NV toggle crashes.
-- Fix: hook AncestryChanged on Atmosphere and instantly recreate if parent becomes nil.
local function protectAtmosphere()
    local atmos = Lighting:FindFirstChildOfClass("Atmosphere")

    local function onRemoved(instance)
        if instance.ClassName == "Atmosphere" and not instance.Parent then
            task.defer(function()
                if not Lighting:FindFirstChildOfClass("Atmosphere") then
                    local a = Instance.new("Atmosphere")
                    a.Density = 0.3
                    a.Offset = 0.25
                    a.Color = Color3.fromRGB(199, 199, 199)
                    a.Decay = Color3.fromRGB(92, 60, 43)
                    a.Glare = 0
                    a.Haze = 1
                    a.Parent = Lighting
                end
            end)
        end
    end

    if atmos then
        pcall(function()
            atmos.AncestryChanged:Connect(function(_, parent)
                if not parent then onRemoved(atmos) end
            end)
        end)
    end

    -- Also watch for new Atmosphere instances being added (in case it recreated externally)
    Lighting.ChildAdded:Connect(function(child)
        if child:IsA("Atmosphere") then
            pcall(function()
                child.AncestryChanged:Connect(function(_, parent)
                    if not parent then onRemoved(child) end
                end)
            end)
        end
    end)

    -- Safety net: periodic check
    task.spawn(function()
        while task.wait(0.5) do
            if not Lighting:FindFirstChildOfClass("Atmosphere") then
                pcall(function()
                    local a = Instance.new("Atmosphere")
                    a.Density = 0.3
                    a.Offset = 0.25
                    a.Color = Color3.fromRGB(199, 199, 199)
                    a.Decay = Color3.fromRGB(92, 60, 43)
                    a.Glare = 0
                    a.Haze = 1
                    a.Parent = Lighting
                end)
            end
        end
    end)
end

-- Initialize both features
setupNightVision()
protectAtmosphere()
