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
	if (phys:IsValid()) then
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

function ENT:OnRemove()
	if self:GetResourceAmount("tiberium") < 1000 then
		BaseClass.OnRemove(self)
		return
	end

	local wreck = ents.Create("wreckedstuff")
	wreck:SetSolid(SOLID_NONE)
	wreck:SetModel(self:GetModel())
	wreck:SetAngles(self:GetAngles())
	wreck:SetPos(self:GetPos())
	wreck:Spawn()
	wreck:Activate()
	wreck.deathtype = 1

	self:Leak()

	BaseClass.OnRemove(self)
end

function ENT:Leak()
	for i = 1, math.Rand(1, 4) do
		if #ents.FindByClass("sa_tibcrystal_rep") >= 100 then return end
		local Pos = SA.Tiberium.FindWorldFloor(self:GetPos() + Vector(math.Rand(-500, 500), math.Rand(-500, 500), 500), nil, {self})
		if Pos then
			local crystal = ents.Create("sa_tibcrystal_rep")
			SA.Tiberium.SetTimeUntilDelete(crystal, CurTime() + math.Rand(10, 30))
			crystal:SetModel("models/ce_ls3additional/tiberium/tiberium_normal.mdl")
			local Height = math.abs(crystal:OBBMaxs().z - crystal:OBBCenter().z)
			crystal:SetPos(Pos-Vector(0, 0, Height-5))
			crystal:SetAngles(Angle(0, math.Rand(0, 359), 0))
			SA.Functions.PropMoveSlow(crystal, crystal:GetPos() + Vector(0, 0, Height-5), math.Rand(10, 45))
			crystal:Spawn()
			crystal.MainSpawnedBy = crystal
		end
	end
end
