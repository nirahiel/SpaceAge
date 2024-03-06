AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")
DEFINE_BASECLASS("rd_pump")

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	local ent = ents.Create("sa_terminal_pump")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	if self:KillIfSpawned() then return end
	BaseClass.Initialize(self)

	self.SkipSBChecks = true

	self:PhysicsInit(SOLID_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:SetNotSolid(true)
	self:DrawShadow(false)

	self.ownerchecked = false
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:SetMass(50000)
	end

	self:SetPumpName(nil, "SA_Terminal_" .. tostring(self:EntIndex()))
end

function ENT:AutospawnDone()
end

function ENT:Think()
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:Receive(res, amount, temperature)
	if not IsValid(self.otherpump) then return end
	local _, ownerId = self.otherpump:CPPIGetOwner()
	if not ownerId then return end
	SA.Terminal.AddTempStorage(ownerId, res, amount)
	return 0
end
