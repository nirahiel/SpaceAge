AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

SA_RawIceStorageModels = {}

SA_RawIceStorageModels['models/mandrac/resource_cache/colossal_cache.mdl'] = 4
SA_RawIceStorageModels['models/mandrac/nitrogen_tank/nitro_large.mdl'] = 3
SA_RawIceStorageModels['models/mandrac/resource_cache/huge_cache.mdl'] = 2
SA_RawIceStorageModels['models/mandrac/energy_cell/large_cell.mdl'] = 1
SA_RawIceStorageModels['models/mandrac/energy_cell/medium_cell.mdl'] = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
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
	local reqLvl = SA_RawIceStorageModels[self:GetModel()]
	if ((reqLvl == nil) or (ply.icerawmod < reqLvl)) then self:Remove() return end
	
	local Capacity = math.floor(8*(4.5^reqLvl))*ply.devlimit
	
	RD_AddResource(self, "Blue Ice", Capacity)
	RD_AddResource(self, "Clear Ice", Capacity)
	RD_AddResource(self, "Glacial Mass", Capacity)
	RD_AddResource(self, "White Glaze", Capacity)
	RD_AddResource(self, "Dark Glitter", Capacity)
	RD_AddResource(self, "Glare Crust", Capacity)
	RD_AddResource(self, "Gelidus", Capacity)
	RD_AddResource(self, "Krystallos", Capacity)
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local ent = ents.Create( "mining_laser_base" )
	ent:SetPos( tr.HitPos + tr.HitNormal * 100 )
	ent:Spawn()
	ent:Activate() 
	return ent
end

function ENT:Think()
	self.BaseClass.Think(self)	
	self:UpdateWireOutput()		
end

function ENT:UpdateWireOutput() 
	Wire_TriggerOutput(self, "Blue Ice", RD_GetResourceAmount(self, "Blue Ice") )
	Wire_TriggerOutput(self, "Clear Ice", RD_GetResourceAmount(self, "Clear Ice") )
	Wire_TriggerOutput(self, "Glacial Mass", RD_GetResourceAmount(self, "Glacial Mass") )
	Wire_TriggerOutput(self, "White Glaze", RD_GetResourceAmount(self, "White Glaze") )
	Wire_TriggerOutput(self, "Dark Glitter", RD_GetResourceAmount(self, "Dark Glitter") )
	Wire_TriggerOutput(self, "Glare Crust", RD_GetResourceAmount(self, "Glare Crust") )
	Wire_TriggerOutput(self, "Gelidus", RD_GetResourceAmount(self, "Gelidus") )
	Wire_TriggerOutput(self, "Krystallos", RD_GetResourceAmount(self, "Krystallos") )
	
	Wire_TriggerOutput(self, "Max Blue Ice", RD_GetNetworkCapacity(self, "Blue Ice") )
	Wire_TriggerOutput(self, "Max Clear Ice", RD_GetNetworkCapacity(self, "Clear Ice") )
	Wire_TriggerOutput(self, "Max Glacial Mass", RD_GetNetworkCapacity(self, "Glacial Mass") )
	Wire_TriggerOutput(self, "Max White Glaze", RD_GetNetworkCapacity(self, "White Glaze"))
	Wire_TriggerOutput(self, "Max Dark Glitter", RD_GetNetworkCapacity(self, "Dark Glitter") )
	Wire_TriggerOutput(self, "Max Glare Crust", RD_GetNetworkCapacity(self, "Glare Crust") )
	Wire_TriggerOutput(self, "Max Gelidus",  RD_GetNetworkCapacity(self, "Gelidus") )
	Wire_TriggerOutput(self, "Max Krystallos", RD_GetNetworkCapacity(self, "Krystallos"))
end