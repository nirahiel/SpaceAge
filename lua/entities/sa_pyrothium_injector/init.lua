AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

util.PrecacheSound("common/warning.wav")
util.PrecacheSound("ambient/energy/electric_loop.wav")

DEFINE_BASECLASS("sa_base_rd3_entity")

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.Active = 0

	RD.RegisterNonStorageDevice(self)

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Boost" })
	end

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.lasersound = CreateSound(self, "ambient/energy/electric_loop.wav")
	self.energyCost = 1000
	self.pyrothiumCost = 50

	self.BeamLength = 1000
end

function ENT:TurnOn()
	if self.Active == 0 then
		self.Active = 1
		self.lasersound:Play()
		if WireAddon then
			Wire_TriggerOutput(self, "On", 1)
		end
		self:SetOOO(1)
		self:SetNWBool("o", true)
	end
end

function ENT:TurnOff()
	if self.Active == 1 then
		self.Active = 0
		self.lasersound:Stop()
		if WireAddon then
			Wire_TriggerOutput(self, "On", 0)
		end
		self:SetOOO(0)
		self:SetNWBool("o", false)
	end
end

function ENT:OnRemove()
	BaseClass.OnRemove(self)
	self.lasersound:Stop()
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		self:SetActive(value)
	end
end

function ENT:Think()
	BaseClass.Think(self)

	if self.Active == 1 then
		local availableEnergy = RD.GetResourceAmount(self, "energy")
		local availablePyrothium = RD.GetResourceAmount(self, "pyrothium")
		if availableEnergy < self.energyCost or availablePyrothium < self.pyrothiumCost then
			self:TurnOff()
			Wire_TriggerOutput(self, "Boost", 0)
			return
		end
		self:ConsumeResource("energy", self.energyCost)
		self:ConsumeResource("pyrothium", self.pyrothiumCost)
		local boosted = SA.Pyrothium.Boost(self)
		Wire_TriggerOutput(self, "Boost", boosted)
	end

	self:NextThink(CurTime() + 1)
	return true
end
