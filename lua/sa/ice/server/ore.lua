SA.REQUIRE("ice.main")

function SA.Ice.GetRefined(ply, ore, efficiency)
	if not efficiency then
		efficiency = 0.5
	end

	local factionmul = 1.00
	if ply.sa_data.faction_name == "ice" or ply.sa_data.faction_name == "alliance" then
		factionmul = 1.33
	end

	local refineTable = SA.Ice.Types[ore].refineTable
	local results = {}
	for res, mult in pairs(refineTable) do
		results[res] = math.floor(mult * factionmul * efficiency)
	end
	return results
end
