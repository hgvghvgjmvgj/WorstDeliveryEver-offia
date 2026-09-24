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
		{Name="Body", Type="Block", Size={4.8,8,4.4}, Position={0,0,0}, Color={225,231,236}, Material="SmoothPlastic"},
		{Name="LeftDoor", Type="Block", Size={2.1,7.3,0.28}, Position={-1.1,0,-2.32}, Color={239,243,246}, Material="SmoothPlastic", CanCollide=false},
		{Name="RightDoor", Type="Block", Size={2.1,7.3,0.28}, Position={1.1,0,-2.32}, Color={239,243,246}, Material="SmoothPlastic", CanCollide=false},
		{Name="HandleL", Type="Block", Size={0.22,4.0,0.35}, Position={-0.35,0,-2.62}, Color={72,78,84}, Material="Metal", CanCollide=false},
		{Name="HandleR", Type="Block", Size={0.22,4.0,0.35}, Position={0.35,0,-2.62}, Color={72,78,84}, Material="Metal", CanCollide=false},
		{Name="Display", Type="Block", Size={0.8,0.55,0.12}, Position={1.05,1.7,-2.58}, Color={45,92,126}, Material="Neon", CanCollide=false}
	}
}

local trunk = {
	Name = "LuxuryFragranceTrunk",
	CargoId = "LuxuryFragranceTrunk",
	SectionId = "LuxuryGoods",
	Rarity = "Common",
	Origin = {0, 5, 0},
	BuildAtSelection = true,
	Parts = {
		{Name="CaseBody", Type="Block", Size={8,4.5,5}, Position={0,0,0}, Color={65,34,82}, Material="SmoothPlastic"},
		{Name="LidFrame", Type="Block", Size={7.5,3.5,0.4}, Position={0,0.2,-2.7}, Color={33,19,43}, Material="SmoothPlastic", CanCollide=false},
		{Name="Glass", Type="Block", Size={6.6,2.7,0.18}, Position={0,0.25,-2.93}, Color={170,220,255}, Material="Glass", Transparency=0.35, CanCollide=false},
		{Name="GoldTrimTop", Type="Block", Size={8.2,0.28,0.28}, Position={0,2.18,-2.68}, Color={211,166,64}, Material="Metal", CanCollide=false},
		{Name="GoldTrimBottom", Type="Block", Size={8.2,0.28,0.28}, Position={0,-2.18,-2.68}, Color={211,166,64}, Material="Metal", CanCollide=false},
		{Name="ClaspL", Type="Block", Size={0.55,1.0,0.35}, Position={-2.2,-0.3,-2.9}, Color={224,181,74}, Material="Metal", CanCollide=false},
		{Name="ClaspR", Type="Block", Size={0.55,1.0,0.35}, Position={2.2,-0.3,-2.9}, Color={224,181,74}, Material="Metal", CanCollide=false},
		{Name="Bottle1", Type="Block", Size={0.9,1.7,0.8}, Position={-2.0,0.2,-3.05}, Color={207,97,111}, Material="Glass", Transparency=0.12, CanCollide=false},
		{Name="Bottle2", Type="Cylinder", Size={1.0,1.9,1.0}, Position={-0.7,0.15,-3.05}, Rotation={0,0,90}, Color={245,173,61}, Material="Glass", Transparency=0.12, CanCollide=false},
		{Name="Bottle3", Type="Block", Size={1.0,2.2,0.8}, Position={0.7,0.35,-3.05}, Color={78,150,228}, Material="Glass", Transparency=0.12, CanCollide=false},
		{Name="Bottle4", Type="Cylinder", Size={1.0,1.8,1.0}, Position={2.0,0.1,-3.05}, Rotation={0,0,90}, Color={142,81,199}, Material="Glass", Transparency=0.12, CanCollide=false}
	}
}

function Examples.FridgeJSON(): string
	return HttpService:JSONEncode(fridge)
end

function Examples.TrunkJSON(): string
	return HttpService:JSONEncode(trunk)
end

return Examples
