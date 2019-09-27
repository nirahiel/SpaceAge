local SA_MaxNameLength = 24

SA.StatsTable = {}

local function SA_ReceiveStatsUpdate(body, code)
	if code ~= 200 then
		return
	end

	for i, v in pairs(body) do
		SA.StatsTable[i] = {}
		SA.StatsTable[i].Name = string.Left(v.Name, SA_MaxNameLength)
		SA.StatsTable[i].TotalCredits = SA.AddCommasToInt(v.TotalCredits)
		local tempColor = SA.Factions.Colors[v.FactionName]
		if (not tempColor) then tempColor = Color(255, 100, 0, 255) end
		SA.StatsTable[i].FactionColor = tempColor
		--[[ SA.StatsTable[i].StatsColor = Color(255, 255, 255, 255)
		 if (tcredits) then
			if tcredits < 0 then tempColor = Color(255, 0, 0, 255) end
			if tcredits > 0 then tempColor = Color(0, 255, 0, 255) end
			SA.StatsTable[i].StatsColor = tempColor
		else
			print("error, variable tcredits does not exist cl_init.lua around line 137 breh")
		end ]]
	end
end
local function SA_RequestStatsUpdate()
	SA.API.Get("/players", SA_ReceiveStatsUpdate)
end
timer.Create("SA_StatsUpdater", 30, 0, SA_RequestStatsUpdate)
timer.Simple(2, SA_RequestStatsUpdate)
