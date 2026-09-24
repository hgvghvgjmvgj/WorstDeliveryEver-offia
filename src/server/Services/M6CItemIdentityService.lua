--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ItemConfig = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("ItemConfig"))
local LootCatalog = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("LootCatalog"))

local Service = {}

local METAL = Color3.fromRGB(73,80,88)
local DARK = Color3.fromRGB(36,41,47)
local LIGHT = Color3.fromRGB(211,218,221)
local CYAN = Color3.fromRGB(70,196,216)
local AMBER = Color3.fromRGB(234,177,61)

local function itemId(part: BasePart): string?
	local attr = part:GetAttribute("ItemId")
	if typeof(attr) == "string" and attr ~= "" then return attr end
	local carry = string.match(part.Name,"^Carry_(.+)_%d+$")
	return carry
end

local function token(text: string, value: string): boolean
	return string.find(string.lower(text),string.lower(value),1,true) ~= nil
end

local function part(root: BasePart, folder: Folder, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = Vector3.new(math.max(0.08,size.X),math.max(0.08,size.Y),math.max(0.08,size.Z))
	p.CFrame = root.CFrame * cf
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Transparency = transparency or 0
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true
	p.CastShadow = false
	p:SetAttribute("M6CIdentityVisual",true)
	p.Parent = folder
	local w = Instance.new("WeldConstraint")
	w.Part0 = root
	w.Part1 = p
	w.Parent = p
	return p
end

local function ball(root: BasePart, folder: Folder, name: string, d: number, cf: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = part(root,folder,name,Vector3.new(d,d,d),cf,color,material,transparency)
	p.Shape = Enum.PartType.Ball
	return p
end

local function cylinder(root: BasePart, folder: Folder, name: string, size: Vector3, cf: CFrame, color: Color3, material: Enum.Material?, transparency: number?): Part
	local p = part(root,folder,name,size,cf,color,material,transparency)
	p.Shape = Enum.PartType.Cylinder
	return p
end

local function addWheel(root: BasePart, folder: Folder, name: string, x: number, y: number, z: number, diameter: number, thickness: number)
	cylinder(root,folder,name,Vector3.new(thickness,diameter,diameter),CFrame.new(x,y,z)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(44,46,49),Enum.Material.Metal,0)
end

local function applyIdentity(root: BasePart)
	local id = itemId(root)
	if not id then return end
	local def = ItemConfig[id]
	if not def then return end
	local baseId = tostring(def.BaseItemId or id)
	local base = LootCatalog.ById[baseId]
	if not base then return end
	if not root:FindFirstChild("M6CArt") then return end
	if root:GetAttribute("M6CIdentityItemId") == id and root:FindFirstChild("M6CIdentity") then return end

	local old = root:FindFirstChild("M6CIdentity")
	if old then old:Destroy() end
	root:SetAttribute("M6CIdentityItemId",id)

	local folder = Instance.new("Folder")
	folder.Name = "M6CIdentity"
	folder.Parent = root

	local s = root.Size
	local lower = string.lower(baseId .. " " .. tostring(base.Name))
	local color = root.Color
	local light = color:Lerp(Color3.new(1,1,1),0.24)
	local dark = color:Lerp(Color3.new(0,0,0),0.38)

	-- Receiving / home readable details.
	if token(lower,"cooler") then
		part(root,folder,"CoolerLid",Vector3.new(s.X*1.02,math.max(0.18,s.Y*0.14),s.Z*1.02),CFrame.new(0,s.Y*0.49,0),light,Enum.Material.SmoothPlastic,0)
		part(root,folder,"CoolerHandle",Vector3.new(s.X*0.54,0.20,0.22),CFrame.new(0,s.Y*0.65,0),DARK,Enum.Material.Metal,0)
	elseif token(lower,"printer") then
		part(root,folder,"PaperTray",Vector3.new(s.X*0.70,0.20,s.Z*0.38),CFrame.new(0,s.Y*0.48,-s.Z*0.08),LIGHT,Enum.Material.SmoothPlastic,0)
		part(root,folder,"OutputSlot",Vector3.new(s.X*0.56,s.Y*0.16,0.12),CFrame.new(0,-s.Y*0.10,-s.Z*0.54),DARK,Enum.Material.Metal,0)
	elseif token(lower,"filing") then
		for y = -0.28,0.28,0.28 do
			part(root,folder,"Drawer",Vector3.new(s.X*0.76,s.Y*0.20,0.13),CFrame.new(0,s.Y*y,-s.Z*0.53),light,Enum.Material.Metal,0)
			part(root,folder,"DrawerPull",Vector3.new(s.X*0.22,0.12,0.12),CFrame.new(0,s.Y*y,-s.Z*0.58),DARK,Enum.Material.Metal,0)
		end
	elseif token(lower,"mail tub") or token(lower,"storage bin") then
		part(root,folder,"BinLip",Vector3.new(s.X*1.04,0.22,s.Z*1.04),CFrame.new(0,s.Y*0.47,0),light,Enum.Material.SmoothPlastic,0)
		for _, x in {-s.X*0.38,s.X*0.38} do
			part(root,folder,"BinHandle",Vector3.new(s.X*0.16,s.Y*0.18,0.12),CFrame.new(x,s.Y*0.12,-s.Z*0.52),DARK,Enum.Material.SmoothPlastic,0)
		end
	elseif token(lower,"box fan") then
		local grill = cylinder(root,folder,"FanGrill",Vector3.new(0.16,s.Y*0.76,s.Y*0.76),CFrame.new(0,0,-s.Z*0.53)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(86,92,98),Enum.Material.Metal,0.06)
		grill.CastShadow = false
		for angle = 0,270,90 do
			part(root,folder,"FanBlade",Vector3.new(s.X*0.28,0.12,s.Z*0.10),CFrame.new(0,0,-s.Z*0.58)*CFrame.Angles(0,0,math.rad(angle)),light,Enum.Material.SmoothPlastic,0)
		end
	elseif token(lower,"shelf") or token(lower,"bookcase") then
		for _, y in {-s.Y*0.30,0,s.Y*0.30} do
			part(root,folder,"ShelfBoard",Vector3.new(s.X*0.88,0.18,s.Z*0.84),CFrame.new(0,y,0),light,Enum.Material.WoodPlanks,0)
		end
	end

	-- Appliance family details not already handled by the base recipe.
	if token(lower,"oven") then
		part(root,folder,"OvenWindow",Vector3.new(s.X*0.66,s.Y*0.44,0.13),CFrame.new(0,-s.Y*0.10,-s.Z*0.56),Color3.fromRGB(32,39,46),Enum.Material.Glass,0.05)
		for _, x in {-s.X*0.27,-s.X*0.09,s.X*0.09,s.X*0.27} do
			ball(root,folder,"OvenKnob",math.max(0.18,s.X*0.07),CFrame.new(x,s.Y*0.35,-s.Z*0.59),METAL,Enum.Material.Metal,0)
		end
	elseif token(lower,"dishwasher") then
		part(root,folder,"DishwasherHandle",Vector3.new(s.X*0.58,0.18,0.18),CFrame.new(0,s.Y*0.31,-s.Z*0.58),METAL,Enum.Material.Metal,0)
	elseif token(lower,"vacuum") then
		part(root,folder,"VacuumWand",Vector3.new(math.max(0.16,s.X*0.12),s.Y*0.64,math.max(0.16,s.Z*0.12)),CFrame.new(0,s.Y*0.14,0)*CFrame.Angles(0,0,math.rad(-8)),METAL,Enum.Material.Metal,0)
		part(root,folder,"VacuumGrip",Vector3.new(s.X*0.56,0.20,0.20),CFrame.new(0,s.Y*0.54,0),dark,Enum.Material.SmoothPlastic,0)
	end

	-- Furniture identity.
	if token(lower,"recliner") then
		part(root,folder,"FootRest",Vector3.new(s.X*0.56,s.Y*0.16,s.Z*0.36),CFrame.new(0,-s.Y*0.22,-s.Z*0.46),light,Enum.Material.SmoothPlastic,0)
	elseif token(lower,"sectional") then
		part(root,folder,"Chaise",Vector3.new(s.X*0.38,s.Y*0.34,s.Z*0.90),CFrame.new(s.X*0.38,-s.Y*0.10,-s.Z*0.18),light,Enum.Material.SmoothPlastic,0)
	end

	-- Electronics.
	if token(lower,"network") or token(lower,"server") then
		for y = -0.30,0.30,0.15 do
			part(root,folder,"ServerBay",Vector3.new(s.X*0.70,s.Y*0.10,0.13),CFrame.new(0,s.Y*y,-s.Z*0.55),DARK,Enum.Material.Metal,0)
			part(root,folder,"ServerLED",Vector3.new(s.X*0.18,0.08,0.10),CFrame.new(s.X*0.22,s.Y*y,-s.Z*0.60),CYAN,Enum.Material.Neon,0.15)
		end
	elseif token(lower,"console") then
		part(root,folder,"ConsoleFace",Vector3.new(s.X*0.58,s.Y*0.42,0.13),CFrame.new(0,0,-s.Z*0.54),DARK,Enum.Material.SmoothPlastic,0)
		ball(root,folder,"ControllerGrip",math.max(0.22,s.X*0.12),CFrame.new(s.X*0.27,-s.Y*0.18,-s.Z*0.56),light,Enum.Material.SmoothPlastic,0)
	elseif token(lower,"display wall") then
		for _, x in {-s.X*0.26,0,s.X*0.26} do
			part(root,folder,"DisplayPanel",Vector3.new(s.X*0.22,s.Y*0.62,0.11),CFrame.new(x,0,-s.Z*0.55),Color3.fromRGB(22,31,45),Enum.Material.Glass,0.04)
		end
	end

	-- Recreation.
	if token(lower,"foosball") then
		for _, z in {-s.Z*0.26,0,s.Z*0.26} do
			part(root,folder,"FoosballRod",Vector3.new(s.X*1.12,0.10,0.10),CFrame.new(0,s.Y*0.20,z),METAL,Enum.Material.Metal,0)
			for _, x in {-s.X*0.24,s.X*0.24} do
				part(root,folder,"FoosballPlayer",Vector3.new(0.18,s.Y*0.24,0.18),CFrame.new(x,s.Y*0.10,z),if x < 0 then Color3.fromRGB(221,75,64) else Color3.fromRGB(70,126,214),Enum.Material.SmoothPlastic,0)
			end
		end
	elseif token(lower,"rowing") then
		part(root,folder,"RowRail",Vector3.new(s.X*0.80,0.18,s.Z*0.18),CFrame.new(0,-s.Y*0.12,0),METAL,Enum.Material.Metal,0)
		part(root,folder,"RowSeat",Vector3.new(s.X*0.22,s.Y*0.12,s.Z*0.34),CFrame.new(-s.X*0.18,s.Y*0.02,0),dark,Enum.Material.SmoothPlastic,0)
	elseif token(lower,"sports") then
		for _, y in {-s.Y*0.22,s.Y*0.18} do
			for _, x in {-s.X*0.24,0,s.X*0.24} do
				ball(root,folder,"SportsBall",math.max(0.28,math.min(s.X,s.Z)*0.13),CFrame.new(x,y,-s.Z*0.48),if x == 0 then Color3.fromRGB(230,131,44) else Color3.fromRGB(82,151,207),Enum.Material.SmoothPlastic,0)
			end
		end
	end

	-- Garage / Auto.
	if token(lower,"wheel") or token(lower,"tire") then
		for _, z in {-s.Z*0.22,s.Z*0.22} do
			addWheel(root,folder,"Tire",0,0,z,math.min(s.X,s.Y)*0.72,math.max(0.18,s.Z*0.16))
		end
	elseif token(lower,"floor jack") then
		part(root,folder,"JackArm",Vector3.new(s.X*0.66,0.24,s.Z*0.20),CFrame.new(0,s.Y*0.10,0)*CFrame.Angles(0,0,math.rad(-18)),Color3.fromRGB(174,55,48),Enum.Material.Metal,0)
		for _, x in {-s.X*0.32,s.X*0.32} do addWheel(root,folder,"JackWheel",x,-s.Y*0.42,0,math.max(0.28,s.Y*0.16),0.18) end
	elseif token(lower,"compressor") then
		local tank = cylinder(root,folder,"CompressorTank",Vector3.new(s.X*0.62,s.Y*0.54,s.Y*0.54),CFrame.new(0,-s.Y*0.08,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(157,61,50),Enum.Material.Metal,0)
		tank.CastShadow = false
	elseif token(lower,"workbench") then
		part(root,folder,"Pegboard",Vector3.new(s.X*0.80,s.Y*0.50,0.16),CFrame.new(0,s.Y*0.28,s.Z*0.38),Color3.fromRGB(76,82,88),Enum.Material.Metal,0)
		part(root,folder,"BenchTop",Vector3.new(s.X*0.92,0.26,s.Z*0.74),CFrame.new(0,s.Y*0.08,0),Color3.fromRGB(142,96,59),Enum.Material.WoodPlanks,0)
	elseif token(lower,"axle") then
		part(root,folder,"AxleShaft",Vector3.new(s.X*0.90,0.28,0.28),CFrame.new(),METAL,Enum.Material.Metal,0)
		for _, x in {-s.X*0.46,s.X*0.46} do addWheel(root,folder,"Hub",x,0,0,math.min(s.Y,s.Z)*0.56,0.22) end
	end

	-- Construction.
	if token(lower,"scaffold") then
		for _, x in {-s.X*0.36,s.X*0.36} do
			for _, z in {-s.Z*0.30,s.Z*0.30} do part(root,folder,"ScaffoldPost",Vector3.new(0.18,s.Y*0.90,0.18),CFrame.new(x,0,z),METAL,Enum.Material.Metal,0) end
		end
		for _, y in {-s.Y*0.24,s.Y*0.24} do part(root,folder,"ScaffoldBrace",Vector3.new(s.X*0.80,0.16,0.16),CFrame.new(0,y,0),AMBER,Enum.Material.Metal,0) end
	elseif token(lower,"saw") or token(lower,"cutter") then
		local blade = cylinder(root,folder,"SawBlade",Vector3.new(0.15,s.Y*0.58,s.Y*0.58),CFrame.new(s.X*0.18,0,-s.Z*0.50)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(158,163,167),Enum.Material.Metal,0)
		blade.CastShadow = false
	elseif token(lower,"compactor") then
		part(root,folder,"CompactorPlate",Vector3.new(s.X*0.86,0.32,s.Z*0.74),CFrame.new(0,-s.Y*0.48,0),DARK,Enum.Material.Metal,0)
		part(root,folder,"CompactorHandle",Vector3.new(s.X*0.10,s.Y*0.70,s.Z*0.10),CFrame.new(0,s.Y*0.18,s.Z*0.28)*CFrame.Angles(math.rad(-18),0,0),AMBER,Enum.Material.Metal,0)
	elseif token(lower,"light rig") then
		for _, x in {-s.X*0.22,s.X*0.22} do part(root,folder,"WorkLight",Vector3.new(s.X*0.22,s.Y*0.20,0.16),CFrame.new(x,s.Y*0.34,-s.Z*0.52),Color3.fromRGB(255,226,137),Enum.Material.Neon,0.16) end
	end

	-- Heavy equipment.
	if token(lower,"generator") then
		part(root,folder,"GeneratorGrille",Vector3.new(s.X*0.64,s.Y*0.44,0.13),CFrame.new(0,0,-s.Z*0.54),DARK,Enum.Material.Metal,0)
		part(root,folder,"GeneratorHandle",Vector3.new(s.X*0.70,0.18,0.18),CFrame.new(0,s.Y*0.54,0),METAL,Enum.Material.Metal,0)
	elseif token(lower,"tool chest") then
		for y = -0.28,0.28,0.19 do
			part(root,folder,"ToolDrawer",Vector3.new(s.X*0.76,s.Y*0.14,0.13),CFrame.new(0,s.Y*y,-s.Z*0.55),Color3.fromRGB(162,55,48),Enum.Material.Metal,0)
		end
	elseif token(lower,"vending") then
		part(root,folder,"VendingGlass",Vector3.new(s.X*0.62,s.Y*0.64,0.13),CFrame.new(-s.X*0.08,s.Y*0.02,-s.Z*0.54),Color3.fromRGB(53,67,78),Enum.Material.Glass,0.18)
		for y = -0.22,0.22,0.14 do
			part(root,folder,"ProductRow",Vector3.new(s.X*0.48,0.10,0.09),CFrame.new(-s.X*0.08,s.Y*y,-s.Z*0.60),Color3.fromRGB(217,91+math.floor((y+0.3)*100),67),Enum.Material.SmoothPlastic,0)
		end
		part(root,folder,"VendingControls",Vector3.new(s.X*0.16,s.Y*0.48,0.14),CFrame.new(s.X*0.32,0,-s.Z*0.56),METAL,Enum.Material.Metal,0)
	elseif token(lower,"battery") then
		for _, x in {-s.X*0.24,s.X*0.24} do ball(root,folder,"BatteryTerminal",math.max(0.22,s.X*0.09),CFrame.new(x,s.Y*0.55,0),if x < 0 then Color3.fromRGB(210,72,60) else Color3.fromRGB(66,88,100),Enum.Material.Metal,0) end
	elseif token(lower,"freezer") then
		part(root,folder,"FreezerHandle",Vector3.new(0.18,s.Y*0.44,0.18),CFrame.new(s.X*0.31,0,-s.Z*0.57),METAL,Enum.Material.Metal,0)
	elseif token(lower,"pressure washer") then
		local reel = cylinder(root,folder,"HoseReel",Vector3.new(0.18,s.Y*0.42,s.Y*0.42),CFrame.new(s.X*0.34,0,-s.Z*0.38)*CFrame.Angles(0,0,math.rad(90)),DARK,Enum.Material.Metal,0)
		reel.CastShadow = false
	end

	-- Industrial machinery.
	if token(lower,"cable reel") then
		for _, x in {-s.X*0.34,s.X*0.34} do
			local flange = cylinder(root,folder,"ReelFlange",Vector3.new(0.20,s.Y*0.86,s.Y*0.86),CFrame.new(x,0,0)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(126,87,54),Enum.Material.WoodPlanks,0)
			flange.CastShadow = false
		end
		cylinder(root,folder,"CableCore",Vector3.new(s.X*0.58,s.Y*0.46,s.Y*0.46),CFrame.new()*CFrame.Angles(0,0,math.rad(90)),DARK,Enum.Material.Metal,0)
	elseif token(lower,"pump") then
		cylinder(root,folder,"PumpBody",Vector3.new(s.X*0.46,s.Y*0.58,s.Y*0.58),CFrame.new()*CFrame.Angles(0,0,math.rad(90)),color,Enum.Material.Metal,0)
		for _, x in {-s.X*0.40,s.X*0.40} do part(root,folder,"PumpPipe",Vector3.new(s.X*0.24,s.Y*0.14,s.Z*0.14),CFrame.new(x,0,0),METAL,Enum.Material.Metal,0) end
	elseif token(lower,"transformer") then
		for _, x in {-s.X*0.28,0,s.X*0.28} do
			cylinder(root,folder,"TransformerCoil",Vector3.new(s.X*0.16,s.Y*0.62,s.Y*0.62),CFrame.new(x,0,-s.Z*0.38)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(158,93,55),Enum.Material.Metal,0)
		end
	elseif token(lower,"gearbox") then
		for _, x in {-s.X*0.20,s.X*0.20} do cylinder(root,folder,"Gear",Vector3.new(0.18,s.Y*0.52,s.Y*0.52),CFrame.new(x,0,-s.Z*0.53)*CFrame.Angles(0,0,math.rad(90)),METAL,Enum.Material.Metal,0) end
	elseif token(lower,"hydraulic") then
		cylinder(root,folder,"HydraulicPiston",Vector3.new(s.X*0.48,s.Y*0.24,s.Y*0.24),CFrame.new(0,s.Y*0.12,-s.Z*0.30)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(172,177,181),Enum.Material.Metal,0)
		part(root,folder,"HydraulicHousing",Vector3.new(s.X*0.56,s.Y*0.42,s.Z*0.46),CFrame.new(0,-s.Y*0.18,0),dark,Enum.Material.Metal,0)
	elseif token(lower,"welding") then
		for _, x in {-s.X*0.22,s.X*0.22} do cylinder(root,folder,"GasCylinder",Vector3.new(s.X*0.14,s.Y*0.58,s.Y*0.14),CFrame.new(x,0,0),if x < 0 then Color3.fromRGB(78,142,88) else Color3.fromRGB(160,74,63),Enum.Material.Metal,0) end
	end

	-- Premium/luxury.
	if token(lower,"chandelier") then
		for angle = 0,300,60 do
			local r = math.rad(angle)
			part(root,folder,"ChandelierArm",Vector3.new(s.X*0.30,0.12,0.12),CFrame.new(math.cos(r)*s.X*0.18,0,math.sin(r)*s.Z*0.18)*CFrame.Angles(0,-r,0),AMBER,Enum.Material.Metal,0)
			ball(root,folder,"Crystal",math.max(0.20,s.X*0.08),CFrame.new(math.cos(r)*s.X*0.34,-s.Y*0.10,math.sin(r)*s.Z*0.34),Color3.fromRGB(224,235,238),Enum.Material.Glass,0.22)
		end
	elseif token(lower,"watch") then
		for _, x in {-s.X*0.24,0,s.X*0.24} do cylinder(root,folder,"WatchFace",Vector3.new(0.12,s.Y*0.22,s.Y*0.22),CFrame.new(x,0,-s.Z*0.57)*CFrame.Angles(0,0,math.rad(90)),AMBER,Enum.Material.Metal,0) end
	elseif token(lower,"luggage") then
		for _, x in {-s.X*0.24,s.X*0.24} do part(root,folder,"LuggageHandle",Vector3.new(s.X*0.18,0.16,0.18),CFrame.new(x,s.Y*0.55,0),AMBER,Enum.Material.Metal,0) end
	end

	-- Art & collectibles.
	if token(lower,"sculpture") then
		part(root,folder,"SculpturePedestal",Vector3.new(s.X*0.66,s.Y*0.18,s.Z*0.66),CFrame.new(0,-s.Y*0.45,0),light,Enum.Material.SmoothPlastic,0)
		ball(root,folder,"SculptureFormA",math.min(s.X,s.Z)*0.44,CFrame.new(-s.X*0.08,s.Y*0.08,0),if token(lower,"bronze") then Color3.fromRGB(145,91,54) else Color3.fromRGB(204,201,192),Enum.Material.SmoothPlastic,0)
		ball(root,folder,"SculptureFormB",math.min(s.X,s.Z)*0.30,CFrame.new(s.X*0.12,s.Y*0.28,0),if token(lower,"bronze") then Color3.fromRGB(121,78,51) else Color3.fromRGB(189,187,181),Enum.Material.SmoothPlastic,0)
	elseif token(lower,"clock") then
		local face = cylinder(root,folder,"ClockFace",Vector3.new(0.16,s.X*0.62,s.X*0.62),CFrame.new(0,s.Y*0.27,-s.Z*0.54)*CFrame.Angles(0,0,math.rad(90)),Color3.fromRGB(227,217,184),Enum.Material.SmoothPlastic,0)
		face.CastShadow = false
		part(root,folder,"Pendulum",Vector3.new(0.18,s.Y*0.30,0.14),CFrame.new(0,-s.Y*0.20,-s.Z*0.55),AMBER,Enum.Material.Metal,0)
	end

	-- Secure.
	if token(lower,"medical") then
		part(root,folder,"MedicalScreen",Vector3.new(s.X*0.42,s.Y*0.24,0.13),CFrame.new(s.X*0.18,s.Y*0.20,-s.Z*0.55),Color3.fromRGB(76,181,197),Enum.Material.Neon,0.14)
		part(root,folder,"MedicalArm",Vector3.new(s.X*0.48,0.18,0.18),CFrame.new(-s.X*0.10,s.Y*0.34,0)*CFrame.Angles(0,0,math.rad(-18)),LIGHT,Enum.Material.Metal,0)
	elseif token(lower,"optics") then
		for _, x in {-s.X*0.22,s.X*0.22} do ball(root,folder,"OpticLens",math.max(0.24,s.Y*0.18),CFrame.new(x,0,-s.Z*0.55),Color3.fromRGB(88,166,202),Enum.Material.Glass,0.18) end
	end

	-- Restricted / Prototype.
	if token(lower,"scanner") then
		for _, x in {-s.X*0.38,s.X*0.38} do part(root,folder,"ScannerTower",Vector3.new(s.X*0.12,s.Y*0.78,s.Z*0.12),CFrame.new(x,0,0),DARK,Enum.Material.Metal,0) end
		part(root,folder,"ScannerBeam",Vector3.new(s.X*0.70,0.14,0.14),CFrame.new(0,s.Y*0.28,-s.Z*0.52),CYAN,Enum.Material.Neon,0.18)
	elseif token(lower,"magnetic") then
		for _, y in {-s.Y*0.25,s.Y*0.25} do
			local ring = cylinder(root,folder,"MagneticRing",Vector3.new(0.16,s.Z*0.88,s.Z*0.88),CFrame.new(0,y,0)*CFrame.Angles(0,0,math.rad(90)),CYAN,Enum.Material.Metal,0)
			ring.CastShadow = false
		end
	elseif token(lower,"containment cylinder") then
		for _, y in {-s.Y*0.32,s.Y*0.32} do part(root,folder,"ContainmentBand",Vector3.new(s.X*0.80,0.22,s.Z*0.80),CFrame.new(0,y,0),DARK,Enum.Material.Metal,0) end
		ball(root,folder,"ContainedSample",math.min(s.X,s.Z)*0.30,CFrame.new(),CYAN,Enum.Material.Neon,0.10)
	elseif token(lower,"drone") then
		for _, x in {-s.X*0.24,s.X*0.24} do
			for _, z in {-s.Z*0.22,s.Z*0.22} do ball(root,folder,"DroneRotor",math.max(0.18,s.X*0.10),CFrame.new(x,s.Y*0.14,z),METAL,Enum.Material.Metal,0) end
		end
	end

	-- If none of the above matched, the M6C base recipe still remains the
	-- intentional fallback. Keep this layer empty instead of decorative noise.
end

local function deferredApply(instance: Instance)
	if not instance:IsA("BasePart") then return end
	task.defer(function()
		task.defer(function()
			task.defer(function()
				if instance.Parent then applyIdentity(instance) end
			end)
		end)
	end)
end

local function watchCharacter(character: Model)
	for _, descendant in character:GetDescendants() do if descendant:IsA("BasePart") then deferredApply(descendant) end end
	character.DescendantAdded:Connect(deferredApply)
end

function Service.Start(world: Folder)
	for _, player in Players:GetPlayers() do
		if player.Character then watchCharacter(player.Character) end
		player.CharacterAdded:Connect(watchCharacter)
	end
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(watchCharacter)
	end)

	for _, descendant in world:GetDescendants() do if descendant:IsA("BasePart") then deferredApply(descendant) end end
	world.DescendantAdded:Connect(deferredApply)
	world:SetAttribute("M6CIdentityLayerEnabled",true)
end

return Service
