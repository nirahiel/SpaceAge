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
	local reqLvl = SA.Ice.GetLevelForStorageModel(self:GetModel())
	if ((reqLvl == nil) or (ply.sa_data.research.ice_raw_storage_level[1] < reqLvl)) then self:Remove() return end

	local Capacity = math.floor(8 * (4.5 ^ reqLvl)) * ply.sa_data.advancement_level

	RD.AddResource(self, "blue ice", Capacity)
	RD.AddResource(self, "clear ice", Capacity)
	RD.AddResource(self, "glacial mass", Capacity)
	RD.AddResource(self, "white glaze", Capacity)
	RD.AddResource(self, "dark glitter", Capacity)
	RD.AddResource(self, "glare crust", Capacity)
	RD.AddResource(self, "gelidus", Capacity)
	RD.AddResource(self, "krystallos", Capacity)
end

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("storage_ice")
	ent:SetPos(tr.HitPos + tr.HitNormal * 100)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Think()
	BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Blue Ice", RD.GetResourceAmount(self, "blue ice"))
	Wire_TriggerOutput(self, "Clear Ice", RD.GetResourceAmount(self, "clear ice"))
	Wire_TriggerOutput(self, "Glacial Mass", RD.GetResourceAmount(self, "glacial mass"))
	Wire_TriggerOutput(self, "White Glaze", RD.GetResourceAmount(self, "white glaze"))
	Wire_TriggerOutput(self, "Dark Glitter", RD.GetResourceAmount(self, "dark glitter"))
	Wire_TriggerOutput(self, "Glare Crust", RD.GetResourceAmount(self, "glare crust"))
	Wire_TriggerOutput(self, "Gelidus", RD.GetResourceAmount(self, "gelidus"))
	Wire_TriggerOutput(self, "Krystallos", RD.GetResourceAmount(self, "krystallos"))

	Wire_TriggerOutput(self, "Max Blue Ice", RD.GetNetworkCapacity(self, "blue ice"))
	Wire_TriggerOutput(self, "Max Clear Ice", RD.GetNetworkCapacity(self, "clear ice"))
	Wire_TriggerOutput(self, "Max Glacial Mass", RD.GetNetworkCapacity(self, "glacial mass"))
	Wire_TriggerOutput(self, "Max White Glaze", RD.GetNetworkCapacity(self, "white glaze"))
	Wire_TriggerOutput(self, "Max Dark Glitter", RD.GetNetworkCapacity(self, "dark glitter"))
	Wire_TriggerOutput(self, "Max Glare Crust", RD.GetNetworkCapacity(self, "glare crust"))
	Wire_TriggerOutput(self, "Max Gelidus",  RD.GetNetworkCapacity(self, "gelidus"))
	Wire_TriggerOutput(self, "Max Krystallos", RD.GetNetworkCapacity(self, "krystallos"))
end
