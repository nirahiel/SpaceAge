include("shared.lua")
function ENT:Think()
	local scale = self:GetNWFloat("Scale", 1)
	self:SetModelScale(Vector(scale, scale, scale))
end

function ENT:Initialize()
end