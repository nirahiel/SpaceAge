AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	self.Outputs = Wire_CreateOutputs(self, {
	"Blue Ice",
	"Clear Ice",
	"Glacial Mass",
	"White Glaze",
	"Dark Glitter",
	"Glare Crust",
	"Gelidus",
	"Krystallos",
	"Max Blue Ice",
	"Max Clear Ice",
	"Max Glacial Mass",
	"Max White Glaze",
	"Max Dark Glitter",
	"Max Glare Crust",
	"Max Gelidus",
	"Max Krystallos"})
end

function ENT:CalcVars(ply)
	if ply.sa_data.research.ice_raw_storage_level[1] < self.MinRawIceStorageMod then
		SA.Research.RemoveEntityWithWarning(self, "ice_raw_storage_level", self.MinRawIceStorageMod)
		return
	end

	local Capacity = math.floor(8 * (4.5 ^ self.rank)) * ply.sa_data.advancement_level

	self:AddResource("blue ice", Capacity)
	self:AddResource("clear ice", Capacity)
	self:AddResource("glacial mass", Capacity)
	self:AddResource("white glaze", Capacity)
	self:AddResource("dark glitter", Capacity)
	self:AddResource("glare crust", Capacity)
	self:AddResource("gelidus", Capacity)
	self:AddResource("krystallos", Capacity)
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Blue Ice", "blue ice")
	self:DoUpdateWireOutput("Clear Ice", "clear ice")
	self:DoUpdateWireOutput("Glacial Mass", "glacial mass")
	self:DoUpdateWireOutput("White Glaze", "white glaze")
	self:DoUpdateWireOutput("Dark Glitter", "dark glitter")
	self:DoUpdateWireOutput("Glare Crust", "glare crust")
	self:DoUpdateWireOutput("Gelidus", "gelidus")
	self:DoUpdateWireOutput("Krystallos", "krystallos")
end
