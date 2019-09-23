AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

ENT.EnergyBase = 3000
ENT.BeamWidthOffset = 50
ENT.YieldOffset = 30000
ENT.YieldIncrement = 200

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_v
end

function ENT:CalcColor(level)
	self:SetNetworkedColor("c", Color(0, 255, 255 - math.floor(level * 0.85)))
end
