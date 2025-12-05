return function(onCallback, ...)
    local productsIds = {...}

	local auth_dvs = Instance.new("ScreenGui")
	local container = Instance.new("Frame")
	local title = Instance.new("Frame")
	local value = Instance.new("TextLabel")
	local auth_component = Instance.new("Frame")
	local text = Instance.new("TextLabel")
	local key = Instance.new("TextBox")
	local btn = Instance.new("TextButton")

	auth_dvs.Name = "auth_dvs"
	auth_dvs.Parent = game.CoreGui
	auth_dvs.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	container.Name = "container"
	container.Parent = auth_dvs
	container.AnchorPoint = Vector2.new(0.5, 0.5)
	container.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
	container.BorderColor3 = Color3.fromRGB(0, 0, 0)
	container.BorderSizePixel = 0
	container.Position = UDim2.new(0.5, 0, 0.400000006, 0)
	container.Size = UDim2.new(0.300000012, 0, 0.550000012, 0)

	title.Name = "title"
	title.Parent = container
	title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Size = UDim2.new(1, 0, 0.100000001, 0)

	value.Name = "value"
	value.Parent = title
	value.AnchorPoint = Vector2.new(0.5, 0)
	value.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	value.BorderColor3 = Color3.fromRGB(0, 0, 0)
	value.BorderSizePixel = 0
	value.Position = UDim2.new(0.5, 0, 0, 0)
	value.Size = UDim2.new(0.899999976, 0, 1, 0)
	value.Font = Enum.Font.Unknown
	value.Text = "DevComplete Studios - Authentication"
	value.TextColor3 = Color3.fromRGB(255, 255, 255)
	value.TextScaled = true
	value.TextSize = 14.000
	value.TextWrapped = true

	auth_component.Name = "auth_component"
	auth_component.Parent = container
	auth_component.AnchorPoint = Vector2.new(0.5, 0.5)
	auth_component.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	auth_component.BorderColor3 = Color3.fromRGB(0, 0, 0)
	auth_component.BorderSizePixel = 0
	auth_component.Position = UDim2.new(0.5, 0, 0.5, 0)
	auth_component.Size = UDim2.new(0.948000014, 0, 0.400000006, 0)

	text.Name = "text"
	text.Parent = auth_component
	text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	text.BackgroundTransparency = 1.000
	text.BorderColor3 = Color3.fromRGB(0, 0, 0)
	text.BorderSizePixel = 0
	text.Size = UDim2.new(1, 0, 0.200000003, 0)
	text.Font = Enum.Font.SourceSans
	text.Text = "Enter your key:"
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextScaled = true
	text.TextSize = 14.000
	text.TextWrapped = true

	key.Name = "key"
	key.Parent = auth_component
	key.AnchorPoint = Vector2.new(0.5, 0.5)
	key.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	key.BorderColor3 = Color3.fromRGB(0, 0, 0)
	key.BorderSizePixel = 0
	key.Position = UDim2.new(0.5, 0, 0.449999988, 0)
	key.Size = UDim2.new(1, 0, 0.200000003, 0)
	key.Font = Enum.Font.Unknown
	key.PlaceholderColor3 = Color3.fromRGB(158, 158, 158)
	key.PlaceholderText = "Enter key:"
	key.Text = ""
	key.TextColor3 = Color3.fromRGB(255, 255, 255)
	key.TextScaled = true
	key.TextSize = 14.000
	key.TextWrapped = true

	btn.Name = "btn"
	btn.Parent = auth_component
	btn.AnchorPoint = Vector2.new(0.5, 0.5)
	btn.BackgroundColor3 = Color3.fromRGB(0, 24, 238)
	btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.Position = UDim2.new(0.5, 0, 0.850000024, 0)
	btn.Size = UDim2.new(0.600000024, 0, 0.200000003, 0)
	btn.Font = Enum.Font.SourceSans
	btn.Text = "Check key"
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.TextSize = 14.000
	btn.TextWrapped = true

	local function MFRXGS_fake_script() -- btn.onClick 
		local script = Instance.new('LocalScript', btn)

		local btn = script.Parent
		local attempts = 0
		local maxAttempts = 8
		local robloxId = game:GetService('Players').LocalPlayer.UserId
		local httpService = game:GetService('HttpService')
		local isLoading = false


		local function createAlert(message, duration)
			local timeDuration = duration or 3

			game.StarterGui:SetCore("SendNotification", {
				Title = "NotificaciÃ³n",
				Text = message,
				Duration = timeDuration,
			})
		end

		local function handleValidationAccess()
			if isLoading then
				return
			end

			if attempts >= maxAttempts then
				createAlert('You exceeded the maximum number of attempts', 2)
				return
			end

			isLoading = true

            local ids = table.concat(productsIds, ",")

			local apiUrl = 'https://devstudios-go.up.railway.app/api/orders/is-buyer'
			local params = '?id='..robloxId..'&product='..ids..'&key='..key.Text
			local url = apiUrl..params

			local response = request(
				{
					Url = url,
					Method = "GET",
					Headers = {
						["Content-Type"] = "application/json"
					},
				}
			)

			local body = httpService:JSONDecode(response.Body)

			if not body then
				isLoading = false
				attempts = attempts + 1
				createAlert('Internal server error, try again later.')
				return
			end

			if body.error then
				isLoading = false
				attempts = attempts + 1
				createAlert(body.error, 2)
				return
			end

			if body.buyer ~= nil then
				isLoading = false
				attempts = attempts + 1
				createAlert('User authenticated!', 5)
				btn.Parent.Parent.Parent:Destroy()

				onCallback(body.buyer)
				return
			end

			createAlert('Internal server error, try again later.')
			isLoading = false
			attempts = attempts + 1
		end

		handleValidationAccess()
		btn.MouseButton1Click:Connect(handleValidationAccess)

	end
	coroutine.wrap(MFRXGS_fake_script)()
end
