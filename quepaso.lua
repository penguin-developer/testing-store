local function onContinue(isBuyer)
    local libraryUrl = "https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/library.lua"
    local Window = loadstring(game:HttpGet(libraryUrl))()
    local plr = game:GetService("Players").LocalPlayer
    local rs = game:GetService("ReplicatedStorage")
    local package = rs:WaitForChild("Package", 5)
    local events = package:WaitForChild("Events")
    local userDatas = rs:WaitForChild("Datas"):WaitForChild(plr.UserId)
    local isUploadForms = false
    local skills = package:WaitForChild("Skills", 5)
    local forms = {} -- transformaciones ordenadas
    local formsRequeriments = {}
    local actives = {}
    local FormsTab = Window.new("Forms", "Forms")

    local uploadTextData = {
        value = "Waiting...",
    }

    local titleTextData = {
        value = "Level up your transformations and unlock new forms",
    }


    local function uploadLevelForm(form)
        local args = { form }
        local buyMs = events:FindFirstChild("BuyMasteryWzeni")

        if not buyMs then
            print("Not buy ms")
            return false
        end

        local isUploading = true
        local formData = userDatas:FindFirstChild(form)
        if not formData then return false end

        while isUploading and isUploadForms do
            print("Subiendo: "..form)

            task.spawn(function()
                local succes, err = pcall(function()
                    local currentValue = formData.Value
                    buyMs:InvokeServer(unpack(args))

                    isUploading = formData.Value > currentValue
                end)

                if err ~= nil then
                    uploadTextData.updateValue("(1s) Error: "..err)
                    task.wait(1)
                else
                    uploadTextData.updateValue("Up: ".. form)
                end
            end)

            task.wait()
        end

        return true
    end

    local function onUploadForms()
        task.spawn(function()
            while isUploadForms and task.wait(0.5) do
                for _, v in pairs(actives) do
                    local ok = uploadLevelForm(v)

                    if ok then
                        uploadTextData.updateValue("Form "..v.." Finish")
                    else
                        uploadTextData.updateValue("Form "..v.." is not valid")
                    end

                    task.wait(2)
                end
            end
        end)
    end

    for _, v in pairs(skills:GetChildren()) do
        local s, err = pcall(function()
            local requerimentsFolder = v:FindFirstChild("Requirements")

            if v:IsA("Folder") and v:FindFirstChild("Time") and requerimentsFolder and v:FindFirstChild("Gamepass") == nil then
                local statsReq = requerimentsFolder:FindFirstChild("Strength").Value
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
                table.insert(forms, v.Name)
            end
        end)

        if err ~= nil then
            warn(err)
        end
    end

    table.sort(forms, function(a, b)
        return formsRequeriments[a] > formsRequeriments[b]
    end)

    local uploadFormsSwitchOption = {
        value = false,
        title = "Start Level up transformations",
        description = "Upload level forms",

        onChange = function(value)
            isUploadForms = value
            onUploadForms()
        end,

        onChangedTrue = function(value)
        end,

        onChangedFalse = function(value)
        end,
    }

    local transformOptions = {
        defaultValue = forms,
        actives = actives,

        onChange = function(array)
            actives = array
        end,

        onDelete = function(value)
            print("Deleted = "..value)
        end,

        onAdd = function(value)
            print('Added = '..value)
        end,
    }


    FormsTab:Text(titleTextData)
    FormsTab:Options(transformOptions)
    FormsTab:Option(uploadFormsSwitchOption)
    FormsTab:Text(uploadTextData)
end

local url = 'https://raw.githubusercontent.com/penguin-developer/testing-store/refs/heads/main/auth.lua'
local onCheck = loadstring(game:HttpGet(url))()

onCheck(onContinue, 4)
