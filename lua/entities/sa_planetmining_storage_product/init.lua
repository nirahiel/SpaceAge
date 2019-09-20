AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

SA_ProdPMStorageModels = {}

SA_ProdPMStorageModels['models/mandrac/resource_cache/colossal_cache.mdl'] = 4
SA_ProdPMStorageModels['models/mandrac/nitrogen_tank/nitro_large.mdl'] = 3
SA_ProdPMStorageModels['models/mandrac/resource_cache/huge_cache.mdl'] = 2
SA_ProdPMStorageModels['models/mandrac/energy_cell/large_cell.mdl'] = 1
SA_ProdPMStorageModels['models/mandrac/energy_cell/medium_cell.mdl'] = 0

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:CalcVars(self:GetTable().Founder)
	self.damaged = 0
	self.WireDebugName = self.PrintName
	
	local Arr = {}
	for _,v in pairs(SA_PM.Ref.Types) do
		table.insert(Arr, v.Name)
	end
	for _,v in pairs(SA_PM.Ref.Types) do
		table.insert(Arr, "Max "..v.Name)
	end
	
	self.Outputs = Wire_CreateOutputs(self, Arr)
end

function ENT:CalcVars(ply)
	local reqLvl = SA_ProdPMStorageModels[self:GetModel()]
	if ((reqLvl == nil) or (ply.pmprodlevel < reqLvl)) then
		ply:ChatPrint("You do not have the required level for this model!")
		self:Remove()
		return
	end
	local Capacity = math.floor(5280*(2.5^reqLvl))*ply.devlimit
	for _,v in pairs(SA_PM.Ref.Types) do
		RD.AddResource(self, v.Name, Capacity)
	end
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
	for _,v in pairs(SA_PM.Ref.Types) do
		Wire_TriggerOutput(self, v.Name, RD.GetResourceAmount(self, v.Name))
		Wire_TriggerOutput(self, "Max "..v.Name, RD.GetNetworkCapacity(self, v.Name))
	end
end