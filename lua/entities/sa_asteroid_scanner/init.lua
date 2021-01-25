AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:AddResource("energy", 0, 0)
	self.Active = 0
	if (WireAddon ~= nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "Result" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(1)
		phys:Wake()
	end
	self.consume = 25
	self.BeamLength = 3000
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self:SetOOO(1)
		self:SetNWBool("o", true)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:SetOOO(0)
		self:SetNWBool("o", false)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

local function ScanRoid(ent)
	local pos = ent:GetPos()
	local up = ent:GetAngles():Up()
	local tr = util.TraceLine({start = pos + (up * ent:OBBMaxs().z), endpos = pos + (up * ent.BeamLength), filter = { ent }})
	local hitent = tr.Entity
	if (not hitent) then return end
	if hitent.IsAsteroid or hitent.IsCrystal then
		ent:UpdateResultOutput((hitent.health / hitent.maxhealth) * 100)
	elseif hitent.IsOreStorage then
		local amount, capacity = hitent:GetResourceData("ore")
		ent:UpdateResultOutput((amount / capacity) * 100)
	else
		ent:UpdateResultOutput(0)
	end
end

function ENT:UpdateResultOutput(result)
	Wire_TriggerOutput(self, "Result", result)
end

function ENT:Think()
	BaseClass.Think(self)
	if (self.Active == 1) then
		if self:ConsumeResource("energy", self.consume) < self.consume then
			self:TurnOff()
		else
			ScanRoid(self)
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end
