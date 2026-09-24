--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BatchConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("M6CProductionBatchConfig"))
local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local RarityConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("RarityConfig"))

local Service = {}
local watched: {[BasePart]: RBXScriptConnection} = {}
local applied = 0

local COLOR_BLEND = table.freeze({[1]=0,[2]=0.03,[3]=0.08,[4]=0.13,[5]=0.17,[6]=0.22,[7]=0.26,[8]=0.20})
local WHITE_GOLD = Color3.fromRGB(248,235,184)
local PEARL = Color3.fromRGB(235,244,249)

local function itemIdFromRoot(root: BasePart): string?
	local attr = root:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	return string.match(root.Name,"^Carry_(.+)_%d+$")
end

local function material(value: Enum.Material): Enum.Material
	return value
end

local function makePart(root: BasePart, folder: Folder, name: string, kind: string, size: Vector3, localCF: CFrame, color: Color3, mat: Enum.Material, transparency: number?): BasePart
	local p: BasePart
	if kind == "Wedge" then
		p = Instance.new("WedgePart")
	elseif kind == "CornerWedge" then
		p = Instance.new("CornerWedgePart")
	else
		local normal = Instance.new("Part")
		if kind == "Cylinder" then normal.Shape = Enum.PartType.Cylinder end
		if kind == "Ball" then normal.Shape = Enum.PartType.Ball end
		p = normal
	end
	p.Name = name
	p.Size = Vector3.new(math.max(0.06,size.X),math.max(0.06,size.Y),math.max(0.06,size.Z))
	p.CFrame = root.CFrame * localCF
	p.Color = color
	p.Material = material(mat)
	p.Transparency = transparency or 0
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = false
	p:SetAttribute("M6CProductionVisual",true)
	p.Parent = folder
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = p
	weld.Parent = p
	return p
end

local function ensureAnchor(root: BasePart, name: string, position: Vector3): Attachment
	local existing = root:FindFirstChild(name)
	if existing and existing:IsA("Attachment") then
		existing.Position = position
		return existing
	end
	local a = Instance.new("Attachment")
	a.Name = name
	a.Position = position
	a.Parent = root
	return a
end

local function ensureVFXAnchors(root: BasePart)
	local half = root.Size * 0.5
	ensureAnchor(root,"VFX_Core",Vector3.zero)
	ensureAnchor(root,"VFX_Top",Vector3.new(0,half.Y,0))
	ensureAnchor(root,"VFX_Left",Vector3.new(-half.X,0,0))
	ensureAnchor(root,"VFX_Right",Vector3.new(half.X,0,0))
	ensureAnchor(root,"VFX_Front",Vector3.new(0,0,-half.Z))
end

local function clearLegacyLayers(root: BasePart)
	for _, name in {
		"M6CArt","M6CIdentity","M6C1ModelCorrection","M6C1Prestige","M6C1EnergyAura",
		"M6CProductionModel","M6CProfessionalVFX","M6C1AuraHighlight","RarityHighlight",
	} do
		local child = root:FindFirstChild(name)
		if child then child:Destroy() end
	end
	for _, child in root:GetChildren() do
		if child:GetAttribute("M6C1EnergyAttachment") == true or child:GetAttribute("M6CProductionTemporary") == true then
			child:Destroy()
		end
	end
end

local function clearProduction(root: BasePart)
	local existing = root:FindFirstChild("M6CProductionModel")
	if existing then existing:Destroy() end
	root:SetAttribute("M6CProductionItemId",nil)
	root:SetAttribute("M6CProductionBaseItemId",nil)
	root.Transparency = 0
end

local function transform(spec: any): CFrame
	local r = spec.Rotation or Vector3.zero
	return CFrame.new(spec.Position) * CFrame.Angles(math.rad(r.X),math.rad(r.Y),math.rad(r.Z))
end

local function tint(specColor: Color3, rarityColor: Color3, rank: number, mat: Enum.Material): Color3
	if rank == 8 and mat == Enum.Material.Neon then return WHITE_GOLD end
	local amount = COLOR_BLEND[rank] or 0
	if mat == Enum.Material.Glass then amount *= 0.45 end
	return specColor:Lerp(rarityColor,amount)
end

local function trim(root: BasePart, folder: Folder, name: string, size: Vector3, cf: CFrame, color: Color3, mat: Enum.Material?)
	return makePart(root,folder,name,"Block",size,cf,color,mat or Enum.Material.Metal,0)
end

