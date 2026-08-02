loadstring(game:HttpGet("https://raw.githubusercontent.com/Yunicxs/Project/refs/heads/main/RandomV1/Cobalts.luau"))()

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        local cobalt = game:GetService("CoreGui").RobloxGui:FindFirstChild("Cobalt")
        if cobalt then
            cobalt.Enabled = not cobalt.Enabled
        else
            print("Cobalt GUI not found")
        end
    end
end)
