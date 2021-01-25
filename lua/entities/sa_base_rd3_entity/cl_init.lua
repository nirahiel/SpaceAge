include("shared.lua")

DEFINE_BASECLASS("base_rd3_entity")
function ENT:Think()
	BaseClass.Think(self)

	if not self.rank and self.IsRanked then
		self:InitializeRankedVars()
	end

	self:NextThink(CurTime() + 1)
	return true
end
