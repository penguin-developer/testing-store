local ui_library_prod = Instance.new("ScreenGui")
local slider = Instance.new("Frame")
local onClick = Instance.new("TextButton")
local main = Instance.new("Frame")
local navBar = Instance.new("ScrollingFrame")
local container = Instance.new("Frame")
local onViewDescription = Instance.new("TextLabel")

ui_library_prod.Name = "ui_library_prod"
ui_library_prod.Parent = game.CoreGui
ui_library_prod.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

slider.Name = "slider"
slider.Parent = ui_library_prod
slider.AnchorPoint = Vector2.new(0.5, 0.5)
slider.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
slider.BorderSizePixel = 0
slider.Position = UDim2.new(0.5, 0, 0.25, 0)
slider.Size = UDim2.new(0.349999994, 0, 0.0340000018, 0)

onClick.Name = "onClick"
onClick.Parent = slider
onClick.AnchorPoint = Vector2.new(1, 0.5)
onClick.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
onClick.BorderColor3 = Color3.fromRGB(0, 0, 0)
onClick.BorderSizePixel = 0
onClick.Position = UDim2.new(1, 0, 0.5, 0)
onClick.Size = UDim2.new(0.0700000003, 0, 1, 0)
onClick.Font = Enum.Font.SourceSans
onClick.Text = ""
onClick.TextColor3 = Color3.fromRGB(0, 0, 0)
onClick.TextSize = 14.000

