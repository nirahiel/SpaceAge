AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:GetCapacity(ply)
	if not (ply.tibstoragemod > 0 and (ply.UserGroup == "legion" or ply.UserGroup == "alliance")) then
		self:Remove()
	end
	return (1550000 + (ply.tiberiummod * 10000)) * ply.devlimit
end
