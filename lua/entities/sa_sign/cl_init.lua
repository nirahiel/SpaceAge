include("shared.lua")

surface.CreateFont("signText", { font = "Trebuchet18", size = 200, weight = 700, antialias = true, shadow = false})

local typeTexts = {
	blank = "",
	x = "X",
	afk_room = "AFK room",
	no_build_zone = "No-build zone",
}

function ENT:DrawSign()
	local typeName = self:GetNWString("type") or ""
	local text = typeTexts[typeName] or typeName

	surface.SetTextColor(255, 0, 0, 255)
	surface.SetFont("signText")
	local w, h = surface.GetTextSize(text)
	surface.SetTextPos(-(w / 2), -(h / 2))
	surface.DrawText(text)
end

function ENT:Draw()
	local pos = self:LocalToWorld(self:OBBCenter())
	local ang = self:GetAngles()
	ang:RotateAroundAxis(self:GetUp(), 90)
	cam.Start3D2D(pos, ang, 0.1)
		self:DrawSign()
	cam.End3D2D()

	ang:RotateAroundAxis(self:GetForward(), 180)
	cam.Start3D2D(pos, ang, 0.1)
		self:DrawSign()
	cam.End3D2D()
end

function ENT:DrawTranslucent()
	self:Draw()
end
