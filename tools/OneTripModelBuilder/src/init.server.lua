--!strict

local HttpService = game:GetService("HttpService")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

local Builder = require(script:WaitForChild("Builder"))
local Examples = require(script:WaitForChild("Examples"))
local CreatorStoreImporter = require(script:WaitForChild("CreatorStoreImporter"))

local toolbar = plugin:CreateToolbar("ONE TRIP")
local openButton = toolbar:CreateButton("Model Builder","Open the ONE TRIP cargo production tools","rbxassetid://4458901886")
openButton.ClickableWhenViewportHidden = true

local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Right,false,false,480,760,400,520)
local widget = plugin:CreateDockWidgetPluginGui("OneTripModelBuilder_v03",widgetInfo)
widget.Title = "ONE TRIP — Cargo Production"

local root = Instance.new("ScrollingFrame")
root.Size = UDim2.fromScale(1,1)
root.CanvasSize = UDim2.fromOffset(0,940)
root.ScrollBarThickness = 6
root.BackgroundColor3 = Color3.fromRGB(24,27,32)
root.BorderSizePixel = 0
root.Parent = widget

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0,12)
padding.PaddingBottom = UDim.new(0,12)
padding.PaddingLeft = UDim.new(0,12)
padding.PaddingRight = UDim.new(0,12)
padding.Parent = root

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0,8)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = root

local function label(text: string, height: number, bold: boolean?): TextLabel
	local value = Instance.new("TextLabel")
	value.Size = UDim2.new(1,0,0,height)
	value.BackgroundTransparency = 1
	value.Font = if bold then Enum.Font.GothamBold else Enum.Font.Gotham
	value.Text = text
	value.TextWrapped = true
	value.TextColor3 = if bold then Color3.fromRGB(245,247,250) else Color3.fromRGB(171,177,188)
	value.TextSize = if bold then 17 else 12
	value.TextXAlignment = Enum.TextXAlignment.Left
	value.TextYAlignment = Enum.TextYAlignment.Top
	value.Parent = root
	return value
end

local function button(text: string, widthScale: number, color: Color3?): TextButton
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(widthScale,-5,1,0)
	b.BackgroundColor3 = color or Color3.fromRGB(48,55,66)
	b.BorderSizePixel = 0
	b.Font = Enum.Font.GothamMedium
	b.Text = text
	b.TextColor3 = Color3.fromRGB(240,243,247)
	b.TextSize = 11
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,5)
	c.Parent = b
	return b
end

local title = label("ONE TRIP CARGO PRODUCTION",30,true)
title.LayoutOrder = 1
local subtitle = label("M6C.1 proof: Creator Store import + existing JSON model recipes. Imported production assets are sanitized and stored in ServerStorage/OneTripImportedAssets.",52,false)
subtitle.LayoutOrder = 2

local importTitle = label("CREATOR STORE IMPORT PROOF",24,true)
importTitle.LayoutOrder = 3

local importHelp = label("Approved IDs: Couch 10710790394 • Refrigerator 482124502 • ArcadeCabinet 105044479380665. Imported assets are treated as untrusted visual input.",48,false)
importHelp.LayoutOrder = 4

local selectedCargo = Instance.new("TextBox")
selectedCargo.LayoutOrder = 5
selectedCargo.Size = UDim2.new(1,0,0,34)
selectedCargo.BackgroundColor3 = Color3.fromRGB(14,16,20)
selectedCargo.BorderSizePixel = 0
selectedCargo.ClearTextOnFocus = false
selectedCargo.Font = Enum.Font.Code
selectedCargo.Text = "Couch"
selectedCargo.PlaceholderText = "Couch / Refrigerator / ArcadeCabinet"
selectedCargo.TextColor3 = Color3.fromRGB(230,233,239)
selectedCargo.TextSize = 13
selectedCargo.Parent = root
local cargoCorner = Instance.new("UICorner")
cargoCorner.CornerRadius = UDim.new(0,6)
cargoCorner.Parent = selectedCargo

local importRow1 = Instance.new("Frame")
importRow1.LayoutOrder = 6
importRow1.Size = UDim2.new(1,0,0,36)
importRow1.BackgroundTransparency = 1
importRow1.Parent = root
local importLayout1 = Instance.new("UIListLayout")
importLayout1.FillDirection = Enum.FillDirection.Horizontal
importLayout1.Padding = UDim.new(0,8)
importLayout1.Parent = importRow1
local importAllButton = button("IMPORT APPROVED ASSETS",0.5,Color3.fromRGB(46,100,72))
importAllButton.Parent = importRow1
local importSelectedButton = button("IMPORT SELECTED",0.5,Color3.fromRGB(57,80,112))
importSelectedButton.Parent = importRow1

