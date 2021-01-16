AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.WorldInternal = true

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self:SetModel("models/props_combine/combine_intwallunit.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableMotion(false)
		phys:SetMass(50000)
	end

	if not self.TeleKey then self.TeleKey = "default" end
	self.LastUse = 0
end

function ENT:Use(ply, called)
	if self.LastUse > CurTime() then return end
	SA.Teleporter.Open(ply, self.TeleKey)
	self.LastUSe = CurTime() + 1
end
