AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

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

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_product_storage_level[1] < self.MinIceProductStorageMod then
		SA.Research.RemoveEntityWithWarning(self, "ice_product_storage_level", self.MinIceProductStorageMod)
		return
	end

	local Capacity = math.floor(30000 * (2.25 ^ self.rank)) * ply.sa_data.advancement_level

	self:AddResource("oxygen isotopes", Capacity)
	self:AddResource("hydrogen isotopes", Capacity)
	self:AddResource("helium isotopes", Capacity)
	self:AddResource("nitrogen isotopes", Capacity)
	self:AddResource("carbon isotopes", Capacity)
	self:AddResource("heavy water", Capacity)
	self:AddResource("strontium clathrates", Capacity)

end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Oxygen Isotopes", "oxygen isotopes")
	self:DoUpdateWireOutput("Hydrogen Isotopes", "hydrogen isotopes")
	self:DoUpdateWireOutput("Helium Isotopes", "helium isotopes")
	self:DoUpdateWireOutput("Nitrogen Isotopes", "nitrogen isotopes")
	self:DoUpdateWireOutput("Carbon Isotopes", "carbon isotopes")
	self:DoUpdateWireOutput("Heavy Water", "heavy water")
	self:DoUpdateWireOutput("Strontium Clathrates", "strontium clathrates")
end
