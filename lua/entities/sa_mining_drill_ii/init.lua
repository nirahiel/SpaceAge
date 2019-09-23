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
	if ply.tibdrillmod < 1 or (ply.UserGroup ~= "legion" and ply.UserGroup ~= "alliance") then
		self:Remove()
		return
	end
	return self.BaseClass.CalcVars(ply)
end
