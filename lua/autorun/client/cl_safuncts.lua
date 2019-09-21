local ENT = FindMetaTable("Entity")

local brshift = bit.rshift
local band = bit.band
local function band255(int)
	return band(int, 255)
end

function ENT:GetNetworkedColor(name)
	local int = self:GetNetworkedInt(name);
	return Color(band255(brshift(int, 0)), band255(brshift(int, 8)), band255(brshift(int, 16)), band255(brshift(int, 24)))
end