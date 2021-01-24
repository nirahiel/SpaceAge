AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.vent = false
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = { }
		self.Outputs = Wire_CreateOutputs(self, { "Permafrost", "TerraCrystal", "Dark Matter", "Max Permafrost", "Max TerraCrystal", "Max Dark Matter" })
	else
		self.Inputs = { }
	end
	self:AddResource("terracrystal", 1000000)
	self:AddResource("dark matter", 1000000)
	self:AddResource("permafrost", 1000000)
	self.caf.custom.masschangeoverride = true
	local pl = self:GetTable().Founder
	if pl and pl:IsValid() and pl:IsPlayer() and pl.sa_data.score and pl.sa_data.score < 1000000 then
		self:Remove()
		return
	end
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:UpdateMass()
end

function ENT:Think()
	BaseClass.Think(self)

	if WireAddon ~= nil then
		self:UpdateWireOutput()
	end
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	local dm = self:GetResourceAmount("dark matter")
	local tc = self:GetResourceAmount("terracrystal")
	local pf = self:GetResourceAmount("permafrost")
	local maxdm = self:GetNetworkCapacity("dark matter")
	local maxtc = self:GetNetworkCapacity("terracrystal")
	local maxpf = self:GetNetworkCapacity("permafrost")

	Wire_TriggerOutput(self, "Dark Matter", dm)
	Wire_TriggerOutput(self, "Permafrost", pf)
	Wire_TriggerOutput(self, "TerraCrystal", tc)
	Wire_TriggerOutput(self, "Max Dark Matter", maxdm)
	Wire_TriggerOutput(self, "Max Permafrost", maxpf)
	Wire_TriggerOutput(self, "Max TerraCrystal", maxtc)
end