main.Name = "main"
main.Parent = slider
main.AnchorPoint = Vector2.new(0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BackgroundTransparency = 0.500
main.BorderColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Position = UDim2.new(0.5, 0, 1, 0)
main.Size = UDim2.new(1, 0, 12, 0)
main.Visible = false

navBar.Name = "navBar"
navBar.Parent = main
navBar.Active = true
navBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
navBar.BackgroundTransparency = 0.500
navBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
navBar.BorderSizePixel = 0
navBar.Size = UDim2.new(0.200000003, 0, 1, 0)
navBar.CanvasSize = UDim2.new(0, 0, 1, 0)

container.Name = "container"
container.Parent = main
container.AnchorPoint = Vector2.new(1, 0.5)
container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
container.BackgroundTransparency = 1.000
container.BorderColor3 = Color3.fromRGB(0, 0, 0)
container.BorderSizePixel = 0
container.Position = UDim2.new(1, 0, 0.5, 0)
container.Size = UDim2.new(0.800000012, 0, 1, 0)

onViewDescription.Name = "onViewDescription"
onViewDescription.Parent = ui_library_prod
onViewDescription.AnchorPoint = Vector2.new(0.5, 0.5)
onViewDescription.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
onViewDescription.BackgroundTransparency = 0.500
onViewDescription.BorderColor3 = Color3.fromRGB(0, 0, 0)
onViewDescription.BorderSizePixel = 0
onViewDescription.Position = UDim2.new(0.5, 0, 0.5, 0)
onViewDescription.Size = UDim2.new(0.150000006, 0, 0.0599999987, 0)
onViewDescription.Visible = false
onViewDescription.Font = Enum.Font.Unknown
onViewDescription.TextColor3 = Color3.fromRGB(255, 255, 255)
onViewDescription.TextScaled = true
onViewDescription.TextSize = 14.000
onViewDescription.TextWrapped = true

local function onHandleFlag()
	slider.Active = true
	slider.Draggable = true

	local function handleClick()
		main.Visible = not main.Visible
	end

	onClick.MouseButton1Click:Connect(handleClick)
end

onHandleFlag()



local components = {
	spaceY = function(parent)
		local paddingY = Instance.new("Frame")
		local paddingY_2 = Instance.new("Frame")

		paddingY.Name = "paddingYTop"
		paddingY.Parent = parent
		paddingY.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		paddingY.BackgroundTransparency = 1.000
		paddingY.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paddingY.BorderSizePixel = 0
		paddingY.Size = UDim2.new(1, 0, 0.00999999978, 0)

		paddingY_2.Name = "paddingYBottom"
		paddingY_2.Parent = parent
		paddingY_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		paddingY_2.BackgroundTransparency = 1.000
		paddingY_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		paddingY_2.BorderSizePixel = 0
		paddingY_2.LayoutOrder = 999
		paddingY_2.Size = UDim2.new(1, 0, 0.00999999978, 0)
	end,

	order = function(parent, padding)
		local padding = padding or 5
		local order = Instance.new("UIListLayout")

		order.Name = "order"
		order.Parent = parent
		order.HorizontalAlignment = Enum.HorizontalAlignment.Center
		order.SortOrder = Enum.SortOrder.LayoutOrder
		order.Padding = UDim.new(0, padding)
		return order
	end,

	border = function(parent, rounded)
		local rounded = rounded or 0.1
		local border = Instance.new("UICorner")

		border.CornerRadius = UDim.new(rounded, 0)
		border.Name = "border"
		border.Parent = parent
	end,

	scrollingFrame = function(name, parent, autoSize)
		local autoSize = autoSize or Enum.AutomaticSize.Y
		local windowFrame = Instance.new("ScrollingFrame")

		windowFrame.Name = name
		windowFrame.Parent = parent
		windowFrame.Active = true
		windowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		windowFrame.BackgroundTransparency = 1.000
		windowFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		windowFrame.BorderSizePixel = 0
		windowFrame.Size = UDim2.new(1, 0, 1, 0)
		windowFrame.Visible = false
		windowFrame.CanvasSize = UDim2.new(0, 0, 1, 0)
		windowFrame.AutomaticCanvasSize = autoSize

		return windowFrame
	end,

}


local navOrder = components.order(navBar, 4)
navOrder.HorizontalAlignment = Enum.HorizontalAlignment.Left


local shared = {

	onError = function(message, title, duration)
		game:GetService("StarterGui"):SetCore("SendNotification",{
			Title = title or 'Error!', -- Required
			Text = message, -- Required
			duration = duration or 6,
		})
	end,

}

local logic = {

	input = function(data, input)
		local title = input.title
		local inputValue = input.inputValue
		local text = input.write.TextBox

		title.Text = data.title

		local errors = {
			number = nil,
			text = nil,
		}

		text.Text = data.value

		local function evaluateErrors()
			if errors.number ~= nil then
				shared.onError(errors.number)
				text.Text = data.value

				if data.onError then
					data.onError(errors.number, data.value)
				end
			elseif errors.text ~= nil then
				shared.onError(errors.text)
				text.Text = data.value
			end
		end

		local function getValueNumber(value)
			if data.inputType ~= 'NUMBER' or value:gsub(' ', '') == '' then return end

			local numberValue = value:gsub("[^%d]", "")
			text.Text = numberValue
			numberValue = tonumber(numberValue)

			if not numberValue or typeof(numberValue) ~= 'number' then
				errors.number = 'Value is not valid'
			elseif data.numberValidations and data.numberValidations.maxValue and numberValue > data.numberValidations.maxValue then
				errors.number = 'The number must be less than '..tostring(data.numberValidations.maxValue)
			elseif data.numberValidations and data.numberValidations.minValue and numberValue <= data.numberValidations.minValue then
				errors.number = 'The number must be greater than '..tostring(data.numberValidations.minValue)
			else
				errors.number = nil
				if data.onChange then
					data.onChange(numberValue)
				end
			end
		end

		local function getValueText(value)
			if  data.inputType ~= 'STRING' then return end
		end


		local function checkText()
			local value = text.Text
			getValueNumber(value)
		end


		text:GetPropertyChangedSignal('Text'):Connect(checkText)
		text.FocusLost:Connect(evaluateErrors)
	end,

	option = function(data, option)
		local btn = option:WaitForChild('btn'):WaitForChild('slider')
		local frame = btn:WaitForChild('onClick')
		local positionActive = UDim2.new(0.98, 0, 0.5, 0)
		local positionDisabled = UDim2.new(0.52, 0, 0.5, 0)
		local txt = option:WaitForChild('title')
		local value = data.value
		local duration = 0.04

		local function onDetectValue()
			if value then
				frame.BackgroundTransparency = 0
				txt.TextTransparency = 0
				frame:TweenPosition(positionActive, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, duration)
			else
				frame.BackgroundTransparency = 0.35
				txt.TextTransparency = 0.4
				frame:TweenPosition(positionDisabled, Enum.EasingDirection.InOut, Enum.EasingStyle.Linear, duration)
			end
		end

		txt.Text = data.title
		onDetectValue()

		btn.MouseButton1Click:Connect(function()
			value = not value
			data.onChange(value)

			if value then
				data.onChangedTrue()
			else
				data.onChangedFalse()
			end

			onDetectValue()
		end)
	end,

	options = function(data, frame)
		local values = frame:WaitForChild('values')
		local active = values:WaitForChild('active')
		local disabled = values:WaitForChild('disabled')

		local function sortByOriginalOrder(elements, originalOrder)
			table.sort(elements, function(a, b)
				local aIndex = table.find(originalOrder, a)
				local bIndex = table.find(originalOrder, b)

				if aIndex and bIndex then
					return aIndex < bIndex
				elseif aIndex then
					return true
				elseif bIndex then
					return false
				else
					return a < b
				end
			end)
			return elements
		end

		function clearElementByName(name, frame)
			for _, v in pairs(frame:GetChildren()) do
				if v:IsA('TextButton') and string.lower(v.Name) == string.lower(name) then
					v:Destroy()
				end
			end
		end

		local function reorderButtons(frame, originalOrder)
			local buttons = {}
			for _, v in pairs(frame:GetChildren()) do
				if v:IsA('TextButton') then
					table.insert(buttons, v.Name)
				end
			end

			buttons = sortByOriginalOrder(buttons, originalOrder)

			for index, btnName in ipairs(buttons) do
				for _, btn in pairs(frame:GetChildren()) do
					if btn:IsA('TextButton') and btn.Name == btnName then
						btn.LayoutOrder = index
					end
				end
			end
		end

		local function simpleBtn(isActive, text)
			local btn = Instance.new("TextButton")
			local border = Instance.new("UICorner")

			btn.Name = text
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(0.920000017, 0, 0.200000003, 0)
			btn.Font = Enum.Font.Roboto
			btn.Text = text
			btn.TextColor3 = Color3.fromRGB(0, 0, 0)
			btn.TextScaled = true
			btn.TextSize = 14.000
			btn.TextWrapped = true

			if isActive then
				btn.Parent = active
				btn.BackgroundTransparency = 0
			else
				btn.Parent = disabled
				btn.BackgroundTransparency = 0.4
			end

			border.CornerRadius = UDim.new(0, 4)
			border.Name = "border"
			border.Parent = btn
			return btn
		end

		function updateCallback()
			local activeElements = {}
			for _, v in pairs(active:GetChildren()) do
				if v:IsA('TextButton') then
					table.insert(activeElements, v.Name)
				end
			end

			activeElements = sortByOriginalOrder(activeElements, data.defaultValue)
			data.onChange(activeElements)
		end

		function addBtnActive(value)
			clearElementByName(value, disabled)
			local btn = simpleBtn(true, value)
			local event

			event = btn.MouseButton1Click:Connect(function()
				addBtnDisabled(value)
				event:Disconnect()
				data.onDelete(value)
				updateCallback()
			end)

			reorderButtons(active, data.defaultValue)
			data.onAdd(value)
			updateCallback()
		end

		function addBtnDisabled(value)
			clearElementByName(value, active)
			local btn = simpleBtn(false, value)
			local event

			event = btn.MouseButton1Click:Connect(function()
				addBtnActive(value)
				event:Disconnect()
			end)

			reorderButtons(disabled, data.defaultValue)
			updateCallback()
		end

		function initializeUI()
			for _, container in pairs({active, disabled}) do
				for _, v in pairs(container:GetChildren()) do
					if v:IsA('TextButton') then
						v:Destroy()
					end
				end
			end

			local activeElements = {}
			for _, v in pairs(data.actives) do
				table.insert(activeElements, v)
			end
			activeElements = sortByOriginalOrder(activeElements, data.defaultValue)

			for _, v in pairs(activeElements) do
				addBtnActive(v)
			end

			local disabledElements = {}
			for _, v in pairs(data.defaultValue) do
				if not table.find(data.actives, v) then
					table.insert(disabledElements, v)
				end
			end
			disabledElements = sortByOriginalOrder(disabledElements, data.defaultValue)

			for _, v in pairs(disabledElements) do
				addBtnDisabled(v)
			end

			reorderButtons(active, data.defaultValue)
			reorderButtons(disabled, data.defaultValue)

			updateCallback()
		end

		for _, container in pairs({active, disabled}) do
			local existingLayout = container:FindFirstChildOfClass("UIListLayout")
			if not existingLayout then
				local layout = Instance.new("UIListLayout")
				layout.Padding = UDim.new(0, 5)
				layout.SortOrder = Enum.SortOrder.LayoutOrder
				layout.Parent = container
			end
		end

		initializeUI()
	end,

	text = function(data, parent)
		local content = parent.content

		content.Text = data.value

		data.updateValue = function(message)
			content.Text = message
		end
	end,

	tab = function(name)
		for _,f in pairs(container:GetChildren()) do
			if f:IsA('Frame') or f:IsA('ScrollingFrame') then
				local btn = navBar:FindFirstChild(f.Name)

				if string.lower(f.Name) == name then
					f.Visible = true
					btn.TextTransparency = 0
				else
					f.Visible = false
					btn.TextTransparency = 0.5				
				end
			end
		end
	end,

}


local Window = {}
Window.__index = Window

function Window.new(name, title)
	local self = setmetatable({}, Window)

	-- Detalles del window
	local name = string.lower(name)
	local title = title or name
	local windowFrame = components.scrollingFrame(name, container)

	local tab = Instance.new("TextButton")

	tab.Name = name
	tab.Parent = navBar
	tab.BackgroundColor3 = Color3.fromRGB(0, 37, 116)
	tab.BackgroundTransparency = 1.000
	tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
	tab.BorderSizePixel = 0
	tab.Size = UDim2.new(0.879999995, 0, 0.119999997, 0)
	tab.Font = Enum.Font.Roboto
	tab.Text = title
	tab.TextColor3 = Color3.fromRGB(255, 255, 255)
	tab.TextScaled = true
	tab.TextSize = 14.000
	tab.TextTransparency = 0.500
	tab.TextWrapped = true

	tab.MouseButton1Click:Connect(function()
		logic.tab(name)
	end)

	components.spaceY(windowFrame)
	components.order(windowFrame)

	self.window = windowFrame
	self.tab = tab
	self.name = name

	return self
end

function Window:Input(data)
	local window = self.window

	local input = Instance.new("Frame")
	local title = Instance.new("TextLabel")
	local write = Instance.new("Frame")
	local TextBox = Instance.new("TextBox")
	local inputValue = Instance.new("TextLabel")

	input.Name = "input"
	input.Parent = window
	input.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	input.BackgroundTransparency = 0.600
	input.BorderColor3 = Color3.fromRGB(0, 0, 0)
	input.BorderSizePixel = 0
	input.Size = UDim2.new(0.980000019, 0, 0.25, 0)

	title.Name = "title"
	title.Parent = input
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1.000
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Position = UDim2.new(0.300000012, 0, 0.699999988, 0)
	title.Size = UDim2.new(0.5, 0, 0.449999988, 0)
	title.Font = Enum.Font.Unknown
	title.Text = "Default Text"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.TextSize = 14.000
	title.TextWrapped = true

	write.Name = "write"
	write.Parent = input
	write.AnchorPoint = Vector2.new(1, 0.5)
	write.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	write.BorderColor3 = Color3.fromRGB(0, 0, 0)
	write.BorderSizePixel = 0
	write.Position = UDim2.new(0.980000019, 0, 0.699999988, 0)
	write.Size = UDim2.new(0.400000006, 0, 0.449999988, 0)
	components.border(write, 0.4)

	TextBox.Parent = write
	TextBox.AnchorPoint = Vector2.new(0.5, 0.5)
	TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
	TextBox.BorderSizePixel = 0
	TextBox.Position = UDim2.new(0.5, 0, 0.5, 0)
	TextBox.Size = UDim2.new(0.980000019, 0, 0.899999976, 0)
	TextBox.Font = Enum.Font.SourceSansBold
	TextBox.Text = "Enter value:"
	TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	TextBox.TextScaled = true
	TextBox.TextSize = 14.000
	TextBox.TextTransparency = 0.500
	TextBox.TextWrapped = true
	components.border(TextBox, 0.4)

	inputValue.Name = "inputValue"
	inputValue.Parent = input
	inputValue.AnchorPoint = Vector2.new(0.5, 0)
	inputValue.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	inputValue.BackgroundTransparency = 0.500
	inputValue.BorderColor3 = Color3.fromRGB(0, 0, 0)
	inputValue.BorderSizePixel = 0
	inputValue.Position = UDim2.new(0.5, 0, 0.0500000007, 0)
	inputValue.Size = UDim2.new(0.920000017, 0, 0.300000012, 0)
	inputValue.Font = Enum.Font.SourceSansBold
	inputValue.Text = "value: 99M"
	inputValue.TextColor3 = Color3.fromRGB(0, 255, 30)
	inputValue.TextScaled = true
	inputValue.TextSize = 14.000
	inputValue.TextWrapped = true

	--TODO: hacer validaciones de la data
	logic.input(data, input)
end

function Window:Option(data)
	local window = self.window

	local option = Instance.new("Frame")
	local title = Instance.new("TextLabel")
	local btn = Instance.new("Frame")
	local slider = Instance.new("TextButton")
	local onClick = Instance.new("Frame")

	option.Name = "option"
	option.Parent = window
	option.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	option.BackgroundTransparency = 0.600
	option.BorderColor3 = Color3.fromRGB(0, 0, 0)
	option.BorderSizePixel = 0
	option.Size = UDim2.new(0.980000019, 0, 0.150000006, 0)
	components.border(option, 0.1)

	title.Name = "title"
	title.Parent = option
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	title.BackgroundTransparency = 1.000
	title.BorderColor3 = Color3.fromRGB(0, 0, 0)
	title.BorderSizePixel = 0
	title.Position = UDim2.new(0.300000012, 0, 0.5, 0)
	title.Size = UDim2.new(0.5, 0, 0.699999988, 0)
	title.Font = Enum.Font.Unknown
	title.Text = "Default Text"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.TextSize = 14.000
	title.TextWrapped = true

	btn.Name = "btn"
	btn.Parent = option
	btn.AnchorPoint = Vector2.new(1, 0.5)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundTransparency = 1.000
	btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
	btn.BorderSizePixel = 0
	btn.Position = UDim2.new(0.949999988, 0, 0.5, 0)
	btn.Size = UDim2.new(0.25, 0, 0.899999976, 0)

	slider.Name = "slider"
	slider.Parent = btn
	slider.AnchorPoint = Vector2.new(0.5, 0.5)
	slider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
	slider.BorderSizePixel = 0
	slider.Position = UDim2.new(0.5, 0, 0.5, 0)
	slider.Size = UDim2.new(0.600000024, 0, 0.699999988, 0)
	slider.Font = Enum.Font.SourceSans
	slider.Text = ""
	slider.TextColor3 = Color3.fromRGB(0, 0, 0)
	slider.TextSize = 14.000
	components.border(slider, 0.8)

	onClick.Name = "onClick"
	onClick.Parent = slider
	onClick.AnchorPoint = Vector2.new(1, 0.5)
	onClick.BackgroundColor3 = Color3.fromRGB(1, 255, 43)
	onClick.BorderColor3 = Color3.fromRGB(0, 0, 0)
	onClick.BorderSizePixel = 0
	onClick.Position = UDim2.new(0.980000019, 0, 0.5, 0)
	onClick.Size = UDim2.new(0.449999988, 0, 0.899999976, 0)
	components.border(onClick, 1)

	logic.option(data, option)
end

function Window:Options(data)
	local window = self.window

	local optionsTest = Instance.new("Frame")
	local messages = Instance.new("Frame")
	local active = Instance.new("TextLabel")
	local active_2 = Instance.new("TextLabel")
	local values = Instance.new("Frame")
	local active_3 = components.scrollingFrame('active', values)
	local disabled = components.scrollingFrame('disabled', values)

	optionsTest.Name = "optionsTest"
	optionsTest.Parent = window
	optionsTest.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	optionsTest.BackgroundTransparency = 0.600
	optionsTest.BorderColor3 = Color3.fromRGB(0, 0, 0)
	optionsTest.BorderSizePixel = 0
	optionsTest.Size = UDim2.new(0.980000019, 0, 0.600000024, 0)

	messages.Name = "messages"
	messages.Parent = optionsTest
	messages.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	messages.BackgroundTransparency = 1.000
	messages.BorderColor3 = Color3.fromRGB(0, 0, 0)
	messages.BorderSizePixel = 0
	messages.Size = UDim2.new(1, 0, 0.200000003, 0)

	active.Name = "active"
	active.Parent = messages
	active.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	active.BackgroundTransparency = 0.600
	active.BorderColor3 = Color3.fromRGB(0, 0, 0)
	active.BorderSizePixel = 0
	active.Size = UDim2.new(0.49000001, 0, 1, 0)
	active.Font = Enum.Font.SourceSansBold
	active.Text = "Active"
	active.TextColor3 = Color3.fromRGB(38, 255, 0)
	active.TextScaled = true
	active.TextSize = 14.000
	active.TextWrapped = true

	active_2.Name = "active"
	active_2.Parent = messages
	active_2.AnchorPoint = Vector2.new(1, 0)
	active_2.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	active_2.BackgroundTransparency = 0.600
	active_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
	active_2.BorderSizePixel = 0
	active_2.Position = UDim2.new(1, 0, 0, 0)
	active_2.Size = UDim2.new(0.49000001, 0, 1, 0)
	active_2.Font = Enum.Font.SourceSansBold
	active_2.Text = "Disabled"
	active_2.TextColor3 = Color3.fromRGB(255, 0, 4)
	active_2.TextScaled = true
	active_2.TextSize = 14.000
	active_2.TextWrapped = true

	values.Name = "values"
	values.Parent = optionsTest
	values.AnchorPoint = Vector2.new(0.5, 1)
	values.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	values.BackgroundTransparency = 1.000
	values.BorderColor3 = Color3.fromRGB(0, 0, 0)
	values.BorderSizePixel = 0
	values.Position = UDim2.new(0.5, 0, 1, 0)
	values.Size = UDim2.new(1, 0, 0.800000012, 0)

	active_3.Visible = true
	active_3.Size = UDim2.new(0.495, 0,1, 0)
	active_3.Position = UDim2.new(0, 0,0, 0)

	disabled.Visible = true
	disabled.Size = UDim2.new(0.495, 0,1, 0)
	disabled.Position = UDim2.new(0.52, 0,0, 0)

	local orderActive = components.order(active_3)
	orderActive.HorizontalAlignment = Enum.HorizontalAlignment.Left

	local orderDisabled = components.order(disabled)
	orderDisabled.HorizontalAlignment = Enum.HorizontalAlignment.Left

	logic.options(data, optionsTest)
end

function Window:Text(data)
	local window = self.window
	local text = Instance.new("Frame")
	local content = Instance.new("TextLabel")

	text.Name = "text"
	text.Parent = window
	text.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	text.BackgroundTransparency = 0.200
	text.BorderColor3 = Color3.fromRGB(0, 0, 0)
	text.BorderSizePixel = 0
	text.Size = UDim2.new(0.980000019, 0, 0.100000001, 0)
	components.border(text, 0.2)

	content.Name = "content"
	content.Parent = text
	content.AnchorPoint = Vector2.new(0.5, 0)
	content.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	content.BackgroundTransparency = 1.000
	content.BorderColor3 = Color3.fromRGB(0, 0, 0)
	content.BorderSizePixel = 0
	content.Position = UDim2.new(0.5, 0, 0.0500000007, 0)
	content.Size = UDim2.new(0.899999976, 0, 0.899999976, 0)
	content.Font = Enum.Font.SourceSansBold
	content.Text = "Enter Stats: 99M"
	content.TextColor3 = Color3.fromRGB(60, 255, 0)
	content.TextScaled = true
	content.TextSize = 14.000
	content.TextWrapped = true
	logic.text(data, text)
end




return Window
