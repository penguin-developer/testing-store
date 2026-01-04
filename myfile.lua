
local function onNext(isbuyer)
    local libraryUrl = "https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/library.lua"
    local Window = loadstring(game:HttpGet(libraryUrl))()
    local AutoFarm = Window.new("AutoFarm", "Farm")
    local QuestsFarm = Window.new("Bosses", "Bosses")
    local Attacks = Window.new("Attacks", "Attacks")
    local Forms = Window.new("Forms", "Forms")
    local questTextValue = { value = 'Quest: none' }
    local million = 1000000
    local httpService = game:GetService('HttpService')
    local minStatsRequiredFarm = 20000
    local minStatsTpBillsPlanet = million * 250
    local minDistanceTp = 1
    local brolyGameId = 133153710156455
    local bossNotQuestSelected = nil

    local transformsDefault = {
        "Kaioken", "FSSJ", "SSJ Kaioken", "SSJ2", "SSJ2 Majin", "Spirit SSJ", "SSJ3", "SSJ2 Kaioken", "LSSJ", "Mystic",
        "SSJ4", "SSJG", "LSSJ Kaioken", "Mystic Kaioken", "SSJ Rage", "Corrupt SSJ", "SSJ Blue", "SSJ Rose", "SSJ5", "LSSJ3", "SSJG4", "SSJB kaioken",
        "True Rose", "SSJ Berserker", "LSSJG", "Kefla SSJ2", "Dark Rose", "Blue Evolution", "Evil SSJ", "Ultra Instinct Omen", "Godly SSJ2", "Mastered Ultra Instinct",
        "Jiren Ultra Instinct", "God of Creation", "God of Destruction", "Super Broly", "SSJB3", "SSJR3", "True God of Destruction", "True God of Creation", "LBSSJ4",
        "SSJB4", "Ultra Ego", "SSJBUI", "Beast", "Blanco", 'True Jui', 'CSSJB3', 'Primal Radiance', 'Primal Ruin', 'Error core: NULLSTATE', 'Primal Ego SSJ4','Northern Star','Christmas Nightmare',
        'Ego Instinct', 'Resolution'
    }

    local fileNames = {
        autofarm = 'autoFarm-devstudios-v2.txt',
        transforms = 'transforms-devstudios-v2.txt',
        attacks = 'attacks-devstudios-v1.txt'
    }

    local function saveDataFile(name, value)
        value = httpService:JSONEncode(value)
        local succes, result = pcall(function()
            writefile(name, value)
            return true
        end)
        if succes then
            return result
        else
            return false
        end
    end

    local function getDataFile(name)
        local succes, result = pcall(function()
            if isfile(name) then
                warn("Existe el file")
                return httpService:JSONDecode(readfile(name))
            else
                warn("No existe el mensaje")
                return nil
            end
        end)
        if succes then
            return result
        else
            return nil
        end
    end

    local autoFarmValues = getDataFile(fileNames.autofarm) or {
        autoFarm = true,
        autoRebirth = false,
        autoMaxRebirth = false,
        multiPlanets = false,
        statsRequiredStartFarm = minStatsRequiredFarm,
        statsBillsPlanet = minStatsTpBillsPlanet,
        distanceTpBoss = minDistanceTp * 3,
        raidBrloly = false,
        secureTpMode = false,

        tpBillsPlanet = true,
        tpNamekPlanet = true,
        tpTournamentPower = true,
    }

    local attacksValues = getDataFile(fileNames.attacks) or {
        melee = true,
        energy = true,
        meleeAttacks = {
            {name = "Divine Smite", stats = million * 1000},
            {name = "God Slicer", stats = 60000000},
            {name = "Spirit Barrage", stats = 60000000},
            {name = "Super Dragon Fist", stats = 50000000},
            {name = "Spirit Breaking Cannon", stats = 200000},
            {name = "Mach Kick", stats = 90000},
            -- {name = "High Power Rush", stats = 65000},
            {name = "Wolf Fang Fist", stats = 2000},
            {name = "Sledgehammer", stats = 1000},
            {name = "Uppercut", stats = 1000},
            {name = "MeteorCharge", stats = 1000},
            {name = "Vital Strike", stats = 500},
        }
    }

    local transformsValues = getDataFile(fileNames.transforms) or {
        autoTransform = true,
        transformsActives = transformsDefault,
        transformsDisabled = {},
    }

    local minStatsQuests = {
        ["Klirin"] = 10000,
    }

    local questsValues = {
        questActive = {},
        questDisabled = {},
        multiQuest = true,
    }

    -- variables
    local players = game:GetService("Players")
    local player = players.LocalPlayer
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local datas = replicatedStorage:WaitForChild("Datas")[player.userId]
    local events = replicatedStorage:WaitForChild("Package"):WaitForChild("Events")
    local living = game.Workspace:WaitForChild("Living")
    local npcs = game.Workspace:WaitForChild("Others"):WaitForChild("NPCs")
    local tp = events:WaitForChild("TP")
    local gameId = game.PlaceId
    local earthId = 3311165597
    local strength = datas:FindFirstChild("Strength")
    local energy = datas:FindFirstChild("Energy")
    local defense = datas:FindFirstChild("Defense")
    local speed = datas:FindFirstChild("Speed")
    local rebirth = datas:FindFirstChild("Rebirth")
    local questValue = datas:FindFirstChild("Quest")
    local punch = events:WaitForChild("p")
    local kb = events:WaitForChild("kb")
    local def = events:WaitForChild("def")
    local ch = events:WaitForChild("ch")
    local quests = {}
    local attempsSearchQuest = 0
    local maxAttempsSearchQuest = 10
    local isPlayerAlive = false
    local isFreezeAttacksMelee = false
    local tpDistance = autoFarmValues.distanceTpBoss
    local isModeAutoTransform = false

    local function updateLog(message)
        pcall(function()
            questTextValue.updateValue(message)
        end)
    end

    local function addLogError(e)
        warn(e)
    end

    local function getMinStats()
        local min = strength.Value
        if energy.Value <= min then
            min = energy.Value
        end
        if defense.Value <= min then
            min = defense.Value
        end
        if speed.Value <= min then
            min = speed.Value
        end
        return min
    end

    local function checkStatsFarm()
        local s, r = pcall(function()
            local statsRequired = autoFarmValues.statsRequiredStartFarm
            return (strength.Value >= statsRequired) and (energy.Value >= statsRequired) and (defense.Value >= statsRequired) and (speed.Value >= statsRequired)
        end)
        if s then
            return r
        else
            return true
        end
    end
 
    local function executePunch(punchValue)
        local value = punchValue or 1
        local args = {
            [1] = "Blacknwhite27",
            [2] = value
        }
        punch:FireServer(unpack(args))
    end

    local function executeAllPunch()
        for i = 1, 4, 1 do
            executePunch(i)
            task.wait(0.3)
        end
    end

    local function executeKb()
        kb:FireServer()
    end

    local function executeDef()
        local args = {
            [1] = "Blacknwhite27"
        }
        def:InvokeServer(unpack(args))
    end

    local function executeCh()
        local args = {
            [1] = "Blacknwhite27"
        }
        ch:InvokeServer(unpack(args))
    end

    local function executeQuest(name)
        local args = {[1] = npcs:FindFirstChild(name)}
        return events:FindFirstChild("Qaction"):InvokeServer(unpack(args))
    end

    local function NoClip()
        local s, err = pcall(function()
            local character = game.Workspace:FindFirstChild(player.Name)
            if character then
                for _, v in pairs(character:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.CanCollide = false
                    end
                end
            end
        end)

        if not s then
            warn('Internal server error in NoClip:', err)
        end
    end

    local function executeReb()
        if autoFarmValues.autoRebirth then
            return events:WaitForChild("reb"):InvokeServer()
        end
    end

    local function tpPlayerSlow(rootPart, frame)
        local tolerance = 3
        local targetPosition = frame.Position

        while (rootPart.Position - targetPosition).Magnitude > tolerance and autoFarmValues.secureTpMode do
            task.spawn(NoClip)
            rootPart.CFrame = rootPart.CFrame:Lerp(frame, 0.03)
            task.wait()
        end
    end

    local function tpPlayer(position, slowMode)
        local isSlowMode = slowMode or false

        local _, e = pcall(function()
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoid = character:FindFirstChild("HumanoidRootPart")

            if slowMode and autoFarmValues.secureTpMode then
                tpPlayerSlow(humanoid, position)
            else
                humanoid.CFrame = position
            end
        end)
        if e then
            addLogError("Error al tp: "..e)
        end
    end

    local function cancelAutoCharge()
        --local args2 = {[1] = false,[2] = eventName}
        --cha:InvokeServer(unpack(args2))
    end

    local function autoCharge()
        if not isModeAutoTransform then
            local args = {
                [1] = "Blacknwhite27"
            }
            events:WaitForChild("cha"):InvokeServer(unpack(args))
        end
    end

    local function autoBlock()
        local args = {
            [1] = "Blacknwhite27"
        }
        events:WaitForChild("block"):InvokeServer(unpack(args))
    end

    local function executeAutoChargeBySeconds(seconds, interval)
        interval = interval or 0
        local timer = tick()
        while (tick() - timer) < seconds do
            autoCharge()
            task.wait(interval)
        end
        cancelAutoCharge()
    end

    local function isValidKi(minValue, minPercent)
        local s, r = pcall(function()
            local character = player.Character or player.CharacterAdded:Wait()
            local ki = character.Stats.Ki
            local isValidPercent = true
            if minPercent then
                isValidPercent = ki.Value >= ((energy.Value / 500) * (minPercent / 100))
            end
            return ki.Value > minValue and isValidPercent
        end)
        if s then
            return r
        else
            warn("Error: "..r)
            return false
        end
    end

    local function checkQuests()
        for _, q in ipairs(npcs:GetChildren()) do
            local _, e = pcall(function()
                local QUEST = q:FindFirstChild("Quest")
                print("Iterando sobre: "..q.Name)
                if QUEST and QUEST.Value then
                    print("Si tiene su valor")
                    local bossName = q.Name
                    local questName = QUEST.Value
                    local questLiving = living:FindFirstChild(questName) or living:FindFirstChild(q.Name)
                    if questLiving then
                        print("Agregando a: "..bossName)
                        local boss = questsValues.questActive[bossName]
                        if not boss then
                            boss = {nickName = questLiving.Name, stats = questLiving.Stats.Strength.Value * 2, name = bossName}
                        end
                        table.insert(quests, boss)
                    else
                        print("No viene en el living")
                    end
                end
            end)
            if e then
                addLogError("Error buscando mision: "..e)
            end
        end
        table.sort(quests, function(a, b)
            return a.stats >= b.stats
        end)
    end

    local function tpPlanets()
        local succes, res = pcall(function()
            if autoFarmValues.raidBrloly and game.PlaceId ~= brolyGameId then
                tp:InvokeServer("BrolyRaid")
                return
            end

            if not autoFarmValues.multiPlanets then
                return false
            end

            local stats = getMinStats()
            local namekId = 138941735852322
            local billsPlanetId = 5151400895
            local powerId = 114014249462644 -- T.O.P

            if stats >= autoFarmValues.statsBillsPlanet and autoFarmValues.tpBillsPlanet then
                if gameId ~= billsPlanetId then
                    tp:InvokeServer("Vills Planet")
                end

                return true
            end

            if stats >= million * 20000000 and autoFarmValues.tpTournamentPower then
                if gameId ~= powerId then
                    tp:InvokeServer("T.O.P")
                end

                return true
            end

            if stats >= million and autoFarmValues.tpNamekPlanet then
                if gameId ~= namekId then
                    tp:InvokeServer("Namek")
                end

                return true
            end

            if gameId ~= earthId then
                tp:InvokeServer("Earth")
                return true
            end
        end)
        if succes then
            return res
        else
            return false
        end
    end

    local function attacksEnergy(position)
        local args = {[1] = "Energy Volley", [2] = {["FaceMouse"] = true, ["MouseHit"] = position}, [3] = "Blacknwhite27"}
        events:WaitForChild("voleys"):InvokeServer(unpack(args))
    end

    local lastAttackTime = 0
    local ATTACK_COOLDOWN = 0.15

    local function attacksMelee(humanoid, myStats, pos)
        if isFreezeAttacksMelee or isModeAutoTransform then
            return
        end

        isFreezeAttacksMelee = true

        if myStats < 100000 or not attacksValues.melee then
            task.spawn(executeAllPunch)
            task.wait(0.3)
            isFreezeAttacksMelee = false
            return
        end

        task.spawn(function()
            for i, melee in ipairs(attacksValues.meleeAttacks) do
                if humanoid.Health <= 0 then
                    break
                end

                local currentTime = os.clock()
                local timeSinceLastAttack = currentTime - lastAttackTime

                if timeSinceLastAttack < ATTACK_COOLDOWN then
                    local waitTime = ATTACK_COOLDOWN - timeSinceLastAttack
                    task.wait(waitTime)
                end

                if isModeAutoTransform then
                    break
                end

                local x, y = pcall(function()
                    if melee.stats <= myStats then
                        local args = {
                            [1] = melee.name,
                            [2] = "Blacknwhite27"
                        }

                        local newEventAttack = events:FindFirstChild('Haha')
                        local attackEvent = events:FindFirstChild('mel')

                        if newEventAttack then
                            newEventAttack:InvokeServer(unpack(args))
                            lastAttackTime = os.clock()
                        elseif not attackEvent then
                            attackEvent = events:FindFirstChild("letsplayagame")

                            if attackEvent then
                                attackEvent:InvokeServer(unpack(args))
                                lastAttackTime = os.clock()
                            end
                        end
                    end
                end)
                if y then
                    warn('Error al ejecutar ataques de melee: '..y)
                end
            end

            task.wait(ATTACK_COOLDOWN / 2)
            attacksEnergy(pos)
            task.wait(ATTACK_COOLDOWN / 2)
            isFreezeAttacksMelee = false
        end)
    end

    local function attacks(humanoid, myStats, pos)
        attacksMelee(humanoid, myStats, pos)
    end

    local function checkBoss(bossLiving)
        local success, result = pcall(function()
            return bossLiving.Humanoid.Health and bossLiving.Humanoid.Health > 0 and isPlayerAlive and autoFarmValues.autoFarm
        end)
        if success then
            return result and isPlayerAlive
        else
            return false
        end
    end

    local function tpBack(pos)
        tpDistance = 140
        tpPlayer(pos * CFrame.new(0, 0, tpDistance))
    end

    local function figthToQuests(bossLiving)
        local stats = getMinStats()
        local attemps = 0

        local percent = 20
        if stats > million * 200 then
            percent = 5
        elseif stats > million * 100 then
            percent = 10
        elseif stats > million * 50 then
            percent = 10
        elseif stats > million * 10 then
            percent = 15
        end

        while checkBoss(bossLiving) do
            local _, e = pcall(function()
                local HumanoidRootPart = bossLiving:FindFirstChild("HumanoidRootPart")
                local pos = HumanoidRootPart.CFrame
                local tpPosition = pos * CFrame.new(0, 0, tpDistance)
                -- local humanoid = player.Character:WaitForChild("Humanoid")

                if stats > 100000 and not isValidKi(40, percent) then
                    while not isValidKi(100, 35) and isPlayerAlive and autoFarmValues.autoFarm do
                        task.spawn(function ()
                            autoBlock()
                            autoCharge()
                        end)
                        tpBack(HumanoidRootPart.CFrame)
                        task.wait()
                    end
                    cancelAutoCharge()
                end

                tpPlayer(tpPosition)

                if isModeAutoTransform then
                    tpDistance = 70
                else
                    task.spawn(autoBlock)
                    tpDistance = autoFarmValues.distanceTpBoss
                    attacks(bossLiving.Humanoid, stats, pos)
                end

            end)

            if e then
                if attemps > 100 then
                    break
                end

                attemps = attemps + 1
                addLogError("Error al atacar al jefe: "..e)
            end
            task.wait()
        end

        cancelAutoCharge()

        tpDistance = autoFarmValues.distanceTpBoss
        task.wait(1.5)

        isFreezeAttacksMelee = false
    end

    local function searchQuest()
        for _, quest in pairs(quests) do
            local boss = living:FindFirstChild(quest.nickName)
            local npc = npcs:FindFirstChild(quest.name)
            if not isPlayerAlive then
                break
            end
            local _ = questsValues.questActive[boss.Name]
            local statsQuest = quest.stats

            if statsQuest >= 1000 then
                statsQuest = statsQuest + (statsQuest / 10)
            end

            if strength.Value >= statsQuest and npc and npc:FindFirstChild("HumanoidRootPart") and boss and boss:FindFirstChild("Humanoid") and boss:FindFirstChild("Humanoid").Health > 0 and executeQuest(quest.name) then
                updateLog("Seleccionando la mision con el nombre: "..quest.name)
                return quest
            end
        end
        return nil
    end

    local function selectForm()
        for i = #transformsValues.transformsActives, 1, -1 do
            local form = transformsValues.transformsActives[i]
            if events.equipskill:InvokeServer(form) then
                return form
            end
        end
        return nil
    end

    local function executeForm()
        local s, e = pcall(function()
            local form = selectForm()
            print(form)

            local folderStatus = player:FindFirstChild("Status")
            if not form or not folderStatus == form then
                print("No viene status")
                return
            end

            local formValue = folderStatus:FindFirstChild("Transformation")

            if formValue.Value == form or isModeAutoTransform then
                return
            end

            while folderStatus.Transformation.Value ~= form and isPlayerAlive and autoFarmValues.autoFarm and isValidKi(80, 20) do
                isModeAutoTransform = true
                local eventForm = events:FindFirstChild('Hehehe')

                if not eventForm then
                    eventForm = events:FindFirstChild('a'):FindFirstChild('Cece')
                end

                if not eventForm then
                    print('No viene')
                    eventForm = events:FindFirstChild("ta")
                end

                eventForm:InvokeServer()
                task.wait()
            end

            task.wait(1)
            isModeAutoTransform = false
        end)
        if e then
            print("Error al form: "..e)
            addLogError("Error al transformarme: "..e)
            isModeAutoTransform = false
        end
    end

    local function selectQuest(quest)
        local name = quest.name
        local bossNpc = npcs:FindFirstChild(name)
        local bossLiving = living:FindFirstChild(quest.nickName)

        if game.PlaceId == brolyGameId or quest.name == bossNotQuestSelected then
            return bossLiving
        end

        if not bossNpc or not bossLiving or not isPlayerAlive then
            return nil
        end
        local rootPart = bossNpc:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            print("No viene el humanoid")
            return nil
        end
        local questPosition = rootPart.CFrame
        if not questPosition then
            print("no viene la posicion")
            return nil
        end
        if questValue.Value == name then
            return bossLiving
        end
        while isPlayerAlive and autoFarmValues.autoFarm and isPlayerAlive and (questValue.Value ~= name or not bossLiving:FindFirstChild("HumanoidRootPart")) do
            local _, e = pcall(function()
                task.spawn(autoCharge)
                tpPlayer(questPosition * CFrame.new(0, 0, 2.5), true)
                local isValidQuest = executeQuest(name)
                updateLog("Start quest: "..name)
            end)
            if questValue.Value == name and not bossLiving:FindFirstChild("HumanoidRootPart") then
                task.wait(1)
            else
                task.wait()
            end
            if e then
                addLogError("Error al seleccionar la mision: "..e)
            end
        end
        updateLog("Quest: "..name)
        return bossLiving
    end

    local function uploadMinStatsRequired()
        while not checkStatsFarm() and isPlayerAlive do
            local _, e = pcall(function()
                local value = autoFarmValues.statsRequiredStartFarm
                if not isValidKi(20, 20) then
                    events:WaitForChild("of"):FireServer()
                    while not isValidKi(99, 70) and isPlayerAlive do
                        print("Esperando ki!")
                        task.spawn(autoCharge)
                        task.wait()
                    end
                    cancelAutoCharge()
                end
                if strength.Value <= value then
                    task.spawn(executePunch)
                end
                if defense.Value <= value then
                    task.spawn(executeDef)
                end
                if energy.Value <= value then
                    task.spawn(executeKb)
                end
                if speed.Value <= value then
                    task.spawn(executeCh)
                end
            end)
            task.wait()
            if e then
                addLogError(e)
                updateLog("Error waiting for stats")
            end
        end
    end

    local alreadyStartedScript = false

    local function onStartFarm()
        while autoFarmValues.autoFarm do
            if not isPlayerAlive then
                break
            end

            pcall(function()
                pcall(uploadMinStatsRequired)

                task.spawn(executeForm)

                local quest

                if bossNotQuestSelected ~= nil then
                    quest = {name = bossNotQuestSelected, nickName = bossNotQuestSelected}
                elseif game.PlaceId == brolyGameId then
                    quest = {name = 'Broccoli', nickName = 'Broccoli'}
                else
                    quest = searchQuest()
                end

                if attempsSearchQuest >= maxAttempsSearchQuest then
                    updateLog("No se encontro una mision, reiniciando!")
                    attempsSearchQuest = 0
                end
                if not quest then
                    attempsSearchQuest = attempsSearchQuest + 1
                    updateLog("No se encontro una mision, revisando de nuevo las misiones")
                    task.wait(2)
                    pcall(checkQuests)
                else
                    attempsSearchQuest = 0
                    local questSelected = selectQuest(quest)

                    if questSelected then
                        figthToQuests(questSelected)
                        while isPlayerAlive and (questValue.Value ~= '' and not selectQuest(quest) and game.PlaceId ~= brolyGameId) and autoFarmValues.autoFarm do
                            task.wait()
                        end
                    else
                        print("No viene nadie con quien pelear")
                    end
                end
            end)

            task.wait()
        end
    end

    local function onStartPlayer()
        return player.CharacterAdded:Connect(function(char)
            warn("Revivio")

            while char and char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health <= 0 do
                task.wait()
                print("Esperando a que reviva")
            end

            isPlayerAlive = true

            char:WaitForChild("Humanoid").Died:Connect(function()
                print("Murio")
                isPlayerAlive = false
            end)

            local _, e = pcall(onStartFarm)
            if e then
                addLogError("Main error: "..e)
            end
        end)
    end

    local function playGame()
        local character = player.Character or player.CharacterAdded:Wait()
        character.Humanoid.Health = 0

        events.Start:InvokeServer()
        updateLog("Loading script...")
        local playerEvent
        playerEvent = onStartPlayer()
        local maxSeconds = 10
        local timer = tick()

        defense.Changed:Connect(function()
            executeReb()
            tpPlanets()
        end)

        while not alreadyStartedScript do
            if tick() - timer >= maxSeconds then
                updateLog("Loading again...")
                timer = tick()
                playerEvent:Disconnect()
                character.Humanoid.Health = 0
                playerEvent = onStartPlayer()
            end
            task.wait()
        end
    end

    local autoFarm = {
        value = autoFarmValues.autoFarm,
        title = 'AutoFarm',
        description = 'Start farm',
        onChange = function(value)
            autoFarmValues.autoFarm = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
        onChangedTrue = function()
        end,
        onChangedFalse = function()
            updateLog("Auto farm stopped")
        end,
    }

    local raidBroly = {
        value = autoFarmValues.raidBrloly,
        title = 'Broly Raid',
        description = 'Raid broly',
        onChange = function(value)
            autoFarmValues.raidBrloly = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,

        onChangedTrue = function()
        end,

        onChangedFalse = function()
        end,
    }

    local autoMaxRebirth = {
        value = autoFarmValues.autoMaxRebirth,
        title = "Auto MaxRebirth",
        description = "Execute max rebirth",
        onChange = function(value)
            autoFarmValues.autoMaxRebirth = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
        onChangedTrue = function()
        end,
        onChangedFalse = function()
            updateLog("Auto farm stopped")
        end,
    }

    local autoRebirth = {
        value = autoFarmValues.autoRebirth,
        title = "Auto Rebirth",
        description = "Execute auto rebirth",
        onChange = function(value)
            autoFarmValues.autoRebirth = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
        onChangedTrue = function()
        end,
        onChangedFalse = function()
            updateLog("Auto farm stopped")
        end,
    }

    local tpSecureModeSlow = {
        value = autoFarmValues.secureTpMode,
        title = "Secure TP (Slow)",
        description = "Execute tp secure mode anti detect",
        onChange = function(value)
            autoFarmValues.secureTpMode = value

            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,

        onChangedTrue = function()
        end,

        onChangedFalse = function()
        end,
    }

    local tpBillsPlanetMode = {
        value = autoFarmValues.tpBillsPlanet,
        title = "TP Bills planet",
        description = "TP to planet",
        onChange = function(value)
            autoFarmValues.tpBillsPlanet = value

            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,

        onChangedTrue = function()
        end,

        onChangedFalse = function()
        end,
    }
    local tpNamekPlanet = {
        value = autoFarmValues.tpNamekPlanet,
        title = "TP Namek",
        description = "TP Namek planet",
        onChange = function(value)
            autoFarmValues.tpNamekPlanet = value

            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,

        onChangedTrue = function()
        end,

        onChangedFalse = function()
        end,
    }

    local tpTournamentPower = {
        value = autoFarmValues.tpTournamentPower,
        title = "TP Tournament Power",
        description = "TP to Tournament power",
        onChange = function(value)
            autoFarmValues.tpTournamentPower = value

            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,

        onChangedTrue = function()
        end,

        onChangedFalse = function()
        end,
    }

    local multiPlanets = {
        value = autoFarmValues.multiPlanets,
        title = "TP planets",
        description = "Execute Auto TP bills or Earth",
        onChange = function(value)
            autoFarmValues.multiPlanets = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
        onChangedTrue = function()
        end,
        onChangedFalse = function()
            updateLog("Auto farm stopped")
        end,
    }

    local statsRequired = {
        title = 'Enter stats start farm:',
        value = autoFarmValues.statsRequiredStartFarm,
        description = 'Start farm with stats',
        inputType = 'NUMBER',
        numberValidations = {
            minValue = minStatsRequiredFarm,
            maxValue = million * 300,
        },
        onChange = function(value)
            autoFarmValues.statsRequiredStartFarm = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
    }

    local statsTpBillsPlanet = {
        title = 'Enter stats tp bills planet:',
        value = autoFarmValues.statsBillsPlanet,
        description = 'Start bills planet',
        inputType = 'NUMBER',
        numberValidations = {
            minValue = minStatsTpBillsPlanet,
            maxValue = minStatsTpBillsPlanet * 100000,
        },
        onChange = function(value)
            autoFarmValues.statsBillsPlanet = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
    }

    local distanceTp = {
        title = 'Tp distance boss',
        value = autoFarmValues.distanceTpBoss,
        description = 'Distance tp boss',
        inputType = 'NUMBER',
        numberValidations = {
            minValue = minDistanceTp,
            maxValue = minDistanceTp * 50,
        },
        onChange = function(value)
            autoFarmValues.distanceTpBoss = value
            saveDataFile(fileNames.autofarm, autoFarmValues)
        end,
    }

    local meleeOption = {
        value = attacksValues.melee,
        title = "Auto Attacks Melee",
        description = "Execute all attacks melee availables",
        onChange = function(value)
            attacksValues.melee = value
            saveDataFile(fileNames.attacks, attacksValues)
        end,
        onChangedTrue = function(value)
        end,
        onChangedFalse = function(value)
        end,
    }

    local energyOption = {
        value = attacksValues.energy,
        title = "Auto Attacks energy",
        description = "Execute all attacks energy availables",
        onChange = function(value)
            attacksValues.energy = value
            saveDataFile(fileNames.attacks, attacksValues)
        end,
        onChangedTrue = function(value)
        end,
        onChangedFalse = function(value)
        end,
    }

    local transformOption = {
        value = transformsValues.autoTransform,
        title = "Execute auto transform",
        description = "Execute auto transform xd",
        onChange = function(value)
            transformsValues.autoTransform = value
            saveDataFile(fileNames.transforms, transformsValues)
        end,
        onChangedTrue = function(value)
        end,
        onChangedFalse = function(value)
        end,
    }

    local transformOptions = {
        defaultValue = transformsDefault,
        actives = transformsValues.transformsActives,
        onChange = function(array)
            transformsValues.transformsActives = array
            saveDataFile(fileNames.transforms, transformsValues)
        end,
        onDelete = function(value)
            print("Deleted = "..value)
        end,
        onAdd = function(value)
            print('Added = '..value)
        end,
    }

    AutoFarm:Option(autoFarm)
    AutoFarm:Option(raidBroly)
    AutoFarm:Option(autoMaxRebirth)
    AutoFarm:Option(autoRebirth)
    AutoFarm:Option(multiPlanets)
    AutoFarm:Option(tpSecureModeSlow)

    AutoFarm:Option(tpBillsPlanetMode)
    AutoFarm:Option(tpNamekPlanet)
    AutoFarm:Option(tpTournamentPower)

    AutoFarm:Input(statsTpBillsPlanet)
    AutoFarm:Input(distanceTp)
    AutoFarm:Input(statsRequired)

    Attacks:Option(meleeOption)
    Attacks:Option(energyOption)
    Forms:Option(transformOption)
    Forms:Options(transformOptions)

    local function addDynamicOptions()
        local living = game.Workspace:FindFirstChild("Living")
        local quests = game.Workspace:FindFirstChild("Others"):FindFirstChild("NPCs"):GetChildren()

        local function getQuestByName(name)
            local quest = nil

            for _, q in pairs(quests) do
                if q.Name == name then
                    quest = q.Name
                    break
                end
            end

            return quest
        end

        for _, boss in pairs(living:GetChildren()) do
            print(quests[boss.Name])
            if boss:FindFirstChild("NPC") and getQuestByName(boss.Name) == nil then
                local optionBoss = {
                    value = false,
                    title = "Kill "..boss.Name,
                    description = "Execute auto transform xd",

                    onChange = function(value)
                    end,

                    onChangedTrue = function(value)
                        if bossNotQuestSelected ~= boss.Name then
                            bossNotQuestSelected = boss.Name
                        end
                    end,

                    onChangedFalse = function(value)
                        if bossNotQuestSelected == boss.Name then
                            bossNotQuestSelected = nil
                        end
                    end,
                }

                QuestsFarm:Option(optionBoss)
                print(boss.Name.." es un boss que no tiene mision")
            end
        end
    end


    pcall(checkQuests)
    playGame()
end

task.wait(1)

pcall(function()
    local bb = game:service'VirtualUser'
    game:service'Players'.LocalPlayer.Idled:connect(function()
        bb:CaptureController()bb:ClickButton2(Vector2.new())
    end)
end)

pcall(function ()
    local playerID = game:GetService('Players').LocalPlayer.userId
    local availablePlayers = {8014173878, 9158091036, 9890816157}

    for _, v in pairs(availablePlayers) do
        if playerID == v then
            onNext(true)
            break
        end
    end
end)

local url = 'https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/auth.lua'
local onCheck = loadstring(game:HttpGet(url))()

onCheck(onNext, 2, 1)
