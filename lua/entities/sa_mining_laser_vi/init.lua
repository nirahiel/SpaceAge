AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_vi
end

function ENT:CalcVars(ply)
	if ply.UserGroup ~= "miners" and ply.UserGroup ~= "alliance" then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(self, ply)
end
