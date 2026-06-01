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
            warn("Failed to fetch script from URL: " .. url .. ", retrying... (" .. numRetries .. "/" .. maxRetries .. ")")
            task.wait(0.5)
        end

    until success or numRetries >= maxRetries

    return success, result
end

local function executeScriptsSequentially(urls)
    for _, url in ipairs(urls) do

        local success, scriptContent = loadScript(url)

        if success then
            print("URL: " .. url .. " ✅")

            local executeSuccess, executeError = pcall(function()
                loadstring(scriptContent)()
            end)

            if executeSuccess then
                print("Executed: " .. url)
            else
                warn("Failed to execute script from URL: " .. url .. " - " .. executeError)
            end
        else
            warn("Failed to fetch script from URL: " .. url .. " ❌")
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
