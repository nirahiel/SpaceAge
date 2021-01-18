AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self:CalcVars(self:GetTable().Founder)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	self.Outputs = Wire_CreateOutputs(self, {
	"Oxygen Isotopes",
	"Hydrogen Isotopes",
	"Helium Isotopes",
	"Nitrogen Isotopes",
	"Liquid Ozone",
	"Heavy Water",
	"Strontium Clathrates",
	"Max Oxygen Isotopes",
	"Max Hydrogen Isotopes",
	"Max Helium Isotopes",
	"Max Nitrogen Isotopes",
	"Max Liquid Ozone",
	"Max Heavy Water",
	"Max Strontium Clathrates"})
end

function ENT:CalcVars(ply)
	local reqLvl = SA.Ice.GetLevelForProductStorageModel(self:GetModel())
	if ((reqLvl == nil) or (ply.sa_data.research.ice_product_storage_level[1] < reqLvl)) then self:Remove() return end

	local Capacity = math.floor(30000 * (2.25 ^ reqLvl)) * ply.sa_data.advancement_level

	RD.AddResource(self, "oxygen isotopes", Capacity)
	RD.AddResource(self, "hydrogen isotopes", Capacity)
	RD.AddResource(self, "helium isotopes", Capacity)
	RD.AddResource(self, "nitrogen isotopes", Capacity)
	RD.AddResource(self, "liquid ozone", Capacity)
	RD.AddResource(self, "heavy water", Capacity)
	RD.AddResource(self, "strontium clathrates", Capacity)

end

function ENT:Think()
	BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Oxygen Isotopes", RD.GetResourceAmount(self, "oxygen isotopes"))
	Wire_TriggerOutput(self, "Hydrogen Isotopes", RD.GetResourceAmount(self, "hydrogen isotopes"))
	Wire_TriggerOutput(self, "Helium Isotopes", RD.GetResourceAmount(self, "helium isotopes"))
	Wire_TriggerOutput(self, "Nitrogen Isotopes", RD.GetResourceAmount(self, "nitrogen isotopes"))
	Wire_TriggerOutput(self, "Liquid Ozone", RD.GetResourceAmount(self, "liquid ozone"))
	Wire_TriggerOutput(self, "Heavy Water", RD.GetResourceAmount(self, "heavy water"))
	Wire_TriggerOutput(self, "Strontium Clathrates", RD.GetResourceAmount(self, "strontium clathrates"))

	Wire_TriggerOutput(self, "Max Oxygen Isotopes", RD.GetNetworkCapacity(self, "oxygen isotopes"))
	Wire_TriggerOutput(self, "Max Hydrogen Isotopes", RD.GetNetworkCapacity(self, "hydrogen isotopes"))
	Wire_TriggerOutput(self, "Max Helium Isotopes", RD.GetNetworkCapacity(self, "helium isotopes"))
	Wire_TriggerOutput(self, "Max Nitrogen Isotopes", RD.GetNetworkCapacity(self, "nitrogen isotopes"))
	Wire_TriggerOutput(self, "Max Liquid Ozone", RD.GetNetworkCapacity(self, "liquid ozone"))
	Wire_TriggerOutput(self, "Max Heavy Water", RD.GetNetworkCapacity(self, "heavy water"))
	Wire_TriggerOutput(self, "Max Strontium Clathrates", RD.GetNetworkCapacity(self, "strontium clathrates"))
end
