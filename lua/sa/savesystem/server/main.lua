SA.SaveSystem = {}

local RestoredFiles = {}

local function SaveFileName(ply)
	if ply and ply.SteamID then
		ply = ply:SteamID()
	end
	return "sa_rdsave_" .. ply:lower():Replace(":", "_") .. ".txt"
end

local function GetRDNetIDData(netid)
	if not netid or netid <= 0 then
		return
	end
	return SA.RD.GetNetTable(netid)
end

local function AddRes(ownId, resource, value, playerData, valuables)
	if not valuables[resource] then
		return
	end
	if not value or value <= 0 then
		return
	end

	local ownData = playerData[ownId]
	if not ownData then
		ownData = {}
		playerData[ownId] = ownData
	end
	ownData[resource] = (ownData[resource] or 0) + value
end

function SA.SaveSystem.SaveAll()
	local nodes = ents.FindByClass("resource_node")
	local valuables = SA.GetValuableResources()

	local playerData = {}
	for _, node in pairs(nodes) do
		local _, ownId = node:CPPIGetOwner()
		if not ownId then
			return
		end

		local netData = GetRDNetIDData(node.netid)
		if not netData or not netData.resources then
			continue
		end

		for name, res in pairs(netData.resources) do
			AddRes(ownId, name, res.value, playerData, valuables)
		end
	end

	for ownId, data in pairs(playerData) do
		file.Write(SaveFileName(ownId), util.TableToJSON({
			owner = ownId,
			resData = data,
		}))
	end
end

function SA.SaveSystem.Save(ply)
	SA.SaveSystem.SaveAll()
end

function SA.SaveSystem.Restore(ply)
	local name = SaveFileName(ply)
	if RestoredFiles[name] then
		return
	end
	RestoredFiles[name] = true

	local data = file.Read(name, "DATA")
	if not data then
		return
	end
	data = util.JSONToTable(data)
	file.Delete(name)

	local remaining = ply.sa_data.station_storage.remaining
	if remaining <= 0 then
		return
	end

	local stationStorage = ply.sa_data.station_storage.contents
	for resource, value in pairs(data.resData) do
		if remaining <= 0 then
			break
		end
		if value > remaining then
			value = remaining
		end
		stationStorage[resource] = (stationStorage[resource] or 0) + value
		remaining = remaining - value
		ply:ChatPrint("Restored " .. tostring(value) .. " " .. SA.RD.GetProperResourceName(resource) .. " to station storage!")
	end
	ply.sa_data.station_storage.remaining = remaining
end

hook.Add("PlayerInitialSpawn", "SA_SaveSystem_RestorePlayer", function(ply)
	SA.SaveSystem.Restore(ply)
end)
for _, ply in pairs(player.GetHumans()) do
	RestoredFiles[SaveFileName(ply)] = true
end
