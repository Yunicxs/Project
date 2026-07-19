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
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V4/sc1",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V4/sc2%2B",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V4/sc3%2B",
	"https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/Game-B-V4/sc4"
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

-- AFKSelect by Cobalt-style helper
-- Section 1: services, ghost detection, selection helpers

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Remotes (listen only; selection is driven through _G.SGC from SelectGhostCmd)
local RadioEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Radio")
local SystemMessage = LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("Radio"):WaitForChild("Remotes"):WaitForChild("SystemMessage")

-- Ghost list container (same path as SelectGhostCmd)
local function getGhostFrame()
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

local function getGhostNames()
	local frame = getGhostFrame()
	local names = {}
	if not frame then return names end
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("ImageButton") and child.Name == "GhostTemplate" then
			local more = child:FindFirstChild("More")
			if more then
				local tl = more:FindFirstChild("TextLabel")
				if tl and tl:IsA("TextLabel") then
					local txt = tl.Text
					if txt and txt ~= "" then
						table.insert(names, txt)
					end
				end
			end
		end
	end
	return names
end

-- extract ghost name from a Quick Chat message like "[QUICK CHAT] X: The Ghost is a ZoZo"
local function extractGhostFromMessage(msg)
	if not msg or type(msg) ~= "string" then return nil end
	local marker = "The Ghost is a "
	local s, e = string.find(msg, marker, 1, true)
	if not s then return nil end
	local rest = string.sub(msg, e + 1)
	-- trim trailing whitespace/newlines
	rest = string.match(rest, "^%s*(.-)%s*$")
	if rest == "" then return nil end
	return rest
end

-- validate extracted name against known ghost list (case-insensitive)
local function matchGhostInList(name)
	if not name then return nil end
	local lowered = string.lower(name)
	for _, n in ipairs(getGhostNames()) do
		if string.lower(n) == lowered then
			return n
		end
	end
	return nil
end

-- resolve the shared SelectGhostCmd system (_G.SGC) so AFK uses the SAME selection logic.
-- waits briefly if Tab 4 hasn't run yet.
local function getSGC()
	-- already loaded
	if _G.SGC and _G.SGC.selectGhost and _G.SGC.getGhostNames then
		return _G.SGC
	end
	-- wait up to ~5s for Tab 4 to populate it
	for _ = 1, 50 do
		if _G.SGC and _G.SGC.selectGhost and _G.SGC.getGhostNames then
			return _G.SGC
		end
		task.wait(0.1)
	end
	return _G.SGC
end

-- Section 2: AFKSelect UI (center screen)
local CoreGui = game:GetService("CoreGui")

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
afkTitle.Text = "Your'e at AFK Farm"
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

local function setAFKSelected(name)
	if name and name ~= "" and name ~= "No Ghost Found" then
		afkSelected.Text = "Selected: " .. name
	else
		afkSelected.Text = "Selected: None"
	end
end

-- Section 3: AFK state + timer
local AFK_ACTIVE = false
local AFK_TIMEOUT = 60          -- seconds of no input before auto-activate
local lastInputTime = tick()
local latestGhost = nil         -- last ghost read from Quick Chat

local function setAFK(active)
	AFK_ACTIVE = active
	setAFKVisible(active)
	if active then
		-- re-apply last known ghost on (re)activation
		setAFKSelected(latestGhost)
	else
		setAFKSelected(nil)
	end
end

-- update latest ghost + (if AFK active) immediately select it via the shared SGC system
local function onGhostDetected(name)
	local matched = matchGhostInList(name)
	if not matched then return end
	latestGhost = matched
	if AFK_ACTIVE then
		local sgc = getSGC()
		if sgc and sgc.selectGhost then
			sgc.selectGhost(matched)   -- fires SelectGhost1 + syncs Journal Selection
		end
		setAFKSelected(matched)
	end
end

-- Section 4: input tracking, toggle/cancel, auto-activate timer
UserInputService.InputBegan:Connect(function(input, processed)
	-- any key press counts as activity
	lastInputTime = tick()

	-- cancel AFK if active and ANY key is pressed
	if AFK_ACTIVE then
		setAFK(false)
		return
	end

	-- toggle AFK with ]
	if input.KeyCode == Enum.KeyCode.RightBracket then
		setAFK(true)
	end
end)

-- auto-activate after 1 minute of no input (skip while already active)
RunService.Heartbeat:Connect(function()
	if AFK_ACTIVE then return end
	if tick() - lastInputTime >= AFK_TIMEOUT then
		setAFK(true)
	end
end)

-- Section 5: listen to chat + quick chat remotes
-- Quick Chat: SystemMessage.OnClientEvent("QuickChat", {Message=..., Author=...})
SystemMessage.OnClientEvent:Connect(function(channel, data)
	if channel ~= "QuickChat" then return end
	if type(data) ~= "table" then return end
	local msg = data.Message
	local ghost = extractGhostFromMessage(msg)
	if ghost then
		onGhostDetected(ghost)
	end
end)

-- Normal chat: Radio.OnClientEvent(player, text)
RadioEvent.OnClientEvent:Connect(function(player, text)
	local ghost = extractGhostFromMessage(text)
	if ghost then
		onGhostDetected(ghost)
	end
end)

-- Section 6: AutoSelectedGhost watcher
-- READ-ONLY: mirror the Journal Selection state into the AFK center-screen label.
-- The actual selection + sync is owned by _G.SGC (SelectGhostCmd, Tab 4).
local function getSelectedGhostName()
	local frame = getGhostFrame()
	if not frame then return nil end
	for _, c in ipairs(frame:GetChildren()) do
		if c:IsA("ImageButton") and c.Name == "GhostTemplate" then
			local sel = c:FindFirstChild("Selection")
			local more = c:FindFirstChild("More")
			local tl = more and more:FindFirstChild("TextLabel")
			if sel and sel:IsA("ImageLabel") and sel.ImageTransparency == 0 and tl then
				return tl.Text
			end
		end
	end
	return nil
end

local function refreshAFKSelected()
	local cur = getSelectedGhostName()
	latestGhost = cur
	setAFKSelected(cur)
end

local function watchTemplate(template)
	local sel = template:FindFirstChild("Selection")
	if not sel or not sel:IsA("ImageLabel") then return end
	sel:GetPropertyChangedSignal("ImageTransparency"):Connect(function()
		refreshAFKSelected()
	end)
end

local function watchAllTemplates()
	local frame = getGhostFrame()
	if not frame then return end
	for _, c in ipairs(frame:GetChildren()) do
		if c:IsA("ImageButton") and c.Name == "GhostTemplate" then
			watchTemplate(c)
		end
	end
end

watchAllTemplates()

-- watch for journal rebuilding its templates later
local gf = getGhostFrame()
if gf then
	gf.ChildAdded:Connect(function(child)
		if child:IsA("ImageButton") and child.Name == "GhostTemplate" then
			watchTemplate(child)
		end
	end)
end
print("AUTO FARM ACYIVATE")
