local RankConfig = {}

RankConfig.Ranks = {
	{ MinimumEarnings = 0, Name = "Intern" },
	{ MinimumEarnings = 500, Name = "Trainee" },
	{ MinimumEarnings = 2_000, Name = "Driver" },
	{ MinimumEarnings = 7_500, Name = "Senior Driver" },
	{ MinimumEarnings = 20_000, Name = "Insurance Risk" },
	{ MinimumEarnings = 50_000, Name = "Delivery Menace" },
}

function RankConfig.GetRank(lifetimeEarnings)
	local rankName = RankConfig.Ranks[1].Name

	for _, rank in RankConfig.Ranks do
		if lifetimeEarnings >= rank.MinimumEarnings then
			rankName = rank.Name
		else
			break
		end
	end

	return rankName
end

return RankConfig
