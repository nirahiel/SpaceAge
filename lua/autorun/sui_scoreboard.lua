if SERVER then
	AddCSLuaFile("autorun/sui_scoreboard.lua")
	AddCSLuaFile("sui_scoreboard/player_frame.lua")
	AddCSLuaFile("sui_scoreboard/player_row.lua")
	AddCSLuaFile("sui_scoreboard/scoreboard.lua")
end

if CLIENT then
	include("sui_scoreboard/scoreboard.lua")

	local SuiScoreBoard = nil

	timer.Simple(1.5, function()
		function GAMEMODE:CreateScoreboard()
			if ScoreBoard then
				ScoreBoard:Remove()
				ScoreBoard = nil
			end

			SuiScoreBoard = vgui.Create("suiscoreboard")

			return true
		end

		function GAMEMODE:ScoreboardShow()
			if not SuiScoreBoard then
				self:CreateScoreboard()
			end

			gui.EnableScreenClicker(true)

			SuiScoreBoard:SetVisible(true)
			SuiScoreBoard:UpdateScoreboard(true)

			return true
		end

		function GAMEMODE:ScoreboardHide()
			gui.EnableScreenClicker(false)

			if SuiScoreBoard then
				SuiScoreBoard:SetVisible(false)
			end

			return true
		end
	end)
end
