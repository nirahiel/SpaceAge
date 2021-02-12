SA.REQUIRE("research.main")

function SA.Research.GetNextInfoByName(ply, name)
	return SA.Research.GetNextInfo(ply, SA.Research.GetByName(name))
end

function SA.Research.RequirementToString(v)
	if type(v) == "string" then
		return v
	end

	if v[1] == "faction" then
		local o = {}
		for _, f in pairs(v[2]) do
			table.insert(o, SA.Factions.ToLong[f])
		end
		return "Factions: " .. table.concat(o, ", ")
	end

	local res = SA.Research.GetByName(v[1])
	return "Research: " .. res.display .. " rank " .. v[2]
end

local function Research_Check_Requirements(ply, reqs, missingReqs, fulfilledReqs, stopOnFail)
	if not reqs then
		return true
	end

	for k, v in pairs(reqs) do
		if v[1] == "faction" then
			if not table.HasValue(v[2], ply.sa_data.faction_name) then
				table.insert(missingReqs, v)
				if stopOnFail then
					return false
				end
			else
				table.insert(fulfilledReqs, v)
			end
		elseif SA.Research.GetFromPlayer(ply, v[1]) < v[2] then
			table.insert(missingReqs, v)
			if stopOnFail then
				return false
			end
		else
			table.insert(fulfilledReqs, v)
		end
	end

	return #missingReqs == 0
end

function SA.Research.GetLevelInfo(ply, Research, stopOnFail, level)
	local cap = Research.ranks
	if cap ~= 0 and cap < level then
		return false, 0, {}, {}
	end

	local cost = Research.cost
	local devl = ply.sa_data.advancement_level - 1
	if devl < 0 then
		devl = 0
	end
	local total = cost + (cost * Research.costinc) * (level - 1)
	total = mmath.ceil(total + (total * (devl * 0.8)))

	if ply.sa_data.faction_name == "legion" or ply.sa_data.faction_name == "alliance" then
		total = math.ceil(total * 0.66)
	elseif ply.sa_data.faction_name == "starfleet" then
		total = math.ceil(total * 0.88)
	end

	local missingReqs = {}
	local fulfilledReqs = {}

	local reqtype = Research.type
	if reqtype ~= "none" then
		local prereq = Research.prereq
		if reqtype == "unlock" then
			if not Research_Check_Requirements(ply, prereq, missingReqs, fulfilledReqs, stopOnFail) then
				return false, total, missingReqs, fulfilledReqs
			end
		elseif reqtype == "perrank" then
			local tbl = Research.prereq[level]
			if not Research_Check_Requirements(ply, tbl, missingReqs, fulfilledReqs, stopOnFail) then
				return false, total, missingReqs, fulfilledReqs
			end
		end
	end

	return true, total, missingReqs, fulfilledReqs
end

function SA.Research.GetNextInfo(ply, Research, stopOnFail)
	local cur = SA.Research.GetFromPlayer(ply, Research.name)
	return SA.Research.GetLevelInfo(ply, Research, stopOnFail, cur + 1)
end
