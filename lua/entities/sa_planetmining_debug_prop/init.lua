AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Holograms/hq_sphere.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetNWFloat("Scale", 1)
end

function ENT:SetDensity(scale)
	self:SetNWFloat("Scale", (scale / 6))
end

function ENT:StartTouch(ent)
end
function ENT:EndTouch(ent)
end

function ENT:Think()
end