local function addRarityGeometry(root: BasePart, folder: Folder, family: string, rank: number, rarityColor: Color3)
	if rank <= 1 then return end
	local s = root.Size
	local accent = if rank == 8 then WHITE_GOLD else rarityColor
	local premium = if rank == 8 then PEARL else rarityColor:Lerp(Color3.new(1,1,1),0.18)

	trim(root,folder,"QualityBadge",Vector3.new(math.max(0.20,s.X*0.10),math.max(0.12,s.Y*0.035),0.08),CFrame.new(s.X*0.32,s.Y*0.34,-s.Z*0.53),accent,Enum.Material.Metal)
	if rank == 2 then return end

	trim(root,folder,"RareTrimL",Vector3.new(math.max(0.10,s.X*0.035),s.Y*0.72,0.08),CFrame.new(-s.X*0.43,0,-s.Z*0.535),accent,Enum.Material.Metal)
	trim(root,folder,"RareTrimR",Vector3.new(math.max(0.10,s.X*0.035),s.Y*0.72,0.08),CFrame.new(s.X*0.43,0,-s.Z*0.535),accent,Enum.Material.Metal)
	if rank == 3 then return end

	if family == "FURNITURE" then
		trim(root,folder,"EpicFurnitureCrest",Vector3.new(s.X*0.46,0.24,0.30),CFrame.new(0,s.Y*0.51,s.Z*0.31),accent,Enum.Material.Metal)
		trim(root,folder,"EpicFurnitureArmL",Vector3.new(s.X*0.12,0.28,s.Z*0.46),CFrame.new(-s.X*0.44,s.Y*0.20,0),accent,Enum.Material.Metal)
		trim(root,folder,"EpicFurnitureArmR",Vector3.new(s.X*0.12,0.28,s.Z*0.46),CFrame.new(s.X*0.44,s.Y*0.20,0),accent,Enum.Material.Metal)
	elseif family == "TECH" or family == "APPLIANCE" then
		trim(root,folder,"EpicTechTop",Vector3.new(s.X*0.62,0.20,s.Z*0.36),CFrame.new(0,s.Y*0.53,0),accent,Enum.Material.Metal)
		trim(root,folder,"EpicTechSideL",Vector3.new(0.18,s.Y*0.42,s.Z*0.52),CFrame.new(-s.X*0.54,s.Y*0.04,0),accent,Enum.Material.Metal)
		trim(root,folder,"EpicTechSideR",Vector3.new(0.18,s.Y*0.42,s.Z*0.52),CFrame.new(s.X*0.54,s.Y*0.04,0),accent,Enum.Material.Metal)
	elseif family == "MACHINE" then
		trim(root,folder,"EpicMachineRailL",Vector3.new(0.24,s.Y*0.72,0.24),CFrame.new(-s.X*0.50,0,0),accent,Enum.Material.Metal)
		trim(root,folder,"EpicMachineRailR",Vector3.new(0.24,s.Y*0.72,0.24),CFrame.new(s.X*0.50,0,0),accent,Enum.Material.Metal)
		trim(root,folder,"EpicMachineBridge",Vector3.new(s.X*0.72,0.22,0.30),CFrame.new(0,s.Y*0.52,0),accent,Enum.Material.Metal)
	elseif family == "LUXURY" then
		trim(root,folder,"EpicLuxuryTop",Vector3.new(s.X*0.82,0.22,0.22),CFrame.new(0,s.Y*0.51,-s.Z*0.49),accent,Enum.Material.Metal)
		trim(root,folder,"EpicLuxuryBottom",Vector3.new(s.X*0.82,0.22,0.22),CFrame.new(0,-s.Y*0.51,-s.Z*0.49),accent,Enum.Material.Metal)
	elseif family == "ART" then
		for _, x in {-1,1} do
			for _, y in {-1,1} do
				trim(root,folder,"EpicArtCorner",Vector3.new(s.X*0.14,s.Y*0.14,0.18),CFrame.new(x*s.X*0.43,y*s.Y*0.42,-s.Z*0.56),accent,Enum.Material.Metal)
			end
		end
	elseif family == "SECURE" then
		for _, y in {-0.32,0.32} do
			trim(root,folder,"EpicVaultBar",Vector3.new(s.X*0.78,0.17,0.17),CFrame.new(0,s.Y*y,-s.Z*0.56),accent,Enum.Material.Metal)
		end
	elseif family == "PROTOTYPE" then
		for _, x in {-1,1} do
			trim(root,folder,"EpicContainmentFin",Vector3.new(s.X*0.20,s.Y*0.52,0.18),CFrame.new(x*s.X*0.53,0,0),accent,Enum.Material.Metal)
		end
	else
		trim(root,folder,"EpicFrameTop",Vector3.new(s.X*0.62,0.20,0.20),CFrame.new(0,s.Y*0.53,0),accent,Enum.Material.Metal)
	end
	if rank == 4 then return end

	trim(root,folder,"LegendaryCrown",Vector3.new(s.X*0.72,0.30,s.Z*0.20),CFrame.new(0,s.Y*0.59,0),accent,Enum.Material.Metal)
	trim(root,folder,"LegendaryBase",Vector3.new(s.X*0.68,0.22,s.Z*0.28),CFrame.new(0,-s.Y*0.57,0),accent,Enum.Material.Metal)
	if rank == 5 then return end

	for _, x in {-1,1} do
		local node = makePart(root,folder,"MythicNode","Ball",Vector3.new(0.42,0.42,0.42),CFrame.new(x*s.X*0.60,s.Y*0.18,0),accent,Enum.Material.Neon,0.03)
		node:SetAttribute("RarityGeometry",true)
	end
	trim(root,folder,"MythicSpine",Vector3.new(0.16,s.Y*0.66,0.16),CFrame.new(0,0,s.Z*0.57),accent,Enum.Material.Neon)
	if rank == 6 then return end

	for _, z in {-1,1} do
		trim(root,folder,"CosmicOrbitRail",Vector3.new(s.X*1.16,0.12,0.12),CFrame.new(0,0,z*s.Z*0.62)*CFrame.Angles(0,0,math.rad(if z > 0 then 16 else -16)),accent,Enum.Material.Neon)
	end
	for _, x in {-1,1} do
		makePart(root,folder,"CosmicAnchor","Ball",Vector3.new(0.34,0.34,0.34),CFrame.new(x*s.X*0.62,0,0),premium,Enum.Material.Neon,0.02)
	end
	if rank == 7 then return end

	trim(root,folder,"EternalHaloBar",Vector3.new(s.X*0.84,0.18,0.18),CFrame.new(0,s.Y*0.66,0),WHITE_GOLD,Enum.Material.Neon)
	trim(root,folder,"EternalPearlCrest",Vector3.new(s.X*0.42,0.34,s.Z*0.24),CFrame.new(0,s.Y*0.61,-s.Z*0.20),PEARL,Enum.Material.SmoothPlastic)