local importRow2 = Instance.new("Frame")
importRow2.LayoutOrder = 7
importRow2.Size = UDim2.new(1,0,0,36)
importRow2.BackgroundTransparency = 1
importRow2.Parent = root
local importLayout2 = Instance.new("UIListLayout")
importLayout2.FillDirection = Enum.FillDirection.Horizontal
importLayout2.Padding = UDim.new(0,8)
importLayout2.Parent = importRow2
local rebuildButton = button("REBUILD SELECTED",0.5,Color3.fromRGB(121,77,47))
rebuildButton.Parent = importRow2
local reviewButton = button("OPEN REVIEW GALLERY",0.5,Color3.fromRGB(89,65,126))
reviewButton.Parent = importRow2

local importStatus = label("Ready to import. If Roblox rejects a public third-party asset, enable 'Allow Loading Third Party Assets' and retry.",76,false)
importStatus.LayoutOrder = 8

local function formatResult(result: any): string
	if not result.Success then return ("FAILED %s: %s"):format(tostring(result.CargoId or "asset"),tostring(result.Error or "unknown error")) end
	local b = result.Bounds
	local boundsText = if typeof(b) == "Vector3" then ("%.1f×%.1f×%.1f"):format(b.X,b.Y,b.Z) else "?"
	local warningText = if result.Warnings and #result.Warnings > 0 then " | WARN " .. table.concat(result.Warnings,"; ") else ""
	return ("OK %s | asset %s | removed %d | scripts %d | parts %d | bounds %s | scale %.3f%s")
		:format(result.CargoId,tostring(result.AssetId),result.Removed or 0,result.ScriptsRemoved or 0,result.PartCount or 0,boundsText,result.Scale or 1,warningText)
end

local function setImportStatus(text: string, good: boolean?)
	importStatus.Text = text
	importStatus.TextColor3 = if good == true then Color3.fromRGB(102,220,148) elseif good == false then Color3.fromRGB(244,112,112) else Color3.fromRGB(171,177,188)
end

local function withRecording(name: string, callback: () -> any): (boolean, any)
	local recording = nil
	pcall(function() recording = ChangeHistoryService:TryBeginRecording(name) end)
	local ok, result = pcall(callback)
	if recording then
		pcall(function() ChangeHistoryService:FinishRecording(recording,if ok then Enum.FinishRecordingOperation.Commit else Enum.FinishRecordingOperation.Cancel) end)
	else
		pcall(function() ChangeHistoryService:SetWaypoint(name) end)
	end
	return ok,result
end

importSelectedButton.MouseButton1Click:Connect(function()
	local cargoId = string.gsub(selectedCargo.Text,"%s+","")
	setImportStatus("Importing " .. cargoId .. "...",nil)
	local ok,result = withRecording("ONE TRIP Import " .. cargoId,function() return CreatorStoreImporter.Import(cargoId,false) end)
	if ok then setImportStatus(formatResult(result),result.Success) else setImportStatus(tostring(result),false) end
end)

rebuildButton.MouseButton1Click:Connect(function()
	local cargoId = string.gsub(selectedCargo.Text,"%s+","")
	setImportStatus("Rebuilding " .. cargoId .. "...",nil)
	local ok,result = withRecording("ONE TRIP Rebuild " .. cargoId,function() return CreatorStoreImporter.Import(cargoId,true) end)
	if ok then setImportStatus(formatResult(result),result.Success) else setImportStatus(tostring(result),false) end
end)

importAllButton.MouseButton1Click:Connect(function()
	setImportStatus("Importing the three approved proof assets...",nil)
	local ok,results = withRecording("ONE TRIP Import Approved Assets",function() return CreatorStoreImporter.ImportApproved(false) end)
	if not ok then setImportStatus(tostring(results),false) return end
	local lines = {}
	local allGood = true
	for _, result in results do
		table.insert(lines,formatResult(result))
		if result.Success ~= true then allGood = false end
	end
	setImportStatus(table.concat(lines,"\n"),allGood)
end)

reviewButton.MouseButton1Click:Connect(function()
	local ok,result = withRecording("ONE TRIP Open Imported Review Gallery",function() return CreatorStoreImporter.OpenReviewGallery() end)
	if ok then setImportStatus("Opened Workspace/OneTripImportedAssetReview. Review Couch → Refrigerator → Arcade Cabinet at intended game scale.",true) else setImportStatus(tostring(result),false) end
end)

