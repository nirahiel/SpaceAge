AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

ENT.EnergyBase = 5000
ENT.BeamWidthOffset = 0
ENT.YieldOffset = 60000
ENT.YieldIncrement = 200

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_vi
end

function ENT:CalcColor(level)
	-- no-op
end

function ENT:CalcVars(ply)
	if ply.UserGroup ~= "miners" and ply.UserGroup ~= "alliance" then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(self, ply)
end
