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

local urls = {
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V5/sc1",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V5/sc2",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V5/sc3",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V5/sc4",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V5/sc5"
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

-- AFKAutoSelectGhost StandAloneScript
-- Based on logic from Tab 6 and User requirements

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Constants
local AFK_TIMEOUT = 15
local SELECTED_COLOR = Color3.fromRGB(52, 78, 58)
local SELECTED_TRANSPARENCY = 0.25
local DEFAULT_COLOR = Color3.fromRGB(25, 25, 25)
local DEFAULT_TRANSPARENCY = 0.2

-- Remotes
local SelectGhostEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("SelectGhost1")
local SystemMessageEvent = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Radio"):WaitForChild("Remotes"):WaitForChild("SystemMessage")

--------------------------------------------------------------------------------
-- UI Section (AFKSelectUI)
--------------------------------------------------------------------------------
-- Prevent duplicate UI
local existingUI = CoreGui:FindFirstChild("AFKSelectUI")
if existingUI then existingUI:Destroy() end

local afkGui = Instance.new("ScreenGui")
afkGui.Name = "AFKSelectUI"
afkGui.ResetOnSpawn = false
afkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
afkGui.Enabled = true
afkGui.Parent = CoreGui

local afkFrame = Instance.new("Frame")
afkFrame.Name = "AFKFrame"
afkFrame.Size = UDim2.new(0, 360, 0, 90)
afkFrame.Position = UDim2.new(0.5, -180, 0.5, -45)
afkFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
afkFrame.BackgroundTransparency = 0.15
afkFrame.BorderSizePixel = 0
afkFrame.Visible = false
afkFrame.Parent = afkGui

local afkCorner = Instance.new("UICorner")
afkCorner.CornerRadius = UDim.new(0, 10)
afkCorner.Parent = afkFrame

local afkStroke = Instance.new("UIStroke")
afkStroke.Color = Color3.fromRGB(120, 90, 200)
afkStroke.Thickness = 1
afkStroke.Transparency = 0.35
afkStroke.Parent = afkFrame

local afkTitle = Instance.new("TextLabel")
afkTitle.Name = "Title"
afkTitle.Size = UDim2.new(1, 0, 0, 44)
afkTitle.Position = UDim2.new(0, 0, 0, 4)
afkTitle.BackgroundTransparency = 1
afkTitle.Text = "You're at AFK Farm"
afkTitle.TextColor3 = Color3.fromRGB(190, 150, 255)
afkTitle.Font = Enum.Font.GothamBold
afkTitle.TextSize = 24
afkTitle.Parent = afkFrame

local afkSelected = Instance.new("TextLabel")
afkSelected.Name = "SelectedGhost"
afkSelected.Size = UDim2.new(1, 0, 0, 32)
afkSelected.Position = UDim2.new(0, 0, 0, 50)
afkSelected.BackgroundTransparency = 1
afkSelected.Text = "Selected: None"
afkSelected.TextColor3 = Color3.fromRGB(120, 220, 160)
afkSelected.Font = Enum.Font.Gotham
afkSelected.TextSize = 18
afkSelected.Parent = afkFrame

local function setAFKVisible(v)
    afkFrame.Visible = v
end

local function getGhostNamesFrame()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local j = pg:FindFirstChild("Journal")
    if not j then return nil end
    local bg = j:FindFirstChild("Background")
    if not bg then return nil end
    local mc = bg:FindFirstChild("MainContent")
    if not mc then return nil end
    local main = mc:FindFirstChild("Main")
    if not main then return nil end
    local others = main:FindFirstChild("Others")
    if not others then return nil end
    local contents = others:FindFirstChild("Contents")
    if not contents then return nil end
    local frames = contents:FindFirstChild("Frames")
    if not frames then return nil end
    local ghosts = frames:FindFirstChild("Ghosts")
    if not ghosts then return nil end
    local content = ghosts:FindFirstChild("Content")
    if not content then return nil end
    local rightContent = content:FindFirstChild("RightContent")
    if not rightContent then return nil end
    local itemsFrame = rightContent:FindFirstChild("ItemsFrame")
    if not itemsFrame then return nil end
    local itemList = itemsFrame:FindFirstChild("ItemList")
    if not itemList then return nil end
    return itemList
end

local function getGhostSelectionFrame()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local j = pg:FindFirstChild("Journal")
    if not j then return nil end
    local bg = j:FindFirstChild("Background")
    if not bg then return nil end
    local mc = bg:FindFirstChild("MainContent")
    if not mc then return nil end
    local main = mc:FindFirstChild("Main")
    if not main then return nil end
    local others = main:FindFirstChild("Others")
    if not others then return nil end
    local contents = others:FindFirstChild("Contents")
    if not contents then return nil end
    local frames = contents:FindFirstChild("Frames")
    if not frames then return nil end
    local evidence = frames:FindFirstChild("Evidence")
    if not evidence then return nil end
    local right = evidence:FindFirstChild("Right")
    if not right then return nil end
    local content = right:FindFirstChild("Content")
    if not content then return nil end
    local cg = content:FindFirstChild("CanvasGroup")
    if not cg then return nil end
    return cg:FindFirstChild("Frame")
end

local function getAllGhostButtonsForNames()
    local itemList = getGhostNamesFrame()
    local buttons = {}
    if not itemList then return buttons end
    for _, child in ipairs(itemList:GetDescendants()) do
        if child:IsA("ImageButton") and child:FindFirstChild("NameLabel") then
            table.insert(buttons, child)
        end
    end
    return buttons
end

local function getAllGhostButtonsForSelection()
    local frame = getGhostSelectionFrame()
    local buttons = {}
    if not frame then return buttons end
    for _, child in ipairs(frame:GetChildren()) do
        if child:IsA("ImageButton") then
            table.insert(buttons, child)
        end
    end
    return buttons
end

local function getGhostNames()
    local buttons = getAllGhostButtonsForNames()
    local names = {}
    for _, btn in ipairs(buttons) do
        local nameLabel = btn:FindFirstChild("NameLabel")
        local txt = nameLabel and nameLabel.Text or btn.Name
        if txt and txt ~= "" then
            table.insert(names, txt)
        end
    end
    return names
end

local function findGhostTemplate(name)
    local buttons = getAllGhostButtonsForNames()
    local lowered = string.lower(name)
    for _, btn in ipairs(buttons) do
        local nameLabel = btn:FindFirstChild("NameLabel")
        local btnName = nameLabel and nameLabel.Text or btn.Name
        if string.lower(btnName) == lowered then
            return btn
        end
    end
    return nil
end

local function getSelectedGhostName()
    local frame = getGhostSelectionFrame()
    if not frame then return nil end
    for _, btn in ipairs(frame:GetChildren()) do
        if btn:IsA("ImageButton") then
            if (btn.BackgroundColor3.R - SELECTED_COLOR.R)^2 < 0.0001
                and (btn.BackgroundColor3.G - SELECTED_COLOR.G)^2 < 0.0001
                and (btn.BackgroundColor3.B - SELECTED_COLOR.B)^2 < 0.0001
                and math.abs(btn.BackgroundTransparency - SELECTED_TRANSPARENCY) < 0.05 then
                return btn.Name
            end
        end
    end
    return nil
end

local function updateSelectedText()
    local name = getSelectedGhostName()
    if name then
        afkSelected.Text = "Selected: " .. name
    else
        afkSelected.Text = "Selected: None"
    end
end



local function selectGhost(name)
    local template = findGhostTemplate(name)
    if template then
        SelectGhostEvent:FireServer(name)
        -- Update Journal visual: highlight the selected ghost, reset others
        local selFrame = getGhostSelectionFrame()
        if selFrame then
            for _, btn in ipairs(selFrame:GetChildren()) do
                if btn:IsA("ImageButton") then
                    if string.lower(btn.Name) == string.lower(name) then
                        btn.BackgroundColor3 = SELECTED_COLOR
                        btn.BackgroundTransparency = SELECTED_TRANSPARENCY
                    else
                        btn.BackgroundColor3 = DEFAULT_COLOR
                        btn.BackgroundTransparency = DEFAULT_TRANSPARENCY
                    end
                end
            end
        end
        return true, name
    else
        SelectGhostEvent:FireServer("No Ghost Found")
        return false, name
    end
end

--------------------------------------------------------------------------------
-- AFK Execution Logic
--------------------------------------------------------------------------------

local isAFK = false
local UserInputService = game:GetService("UserInputService")
local lastInputTime = tick()

local function toggleAFK(state)
    isAFK = state
    setAFKVisible(state)
    if state then
        
    else
        
    end
end

-- Hook ghost button clicks to enforce single selection
local function isBtnSelected(btn)
    return (btn.BackgroundColor3.R - SELECTED_COLOR.R)^2 < 0.0001
        and (btn.BackgroundColor3.G - SELECTED_COLOR.G)^2 < 0.0001
        and (btn.BackgroundColor3.B - SELECTED_COLOR.B)^2 < 0.0001
        and math.abs(btn.BackgroundTransparency - SELECTED_TRANSPARENCY) < 0.05
end

local function hookGhostClicks()
    local frame = getGhostSelectionFrame()
    if not frame then return end
    for _, btn in ipairs(frame:GetChildren()) do
        if btn:IsA("ImageButton") and not btn:GetAttribute("MCPHook") then
            btn:SetAttribute("MCPHook", true)
            btn.Activated:Connect(function()
                for _, other in ipairs(frame:GetChildren()) do
                    if other:IsA("ImageButton") and other ~= btn and isBtnSelected(other) then
                        other.BackgroundColor3 = DEFAULT_COLOR
                        other.BackgroundTransparency = DEFAULT_TRANSPARENCY
                    end
                end
            end)
        end
    end
end

task.spawn(function()
    while true do
        hookGhostClicks()
        task.wait(2)
    end
end)

-- Realtime watcher: reads the actual Journal selection every frame
RunService.Heartbeat:Connect(updateSelectedText)

-- Vote-based auto-select logic
local function getGhostVoteCount(ghostName)
    local frame = getGhostSelectionFrame()
    if not frame then return 0 end
    local btn = frame:FindFirstChild(ghostName)
    if not btn or not btn:IsA("ImageButton") then return 0 end
    local pi = btn:FindFirstChild("PlayerIcons")
    if not pi then return 0 end

    local iconCount = 0
    for _, c in ipairs(pi:GetChildren()) do
        if c:IsA("ImageLabel") and c.Name ~= "IconTemplate" then
            iconCount = iconCount + 1
        end
    end

    local overflow = pi:FindFirstChild("Overflow")
    local overflowNum = 0
    if overflow and overflow.Visible then
        local numStr = overflow.Text:match("%+(%d+)")
        if numStr then
            overflowNum = tonumber(numStr) or 0
        end
    end

    return iconCount + overflowNum
end

local function getMostVotedGhost()
    local frame = getGhostSelectionFrame()
    if not frame then return nil, 0 end

    local bestName = nil
    local bestVotes = 0
    for _, btn in ipairs(frame:GetChildren()) do
        if btn:IsA("ImageButton") then
            local votes = getGhostVoteCount(btn.Name)
            if votes > bestVotes then
                bestVotes = votes
                bestName = btn.Name
            end
        end
    end
    return bestName, bestVotes
end

local function isGhostSelectedFromUI(name)
    local frame = getGhostSelectionFrame()
    if not frame then return false end
    local btn = frame:FindFirstChild(name)
    if not btn or not btn:IsA("ImageButton") then return false end
    return (btn.BackgroundColor3.R - SELECTED_COLOR.R)^2 < 0.0001
        and (btn.BackgroundColor3.G - SELECTED_COLOR.G)^2 < 0.0001
        and (btn.BackgroundColor3.B - SELECTED_COLOR.B)^2 < 0.0001
        and math.abs(btn.BackgroundTransparency - SELECTED_TRANSPARENCY) < 0.05
end

task.spawn(function()
    while true do
        task.wait(3)
        if not isAFK then continue end
        local name, votes = getMostVotedGhost()
        if name and votes >= 3 and not isGhostSelectedFromUI(name) then
            selectGhost(name)
        end
    end
end)

-- Listen for SystemMessage (QuickChat)
SystemMessageEvent.OnClientEvent:Connect(function(type, data)
    if not isAFK then return end -- Only auto-select if AFK mode is active
    
    if type == "QuickChat" and data and data.Message then
        local msg = data.Message
        if string.find(msg, "The Ghost is a") then
            -- Vote-based logic takes priority: if a ghost has >= 3 votes and is selected, ignore QuickChat
            local votedName, votedCount = getMostVotedGhost()
            if votedName and votedCount >= 3 and isGhostSelectedFromUI(votedName) then
                return
            end

            local ghostName = msg:match("The Ghost is a%s+(.+)$")
            if ghostName then
                ghostName = string.gsub(ghostName, "[%p%s]+$", "")
                selectGhost(ghostName)
            end
        end
    end
end)

-- Input Detection to disable AFK (catches ALL keyboard, mouse, GUI, and chat input)
UserInputService.InputBegan:Connect(function(input, processed)
    -- ']' toggles AFK (only when unprocessed to avoid accidental toggle while typing)
    if input.KeyCode == Enum.KeyCode.RightBracket and not processed then
        toggleAFK(not isAFK)
        lastInputTime = tick()
        return
    end

    -- H broadcasts the selected ghost name via QuickChat
    if input.KeyCode == Enum.KeyCode.H and not processed then
        local name = getSelectedGhostName()
        if name then
            local QuickChatSent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("QuickChatSent")
            if QuickChatSent then
                QuickChatSent:FireServer({
                    Id = "GhostCertain",
                    ButtonText = "The Ghost is a ＿＿",
                    Message = "The Ghost is a %s",
                    ExtraDetailsType = "Ghosts"
                }, name)
            end
        end
        return
    end

    -- Any input at all disables AFK and resets idle timer
    lastInputTime = tick()
    if isAFK then
        toggleAFK(false)
    end
end)



-- AFK Idle Timer Logic
task.spawn(function()
    while true do
        task.wait(1)
        if not isAFK and (tick() - lastInputTime) >= AFK_TIMEOUT then
            toggleAFK(true)
        end
    end
end)


print("AUTO FARM ACYIVATE")

local player = game.Players.LocalPlayer

local function setBool(name)
	local value = player:FindFirstChild(name)
	if value and value:IsA("BoolValue") then
		value.Value = true
		
	else
		warn(("%s BoolValue not found on LocalPlayer"):format(name))
	end
end

setBool("DoubleStamina")
setBool("SanityTracker")

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

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local StarterGui = game:GetService("StarterGui")

local GEN = (_G.videoCamerasAnywhereGen or 0) + 1
_G.videoCamerasAnywhereGen = GEN
local function decoy()
	return _G.videoCamerasAnywhereGen ~= GEN
end

local function getKeyboard()
	local map = workspace:FindFirstChild("Map")
	local van = map and map:FindFirstChild("Van")
	local core = van and van:FindFirstChild("CoreElements")
	return core and core:FindFirstChild("Keyboard") or nil
end

local function getPrompt()
	local kb = getKeyboard()
	if not kb then
		return nil
	end
	local p = kb:FindFirstChild("VanKeyboardViewCamerasPrompt")
	if p and p:IsA("ProximityPrompt") then
		return p
	end
	return kb:FindFirstChildOfClass("ProximityPrompt")
end

local function getVideoCameraGui()
	return LocalPlayer.PlayerGui:FindFirstChild("VideoCamera")
end

local function isViewing()
	local vc = getVideoCameraGui()
	return vc ~= nil and vc.Enabled == true
end

local function getBindable(name)
	local b = ReplicatedStorage:FindFirstChild("Bindables")
	return b and b:FindFirstChild(name) or nil
end

local function safeToView()
	local rv = ReplicatedStorage:FindFirstChild("ReplicatedValues")
	if rv and rv:FindFirstChild("ServerLoaded") and not rv.ServerLoaded.Value then
		return false
	end
	if _G.IntroCutscene then
		return false
	end
	if LocalPlayer:GetAttribute("CutsceneActive") then
		return false
	end
	if LocalPlayer:FindFirstChild("Dead") and LocalPlayer.Dead.Value then
		return false
	end
	local char = LocalPlayer.Character
	if not char then
		return false
	end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return false
	end
	return true
end

local function openCameras()
	if not safeToView() then
		return false
	end
	local prompt = getPrompt()
	if not prompt then
		return false
	end
	if not prompt.Enabled then
		prompt.Enabled = true
	end
	fireproximityprompt(prompt)
	return true
end

local function closeCameras()
	local b = getBindable("ToggleVideoCamera")
	if b then
		b:Fire()
	end
end

local function toggle()
	if isViewing() then
		closeCameras()
	else
		openCameras()
	end
end

-- ---- Remove the "Confirm" purchase popup ----
local function purgeConfirm()
	-- Delete the StarterGui template (the frame the user wants gone).
	pcall(function()
		local j = StarterGui:FindFirstChild("Journal")
		if not j then
			return
		end
		local frames = j.Background.MainContent.Main.Others.Contents.Frames
		local confirm = frames:FindFirstChild("Confirm")
		if confirm then
			confirm:Destroy()
		end
	end)
	-- Live PlayerGui clone: keep the instance (game has live connections to it) but hide it.
	pcall(function()
		local j = LocalPlayer.PlayerGui:FindFirstChild("Journal")
		if not j then
			return
		end
		local frames = j.Background.MainContent.Main.Others.Contents.Frames
		local confirm = frames and frames:FindFirstChild("Confirm")
		if confirm then
			confirm.Visible = false
		end
	end)
end
purgeConfirm()

-- Keep any re-cloned journal's Confirm hidden
task.spawn(function()
	while not decoy() do
		pcall(function()
			local j = LocalPlayer.PlayerGui:FindFirstChild("Journal")
			if j then
				local frames = j.Background.MainContent.Main.Others.Contents.Frames
				local confirm = frames and frames:FindFirstChild("Confirm")
				if confirm then
					confirm.Visible = false
				end
			end
		end)
		task.wait(3)
	end
end)

local weClosedJournal = false
local vcGui = LocalPlayer.PlayerGui:WaitForChild("VideoCamera", 30)
if vcGui then
	vcGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if decoy() then
			return
		end
		if vcGui.Enabled == false and weClosedJournal then
			weClosedJournal = false
			local j = LocalPlayer.PlayerGui:FindFirstChild("Journal")
			if j then
				j.Enabled = true
			end
		end
	end)
end

-- ---- KeyCode.U toggle ----
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if decoy() then
		return
	end
	if gameProcessed then
		return
	end
	if input.KeyCode ~= Enum.KeyCode.U then
		return
	end
	if UserInputService:GetFocusedTextBox() then
		return
	end
	toggle()
end)

-- ---- VideoCamera ImageButton click opens cameras ----
pcall(function()
	local j = LocalPlayer.PlayerGui:WaitForChild("Journal", 30)
	if not j then
		return
	end
	local btn = j.Background.MainContent.Main.Others.Contents.SideBar.VideoCamera
	if not btn then
		return
	end
	btn.Activated:Connect(function()
		if decoy() then
			return
		end
		if isViewing() then
			return
		end
		if openCameras() then
			local journal = LocalPlayer.PlayerGui:FindFirstChild("Journal")
			if journal and journal.Enabled then
				journal.Enabled = false
				weClosedJournal = true
			end
		end
	end)
end)
