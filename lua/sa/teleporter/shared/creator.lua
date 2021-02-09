local function MakeMap()
	local otherLocations = {}
	local planetTeleporters = {}

	for _, otherEnt in pairs(ents.FindByClass("sa_teleport_panel")) do
		local otherName = otherEnt:GetNWString("TeleKey")
		if not otherLocations[otherName] then
			local otherPlanet = SA.SB.FindClosestPlanet(otherEnt:GetPos(), false).name
			otherLocations[otherName] = otherPlanet
			planetTeleporters[otherPlanet] = otherName
		end
	end

	local planets = {}
	for _, p in pairs(SA.SB.GetPlanets()) do
		local op = planets[p.name]
		if op and op.radius >= p.radius then
			continue
		end
		planets[p.name] = {
			position = p.position,
			radius = p.radius,
			teleporterName = planetTeleporters[p.name],
		}
	end

	return {
		planets = planets,
	}
end

local function WriteMap(ply)
	if SERVER and IsValid(ply) and not ply:IsAdmin() then
		return
	end

	local map = MakeMap()
	local mapStr = "DefineMap(\"" .. game.GetMap() .. "\", { planets = {\n"
	for n, p in pairs(map.planets) do
		mapStr = mapStr .. "\t[\"" .. n .. "\"] = {\n"
		mapStr = mapStr .. "\t\tradius = " .. p.radius .. ",\n"
		if p.teleporterName then
			mapStr = mapStr .. "\t\tteleporterName = \"" .. p.teleporterName .. "\",\n"
		end
		mapStr = mapStr .. "\t\tposition = Vector(" .. p.position.x .. "," .. p.position.y .. "," .. p.position.z .. "),\n"
		mapStr = mapStr .. "\t},\n"
	end
	mapStr = mapStr .. "}})"
	file.Write("sa_teleporters_" .. game.GetMap() .. ".txt", mapStr)
end
concommand.Add("sa_make_teleporter_map", WriteMap)
