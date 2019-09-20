AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

SA_IceProductStorageModels = {}
SA_IceProductStorageModels['models/slyfo/doublecarrier.mdl'] = 6
SA_IceProductStorageModels['models/slyfo/carrierbay.mdl'] = 5
SA_IceProductStorageModels['models/spacebuild/medbridge2_fighterbay3.mdl'] = 4
SA_IceProductStorageModels['models/mandrac/resource_cache/colossal_cache.mdl'] = 3
SA_IceProductStorageModels['models/mandrac/water_storage/water_storage_large.mdl'] = 2
SA_IceProductStorageModels['models/mandrac/resource_cache/hangar_container.mdl'] = 1 
SA_IceProductStorageModels['models/mandrac/hw_tank/hw_tank_large.mdl'] = 0


function ENT:Initialize()
	self.BaseClass.Initialize(self)
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
	local reqLvl = SA_IceProductStorageModels[self:GetModel()]
	if ((reqLvl == nil) or (ply.iceproductmod < reqLvl)) then self:Remove() return end
	
	local Capacity = math.floor(30000*(2.25^reqLvl))*ply.devlimit
	
	RD_AddResource(self, "Oxygen Isotopes", Capacity)
	RD_AddResource(self, "Hydrogen Isotopes", Capacity)
	RD_AddResource(self, "Helium Isotopes", Capacity)
	RD_AddResource(self, "Nitrogen Isotopes", Capacity)
	RD_AddResource(self, "Liquid Ozone", Capacity)
	RD_AddResource(self, "heavy water", Capacity)
	RD_AddResource(self, "Strontium Clathrates", Capacity)
		
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:UpdateWireOutput()
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Oxygen Isotopes", RD_GetResourceAmount(self, "Oxygen Isotopes") )
	Wire_TriggerOutput(self, "Hydrogen Isotopes", RD_GetResourceAmount(self, "Hydrogen Isotopes") )
	Wire_TriggerOutput(self, "Helium Isotopes", RD_GetResourceAmount(self, "Helium Isotopes") )
	Wire_TriggerOutput(self, "Nitrogen Isotopes", RD_GetResourceAmount(self, "Nitrogen Isotopes") )
	Wire_TriggerOutput(self, "Liquid Ozone", RD_GetResourceAmount(self, "Liquid Ozone") )
	Wire_TriggerOutput(self, "Heavy Water", RD_GetResourceAmount(self, "Heavy Water") )
	Wire_TriggerOutput(self, "Strontium Clathrates", RD_GetResourceAmount(self, "Strontium Clathrates") )
	
	Wire_TriggerOutput(self, "Max Oxygen Isotopes", RD_GetNetworkCapacity(self, "Oxygen Isotopes") )
	Wire_TriggerOutput(self, "Max Hydrogen Isotopes", RD_GetNetworkCapacity(self, "Hydrogen Isotopes") )
	Wire_TriggerOutput(self, "Max Helium Isotopes", RD_GetNetworkCapacity(self, "Helium Isotopes") )
	Wire_TriggerOutput(self, "Max Nitrogen Isotopes", RD_GetNetworkCapacity(self, "Nitrogen Isotopes") )
	Wire_TriggerOutput(self, "Max Liquid Ozone", RD_GetNetworkCapacity(self, "Liquid Ozone") )
	Wire_TriggerOutput(self, "Max Heavy Water", RD_GetNetworkCapacity(self, "Heavy Water") )
	Wire_TriggerOutput(self, "Max Strontium Clathrates", RD_GetNetworkCapacity(self, "Strontium Clathrates") )
end



