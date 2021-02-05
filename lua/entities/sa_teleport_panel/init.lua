AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.WorldInternal = true

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self.SkipSBChecks = true

	self:SetModel("models/props_combine/combine_intwallunit.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:SetMass(50000)
	end
end

function ENT:Use(ply)
	SA.Teleporter.Open(ply, self)
end
