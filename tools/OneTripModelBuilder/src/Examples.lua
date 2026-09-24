--!strict

local HttpService = game:GetService("HttpService")

local Examples = {}

local fridge = {
	Name = "CommonRefrigerator",
	CargoId = "Refrigerator",
	SectionId = "Appliances",
	Rarity = "Common",
	Origin = {0, 5, 0},
	BuildAtSelection = true,
	Parts = {
		{Name="Body", Type="Block", Size={4.6,8,4.4}, Position={0,0,0}, Color={206,211,215}, Material="SmoothPlastic"},
		{Name="LeftDoor", Type="Block", Size={2.08,7.45,0.30}, Position={-1.08,0,-2.29}, Color={232,236,239}, Material="SmoothPlastic", CanCollide=false},
		{Name="RightDoor", Type="Block", Size={2.08,7.45,0.30}, Position={1.08,0,-2.29}, Color={232,236,239}, Material="SmoothPlastic", CanCollide=false},
		{Name="HandleL", Type="Block", Size={0.20,4.2,0.26}, Position={-0.33,0,-2.53}, Color={69,75,82}, Material="Metal", CanCollide=false},
		{Name="HandleR", Type="Block", Size={0.20,4.2,0.26}, Position={0.33,0,-2.53}, Color={69,75,82}, Material="Metal", CanCollide=false},
		{Name="Display", Type="Block", Size={0.85,0.62,0.12}, Position={1.03,1.65,-2.56}, Color={53,142,181}, Material="Neon", CanCollide=false},
		{Name="KickPlate", Type="Block", Size={3.95,0.42,0.18}, Position={0,-3.62,-2.40}, Color={91,98,104}, Material="Metal", CanCollide=false}
	}
}

local couch = {
	Name = "CommonCouch",
	CargoId = "Couch",
	SectionId = "Furniture",
	Rarity = "Common",
	Origin = {0,5,0},
	BuildAtSelection = true,
	Parts = {
		{Name="SeatBase", Type="Block", Size={9.5,1.15,3.55}, Position={0,-0.45,0.10}, Color={74,124,170}, Material="SmoothPlastic"},
		{Name="BackFrame", Type="Block", Size={9.35,2.75,0.72}, Position={0,1.15,1.38}, Rotation={-7,0,0}, Color={67,113,157}, Material="SmoothPlastic", CanCollide=false},
		{Name="ArmL", Type="Block", Size={0.82,2.25,3.72}, Position={-4.75,0.25,0.04}, Color={61,105,147}, Material="SmoothPlastic", CanCollide=false},
		{Name="ArmR", Type="Block", Size={0.82,2.25,3.72}, Position={4.75,0.25,0.04}, Color={61,105,147}, Material="SmoothPlastic", CanCollide=false},
		{Name="Seat1", Type="Block", Size={2.75,0.58,2.80}, Position={-3.0,0.25,-0.12}, Color={96,151,196}, Material="SmoothPlastic", CanCollide=false},
		{Name="Seat2", Type="Block", Size={2.75,0.58,2.80}, Position={0,0.25,-0.12}, Color={101,157,201}, Material="SmoothPlastic", CanCollide=false},
		{Name="Seat3", Type="Block", Size={2.75,0.58,2.80}, Position={3.0,0.25,-0.12}, Color={96,151,196}, Material="SmoothPlastic", CanCollide=false},
		{Name="Back1", Type="Block", Size={2.72,1.75,0.56}, Position={-3.0,1.18,1.04}, Rotation={-8,0,0}, Color={99,153,197}, Material="SmoothPlastic", CanCollide=false},
		{Name="Back2", Type="Block", Size={2.72,1.75,0.56}, Position={0,1.18,1.04}, Rotation={-8,0,0}, Color={104,159,202}, Material="SmoothPlastic", CanCollide=false},
		{Name="Back3", Type="Block", Size={2.72,1.75,0.56}, Position={3.0,1.18,1.04}, Rotation={-8,0,0}, Color={99,153,197}, Material="SmoothPlastic", CanCollide=false},
		{Name="FootL", Type="Block", Size={0.45,0.55,0.45}, Position={-4.0,-1.85,1.15}, Color={59,46,38}, Material="Metal", CanCollide=false},
		{Name="FootR", Type="Block", Size={0.45,0.55,0.45}, Position={4.0,-1.85,1.15}, Color={59,46,38}, Material="Metal", CanCollide=false}
	}
}

