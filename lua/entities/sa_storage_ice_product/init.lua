AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	self.Outputs = Wire_CreateOutputs(self, {
	"Oxygen Isotopes",
	"Hydrogen Isotopes",
	"Helium Isotopes",
	"Nitrogen Isotopes",
	"Carbon Isotopes",
	"Heavy Water",
	"Strontium Clathrates",
	"Max Oxygen Isotopes",
	"Max Hydrogen Isotopes",
	"Max Helium Isotopes",
	"Max Nitrogen Isotopes",
	"Max Carbon Isotopes",
	"Max Heavy Water",
	"Max Strontium Clathrates"})
end

function ENT:CAF_PostInit()
	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	local reqLvl = SA.Ice.GetLevelForProductStorageModel(self:GetModel())
	if not reqLvl then
		self:remove()
		return
	end
	if ply.sa_data.research.ice_product_storage_level[1] < reqLvl then
		SA.Research.RemoveEntityWithWarning(self, "ice_product_storage_level", reqLvl)
		return
	end

	local Capacity = math.floor(30000 * (2.25 ^ reqLvl)) * ply.sa_data.advancement_level

	self:AddResource("oxygen isotopes", Capacity)
	self:AddResource("hydrogen isotopes", Capacity)
	self:AddResource("helium isotopes", Capacity)
	self:AddResource("nitrogen isotopes", Capacity)
	self:AddResource("carbon isotopes", Capacity)
	self:AddResource("heavy water", Capacity)
	self:AddResource("strontium clathrates", Capacity)

end

function ENT:Think()
	BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Oxygen Isotopes", self:GetResourceAmount("oxygen isotopes"))
	Wire_TriggerOutput(self, "Hydrogen Isotopes", self:GetResourceAmount("hydrogen isotopes"))
	Wire_TriggerOutput(self, "Helium Isotopes", self:GetResourceAmount("helium isotopes"))
	Wire_TriggerOutput(self, "Nitrogen Isotopes", self:GetResourceAmount("nitrogen isotopes"))
	Wire_TriggerOutput(self, "Carbon Isotopes", self:GetResourceAmount("carbon isotopes"))
	Wire_TriggerOutput(self, "Heavy Water", self:GetResourceAmount("heavy water"))
	Wire_TriggerOutput(self, "Strontium Clathrates", self:GetResourceAmount("strontium clathrates"))

	Wire_TriggerOutput(self, "Max Oxygen Isotopes", self:GetNetworkCapacity("oxygen isotopes"))
	Wire_TriggerOutput(self, "Max Hydrogen Isotopes", self:GetNetworkCapacity("hydrogen isotopes"))
	Wire_TriggerOutput(self, "Max Helium Isotopes", self:GetNetworkCapacity("helium isotopes"))
	Wire_TriggerOutput(self, "Max Nitrogen Isotopes", self:GetNetworkCapacity("nitrogen isotopes"))
	Wire_TriggerOutput(self, "Max Carbon Isotopes", self:GetNetworkCapacity("carbon isotopes"))
	Wire_TriggerOutput(self, "Max Heavy Water", self:GetNetworkCapacity("heavy water"))
	Wire_TriggerOutput(self, "Max Strontium Clathrates", self:GetNetworkCapacity("strontium clathrates"))
end
