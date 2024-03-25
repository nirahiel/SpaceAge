AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

function ENT:Initialize()
	BaseClass.Initialize(self)

	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Outputs = Wire_CreateOutputs(self, { "Pyrothium", "Max Pyrothium" })
	end

	self:AddResource("pyrothium", 10000)

	local pl = self:GetTable().Founder
	if pl and pl:IsValid() and pl:IsPlayer() and not pl:IsAdmin() then
		pl:AddHint("Only admins can spawn this for now", NOTIFY_ERROR)
		self:Remove()
	end

end

function ENT:UpdateWireOutput()
	self:DoUpdateWireOutput("Pyrothium", "pyrothium")
end
