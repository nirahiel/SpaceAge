AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, { "Tiberium", "Max Tiberium" })
	end

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:SetMass(500)
	end
end

function ENT:CalcVars(ply)
	self.IsTiberiumStorage = true
	self:AddResource("tiberium", self:GetCapacity(ply), 0)
end

function ENT:GetCapacity(ply)
	if ply.sa_data.research.tiberium_storage_level[1] < self.MinTiberiumStorageMod then
		SA.Research.RemoveEntityWithWarning(self, "tiberium_storage_level", self.MinTiberiumStorageMod)
	end
	return (self.StorageOffset + (ply.sa_data.research.tiberium_storage_capacity[self.MinTiberiumStorageMod + 1] * self.StorageIncrement)) * ply.sa_data.advancement_level
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Tiberium", "tiberium")
end
