AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.WorldInternal = true

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:OnRemove()
	SA.Ore.OnAsteroidRemove(self)
end
