SA.REQUIRE("ice.main")

function SA.Ice.GetRefined(ore, efficiency)
	if not efficiency then
		efficiency = 0.5
	end

	local refineTable = SA.Ice.Types[ore].refineTable
	local results = {}
	for res, mult in pairs(refineTable) do
		results[res] = math.floor(mult * efficiency)
	end
	return results
end
