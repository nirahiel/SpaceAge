AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:CAF_PostInit()
	self:InitializeRankedVars()

	if self.ForcedModel and self:GetModel():lower() ~= self.ForcedModel:lower() then
		self:Remove()
		return
	end

	self:CalcVars(self:GetTable().Founder)
end

function ENT:CalcVars(ply)
	-- Do nothing here, subclasses override it
end
