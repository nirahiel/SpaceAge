AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")
local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	local ply = self:GetTable().Founder
	
	if not ply:IsAdmin() then self:SetModel("models/slyfo/sat_resourcetank.mdl") end
	
	self:CalcVars(ply)
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, { "Ore", "Max Ore" })
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()	
		phys:SetMass(500)
	end
end

function ENT:CalcVars(ply)
	self.IsOreStorage = true
	RD.AddResource(self, "ore", (50000 + (ply.oremod * 5000)) * ply.devlimit, 0)
end

function ENT:Think()
	if WireAddon != nil then 
		self:UpdateWireOutput()
	end	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:UpdateWireOutput()
	Wire_TriggerOutput(self, "Ore", RD.GetResourceAmount( self, "ore" ))
	Wire_TriggerOutput(self, "Max Ore", RD.GetNetworkCapacity( self, "ore" ))
end
