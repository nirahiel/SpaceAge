AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

ENT.EnergyBase = 1200
ENT.BeamWidthOffset = 20
ENT.YieldOffset = 2000
ENT.YieldIncrement = 12.5

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_ii
end

function ENT:CalcColor(level)
	self:SetNetworkedColor("c",Color(255, 0, math.floor(level * 0.85)))
end
