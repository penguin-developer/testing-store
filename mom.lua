local function onNext(isBuyer)
    local window = loadstring(game:HttpGet("https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/library.lua"))()

    local rs = game:GetService("ReplicatedStorage")
    local remotes = rs:WaitForChild("Remotes")
    local treadMills = game.Workspace:FindFirstChild("Treadmill")
    local summerCoins = game.Workspace:FindFirstChild("SummerCoinsLocal")
    local players = game:GetService("Players")
    local zones = game.Workspace:WaitForChild("Zones"):FindFirstChild("Stages")
    local autoCollectCoinsEnabled = false
    local autoCollectCoinsThread = nil
    local autoRebirthEnabled = false
    local autoRebirthThread = nil
    local autoBuyEnabled = false
    local autoBuyThread = nil
    local selectedBuyObjects = {}
    local coinStatusData = nil

    local function executeKeyboard()
        local args = {
            [1] = "Walking"
        }

        remotes:WaitForChild("UpdateSpeed"):FireServer(unpack(args))
    end

    local function buyObjectStore(typeObject) -- Rare, Uncommon, Common, Mysterious, Legendary
        local args = {
            [1] = typeObject
        }

        remotes:WaitForChild("remo"):WaitForChild("container"):WaitForChild("BuyWins"):FireServer(unpack(args))
    end

    local function tpPlayer(cfr:CFrame)
        local player = players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if not rootPart then return end

        rootPart.CFrame = cfr
    end

    local function tpToTreadMill()
        if not treadMills then return end
        local tread = treadMills:FindFirstChild("Treadmill")
        if not tread then return end

        local blockModel = tread:FindFirstChild("Smooth Block Model")
        if not blockModel then return end
        
        tpPlayer(blockModel.CFrame + Vector3.new(0, 4, 0))
    end

    local function getHuamnoidRootPart()
        local player = players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)

        return rootPart
    end

    local function getAvailableCoins()
        if not summerCoins then return {} end

        local coins = {}

        for _, value in ipairs(summerCoins:GetChildren()) do
            if value:FindFirstChild("Coin") then
                table.insert(coins, value)
            end
        end

        return coins
    end

    local function updateCoinStatus(currentIndex, totalCoins)
        if not coinStatusData or not coinStatusData.updateValue then return end

        local message = string.format("Coins available: %d", #getAvailableCoins())

        if currentIndex and totalCoins then
            message = string.format("%s | Progress: %d/%d", message, currentIndex, totalCoins)
        end

        coinStatusData.updateValue(message)
    end

    local function autoCollectCoin(shouldContinue)
        if not summerCoins then return end

        local playerPart = getHuamnoidRootPart()
        if not playerPart then return end

        local lastPosition = playerPart.CFrame
        local coins = getAvailableCoins()

        print("Total:", #coins)
        updateCoinStatus(0, #coins)

        for i, v in ipairs(coins) do
            if shouldContinue and not shouldContinue() then
                break
            end

            local c = v:FindFirstChild("Coin")

            if not c then
                continue
            end

            local cfr = c.CFrame + Vector3.new(0, 2, 0)
            tpPlayer(cfr)

            task.wait(0.5)
            updateCoinStatus(i, #coins)
        end

        print("BACK PLAYER")
        tpPlayer(lastPosition + Vector3.new(0, 2, 0))
        updateCoinStatus()
    end

    local function autoRebirth()
        remotes:WaitForChild("Rebirth"):FireServer()
    end

    local function tpToZone(zone)
        if not zones then return end
        local zone = zones:FindFirstChild(zone)
        if not zone then return false end

        local cfr = zone.CFrame
        if not cfr then return false end

        tpPlayer(cfr + Vector3.new(0, 3, 0))
        return true
    end

    local function getZoneNames()
        if not zones then return {} end

        local zoneNames = {}

        for _, zone in ipairs(zones:GetChildren()) do
            table.insert(zoneNames, zone.Name)
        end

        table.sort(zoneNames)
        return zoneNames
    end

    local autoFarm = window.new("auto farm", "Auto farm")

    coinStatusData = {
        value = string.format("Coins available: %d", #getAvailableCoins()),
    }

    autoFarm:Text(coinStatusData)

    autoFarm:Option({
        title = "Auto collect coins",
        value = false,
        onChange = function(isEnabled)
            autoCollectCoinsEnabled = isEnabled
        end,
        onChangedTrue = function()
            if autoCollectCoinsThread then return end

            autoCollectCoinsThread = task.spawn(function()
                while autoCollectCoinsEnabled do
                    autoCollectCoin(function()
                        return autoCollectCoinsEnabled
                    end)
                    task.wait(0.1)
                end

                autoCollectCoinsThread = nil
            end)
        end,
        onChangedFalse = function()
            -- onChange actualiza el booleano y el ciclo termina por sí solo.
        end,
    })

    if summerCoins then
        summerCoins.ChildAdded:Connect(function()
            task.defer(updateCoinStatus)
        end)

        summerCoins.ChildRemoved:Connect(function()
            task.defer(updateCoinStatus)
        end)
    end

    local zonesListData = {
        title = "Teleport to zone",
        values = getZoneNames(),
        onClick = function(zoneName)
            tpToZone(zoneName)
        end,
    }

    autoFarm:ActionList(zonesListData)

    if zones then
        local function refreshZones()
            zonesListData.updateValues(getZoneNames())
        end

        zones.ChildAdded:Connect(refreshZones)
        zones.ChildRemoved:Connect(refreshZones)
    end

    autoFarm:Option({
        title = "Auto rebirth",
        value = false,
        onChange = function(isEnabled)
            autoRebirthEnabled = isEnabled
        end,
        onChangedTrue = function()
            if autoRebirthThread then return end

            autoRebirthThread = task.spawn(function()
                while autoRebirthEnabled do
                    autoRebirth()
                    task.wait(1)
                end

                autoRebirthThread = nil
            end)
        end,
        onChangedFalse = function()
            -- onChange detiene el ciclo al actualizar el booleano.
        end,
    })

    local buyObjectTypes = {
        "Rare",
        "Uncommon",
        "Common",
        "Mysterious",
        "Legendary",
    }

    autoFarm:Options({
        defaultValue = buyObjectTypes,
        actives = {},
        onChange = function(values)
            selectedBuyObjects = table.clone(values)
        end,
        onAdd = function()
        end,
        onDelete = function()
        end,
    })

    autoFarm:Option({
        title = "Auto buy objects",
        value = false,
        onChange = function(isEnabled)
            autoBuyEnabled = isEnabled
        end,
        onChangedTrue = function()
            if autoBuyThread then return end

            autoBuyThread = task.spawn(function()
                while autoBuyEnabled do
                    for _, objectType in ipairs(selectedBuyObjects) do
                        if not autoBuyEnabled then break end

                        buyObjectStore(objectType)
                        task.wait(0.2)
                    end

                    task.wait(1)
                end

                autoBuyThread = nil
            end)
        end,
        onChangedFalse = function()
            -- onChange detiene el ciclo al actualizar el booleano.
        end,
    })
end

pcall(function()
    local bb = game:service'VirtualUser'
    game:service'Players'.LocalPlayer.Idled:connect(function()
        bb:CaptureController()bb:ClickButton2(Vector2.new())
    end)
end)

local productID = "f50271e2-386f-4648-89a4-ad8b6aee29c3"

local url = 'https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/auth.lua'
local onCheck = loadstring(game:HttpGet(url))()
onCheck(onNext, productID)
