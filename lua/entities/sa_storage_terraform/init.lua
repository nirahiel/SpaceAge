AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.damaged = 0
	self.vent = false
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = { }
		self.Outputs = Wire_CreateOutputs(self, { "Permafrost", "TerraCrystal", "Dark Matter", "Max Permafrost", "Max TerraCrystal", "Max Dark Matter" })
	else
		self.Inputs = { }
	end
	self:AddResource("terracrystal", 1000000)
	self:AddResource("dark matter", 1000000)
	self:AddResource("permafrost", 1000000)
	self.caf.custom.masschangeoverride = true
	local pl = self:GetTable().Founder
	if pl and pl:IsValid() and pl:IsPlayer() and pl.sa_data.score and pl.sa_data.score < 1000000 then
		pl:AddNotify("You need 1.000.000 score to spawn a terraforming storage", NOTIFY_ERROR, 5)
		self:Remove()
		return
	end
end

function ENT:Destruct()
	if CAF and CAF.GetAddon("Life Support") then
		CAF.GetAddon("Life Support").Destruct(self, true)
	end
end

function ENT:UpdateMass()
end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Dark Matter", "dark matter")
	self:DoUpdateWireOutput("TerraCrystal", "terracrystal")
	self:DoUpdateWireOutput("Permafrost", "permafrost")
end
