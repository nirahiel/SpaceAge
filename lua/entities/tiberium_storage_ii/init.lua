AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	local ply = self:GetTable().Founder
	if not (ply.tibstoragemod > 0 and (ply.UserGroup == "legion" or ply.UserGroup == "alliance")) then
		self:Remove()
	end
end

function ENT:GetCapacity(ply)
	return (1550000 + (ply.tiberiummod * 10000)) * ply.devlimit
end
