SA.SaveSystem = {}

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

duplicator.RegisterConstraint("Parent", function(ent1, ent2)
	if IsValid(ent1) and IsValid(ent2) then
		ent1:SetParent(ent2)
	end
end, "Ent1", "Ent2")

function SA.SaveSystem.Save(ply)
	if not IsValid(ply) then
		return
	end

	local parents = {}
	local toSave = {}
	for _, ent in pairs(ents.GetAll()) do
		local own = ent:CPPIGetOwner()
		if own ~= ply then
			continue
		end
		parents[ent] = ent:GetParent()
		table.insert(toSave, ent)
	end

	local dupe = duplicator.CopyEnts(toSave)

	for ent, parent in pairs(parents) do
		local own = parent:CPPIGetOwner()
		if own ~= ply then
			continue
		end
		dupe.Constraints["Parent_" .. ent:EntIndex()] = {
			Bone1 = 0,
			Type = "Parent",
			Entity = {
				{ Bone = 0, World = false, Index = ent:EntIndex() },
				{ Bone = 0, World = false, Index = parent:EntIndex() },
			},
		}
	end

	file.Write(SaveFileName(ply), util.TableToJSON(dupe))
end

function SA.SaveSystem.Restore(ply)
	if not IsValid(ply) then
		return
	end
	local data = file.Read(SaveFileName(ply), "DATA")
	if not data then
		return
	end
	data = util.JSONToTable(data)

	DisablePropCreateEffect = true

	local pasted = duplicator.Paste(ply, data.Entities, data.Constraints)
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
