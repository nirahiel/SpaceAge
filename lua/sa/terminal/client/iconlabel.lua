local PANEL = {}

function PANEL:Setup(str, color, silkicon)
	self:SetPaintBackground(false)

	local label = vgui.Create("DLabel", self)
	label:SetText(str)
	label:SizeToContents()
	label:SetColor(color)
	label:SetPos(20, 0)

	local icon = vgui.Create("DImage", self)
	icon:SetImage("icon16/" .. silkicon .. ".png")
	icon:SetSize(16, 16)
	icon:SetPos(0, 0)

	self.Icon = icon
	self.Label = label

	local lw, lh = label:GetSize()
	if lh < 16 then
		lh = 16
	end
	self:SetSize(lw + 20, lh)

	label:CenterVertical()
	icon:CenterVertical()
end

vgui.Register("SA_IconLabel", PANEL, "DPanel")
