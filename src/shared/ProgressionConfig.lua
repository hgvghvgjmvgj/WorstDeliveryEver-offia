local ProgressionConfig = {}

ProgressionConfig.StartingUnlocked = 2

ProgressionConfig.Contracts = {
	{
		ObjectId = "Couch",
		UnlockCash = 0,
		Payout = 45,
	},
	{
		ObjectId = "Wardrobe",
		UnlockCash = 0,
		Payout = 60,
	},
	{
		ObjectId = "Sectional",
		UnlockCash = 100,
		Payout = 90,
	},
	{
		ObjectId = "Piano",
		UnlockCash = 180,
		Payout = 125,
	},
}

function ProgressionConfig.GetUnlockedCount(cash)
	local count = 0
	for _, contract in ProgressionConfig.Contracts do
		if cash >= contract.UnlockCash then
			count += 1
		end
	end
	return math.max(count, ProgressionConfig.StartingUnlocked)
end

function ProgressionConfig.GetContract(index)
	return ProgressionConfig.Contracts[index]
end

function ProgressionConfig.GetNextLocked(cash)
	for index, contract in ProgressionConfig.Contracts do
		if cash < contract.UnlockCash then
			return index, contract
		end
	end
	return nil, nil
end

return ProgressionConfig
