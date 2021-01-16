AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

ENT.WorldInternal = true

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(false)
	end
end

function ENT:OnRemove()
	local smokepuff = ents.Create("env_ar2explosion")
	smokepuff:SetPos(self:GetPos())
	smokepuff:SetKeyValue("material", "particle/particle_noisesphere")
	smokepuff:Spawn()
	smokepuff:Activate()
	smokepuff:Fire("explode", "", 0)
	smokepuff:Fire("kill", "", 10)

	if self.RespawnDelay and self.RespawnDelay > 0 then
		local mineralName = self.MineralName
		local icePattern = self.IcePattern
		local iceData = self.IceData
		timer.Simple(self.RespawnDelay, function() SA.Ice.SpawnRoid(mineralName, icePattern, iceData) end)
	end
end

function ENT:Think()
	if self.MineralAmount <= 1 then
		self:Remove()
		return false
	end

	if self.MineralAmount < self.MineralMax then
		local newamount = self.MineralAmount + (self.MineralRegen / (60 * 60))
		if newamount > self.MineralMax then
			self.MineralAmount = self.MineralMax
		else
			self.MineralAmount = newamount
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end


