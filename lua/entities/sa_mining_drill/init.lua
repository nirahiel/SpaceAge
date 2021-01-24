AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:GetPlayerLevel(ply)
	return ply.sa_data.research.tiberium_drill_yield[self.MinTibDrillMod + 1]
end

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:AddResource("energy", 0, 0)
	self:AddResource("tiberium", 0, 0)
	self.Active = 0
	self.damage = 30
	self.TouchEnt = nil
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Output" })
	end

	self.CrystalResistant = true

	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(120)
		phys:Wake()
	end

	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.tiberium_drill_level[1] < self.MinTibDrillMod then
		self:Remove()
		return
	end

	local miningmod = 1
	if ply.sa_data.faction_name == "miners" or ply.sa_data.faction_name == "alliance" then
		miningmod = 1.33
	elseif ply.sa_data.faction_name == "starfleet" then
		miningmod = 1.11
	end
	local level = self:GetPlayerLevel(ply)
	local energycost = ply.sa_data.research.mining_energy_efficiency[1] * 50
	if (energycost > self.EnergyBase * 0.75) then
		energycost = self.EnergyBase * 0.75
	end
	self.consume = self.EnergyBase - energycost
	self.yield = math.floor((self.YieldOffset + (level * self.YieldIncrement)) * miningmod) * 2
	self.oldyield = self.yield
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		if (self:GetResourceAmount("energy") < self.consume) then
			self:TurnOff()
			return
		end
		if WireAddon then
			Wire_TriggerOutput(self, "On", 1)
		end
		self:SetOOO(1)
		self:SetNWBool("o", false)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		if WireAddon then
			Wire_TriggerOutput(self, "On", 0)
		end
		self:SetOOO(0)
		self:SetNWBool("o", false)
	end
end

function ENT:OnRemove()

end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		self:SetActive(value)
	end
end

function ENT:StartTouch(ent)
	if ent.IsCrystal then
		self.TouchEnt = ent
	end
end

function ENT:EndTouch(ent)
	if ent.IsCrystal then
		self.TouchEnt = nil
	end
end

function ENT:Think()
	BaseClass.Think(self)
	if (self.Active == 1) then
		if (self:GetResourceAmount(self, "energy") >= self.consume) then
			self:ConsumeResource(self, "energy", self.consume)
			local myOwner = SA.PP.GetOwner(self)
			if self.TouchEnt and self.TouchEnt.IsCrystal and myOwner and myOwner:IsValid() and myOwner:GetPos():Distance(self:GetPos()) <= 350 and myOwner:InVehicle() then
				local skin = self.TouchEnt:GetSkin()
				if skin == 2 then
					self.yield = math.floor(self.oldyield * 1.5)
				elseif skin == 0 then
					self.yield = math.floor(self.oldyield * 1.2)
				else
					self.yield = self.oldyield
				end
				SA.Functions.MineThing(self, self.TouchEnt, "tiberium")
				self.yield = self.oldyield
			end
		else
			self:TurnOff()
		end
	else
		self:TurnOff()
	end
	self:NextThink(CurTime() + 1)
	return true
end
