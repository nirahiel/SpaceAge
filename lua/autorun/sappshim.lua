SAPPShim = {}

function SAPPShim.GetOwner(ent)
	return ent:CPPIGetOwner()
end

function SAPPShim.MakeOwner(ent, owner)
	return ent:CPPISetOwner(owner)
end

function SAPPShim.IsWorldEnt(ent)
	local owner, ownerId = ent:CPPISetOwner()
	return not ownerId
end

function SAPPShim.PlyCanPerform(ply, ent)
	return ent:CPPICanPhysgun(ply)
end

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:IsVIP(self)
	return false
end
