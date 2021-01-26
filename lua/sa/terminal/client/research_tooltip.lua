local PANEL = {}

DEFINE_BASECLASS("DTooltip")

local OKColor = Color(0, 128, 0, 255)
local FAILColor = Color(128, 0, 0, 255)

function PANEL:Init()
	BaseClass.Init(self)
end

function PANEL:AddRequirement(subPanel, req, color, silkicon, pw, ph)
	local str = SA.Research.RequirementToString(req)

	local label = vgui.Create("SA_IconLabel", subPanel)
	label:Setup(str, color, silkicon)
	label:Dock(TOP)

	local lw, lh = label:GetSize()
	if lw > pw then
		pw = lw
	end
	ph = ph + lh
	return pw, ph
end

function PANEL:OpenForPanel(panel)
	BaseClass.OpenForPanel(self, panel)

	local missingReqs = panel.MissingReqs
	local fulfilledReqs = panel.FulfilledReqs
	if not missingReqs and not fulfilledReqs then
		self:SetText("N/A")
		return
	end

	local pw = 0
	local ph = 0

	local subPanel = vgui.Create("DPanel")
	subPanel:SetPaintBackground(false)

	if panel.MaxedOut then
		pw, ph = self:AddRequirement(subPanel, "This research is maxed out", FAILColor, "cross", pw, ph)
	elseif #missingReqs < 1 and #fulfilledReqs < 1 then
		pw, ph = self:AddRequirement(subPanel, "This research has no requirements", OKColor, "tick", pw, ph)
	end

	for _, req in pairs(panel.MissingReqs) do
		pw, ph = self:AddRequirement(subPanel, req, FAILColor, "cross", pw, ph)
	end

	for _, req in pairs(panel.FulfilledReqs) do
		pw, ph = self:AddRequirement(subPanel, req, OKColor, "tick", pw, ph)
	end

	subPanel:SetSize(pw, ph)

	self:SetContents(subPanel, true)
end

vgui.Register("SA_Terminal_Research_Tooltip", PANEL, "DTooltip")
