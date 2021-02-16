SA.SaveSystem = {}

local RD = CAF.GetAddon("Resource Distribution")

local SA_PASTE_RUNNING = false

local function SaveFileName(ply)
	if ply and ply.SteamID then
		ply = ply:SteamID()
	end
	return "sa_save_" .. ply:Replace(":", "_") .. ".txt"
end

function SA.SaveSystem.SaveAll()
	for _, ply in pairs(player.GetHumans()) do
		SA.SaveSystem.Save(ply)
	end
end

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

		RD.SupplyNetResource(netid, name, data.value, data.temperature)
	end
end, "Ent1", "NetTable")

local function GetRDNetData(node)
	if node:GetClass() ~= "resource_node" then
		return
	end
	local netid = node:GetNWInt("netid")
	if netid <= 0 then
		return
	end
	return RD.GetNetTable(netid)
end

function SA.SaveSystem.Save(ply)
	if not IsValid(ply) then
		return
	end

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
		nodes[ent] = GetRDNetData(ent)
	end

	local dupe = duplicator.CopyEnts(toSave)

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
		if not data and data.resources then
			continue
		end
		dupe.Constraints["RDNet_" .. ent:EntIndex()] = {
			Type = "SA_RDNetData",
			Entity = {
				{ Bone = 0, World = false, Index = ent:EntIndex() },
			},
			NetTable = data.resources,
		}
	end

	file.Write(SaveFileName(ply), util.TableToJSON(dupe))
end

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
