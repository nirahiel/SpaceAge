AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	local ent = ents.Create("sa_sign")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self.SkipSBChecks = true

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.ownerchecked = false
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:SetMass(50000)
	end
end
