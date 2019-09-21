SAPPShim = {}

function SAPPShim.GetOwner(ent)

end

function SAPPShim.MakeOwner(ent, owner)
	return nil
end

function SAPPShim.IsWorldEnt(ent)
	return false
end

function SAPPShim.PlyCanPerform(ply, ent)
	return true
end

local PlayerMeta = FindMetaTable("Player")
function PlayerMeta:IsVIP(self)
	return false
end
