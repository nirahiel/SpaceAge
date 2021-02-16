SA.SaveSystem = {}

local SA_PASTE_RUNNING = false
local NodeDupeTables = {}

local function SaveFileName(ply)
	if ply and ply.SteamID then
		ply = ply:SteamID()
	end
	return "sa_save_" .. ply:Replace(":", "_") .. ".txt"
end

function SA.SaveSystem.SaveAll(cb)
	NodeDupeTables = {}
	local i = 0
	for _, ply in pairs(player.GetHumans()) do
		local xply = ply
		timer.Simple(i, function()
			SA.SaveSystem.Save(xply)
		end)
		i = i + 1
	end
	if cb then
		timer.Simple(i, cb)
	end
end
timer.Create("SA_SaveSystem_SaveAll", 60 * 10, 0, SA.SaveSystem.SaveAll)

duplicator.RegisterConstraint("SA_Parent", function(ent1, ent2)
	if not SA_PASTE_RUNNING then
		return
	end

	if IsValid(ent1) and IsValid(ent2) then
		ent1:SetParent(ent2)
	end
end, "Ent1", "Ent2")

duplicator.RegisterConstraint("SA_RDNetData", function(ent, tbl)
	if not SA_PASTE_RUNNING then
		return
	end

	local netid = ent:GetNWInt("netid")

	for name, data in pairs(tbl) do
		if data.value <= 0 then
			continue
		end

		SA.RD.SupplyNetResource(netid, name, data.value, data.temperature)
	end
end, "Ent1", "NetTable")

local function GetRDNetIDData(netid)
	if netid <= 0 then
		return
	end
	return SA.RD.GetNetTable(netid)
end

local function GetRDNetData(node)
	if node:GetClass() ~= "resource_node" then
		return
	end
	local netid = node:GetNWInt("netid")
	return netid, GetRDNetIDData(netid)
end

function SA.SaveSystem.Save(ply)
	if not IsValid(ply) then
		return
	end
	local sid = ply:SteamID()

	local nodes = {}
	local parents = {}
	local toSave = {}
	for _, ent in pairs(ents.GetAll()) do
		local own = ent:CPPIGetOwner()
		if own ~= ply then
			continue
		end
		parents[ent] = ent:GetParent()
		table.insert(toSave, ent)
		nodes[ent] = {GetRDNetData(ent)}
	end

	local dupe = duplicator.CopyEnts(toSave)
	dupe.Owner = sid

	for ent, parent in pairs(parents) do
		local own = parent:CPPIGetOwner()
		if own ~= ply then
			continue
		end
		dupe.Constraints["Parent_" .. ent:EntIndex()] = {
			Type = "SA_Parent",
			Entity = {
				{ Bone = 0, World = false, Index = ent:EntIndex() },
				{ Bone = 0, World = false, Index = parent:EntIndex() },
			},
		}
	end

	for ent, data in pairs(nodes) do
		local netId = data[1]
		local nodeData = data[2]
		if not netId or not nodeData or not nodeData.resources then
			continue
		end
		local tblC = {
			Type = "SA_RDNetData",
			Entity = {
				{ Bone = 0, World = false, Index = ent:EntIndex() },
			},
			NetTable = nodeData.resources,
		}
		dupe.Constraints["RDNet_" .. netId] = tblC
		NodeDupeTables[netId] = {
			tbl = tblC,
			dupe = dupe,
			ply = sid,
		}
	end

	for idx, _ in pairs(dupe.Entities) do
		local ent = Entity(idx)
		local own = ent:CPPIGetOwner()
		if own ~= ply then
			dupe.Entities[idx] = nil
		end
	end

	SA.SaveSystem.SaveDupe(dupe)
end

function SA.SaveSystem.SaveNetID(netId)
	if not netId or netId < 0 then
		return
	end
	local data = GetRDNetIDData(netId)

	local tbl = NodeDupeTables[netId]
	if not tbl then
		return
	end

	if not data or not data.resources then
		tbl.tbl.NetTable = nil
		tbl.dupe.Constraints["RDNet_" .. netId] = nil
	else
		tbl.tbl.NetTable = data.resources
	end

	return tbl.dupe
end

function SA.SaveSystem.SaveDupe(dupe)
	local ply = player.GetBySteamID(dupe.Owner)
	if IsValid(ply) then
		dupe.OwnerPos = ply:GetPos()
	end
	file.Write(SaveFileName(dupe.Owner), util.TableToJSON(dupe))
end

function SA.SaveSystem.Delete(ply)
	file.Delete(SaveFileName(ply))
end
hook.Add("PlayerDisconnected", "SA_SaveSystem_Cleanup", function(ply)
	local sid = ply:SteamID()
	timer.Create("SA_SaveSystem_CleanupTimer_" .. sid, 300, 1, function()
		if IsValid(player.GetBySteamID(sid)) then
			return
		end
		SA.SaveSystem.Delete(sid)
	end)
end)

function SA.SaveSystem.Restore(ply, delete)
	if not IsValid(ply) then
		return
	end

	local fileName = SaveFileName(ply)
	local data = file.Read(fileName, "DATA")
	if not data then
		return
	end
	data = util.JSONToTable(data)

	if delete then
		file.Delete(fileName)
	end

	DisablePropCreateEffect = true

	SA_PASTE_RUNNING = true
	local pasted = duplicator.Paste(ply, data.Entities, data.Constraints)
	SA_PASTE_RUNNING = false

	for _, ent in pairs(pasted) do
		ent:CPPISetOwner(ply)
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
			ply:AddFrozenPhysicsObject(ent, phys)
		end
		ply:AddCleanup("duplicates", ent)
	end

	DisablePropCreateEffect = nil
end
