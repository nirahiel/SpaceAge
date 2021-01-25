ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Base SA RD3 Entity"
ENT.Author = "Doridian"
ENT.Category = "N/A"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RankedVars = {}
ENT.IsRanked = false

function ENT:InitializeRankedVars()
	if not self.IsRanked then
		return
	end

	local rank = self:GetNWInt("rank")
	if rank <= 0 then
		if SERVER then self:Remove() end
		return
	end

	local vars = self.RankedVars[rank]
	if not vars then
		if SERVER then self:Remove() end
		return
	end

	self.rank = rank

	for k, v in pairs(vars) do
		self[k] = v
	end

	self.PrintName = scripted_ents.Get(self:GetClass()).PrintName .. " (Level " .. SA.ToRomanNumerals(rank) .. ")"
end