end

local function apply(root: BasePart)
	local itemId = itemIdFromRoot(root)
	if not itemId then
		if root:FindFirstChild("M6CProductionModel") then clearProduction(root) end
		return
	end
	local def = ItemConfig[itemId]
	if not def then
		if root:FindFirstChild("M6CProductionModel") then clearProduction(root) end
		return
	end
	local baseId = tostring(def.BaseItemId or itemId)
	local recipe = BatchConfig.Recipes[baseId]
	if not recipe then
		if root:FindFirstChild("M6CProductionModel") then clearProduction(root) end
		return
	end
	if root:GetAttribute("M6CProductionItemId") == itemId and root:FindFirstChild("M6CProductionModel") then return end

	clearLegacyLayers(root)
	ensureVFXAnchors(root)
	root.Transparency = 1
	root:SetAttribute("M6CProductionItemId",itemId)
	root:SetAttribute("M6CProductionBaseItemId",baseId)

	local rarity = tostring(def.Rarity or "Common")
	local tier = RarityConfig.Tiers[rarity] or RarityConfig.Tiers.Common
	local folder = Instance.new("Folder")
	folder.Name = "M6CProductionModel"
	folder:SetAttribute("BaseItemId",baseId)
	folder:SetAttribute("Rarity",rarity)
	folder:SetAttribute("ModelSource",recipe.ModelSource)
	folder.Parent = root

	for _, spec in recipe.Parts do
		makePart(root,folder,spec.Name,spec.Type,spec.Size,transform(spec),tint(spec.Color,tier.Color,tier.Rank,spec.Material),spec.Material,spec.Transparency)
	end
	addRarityGeometry(root,folder,recipe.Family,tier.Rank,tier.Color)
	applied += 1
end

local function watchPart(root: BasePart)
	if watched[root] then return end
	watched[root] = root:GetAttributeChangedSignal("ItemId"):Connect(function()
		task.defer(function() if root.Parent then apply(root) end end)
	end)
	task.defer(function() if root.Parent then apply(root) end end)
end

local function descendant(instance: Instance)
	if instance:IsA("BasePart") then watchPart(instance) end
end

local function character(character: Model)
	for _, d in character:GetDescendants() do descendant(d) end
	character.DescendantAdded:Connect(descendant)
end

local function player(p: Player)
	p.CharacterAdded:Connect(character)
	if p.Character then character(p.Character) end
end

function Service.Start(world: Folder)
	applied = 0
	for _, d in world:GetDescendants() do descendant(d) end
	world.DescendantAdded:Connect(descendant)
	for _, p in Players:GetPlayers() do player(p) end
	Players.PlayerAdded:Connect(player)
	task.delay(1.5,function()
		if world.Parent then
			world:SetAttribute("M6CProductionBatchEnabled",true)
			world:SetAttribute("M6CProductionBatchModelCount",applied)
		end
	end)
end

return Service
