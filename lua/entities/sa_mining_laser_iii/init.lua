AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

ENT.EnergyBase = 1800
ENT.BeamWidthOffset = 30
ENT.YieldOffset = 6000
ENT.YieldIncrement = 25

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_iii
end

function ENT:CalcColor(level)
	self:SetNetworkedColor("c", Color(255 - math.floor(level * 0.85), 0, 255))
end