local pc = {
	Name = "CommonGamingPC",
	CargoId = "GamingPC",
	SectionId = "Electronics",
	Rarity = "Common",
	Origin = {0,5,0},
	BuildAtSelection = true,
	Parts = {
		{Name="Chassis", Type="Block", Size={3.2,6.2,3.0}, Position={0,0,0}, Color={43,49,62}, Material="SmoothPlastic"},
		{Name="GlassSide", Type="Block", Size={0.12,5.35,2.45}, Position={-1.66,0,-0.08}, Color={78,142,171}, Material="Glass", Transparency=0.34, CanCollide=false},
		{Name="FrontPanel", Type="Block", Size={2.55,5.40,0.18}, Position={0,0,-1.58}, Color={28,33,43}, Material="SmoothPlastic", CanCollide=false},
		{Name="Fan1", Type="Cylinder", Size={0.20,0.95,0.95}, Position={0,1.65,-1.72}, Rotation={0,0,90}, Color={70,215,235}, Material="Neon", CanCollide=false},
		{Name="Fan2", Type="Cylinder", Size={0.20,0.95,0.95}, Position={0,0.15,-1.72}, Rotation={0,0,90}, Color={70,215,235}, Material="Neon", CanCollide=false},
		{Name="Fan3", Type="Cylinder", Size={0.20,0.95,0.95}, Position={0,-1.35,-1.72}, Rotation={0,0,90}, Color={70,215,235}, Material="Neon", CanCollide=false},
		{Name="GPU", Type="Block", Size={2.10,0.55,0.72}, Position={-0.15,-0.15,-0.15}, Color={93,55,143}, Material="Metal", CanCollide=false},
		{Name="Motherboard", Type="Block", Size={0.16,2.65,2.10}, Position={-1.38,0.55,0.10}, Color={40,75,72}, Material="SmoothPlastic", CanCollide=false},
		{Name="PSU", Type="Block", Size={2.40,1.0,2.20}, Position={0,-2.35,0.10}, Color={31,34,39}, Material="Metal", CanCollide=false},
		{Name="TopVent", Type="Block", Size={2.45,0.12,1.75}, Position={0,3.16,0.25}, Color={79,85,94}, Material="Metal", CanCollide=false}
	}
}

local trunk = {
	Name = "DesignerFragranceTrunk",
	CargoId = "DesignerFragranceTrunk",
	SectionId = "LuxuryGoods",
	Rarity = "Common",
	Origin = {0, 5, 0},
	BuildAtSelection = true,
	Parts = {
		{Name="Case", Type="Block", Size={8,4.8,5}, Position={0,0,0}, Color={75,45,64}, Material="SmoothPlastic"},
		{Name="FrontFrame", Type="Block", Size={7.4,3.65,0.36}, Position={0,0.10,-2.62}, Color={37,24,36}, Material="SmoothPlastic", CanCollide=false},
		{Name="Glass", Type="Block", Size={6.5,2.70,0.16}, Position={0,0.10,-2.84}, Color={176,214,235}, Material="Glass", Transparency=0.30, CanCollide=false},
		{Name="TopTrim", Type="Block", Size={8.18,0.24,0.28}, Position={0,2.28,-2.60}, Color={184,142,67}, Material="Metal", CanCollide=false},
		{Name="BottomTrim", Type="Block", Size={8.18,0.24,0.28}, Position={0,-2.28,-2.60}, Color={184,142,67}, Material="Metal", CanCollide=false},
		{Name="ClaspL", Type="Block", Size={0.62,1.05,0.32}, Position={-2.45,-0.38,-2.78}, Color={215,169,77}, Material="Metal", CanCollide=false},
		{Name="ClaspR", Type="Block", Size={0.62,1.05,0.32}, Position={2.45,-0.38,-2.78}, Color={215,169,77}, Material="Metal", CanCollide=false},
		{Name="BottleA", Type="Block", Size={1.0,1.85,0.75}, Position={-2.15,0.15,-2.98}, Color={210,92,118}, Material="Glass", Transparency=0.10, CanCollide=false},
		{Name="BottleB", Type="Cylinder", Size={0.95,1.95,0.95}, Position={-0.75,0.12,-2.98}, Rotation={0,0,90}, Color={237,165,71}, Material="Glass", Transparency=0.10, CanCollide=false},
		{Name="BottleC", Type="Block", Size={1.0,2.25,0.75}, Position={0.75,0.30,-2.98}, Color={79,153,223}, Material="Glass", Transparency=0.10, CanCollide=false},
		{Name="BottleD", Type="Cylinder", Size={0.95,1.80,0.95}, Position={2.15,0.05,-2.98}, Rotation={0,0,90}, Color={147,91,196}, Material="Glass", Transparency=0.10, CanCollide=false}
	}
}

function Examples.FridgeJSON(): string return HttpService:JSONEncode(fridge) end
function Examples.CouchJSON(): string return HttpService:JSONEncode(couch) end
function Examples.PCJSON(): string return HttpService:JSONEncode(pc) end
function Examples.TrunkJSON(): string return HttpService:JSONEncode(trunk) end

return Examples
