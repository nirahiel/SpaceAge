include("player_infocard.lua")

local texGradient = surface.GetTextureID("gui/center_gradient")

local PANEL = {}

function PANEL:Paint(w, h)
	if not IsValid(self.Player) then
		self:Remove()
		SCOREBOARD:InvalidateLayout()
		return
	end

	local color = Color(100, 100, 100, 255)

	if IsValid(self.Player) then
		color = team.GetColor(self.Player:Team())
	end

	draw.RoundedBox(4, 18, 0, w - 36, 20, color)

	surface.SetTexture(texGradient)
	surface.SetDrawColor(255, 255, 255, 150)
	surface.DrawTexturedRect(0, 0, w - 36, 20)

	return true
end

function PANEL:SetPlayer(ply)
	self.Player = ply
	self:UpdatePlayerData()
	self.imgAvatar:SetPlayer(ply)
end

function PANEL:UpdatePlayerData()
	local ply = self.Player
	if not IsValid(ply) then return end

	self.lblName:SetText(ply:Nick())
	local teamName = team.GetName(ply:Team())
	if ply:GetNWBool("isleader") then
		teamName = teamName .. " [Leader]"
	end
	self.lblTeam:SetText(teamName)

	self.lblScore:SetText(SA.AddCommasToInt(ply:GetNWString("score")))
	self.lblPing:SetText(ply:Ping())
end

function PANEL:Init()
	self.lblName 	= vgui.Create("DLabel", self)
	self.lblTeam 	= vgui.Create("DLabel", self)
	self.lblScore 	= vgui.Create("DLabel", self)
	self.lblPing 	= vgui.Create("DLabel", self)
	self.lblPing:SetText("9999")

	self.btnAvatar = vgui.Create("DButton", self)
	self.btnAvatar.DoClick = function() self.Player:ShowProfile() end

	self.imgAvatar = vgui.Create("AvatarImage", self.btnAvatar)

	--If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled(false)
	self.lblTeam:SetMouseInputEnabled(false)
	self.lblPing:SetMouseInputEnabled(false)
	self.lblScore:SetMouseInputEnabled(false)
	self.imgAvatar:SetMouseInputEnabled(false)
end

function PANEL:ApplySchemeSettings()
	self.lblName:SetFont("suiscoreboardplayername")
	self.lblTeam:SetFont("suiscoreboardplayername")
	self.lblScore:SetFont("suiscoreboardplayername")
	self.lblPing:SetFont("suiscoreboardplayername")

	self.lblName:SetTextColor(color_black)
	self.lblTeam:SetTextColor(color_black)
	self.lblScore:SetTextColor(color_black)
	self.lblPing:SetTextColor(color_black)
end

function PANEL:Think()
	if not self.PlayerUpdate or self.PlayerUpdate < CurTime() then
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
	end
end

function PANEL:PerformLayout(w, h)
	self:SetSize(w, 20)

	self.btnAvatar:SetPos(21, 2)
	self.btnAvatar:SetSize(16, 16)

	self.imgAvatar:SetSize(16, 16)

	self.lblName:SizeToContents()
	self.lblTeam:SizeToContents()
	self.lblScore:SizeToContents()
	self.lblPing:SizeToContents()
	self.lblPing:SetWide(100)

	self.lblName:SetPos(60, 2)

	local parentWidth = self:GetParent():GetWide()

	self.lblTeam:SetPos(parentWidth - 45 * 10.2 - 6, 2)
	self.lblScore:SetPos(parentWidth - 45 * 5.4 - 6, 2)
	self.lblPing:SetPos(parentWidth - 45 - 6, 2)
end

function PANEL:HigherOrLower(row)
	if self.Player:Team() == TEAM_CONNECTING then return false end
	if row.Player:Team() == TEAM_CONNECTING then return true end

	if self.Player:Team() ~= row.Player:Team() then
		return self.Player:Team() < row.Player:Team()
	end

	local selfScore = tonumber(self.Player:GetNWString("score")) or 0
	local otherScore = tonumber(row.Player:GetNWString("score")) or 0
	if selfScore ~= otherScore then
		return selfScore > otherScore
	end

	return false
end

vgui.Register("suiscoreplayerrow", PANEL, "DPanel")
