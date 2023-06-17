include("shared.lua")

surface.CreateFont("signText", { font = "Trebuchet18", size = 200, weight = 700, antialias = true, shadow = false})

local typeTexts = {
	x = "X",
	afk = "AFK\nroom",
	no_build_zone = "No-build\nzone"
}

function ENT:DrawSign()
	local text = typeTexts[self:GetNWString("type") or ""] or "..."

	surface.SetTextPos(0, 0)
	surface.SetTextColor(255, 0, 0, 255)
	surface.SetFont("signText")
	surface.DrawText(text)
end

function ENT:Draw()
	-- cam.Start3D2D(self:GetPos(), self:GetAngles() + Angle(90, 90, 90), 0.1)
	-- 	self:DrawSign()
	-- cam.End3D2D()
	-- cam.Start3D2D(self:GetPos(), self:GetAngles() + Angle(90, -90, 90), 0.1)
	-- 	self:DrawSign()
	-- cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:Draw()
end
