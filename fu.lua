local replicatedStorage = game:GetService("ReplicatedStorage")

local maxAttemps = 30
local attemps = 0

local players = game:GetService("Players")
local plr = players.LocalPlayer

local fusionTarget = plr:FindFirstChild("Status"):FindFirstChild("FusionTarget")
local playerFuse = 'DexPenguin666'

local function getPlayerByName(name)
    for _, p in ipairs(players:GetPlayers()) do
        if string.lower(p.Name) == string.lower(name) then
            return p
        end
    end

    return nil
end

local playerToFuse = getPlayerByName(playerFuse)
local million = 1000000

local function executeFuse()
    local datas = replicatedStorage:WaitForChild("Datas")[playerToFuse.userId]
    local strength = datas.Strength
    local energy = datas.Energy
    local defense = datas.Defense
    local speed = datas.Speed

    while fusionTarget.Value ~= playerFuse and attemps < maxAttemps do
        local _, internalError = pcall(function()
            if playerToFuse == nil then
                task.wait(1)
                attemps = attemps + 1
                playerToFuse = getPlayerByName(playerFuse)
            elseif strength.Value > million and energy.Value > million and defense.Value > million and speed.Value > million then
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
                attemps = 0
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
