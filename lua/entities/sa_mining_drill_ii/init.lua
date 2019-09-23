AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:GetPlayerLevel(ply)
	return ply.tiberiumyield_ii
end

ENT.EnergyBase = 1200
ENT.YieldOffset = 100
ENT.YieldIncrement = 20

function ENT:CalcVars(ply)
	if not (ply.tibdrillmod > 0 and (ply.UserGroup == "legion" or ply.UserGroup == "alliance")) then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(ply)
end
