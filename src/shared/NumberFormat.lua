--!strict

local NumberFormat = {}

local SUFFIXES = {
	{ 1e12, "T" },
	{ 1e9, "B" },
	{ 1e6, "M" },
	{ 1e3, "K" },
}

local function trim(value: string): string
	value = string.gsub(value, "(%..-)0+$", "%1")
	value = string.gsub(value, "%.$", "")
	return value
end

function NumberFormat.Compact(value: number): string
	local sign = if value < 0 then "-" else ""
	local absolute = math.abs(value)

	for _, pair in SUFFIXES do
		local threshold = pair[1]
		local suffix = pair[2]
		if absolute >= threshold then
			local scaled = absolute / threshold
			local decimals = if scaled < 10 then 2 elseif scaled < 100 then 1 else 0
			return sign .. trim(string.format("%." .. decimals .. "f", scaled)) .. suffix
		end
	end

	return sign .. tostring(math.floor(absolute + 0.5))
end

function NumberFormat.Cash(value: number): string
	return "$" .. NumberFormat.Compact(value)
end

function NumberFormat.Rate(valuePerMinute: number): string
	return "+$" .. NumberFormat.Compact(valuePerMinute) .. "/min"
end

return table.freeze(NumberFormat)
