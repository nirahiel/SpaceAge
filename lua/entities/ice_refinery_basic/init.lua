AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	BaseClass.Initialize(self)

	self:SetModel(self.Model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end

	RD.AddResource(self, "energy", 0)
	RD.AddResource(self, "liquid nitrogen", 0)
	RD.AddResource(self, "water", 0)
	RD.AddResource(self, "heavy water", 0)

	for type, _ in pairs(SA.Ice.Types) do
		RD.AddResource(self, type, 0)
	end

	RD.AddResource(self, "oxygen isotopes", 0)
	RD.AddResource(self, "hydrogen isotopes", 0)
	RD.AddResource(self, "helium isotopes", 0)
	RD.AddResource(self, "nitrogen isotopes", 0)
	RD.AddResource(self, "liquid ozone", 0)
	RD.AddResource(self, "strontium clathrates", 0)

	self:SetOverlayText(self.PrintName .. "\n" .. "Progress: 0%")

	self.Inputs = Wire_CreateInputs(self, { "Activate" })
	self.Outputs = Wire_CreateOutputs(self, { "Active", "Progress" })

	self.ShouldRefine = false;
	self.CurrentRef = nil;
	self.Volume = 0;
	self.NextCycle = 0;

	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_refinery_level[1] < self.MinIceRefineryMod then
		return self:Remove()
	end
end

function ENT:Refine()
	local own = SA.PP.GetOwner(self)
	if own and own.IsAFK then return end

	local CurEnergy = RD.GetResourceAmount(self, "energy")
	local EnergyReq = self.CycleEnergy / self.CycleTime

	if (CurEnergy > EnergyReq) then
		if not self.CurrentRef then
			for type, _ in pairs(SA.Ice.Types) do
				local Avail = RD.GetResourceAmount(self, type)
				if (Avail > 0) then
					self.CurrentRef = type
					self.Volume = 1000
					RD.ConsumeResource(self, type, 1)
					Wire_TriggerOutput(self, "Active", 1)
					break
				end
			end
		end
		if (self.CurrentRef) then
			RD.ConsumeResource(self, "energy", EnergyReq)

			local RefSpeed = (self.CycleVol / self.CycleTime) * 1000
			self.Volume = self.Volume - RefSpeed
			local Progress = math.Clamp((1000-self.Volume) / 10, 0, 100)
			Wire_TriggerOutput(self, "Progress", Progress)
			self:SetOverlayText(self.PrintName .. "\nProgress: " .. tostring(Progress) .. "%")
			if (self.Volume <= 0) then
				local gives = SA.Ice.GetRefined(self.CurrentRef, self.RefineEfficiency)
				for res, count in pairs(gives) do
					RD.SupplyResource(self, res, count)
				end
				self.CurrentRef = nil
				Wire_TriggerOutput(self, "Active", 0)
				Wire_TriggerOutput(self, "Progress", 0)
				self:SetOverlayText(self.PrintName .. "\nProgress: 0%")
			end
		end
	end
end

function ENT:Think()
	BaseClass.Think(self)

	if (self.ShouldRefine and self.NextCycle < CurTime()) then
		self:Refine()
		self.NextCycle = CurTime() + 1
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then
		if value == 1 then
			self.ShouldRefine = true
		else
			self.ShouldRefine = false
			Wire_TriggerOutput(self, "Active", 0)
			Wire_TriggerOutput(self, "Progress", 0)
			self:SetOverlayText(self.PrintName .. "\nProgress: 0%")
		end
	end
end
