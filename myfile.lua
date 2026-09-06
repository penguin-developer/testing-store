local function onNext(isbuyer)
    local libraryUrl = "https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/library.lua"
    local Window = loadstring(game:HttpGet(libraryUrl))()
    local AutoFarm = Window.new("AutoFarm", "Farm")
    local RebirthsWindow = Window.new("Rebirths", "Rebirths")
    local CodesWindow = Window.new("Codes", "Codes")
    local QuestsWindow = Window.new("Quests", "Quests")
    local QuestsFarm = Window.new("Bosses", "Bosses")
    local Attacks = Window.new("Attacks", "Attacks")
    local Forms = Window.new("Forms", "Forms")
    local statsForReb = 2000000

    local questTextValue = { value = 'Quest: none' }
    local alertForms = { value = 'Warning: Do not equip unknown transformations (in. Kawaii). Risk of being banned.' }
    local priorizedQuests = {} -- questName, bossName {quest = questName, boss = bossName}

    local million = 1000000
    local httpService = game:GetService('HttpService')
    local minStatsRequiredFarm = 20000
    local minDistanceTp = 1
    local bossNotQuestSelected = {}

    local transformsDefault = {}
    local formsNotActive = {"Dima SSJ4", 'Christmas Spirit', 'Ashie', 'Zyben SSJG', 'cont', 'Kawaii', 'Kan', 'Fairys Chosen'}

    local rs = game:GetService("ReplicatedStorage")
    local package = rs:WaitForChild("Package", 5)
    local skills = package:WaitForChild("Skills", 5)
    local formsRequeriments = {}
    local isInfiniteRebirths =  false

    local meleeAttacks = {}
    local meleeAttacksRequeriments = {}
    local unavailableMeleeAttacks = {
        divinecounter = true,
        timeskipmolotov = true,
        punisherdrive = true,
        savagestrike = true,
    }

    local function isAvailableMeleeAttack(name)
        local normalizedName = name:lower():gsub("[^%w]", "")
        return not unavailableMeleeAttacks[normalizedName]
    end

    local function isValidForm(name)
        for _, v in pairs(formsNotActive) do
            if v == name then
                return false
            end
        end

        return true
    end

    for _, v in pairs(skills:GetChildren()) do
        local s, err = pcall(function()
            local requerimentsFolder = v:FindFirstChild("Requirements")

            if v:IsA("Folder") and v:FindFirstChild("Time") and requerimentsFolder and isValidForm(v.Name) then
                local statsReq = tonumber(requerimentsFolder:FindFirstChild("Strength").Value)
                local percent = 80

                if statsReq >= 50000000 then
                    percent = 40
                elseif statsReq >= 20000000 then
                    percent = 60
                end

                if v:FindFirstChild("Gamepass") then
                    statsReq = statsReq + ((statsReq * percent) / 100)
                end

                formsRequeriments[v.Name] = statsReq
                table.insert(transformsDefault, v.Name)
            end
        end)

        if err ~= nil then
            warn(err)
        end
    end

    table.sort(transformsDefault, function(a, b)
        return formsRequeriments[a] > formsRequeriments[b]
    end)

    for _, v in pairs(skills:GetChildren()) do
        local cost = v:FindFirstChild("Cost")
        local requeriments = v:FindFirstChild("Requirements")

        if cost and requeriments then
            local strengthValue = requeriments:FindFirstChild("Strength")
            local energyValue = requeriments:FindFirstChild("Energy")

            if not isAvailableMeleeAttack(v.Name) or not strengthValue or not strengthValue:IsA("IntValue") or tonumber(strengthValue.Value) == 0 or (energyValue and tonumber(energyValue.Value) > 0 and v.Name ~= "Energy Volley") then
            -- if not strengthValue or not strengthValue:IsA("IntValue") or tonumber(strengthValue.Value) == 0 then
                continue
            end

            meleeAttacksRequeriments[v.Name] = tonumber(strengthValue.Value)
            table.insert(meleeAttacks, v.Name)
        end
    end

    table.sort(meleeAttacks, function(a, b)
        return meleeAttacksRequeriments[a] > meleeAttacksRequeriments[b]
    end)

    local rebirthsValues = {
        multiplerRebirthBaseForMaxReb = 20000,
    }

    local raidsValues = {
        BrolyRaid = {
            placeID = 133153710156455,
            boss = 'Broly'
        },

        HellRaid = {
            placeID = 133153710156455,
            boss = 'Goheta'
        },

        ['Future Raid (Solo)'] = {
            placeID = 139274481709472,
            boss = 'Wukong Black'
        },
    }

    local fileNames = {
        autofarm = 'autoFarm-devstudios-v2.txt',
        transforms = 'transforms-devstudios-v5.txt',
        attacks = 'attacks-devstudios-v1.txt',
        meleeAttacks = 'melee-attacks-devstudios-v1.txt',
        rebirthFile = 'rebirth-values-dvs-v1.txt'
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
        statsRequiredStartFarm = minStatsRequiredFarm,
        distanceTpBoss = minDistanceTp * 3,
        secureTpMode = false,
    }

    for name, _ in pairs(raidsValues) do
        if autoFarmValues[name] == nil then
            autoFarmValues[name] = false
        end
    end

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

    local meleeAttackValues = getDataFile(fileNames.meleeAttacks)
    if type(meleeAttackValues) ~= "table" then
        meleeAttackValues = {}
    end

    for _, name in ipairs(meleeAttacks) do
        if type(meleeAttackValues[name]) ~= "boolean" then
            meleeAttackValues[name] = true
        end
    end

    local function isMeleeAttackEnabled(name)
        return attacksValues.melee and isAvailableMeleeAttack(name) and meleeAttackValues[name] == true
    end

    local function createMeleeAttackOptions()
        local activeAttacks = {}
        for _, name in ipairs(meleeAttacks) do
            if meleeAttackValues[name] then
                table.insert(activeAttacks, name)
            end
        end

        local initializing = true
        Attacks:Options({
            defaultValue = meleeAttacks,
            actives = activeAttacks,
            onChange = function(selectedAttacks)
                -- Options emite cambios parciales mientras crea sus botones.
                if initializing then return end

                for _, name in ipairs(meleeAttacks) do
                    meleeAttackValues[name] = table.find(selectedAttacks, name) ~= nil
                end
                saveDataFile(fileNames.meleeAttacks, meleeAttackValues)
            end,
            onAdd = function() end,
            onDelete = function() end,
        })
        initializing = false
    end

    local transformsValues = getDataFile(fileNames.transforms) or {
        autoTransform = true,
        alwaysEnabledForm = false,
        transformsActives = transformsDefault,
        transformsDisabled = {},
    }

    if isInfiniteRebirths then
        transformsValues.autoTransform = false
    end

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
            print(message)
        end)
    end

    local function isMultiBoss(name:string): boolean
        local count = 0

        for _, v in pairs(living:GetChildren()) do
            if v.Name == name then
                count = count + 1
            end

            if count > 2 then
                return true
            end
        end

        return false
    end

    local function getStrengthValue()
        return tonumber(strength.Value)
    end

    local function getEnergyValue()
        return tonumber(energy.Value)
    end

    local function getDefenseValue()
        return tonumber(defense.Value)
    end

    local function getSpeedValue()
        return tonumber(speed.Value)
    end


    local function addLogError(e)
        warn(e)
    end

    local redeemCodeTextData = {
        value = "Redeem codes :)"
    }

    CodesWindow:Text(redeemCodeTextData)

    local function executeAllCodes()
        local codes = package:FindFirstChild("Codes")

        if not codes then
            return
        end

        for _, code in pairs(codes:GetChildren()) do
            if code:IsA("IntValue") then
                local success, fallo = pcall(function()
                    local args = {[1] = code.Name}
                    events.SendCode:FireServer(unpack(args))
                end)

                if fallo then
                    redeemCodeTextData.updateValue("Error in redeem code: "..code.Name)
                    task.wait(2)
                else
                    redeemCodeTextData.updateValue("Code success: "..code.Name)
                end
            end

            task.wait()
        end
    end

    local function missingAttackInformation(nameAttack)
        print("No viene informacion para el ataque: "..nameAttack..". Ejecucion cancelada.")
        return false
    end

    local function executeAttack(nameAttack, position)
        if not isMeleeAttackEnabled(nameAttack) then return false end

        local backpack = player:WaitForChild('Backpack', 5)
        local character = player.Character
        local attack = character and character:FindFirstChild(nameAttack)
            or backpack and backpack:FindFirstChild(nameAttack)
        if not attack or not attack:IsA("Tool") then
            return missingAttackInformation(nameAttack)
        end

        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid or not isMeleeAttackEnabled(nameAttack) then return false end

        humanoid:EquipTool(attack)
        task.wait()

        local success, result = pcall(function()
            if not isMeleeAttackEnabled(nameAttack) then return false end

            local plrLiving = living:FindFirstChild(player.Name)
            if not plrLiving then
                return missingAttackInformation(nameAttack)
            end

            local toolAttack = plrLiving:WaitForChild(nameAttack, 2)
            if not toolAttack then
                return missingAttackInformation(nameAttack)
            end

            local attackModule = toolAttack:WaitForChild("Module", 5)
            if not attackModule or not attackModule:IsA("ModuleScript") then
                return missingAttackInformation(nameAttack)
            end

            local moduleScript = require(attackModule)
            if type(moduleScript) ~= "table" or type(moduleScript.Activate) ~= "function" then
                return missingAttackInformation(nameAttack)
            end

            if not isMeleeAttackEnabled(nameAttack) then return false end

            if nameAttack == "Energy Volley" then
                local dataEnergy = {
                    ["MouseHit"] = position,
                    ["FaceMouse"] = true
                }

                moduleScript.Activate(player, true, dataEnergy)
            else
                moduleScript.Activate(player)
            end

            return true
        end)

        if success then
            return result
        end

        warn("Error in execute attack: "..tostring(result))
        return false
    end

    local function equipSkill(attack, position)
        if not isMeleeAttackEnabled(attack) then return false end

        local args = {
            [1] = attack
        }

        events.equipskill:InvokeServer(unpack(args))

        return executeAttack(attack, position)
    end

    local function getMinStats()
        local min = getStrengthValue()
        if getEnergyValue() <= min then
            min = getEnergyValue()
        end
        if getDefenseValue() <= min then
            min = getDefenseValue()
        end
        if getSpeedValue() <= min then
            min = getSpeedValue()
        end
        return min
    end

    local function checkStatsFarm()
        local s, r = pcall(function()
            local statsRequired = autoFarmValues.statsRequiredStartFarm
            return (getStrengthValue() >= statsRequired) and (getEnergyValue() >= statsRequired) and (getDefenseValue() >= statsRequired) and (getSpeedValue() >= statsRequired)
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
        if autoFarmValues.autoMaxRebirth then
            local s = getMinStats()
            local rebReq = tonumber(rebirth.Value) * statsForReb

            if s >= (rebReq * rebirthsValues.multiplerRebirthBaseForMaxReb) then
                events:WaitForChild("Multireb"):InvokeServer()
            end
        elseif autoFarmValues.autoRebirth then
            local ok = events:WaitForChild("reb"):InvokeServer()
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

    local function isValidKi(percent)
        local s, r = pcall(function()
            local character = player.Character or player.CharacterAdded:Wait()
            local ki = tonumber(character.Stats.Ki.Value)
            local isValidPercent = true

            return ki >= percent
        end)
        if s then
            return r
        else
            warn("Error: "..r)
            return false
        end
    end

    local function checkQuests()
        for _, q in pairs(npcs:GetChildren()) do
            pcall(function()
                local questLiving = living:FindFirstChild(q.Name)

                if not questLiving then
                    local QUEST = q:FindFirstChild("Quest")
                    print("Iterando sobre con nombre diferente: "..q.Name)

                    if not QUEST or not QUEST.Value or isMultiBoss(QUEST.Value) then
                        error("boss is not valid")
                    end

                    questLiving = living:FindFirstChild(QUEST.Value)
                end

                local bossName = q.Name

                if questLiving then
                    local boss = questsValues.questActive[bossName]

                    if not boss then
                        boss = {nickName = questLiving.Name, stats = tonumber(questLiving.Stats.Strength.Value), name = bossName}
                    end

                    table.insert(quests, boss)
                end
            end)
        end

        table.sort(quests, function(a, b)
            return a.stats >= b.stats
        end)
    end


    local attacks = {
        {
            name = 'Energy Volley',
            event = 'voleys'
        },
    }

    -- local lastAttackTime = 0
    local ATTACK_COOLDOWN = 0.1

    local function attacksMelee(humanoid:Humanoid, myStats, pos)
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
            -- attacksEnergy(pos, humanoid)
            local plrStats = getMinStats()

            for i, melee in ipairs(meleeAttacks) do
                if humanoid.Health <= 0 or not autoFarmValues.autoFarm or not attacksValues.melee or isModeAutoTransform or not isPlayerAlive then
                    break
                end

                if isMeleeAttackEnabled(melee) and meleeAttacksRequeriments[melee] <= plrStats then
                    -- local currentTime = os.clock()
                    -- local timeSinceLastAttack = currentTime - lastAttackTime

                    -- if timeSinceLastAttack < ATTACK_COOLDOWN then
                    --     local waitTime = ATTACK_COOLDOWN - timeSinceLastAttack
                    --     task.wait(waitTime)
                    -- end

                    task.spawn(function()
                        equipSkill(melee, humanoid.RootPart.CFrame)
                    end)
                end
            end

            task.wait(ATTACK_COOLDOWN)

            -- attacksEnergy(pos, humanoid)
            isFreezeAttacksMelee = false
        end)
    end

    local function attacks(humanoid, myStats, pos)
        attacksMelee(humanoid, myStats, pos)
    end

    local function checkBoss(bossLiving)
        local success, result = pcall(function()
            return bossLiving.Humanoid.Health and bossLiving.Humanoid.Health > 0
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

        while checkBoss(bossLiving) and isPlayerAlive and autoFarmValues.autoFarm do
            local HumanoidRootPart = bossLiving:FindFirstChild("HumanoidRootPart")
            if not HumanoidRootPart then
                break
            end

            local _, e = pcall(function()
                local pos = HumanoidRootPart.CFrame
                local tpPosition = pos * CFrame.new(0, 0, tpDistance)
                -- local humanoid = player.Character:WaitForChild("Humanoid")

                if stats > 100000 and not isValidKi(30) then
                    while not isValidKi(99) and isPlayerAlive and autoFarmValues.autoFarm and bossLiving.Humanoid and bossLiving.Humanoid.Health > 0 do
                        task.spawn(function ()
                            autoCharge()
                        end)
                        tpBack(HumanoidRootPart.CFrame)
                        task.wait()
                    end
                end

                tpPlayer(tpPosition)
                task.wait()

                if isModeAutoTransform then
                    tpDistance = 50
                else
                    tpDistance = autoFarmValues.distanceTpBoss
                    attacks(bossLiving.Humanoid, stats, pos)
                end

            end)

            if e then
                if attemps >= 20 then
                    break
                end

                attemps = attemps + 1
                addLogError("Error al atacar al jefe: "..e)
                task.wait()
            end
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
                statsQuest = math.floor(statsQuest + (statsQuest / 10))
            end

            if getStrengthValue() >= statsQuest and npc and npc:FindFirstChild("HumanoidRootPart") and boss and boss:FindFirstChild("Humanoid") and boss:FindFirstChild("Humanoid").Health > 0 and executeQuest(quest.name) then
                updateLog("Seleccionando la mision con el nombre: "..quest.name)
                return quest
            end
        end
        return nil
    end

    local function selectForm()
        print("starting select form")

        if not transformsValues.autoTransform then
            return nil
        end

        local attempsForm = 1
        local maxAttempsForm = 10
        local folderStatus = player:FindFirstChild("Status")

        if not folderStatus or not autoFarmValues.autoFarm then
            return
        end

        local formValue = folderStatus:FindFirstChild("Transformation")
        local strength = getMinStats()

        for _, form in ipairs(transformsValues.transformsActives) do
            local req = formsRequeriments[form]

            if strength < req then
                continue
            end

            if events.equipskill:InvokeServer(form) or not autoFarmValues.autoFarm or not isPlayerAlive then
                if form == formValue.Value or not autoFarmValues.autoFarm or not isPlayerAlive then
                    return
                end

                print("Select form: "..form)
                isModeAutoTransform = true

                while not transformsValues.alwaysEnabledForm and not isrbxactive() and attempsForm <= maxAttempsForm and autoFarmValues.autoFarm and isPlayerAlive do
                    attempsForm = attempsForm + 1
                    updateLog("Wait for Roblox Window active("..tostring(attempsForm)..")")
                    task.wait(1)
                end

                if attempsForm == maxAttempsForm or not isPlayerAlive or not autoFarmValues.autoFarm then
                    return
                end

                attempsForm = 0
                local message = ""

                while formValue.Value ~= form and attempsForm <= maxAttempsForm and isPlayerAlive and autoFarmValues.autoFarm do
                    local ok, err = pcall(function ()
                        while not isValidKi(80) and isPlayerAlive and autoFarmValues.autoFarm do
                            updateLog("Charging energy for transformation")
                            isModeAutoTransform = false
                            autoCharge()
                            task.wait()
                        end

                        isModeAutoTransform = true

                        if transformsValues.alwaysEnabledForm then
                            message = "Execute form (not safe)"
                            events:WaitForChild("Fa"):InvokeServer()
                        else
                            message = "Execute form (anti-detect) Attemps = "..tostring(attempsForm).."/"..tostring(maxAttempsForm)
                            keypress(0x47)
                        end

                        attempsForm = attempsForm + 1
                        updateLog(message)

                        task.wait()
                    end)

                    if err then
                        updateLog("Error in form: "..err)
                        break
                    end
                end

                isModeAutoTransform = false
                return
            end
        end

        return nil
    end

    local function selectQuest(quest)
        local name = quest.name
        local bossNpc = npcs:FindFirstChild(name)
        local bossLiving = living:FindFirstChild(quest.nickName)
        local isOtherQuest = false

        for _, v in pairs(bossNotQuestSelected) do
            if name == v then
                return bossLiving
            end
        end

        for _, v in pairs(raidsValues) do
            if v.placeID == game.PlaceId then
                isOtherQuest = true
                break
            end
        end

        if isOtherQuest then
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

                if not isValidKi(20) then
                    events:WaitForChild("of"):FireServer()
                    while not isValidKi(70) and isPlayerAlive do
                        print("Esperando ki!")
                        task.spawn(autoCharge)
                        task.wait()
                    end
                    cancelAutoCharge()
                end

                if getStrengthValue() <= value then
                    task.spawn(executePunch)
                end

                if tonumber(getDefenseValue()) <= value then
                    task.spawn(executeDef)
                end

                if tonumber(getEnergyValue()) <= value then
                    task.spawn(executeKb)
                end

                if tonumber(getSpeedValue()) <= value then
                    task.spawn(executePunch)
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
        while task.wait() and isPlayerAlive do
            if autoFarmValues.autoFarm then
                succes, err = pcall(function()
                    pcall(uploadMinStatsRequired)
                    pcall(selectForm)

                    local quest

                    if #bossNotQuestSelected > 0 then
                        for _, q in pairs(bossNotQuestSelected) do
                            local boss = living:FindFirstChild(q)

                            if boss and boss:FindFirstChild("Humanoid") and boss:FindFirstChild("Humanoid").Health > 0 then
                                quest = {name = q, nickName = q}
                                break
                            end
                        end
                    elseif #priorizedQuests > 0 then
                        for _, q in pairs(priorizedQuests) do
                            local boss = living:FindFirstChild(q.nickName)

                            if boss and boss:FindFirstChild("Humanoid") and boss:FindFirstChild("Humanoid").Health > 0 then
                                quest = q
                                break
                            end
                        end
                    else
                        for bossName, v in pairs(raidsValues) do
                            if autoFarmValues[bossName] and living:FindFirstChild(v.boss) then
                                quest = {name = v.boss, nickName = v.boss}
                                break
                            end
                        end

                        if quest == nil then
                            quest = searchQuest()
                        end
                    end

                    if attempsSearchQuest >= maxAttempsSearchQuest then
                        updateLog("Waiting fot available quest!")
                        attempsSearchQuest = 0
                    end

                    if not quest then
                        attempsSearchQuest = attempsSearchQuest + 1
                        updateLog("Waiting fot available quest!")
                        -- task.wait(2)
                        -- pcall(checkQuests)
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

                if err then
                    updateLog("Internal error: "..err)
                end
            end
        end
    end

    local function onStartPlayer()
        return player.CharacterAdded:Connect(function(char)

            while char and char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health <= 0 do
                task.wait()
                print("Esperando a que reviva")
            end

            if isInfiniteRebirths then
                pcall(executeAllCodes)
            end

            alreadyStartedScript = true
            isPlayerAlive = true

            char:WaitForChild("Humanoid").Died:Connect(function()
                isPlayerAlive = false
                print("Murio")
            end)

            local _, e = pcall(onStartFarm)

            if e then
                addLogError("Main error: "..e)
            end
        end)
    end

    local function playGame()
        warn("Subiendo rebirths...")

        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild('Humanoid', 5)
        humanoid.Health = 0

        events.Start:InvokeServer()
        updateLog("Loading script...")
        local playerEvent

        playerEvent = onStartPlayer()
        local maxSeconds = 10
        local timer = tick()

        defense.Changed:Connect(function()
            executeReb()
        end)

        while not alreadyStartedScript do
            if tick() - timer >= maxSeconds then
                character = player.Character or player.CharacterAdded:Wait()

                updateLog("Loading again...")
                timer = tick()
                playerEvent:Disconnect()
                character.Humanoid.Health = 0
                playerEvent = onStartPlayer()
            end
            task.wait()
        end

        local Players = game:GetService("Players")
local ProceduralBehaviorSchedulerService = game:GetService("ProceduralBehaviorSchedulerService")
        local LocalPlayer = Players.LocalPlayer

        --if #Players:GetPlayers() > 2 then
        --    LocalPlayer:Kick("Server public detected")
        --end
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

    local autoMaxRebirth = {
        value = autoFarmValues.autoMaxRebirth,
        title = "Auto MultiReb",
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

    local rebirthOptionStats = {
        title = 'Min rebirths for exec. MultiReb',
        value = rebirthsValues.multiplerRebirthBaseForMaxReb,
        description = 'Min rebirths for exec. MaxRebirth',
        inputType = 'NUMBER',
        numberValidations = {
            minValue = 10,
            maxValue = 1000000000000,
        },
        onChange = function(value)
            rebirthsValues.multiplerRebirthBaseForMaxReb = value
            saveDataFile(fileNames.rebirthFile, rebirthsValues)
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

    local transformAlwaysMode = {
        value = transformsValues.alwaysEnabledForm,
        title = "Always enable transformation (no anti-detect)",
        description = "Disable secure mode",
        onChange = function(value)
            transformsValues.alwaysEnabledForm = value
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

    for quest, _ in pairs(raidsValues) do
        if autoFarmValues[quest] ~= nil then
            local raidValue = {
                value = autoFarmValues[quest],
                title = quest..' - Raid',

                description = quest..' Raid',

                onChange = function(value)
                    autoFarmValues[quest] = value
                    saveDataFile(fileNames.autofarm, autoFarmValues)
                end,

                onChangedTrue = function()
                end,

                onChangedFalse = function()
                end,
            }

            AutoFarm:Option(raidValue)
        end
    end

    local redeemCodesData = {
        title = "Redeem all codes",

        onClick = executeAllCodes
    }

    AutoFarm:Text(questTextValue)
    AutoFarm:Option(autoMaxRebirth)
    AutoFarm:Option(autoRebirth)
    AutoFarm:Option(tpSecureModeSlow)

    AutoFarm:Input(distanceTp)
    AutoFarm:Input(statsRequired)

    Attacks:Option(meleeOption)
    Attacks:Option(energyOption)
    createMeleeAttackOptions()

    if not isInfiniteRebirths then
        Forms:Option(transformOption)
    end

    Forms:Text(alertForms)
    Forms:Option(transformAlwaysMode)
    Forms:Options(transformOptions)

    RebirthsWindow:Input(rebirthOptionStats)

    CodesWindow:Button(redeemCodesData)

    local function addDynamicOptions()
        local bossMaps = game.Workspace:FindFirstChild("Others"):FindFirstChild("BossMaps")
        local quests = game.Workspace:FindFirstChild("Others"):FindFirstChild("NPCs"):GetChildren()

        local function getIndexBossInNotQuests(name)
            for i, q in pairs(bossNotQuestSelected) do
                if q == name then
                    return i
                end
            end

            return 0
        end

        for _, boss in pairs(living:GetChildren()) do
            if boss:FindFirstChild("HitBy") and not bossMaps:FindFirstChild(boss.Name) and not isMultiBoss(boss.Name) then
                local optionBoss = {
                    value = false,
                    title = "Kill "..boss.Name,
                    description = "Execute auto transform xd",

                    onChange = function(value)
                    end,

                    onChangedTrue = function(value)
                        table.insert(bossNotQuestSelected, boss.Name)
                    end,

                    onChangedFalse = function(value)
                        local index = getIndexBossInNotQuests(boss.Name)
                        if index == 0 then return end

                        table.remove(bossNotQuestSelected, index)
                    end,
                }

                QuestsFarm:Option(optionBoss)
            end
        end
    end

    local function addPriorizedQuestsOptions()
        for _, v in pairs(quests) do
            local option = {
                value = false,
                title = "Prioritize "..v.name,
                description = "Add Prioritize quests!",

                onChange = function(value)
                end,

                onChangedTrue = function(value)
                    table.insert(priorizedQuests, v)
                end,

                onChangedFalse = function(value)
                    for i, qv in pairs(priorizedQuests) do
                        if qv.name == v.name then
                            table.remove(priorizedQuests, i)
                            break
                        end
                    end
                end,
            }

            --TODO: add tab
            QuestsWindow:Option(option)
        end
    end

    addDynamicOptions()
    pcall(checkQuests)
    addPriorizedQuestsOptions()

    playGame()
end

task.wait(2)

pcall(function()
    local bb = game:service'VirtualUser'
    game:service'Players'.LocalPlayer.Idled:connect(function()
        bb:CaptureController()bb:ClickButton2(Vector2.new())
    end)
end)

local url = 'https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/auth.lua'
local onCheck = loadstring(game:HttpGet(url))()
onCheck(onNext, "7103e2e5-16ed-4e19-b86f-25c8ba4cb77a", "0a5c74b1-742e-491d-99a3-488add07a6db", "cdb40b55-5eca-4872-98fe-523fe2f85fd1")
