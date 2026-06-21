loadstring(game:HttpGet("https://github.com/notpoiu/cobalt/releases/latest/download/Cobalt.luau"))()

local UserInputService = game:GetService("UserInputService")

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        local cobalt = game:GetService("CoreGui").RobloxGui:FindFirstChild("Cobalt")
        if cobalt then
            cobalt.Enabled = not cobalt.Enabled
            print("Cobalt is now " .. (cobalt.Enabled and "Enabled" or "Disabled"))
        else
            print("Cobalt GUI not found")
        end
    end
end)
