local function onNext(isBuyer)
    local libraryUrl = "https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/library.lua"
    local Window = loadstring(game:HttpGet(libraryUrl))()

    local autoFarmEnvs = {
        AutoFarm = false,
        AutoWeight = false,
        AutoRebirth = false,

        LimitOfRebirths = 460,
        limitRebirths = false,

        tpMuscleKingGym = false,
    }

    local autoRocksEnvs = {
    }

    local autoPlayersEnvs = {
        AttackAll = false,
    }

    local ultimateFarmEnvs = {}


    local players = game:GetService("Players")
    local plr = players.LocalPlayer
    local playerGui = plr:WaitForChild("PlayerGui")
    local gameGUI = playerGui:WaitForChild("gameGui")
    local ultimatesGUI = playerGui:WaitForChild("ultimatesGui"):WaitForChild("ultimatesMenu"):WaitForChild("ultimatesScrollMenu")
    local machinesFolder = game.Workspace:WaitForChild("machinesFolder")
    local KingGymPos = CFrame.new(-8749.36719, 23.6517239, -5858.39697, 0.997915983, 3.3654306e-09, 0.0645264462, -5.68376546e-09, 1, 3.57448755e-08, -0.0645264462, -3.60371359e-08, 0.997915983)
    local leaderboardStats = plr:WaitForChild("leaderstats")
    local rebValue = leaderboardStats:WaitForChild("Rebirths")

    local function getBackpack()
        return plr:FindFirstChild("Backpack") or plr:WaitForChild("Backpack", 5)
    end

    local function executeTool(toolName)
        local character = plr.Character or plr.CharacterAdded:Wait()
        if not character then return false end

        local currentBackpack = getBackpack()
        local tool = currentBackpack and currentBackpack:FindFirstChild(toolName)
            or character:FindFirstChild(toolName)

        if not tool then return false end

        local humanoid = character:FindFirstChildOfClass("Humanoid")
            or character:WaitForChild("Humanoid", 2)
        if not humanoid then return false end

        humanoid:EquipTool(tool)
        tool:Activate()
    end

    local function autoWeight()
        while autoFarmEnvs.AutoWeight do
            pcall(function ()
                executeTool("Weight")
            end)

            task.wait()
        end
    end

    local function autoPunch(isEnabled, keepPosition)
        while isEnabled() do
            pcall(function ()
                keepPosition()
                executeTool("Punch")
            end)

            task.wait()
        end
    end

    local function loopTools()
        local character = plr.Character
        if not character then return end

        local containers = {character}
        local currentBackpack = getBackpack()

        if currentBackpack then
            table.insert(containers, 1, currentBackpack)
        end

        for _, container in ipairs(containers) do
            for _, tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("repTime") then
                    executeTool(tool.Name)
                end
            end
        end
    end

    local function tpPlayer(position) -- CFrame
        local character = plr.Character or plr.CharacterAdded:Wait()
        if not character then return false end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            or character:WaitForChild("HumanoidRootPart", 2)
        if not humanoidRootPart then return false end

        humanoidRootPart.CFrame = position
        return true
    end

    local function getPlayerPosition()
        local character = plr.Character
        if not character then return nil end

        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        return humanoidRootPart and humanoidRootPart.CFrame or nil
    end

    local function loopRocks()
        local rocks = {}

        for _, machine in ipairs(machinesFolder:GetChildren()) do
            local rock = machine:FindFirstChild("Rock")

            if rock and rock:IsA("BasePart") then
                local rockGui = machine:FindFirstChild("rockGui")
                local rockName = rockGui and rockGui:FindFirstChild("rockName")

                table.insert(rocks, {
                    rock = rock,
                    title = rockName and rockName:IsA("TextLabel") and rockName.Text or machine.Name,
                })
            end
        end

        return rocks
    end

    local function farmRock(rock)
        if not rock:IsDescendantOf(machinesFolder) then return end

        local initialPosition = getPlayerPosition()
        if not initialPosition then return end

        autoPunch(function()
            task.wait(0.2)
            return autoRocksEnvs[rock] == true and rock:IsDescendantOf(machinesFolder)
        end, function()
            local safePosition = (rock.CFrame + Vector3.new(rock.Size.X / 2 - 2, 4, 0)).Position
            local rockCenter = Vector3.new(rock.Position.X, safePosition.Y, rock.Position.Z)
            tpPlayer(CFrame.lookAt(safePosition, rockCenter))
        end)

        tpPlayer(initialPosition)
    end

    local function createRocksSection(rocks)
        local section = Window.new("rocks", "Rocks")

        for _, rockData in ipairs(rocks) do
            local rock = rockData.rock
            autoRocksEnvs[rock] = false

            section:Option({
                title = "Auto Punch "..rockData.title,
                value = false,

                onChange = function(enabled)
                    autoRocksEnvs[rock] = enabled
                end,

                onChangedTrue = function()
                    task.spawn(function()
                        farmRock(rock)
                    end)
                end,
                onChangedFalse = function() end,
            })
        end
    end

    local function getAttackablePlayers(onlyEnabled)
        local availablePlayers = {}

        for _, targetPlayer in ipairs(players:GetPlayers()) do
            local character = targetPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
            local isEnabled = not onlyEnabled or autoPlayersEnvs[targetPlayer] == true

            if targetPlayer ~= plr and isEnabled and humanoid and humanoid.Health > 0 and humanoidRootPart then
                table.insert(availablePlayers, targetPlayer)
            end
        end

        return availablePlayers
    end

    local function attackPlayer(targetPlayer)
        local character = targetPlayer.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then return false end

        local direction = Vector3.new(
            humanoidRootPart.CFrame.LookVector.X,
            0,
            humanoidRootPart.CFrame.LookVector.Z
        )

        if direction.Magnitude == 0 then return false end

        local targetPosition = humanoidRootPart.Position
        local attackPosition = targetPosition + direction.Unit * 3
        local lookAtPosition = Vector3.new(targetPosition.X, attackPosition.Y, targetPosition.Z)

        if not tpPlayer(CFrame.lookAt(attackPosition, lookAtPosition)) then return false end

        task.wait()
        executeTool("Punch")
        return true
    end


    local function createPlayersSection()
        local section = Window.new("players", "Players")
        local optionFrames = {}

        section:Option({
            title = "Attack all users",
            value = autoPlayersEnvs.AttackAll,

            onChange = function(enabled)
                autoPlayersEnvs.AttackAll = enabled
            end,

            onChangedTrue = function() end,
            onChangedFalse = function() end,
        })

        local function addPlayer(targetPlayer)
            if targetPlayer == plr or autoPlayersEnvs[targetPlayer] ~= nil then return end

            local previousChildren = {}
            for _, child in ipairs(section.window:GetChildren()) do
                previousChildren[child] = true
            end

            autoPlayersEnvs[targetPlayer] = false
            section:Option({
                title = targetPlayer.Name,
                value = false,

                onChange = function(enabled)
                    autoPlayersEnvs[targetPlayer] = enabled
                end,

                onChangedTrue = function() end,
                onChangedFalse = function() end,
            })

            for _, child in ipairs(section.window:GetChildren()) do
                if not previousChildren[child] then
                    optionFrames[targetPlayer] = child
                    break
                end
            end
        end

        for _, targetPlayer in ipairs(players:GetPlayers()) do
            addPlayer(targetPlayer)
        end

        players.PlayerAdded:Connect(addPlayer)
        players.PlayerRemoving:Connect(function(targetPlayer)
            autoPlayersEnvs[targetPlayer] = nil

            local optionFrame = optionFrames[targetPlayer]
            if optionFrame then
                optionFrame:Destroy()
                optionFrames[targetPlayer] = nil
            end
        end)
    end

    local function runPlayersAttack()
        local initialPosition = nil
        local selectedIndex = 0
        local lastRandomPlayer = nil

        task.spawn(function()
            while plr:IsDescendantOf(players) do
                local attackablePlayers = getAttackablePlayers(not autoPlayersEnvs.AttackAll)
                local targetPlayer = nil

                if autoPlayersEnvs.AttackAll and #attackablePlayers > 0 then
                    if #attackablePlayers == 1 then
                        targetPlayer = attackablePlayers[1]
                    else
                        repeat
                            targetPlayer = attackablePlayers[math.random(1, #attackablePlayers)]
                        until targetPlayer ~= lastRandomPlayer
                    end

                    lastRandomPlayer = targetPlayer
                elseif #attackablePlayers > 0 then
                    selectedIndex = selectedIndex % #attackablePlayers + 1
                    targetPlayer = attackablePlayers[selectedIndex]
                    lastRandomPlayer = nil
                else
                    selectedIndex = 0
                    lastRandomPlayer = nil
                end

                if targetPlayer then
                    initialPosition = initialPosition or getPlayerPosition()
                    attackPlayer(targetPlayer)
                elseif initialPosition then
                    tpPlayer(initialPosition)
                    initialPosition = nil
                end

                task.wait()
            end
        end)
    end

    local function simulateClick(btn)
        print("Dando click en: "..btn.Name)

        local success, failed = pcall(function ()
            firesignal(btn.Activated)
        end)

        if failed then
            warn("Unexpected error (smclk): "..failed)
        end

        return success
    end

    local function autoRebirth()
        if not autoFarmEnvs.AutoRebirth then return false end
        if autoFarmEnvs.limitRebirths and rebValue.Value >= autoFarmEnvs.LimitOfRebirths then return true end

        local btnReb = gameGUI.rebirthNewMenu.Content.ConfimButton
        simulateClick(btnReb)
        return true
    end

    local function createAutoFarmSection()
        local section = Window.new("autoFarm", "Auto Farm")

        section:Option({
            title = "Auto Farm (Weight)",
            value = autoFarmEnvs.AutoWeight,

            onChange = function(enabled)
                autoFarmEnvs.AutoWeight = enabled
            end,

            onChangedTrue = function ()
                task.spawn(autoWeight)
            end,
            onChangedFalse = function() end,
        })

        section:Option({
            title = "Auto Farm (All)",
            value = autoFarmEnvs.AutoFarm,

            onChange = function(enabled)
                autoFarmEnvs.AutoFarm = enabled
            end,

            onChangedTrue = function() end,
            onChangedFalse = function() end,
        })

        section:Option({
            title = "TP Muscle King Gym",
            value = autoFarmEnvs.tpMuscleKingGym,

            onChange = function(enabled)
                autoFarmEnvs.tpMuscleKingGym = enabled
            end,

            onChangedTrue = function() end,
            onChangedFalse = function() end,
        })

        section:Option({
            title = "Auto Rebirth",
            value = autoFarmEnvs.AutoRebirth,

            onChange = function(enabled)
                autoFarmEnvs.AutoRebirth = enabled
            end,

            onChangedTrue = function() end,
            onChangedFalse = function() end,
        })

        section:Input({
            title = "Rebirth Limit",
            value = tostring(autoFarmEnvs.LimitOfRebirths),
            inputType = "NUMBER",
            numberValidations = {
                minValue = -1,
            },

            onChange = function(value)
                autoFarmEnvs.LimitOfRebirths = value
            end,
        })

        section:Option({
            title = "Rebirth Limit",
            value = tostring(autoFarmEnvs.limitRebirths),
            onChange = function(enabled)
                autoFarmEnvs.limitRebirths = enabled
            end,

            onChangedTrue = function() end,
            onChangedFalse = function() end,
        })
    end

    local function runAutoFarm()
        task.spawn(function()
            while plr:IsDescendantOf(players) do
                if autoFarmEnvs.AutoFarm then
                    loopTools()
                end

                task.wait(0.1)
            end
        end)
    end

    local function runMuscleKingGymTP()
        task.spawn(function()
            while plr:IsDescendantOf(players) do
                if autoFarmEnvs.tpMuscleKingGym then
                    tpPlayer(KingGymPos)
                end

                task.wait(0.2)
            end
        end)
    end

    local function runAutoRebirth()
        task.spawn(function()
            while plr:IsDescendantOf(players) do
                autoRebirth()
                task.wait(1)
            end
        end)
    end

    local function getUltimateConfirmButton()
        local menu = playerGui:WaitForChild("ultimatesGui"):FindFirstChild("confirmUltimateNewMenu")
        local content = menu:FindFirstChild("Content")
        local buttons = content:FindFirstChild("Buttons")

        if not buttons then return nil end
        return buttons:FindFirstChild("yesButton")
    end

    local function getUltimates()
        local ultimates = {}

        for _, menu in ipairs(ultimatesGUI:GetChildren()) do
            if menu:IsA("Frame") then
                for _, button in ipairs(menu:GetChildren()) do
                    if button:IsA("GuiButton") then
                        local title = button:FindFirstChild("titleLabel")
                        table.insert(ultimates, {
                            button = button,
                            title = title and title:IsA("TextLabel") and title.Text or button.Name,
                        })
                    end
                end
            end
        end

        return ultimates
    end

    local function buyUltimate(ultimate)
        local button = ultimate.button
        if not ultimateFarmEnvs[button] or not button:IsDescendantOf(ultimatesGUI) then return end
        if not ultimateFarmEnvs[button] or not button:IsDescendantOf(ultimatesGUI) then return end
        simulateClick(ultimate.button)

        local confirmButton = getUltimateConfirmButton()
        if not confirmButton then return end

        simulateClick(confirmButton)
    end

    local function createUltimatesSection(ultimates)
        local section = Window.new("ultimatePlus", "Ultimates")

        for _, ultimate in ipairs(ultimates) do
            local button = ultimate.button
            ultimateFarmEnvs[button] = false

            section:Option({
                title = "Buy "..ultimate.title,
                value = false,

                onChange = function(enabled)
                    ultimateFarmEnvs[button] = enabled
                end,

                onChangedTrue = function() end,
                onChangedFalse = function() end,
            })
        end
    end

    local function runUltimatesFarm(ultimates)
        task.spawn(function()
            while ultimatesGUI:IsDescendantOf(playerGui) do
                for _, ultimate in ipairs(ultimates) do
                    buyUltimate(ultimate)
                    task.wait(0.1)
                end
                task.wait(1)
            end
        end)
    end


    print("===========================================")

    local function main()
        if not isBuyer then return false end

        local ultimates = getUltimates()
        local rocks = loopRocks()
        createAutoFarmSection()
        createRocksSection(rocks)
        createPlayersSection()
        createUltimatesSection(ultimates)
        runAutoFarm()
        runMuscleKingGymTP()
        runAutoRebirth()
        runPlayersAttack()
        runUltimatesFarm(ultimates)
    end

    main()
end

local url = 'https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/auth.lua'
local onCheck = loadstring(game:HttpGet(url))()
onCheck(onNext, "89ab70da-da2f-4d06-871a-da5c047b5d22")
