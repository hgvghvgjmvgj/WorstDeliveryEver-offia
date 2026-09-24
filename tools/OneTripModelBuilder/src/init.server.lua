--!strict

local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Builder = require(script:WaitForChild("Builder"))
local Examples = require(script:WaitForChild("Examples"))

local toolbar = plugin:CreateToolbar("ONE TRIP")
local openButton = toolbar:CreateButton(
	"Model Builder",
	"Open the ONE TRIP AI model recipe builder",
	"rbxassetid://4458901886"
)
openButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Right,
	false,
	false,
	460,
	620,
	380,
	420
)

local widget = plugin:CreateDockWidgetPluginGui("OneTripModelBuilder_v02", widgetInfo)
widget.Title = "ONE TRIP — AI Model Builder"

local root = Instance.new("Frame")
root.Size = UDim2.fromScale(1, 1)
root.BackgroundColor3 = Color3.fromRGB(24, 27, 32)
root.BorderSizePixel = 0
root.Parent = widget

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = root

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = root

local title = Instance.new("TextLabel")
title.LayoutOrder = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "ONE TRIP MODEL BUILDER"
title.TextColor3 = Color3.fromRGB(245, 247, 250)
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = root

local subtitle = Instance.new("TextLabel")
subtitle.LayoutOrder = 2
subtitle.Size = UDim2.new(1, 0, 0, 42)
subtitle.BackgroundTransparency = 1
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "Build stylized cargo recipes with automatic carry hitbox + standardized VFX anchors. M6C production examples are included below."
subtitle.TextWrapped = true
subtitle.TextColor3 = Color3.fromRGB(171, 177, 188)
subtitle.TextSize = 13
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.TextYAlignment = Enum.TextYAlignment.Top
subtitle.Parent = root

local recipeBox = Instance.new("TextBox")
recipeBox.LayoutOrder = 3
recipeBox.Size = UDim2.new(1, 0, 1, -205)
recipeBox.BackgroundColor3 = Color3.fromRGB(14, 16, 20)
recipeBox.BorderSizePixel = 0
recipeBox.ClearTextOnFocus = false
recipeBox.Font = Enum.Font.Code
recipeBox.MultiLine = true
recipeBox.Text = Examples.FridgeJSON()
recipeBox.TextColor3 = Color3.fromRGB(222, 226, 233)
recipeBox.TextSize = 12
recipeBox.TextWrapped = false
recipeBox.TextXAlignment = Enum.TextXAlignment.Left
recipeBox.TextYAlignment = Enum.TextYAlignment.Top
recipeBox.Parent = root

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = recipeBox

local exampleRow = Instance.new("Frame")
exampleRow.LayoutOrder = 4
exampleRow.Size = UDim2.new(1, 0, 0, 32)
exampleRow.BackgroundTransparency = 1
exampleRow.Parent = root

local exampleLayout = Instance.new("UIListLayout")
exampleLayout.FillDirection = Enum.FillDirection.Horizontal
exampleLayout.Padding = UDim.new(0, 6)
exampleLayout.Parent = exampleRow

local function button(text: string, widthScale: number): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(widthScale, -5, 1, 0)
	b.BackgroundColor3 = Color3.fromRGB(48, 55, 66)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamMedium
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240, 243, 247)
	b.TextSize = 11
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 5)
	c.Parent = b
	return b
end

local fridgeButton = button("FRIDGE", 0.25)
fridgeButton.Parent = exampleRow
local couchButton = button("COUCH", 0.25)
couchButton.Parent = exampleRow
local pcButton = button("PC", 0.25)
pcButton.Parent = exampleRow
local trunkButton = button("FRAGRANCE", 0.25)
trunkButton.Parent = exampleRow

local actionRow = Instance.new("Frame")
actionRow.LayoutOrder = 5
actionRow.Size = UDim2.new(1, 0, 0, 38)
actionRow.BackgroundTransparency = 1
actionRow.Parent = root

local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.Padding = UDim.new(0, 8)
actionLayout.Parent = actionRow

local validateButton = button("VALIDATE", 0.4)
validateButton.BackgroundColor3 = Color3.fromRGB(57, 80, 112)
validateButton.Parent = actionRow

local buildButton = button("BUILD MODEL", 0.6)
buildButton.BackgroundColor3 = Color3.fromRGB(43, 112, 73)
buildButton.Parent = actionRow

local status = Instance.new("TextLabel")
status.LayoutOrder = 6
status.Size = UDim2.new(1, 0, 0, 26)
status.BackgroundTransparency = 1
status.Font = Enum.Font.Gotham
status.Text = "Ready."
status.TextColor3 = Color3.fromRGB(171, 177, 188)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = root

local function setStatus(text: string, good: boolean?)
	status.Text = text
	if good == true then
		status.TextColor3 = Color3.fromRGB(102, 220, 148)
	elseif good == false then
		status.TextColor3 = Color3.fromRGB(244, 112, 112)
	else
		status.TextColor3 = Color3.fromRGB(171, 177, 188)
	end
end

local function decodeRecipe(): (any?, string?)
	local ok, decoded = pcall(function()
		return HttpService:JSONDecode(recipeBox.Text)
	end)
	if not ok then
		return nil, "Invalid JSON: " .. tostring(decoded)
	end
	return decoded, nil
end

local function loadExample(name: string, json: string)
	recipeBox.Text = json
	setStatus("Loaded M6C Common " .. name .. " recipe.", nil)
end

fridgeButton.MouseButton1Click:Connect(function() loadExample("Refrigerator",Examples.FridgeJSON()) end)
couchButton.MouseButton1Click:Connect(function() loadExample("Couch",Examples.CouchJSON()) end)
pcButton.MouseButton1Click:Connect(function() loadExample("Gaming PC",Examples.PCJSON()) end)
trunkButton.MouseButton1Click:Connect(function() loadExample("Designer Fragrance Trunk",Examples.TrunkJSON()) end)

validateButton.MouseButton1Click:Connect(function()
	local recipe, err = decodeRecipe()
	if not recipe then
		setStatus(err or "Invalid recipe.", false)
		return
	end
	local ok, message = Builder.Validate(recipe)
	setStatus(message, ok)
end)

buildButton.MouseButton1Click:Connect(function()
	local recipe, err = decodeRecipe()
	if not recipe then
		setStatus(err or "Invalid recipe.", false)
		return
	end
	local valid, message = Builder.Validate(recipe)
	if not valid then
		setStatus(message, false)
		return
	end

	local recording = nil
	pcall(function()
		recording = ChangeHistoryService:TryBeginRecording("ONE TRIP Build Model")
	end)

	local ok, result = pcall(function()
		return Builder.Build(recipe)
	end)

	if recording then
		pcall(function()
			ChangeHistoryService:FinishRecording(
				recording,
				if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel
			)
		end)
	else
		pcall(function()
			ChangeHistoryService:SetWaypoint("ONE TRIP Build Model")
		end)
	end

	if ok then
		setStatus("Built " .. result.Name .. " and selected it in Workspace.", true)
	else
		setStatus("Build failed: " .. tostring(result), false)
	end
end)

openButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

plugin.Unloading:Connect(function()
	widget.Enabled = false
end)
