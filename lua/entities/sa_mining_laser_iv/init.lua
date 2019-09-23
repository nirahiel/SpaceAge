AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

ENT.EnergyBase = 2400
ENT.BeamWidthOffset = 40
ENT.YieldOffset = 15000
ENT.YieldIncrement = 50

function ENT:GetPlayerLevel(ply)
	return ply.miningyield_iv
end

function ENT:CalcColor(level)
	self:SetNetworkedColor("c", Color(0, math.floor(level * 0.85), 255))
end
