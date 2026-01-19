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

local playerToFuse = getPlayerByName(playerFuse)

local function executeFuse()
    while fusionTarget.Value ~= playerFuse and attemps < maxAttemps do
        local _, internalError = pcall(function()
            if playerToFuse == nil then
                task.wait(1)
                attemps = attemps + 1
                playerToFuse = getPlayerByName(playerFuse)
            else
                local cframe = playerToFuse.Character.HumanoidRootPart.CFrame
                plr.Character.HumanoidRootPart.CFrame = cframe

                print("Haciendo TP V2...")

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

        task.wait()
        if internalError then
            warn("Internal server error in fuse: "..internalError)
            task.wait(1)
        end
    end
end

executeFuse()

plr.CharacterAdded:Connect(executeFuse)
print(fusionTarget.Value)
