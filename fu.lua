local maxAttemps = 30
local attemps = 0

local players = game:GetService("Players")
local plr = players.LocalPlayer

local fusionTarget = plr:FindFirstChild("Status"):FindFirstChild("FusionTarget")
local playerFuse = 'Angular_Dev'


local function getPlayerByName(name)
    for _, p in ipairs(players:GetPlayers()) do
        if string.lower(p.Name) == string.lower(name) then
            return p
        end
    end

    return nil
end

players.PlayerAdded:Connect(function(player)
    if playerToFuse == nil then
        playerToFuse = getPlayerByName(playerFuse)
    end
end)

players.PlayerRemoving:Connect(function(player)
    if playerToFuse ~= nil and string.lower(player.Name) == string.lower(playerFuse) then
        attemps = maxAttemps
    end
end)

local playerToFuse = getPlayerByName(playerFuse)

local function executeFuse()
    while fusionTarget.Value ~= playerFuse and task.wait() and attemps < maxAttemps do
        local _, internalError = pcall(function()
            if playerToFuse == nil then
                task.wait(1)
                attemps = attemps + 1
            else
                local cframe = playerToFuse.Character.HumanoidRootPart.CFrame
                plr.Character.HumanoidRootPart.CFrame = cframe
                print("Haciendo TP...")

                local args = {
                    [1] = "Fusion",
                    [2] = {
                        ["MouseHit"] = cframe
                    }
                }

                game:GetService("ReplicatedStorage").Package.Events.Fuse:InvokeServer(unpack(args))
                print("Starting fuse with: "..playerToFuse.Name)
            end
        end)

        if internalError then
            warn("Internal server error in fuse: "..internalError)
            task.wait(1)
        end
    end
end

executeFuse()

plr.CharacterAdded:Connect(executeFuse)
print(fusionTarget.Value)
