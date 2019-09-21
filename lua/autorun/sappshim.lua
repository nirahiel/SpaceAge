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
function PlayerMeta:IsVIP()
	return self.donator
end

function PlayerMeta:GetLevel()
	if self:IsSuperAdmin() then
		return 3
	end
	if self:IsAdmin() then
		return 2
	end
	if self:IsVIP() then
		return 1
	end
	return 0
end