local recipeTitle = label("JSON MODEL BUILDER",24,true)
recipeTitle.LayoutOrder = 9
local recipeBox = Instance.new("TextBox")
recipeBox.LayoutOrder = 10
recipeBox.Size = UDim2.new(1,0,0,330)
recipeBox.BackgroundColor3 = Color3.fromRGB(14,16,20)
recipeBox.BorderSizePixel = 0
recipeBox.ClearTextOnFocus = false
recipeBox.Font = Enum.Font.Code
recipeBox.MultiLine = true
recipeBox.Text = Examples.FridgeJSON()
recipeBox.TextColor3 = Color3.fromRGB(222,226,233)
recipeBox.TextSize = 12
recipeBox.TextWrapped = false
recipeBox.TextXAlignment = Enum.TextXAlignment.Left
recipeBox.TextYAlignment = Enum.TextYAlignment.Top
recipeBox.Parent = root
local recipeCorner = Instance.new("UICorner")
recipeCorner.CornerRadius = UDim.new(0,6)
recipeCorner.Parent = recipeBox

local exampleRow = Instance.new("Frame")
exampleRow.LayoutOrder = 11
exampleRow.Size = UDim2.new(1,0,0,32)
exampleRow.BackgroundTransparency = 1
exampleRow.Parent = root
local exampleLayout = Instance.new("UIListLayout")
exampleLayout.FillDirection = Enum.FillDirection.Horizontal
exampleLayout.Padding = UDim.new(0,6)
exampleLayout.Parent = exampleRow
local fridgeButton = button("FRIDGE",0.25) fridgeButton.Parent = exampleRow
local couchButton = button("COUCH",0.25) couchButton.Parent = exampleRow
local pcButton = button("PC",0.25) pcButton.Parent = exampleRow
local trunkButton = button("FRAGRANCE",0.25) trunkButton.Parent = exampleRow
fridgeButton.MouseButton1Click:Connect(function() recipeBox.Text = Examples.FridgeJSON() end)
couchButton.MouseButton1Click:Connect(function() recipeBox.Text = Examples.CouchJSON() end)
pcButton.MouseButton1Click:Connect(function() recipeBox.Text = Examples.PCJSON() end)
trunkButton.MouseButton1Click:Connect(function() recipeBox.Text = Examples.TrunkJSON() end)

local actionRow = Instance.new("Frame")
actionRow.LayoutOrder = 12
actionRow.Size = UDim2.new(1,0,0,38)
actionRow.BackgroundTransparency = 1
actionRow.Parent = root
local actionLayout = Instance.new("UIListLayout")
actionLayout.FillDirection = Enum.FillDirection.Horizontal
actionLayout.Padding = UDim.new(0,8)
actionLayout.Parent = actionRow
local validateButton = button("VALIDATE",0.4,Color3.fromRGB(57,80,112)) validateButton.Parent = actionRow
local buildButton = button("BUILD MODEL",0.6,Color3.fromRGB(43,112,73)) buildButton.Parent = actionRow
local recipeStatus = label("Recipe builder ready.",26,false)
recipeStatus.LayoutOrder = 13

local function decodeRecipe(): (any?,string?)
	local ok,decoded = pcall(function() return HttpService:JSONDecode(recipeBox.Text) end)
	if not ok then return nil,"Invalid JSON: " .. tostring(decoded) end
	return decoded,nil
end

validateButton.MouseButton1Click:Connect(function()
	local recipe,err = decodeRecipe()
	if not recipe then recipeStatus.Text = err or "Invalid recipe." return end
	local ok,message = Builder.Validate(recipe)
	recipeStatus.Text = message
	recipeStatus.TextColor3 = if ok then Color3.fromRGB(102,220,148) else Color3.fromRGB(244,112,112)
end)

buildButton.MouseButton1Click:Connect(function()
	local recipe,err = decodeRecipe()
	if not recipe then recipeStatus.Text = err or "Invalid recipe." return end
	local valid,message = Builder.Validate(recipe)
	if not valid then recipeStatus.Text = message return end
	local ok,result = withRecording("ONE TRIP Build Model",function() return Builder.Build(recipe) end)
	if ok then recipeStatus.Text = "Built " .. result.Name .. " and selected it in Workspace." else recipeStatus.Text = "Build failed: " .. tostring(result) end
end)

openButton.Click:Connect(function() widget.Enabled = not widget.Enabled end)
plugin.Unloading:Connect(function() widget.Enabled = false end)
