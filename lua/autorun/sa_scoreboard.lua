if SERVER then
	AddCSLuaFile("autorun/SA_Scoreboard.lua")
	AddCSLuaFile("sa_scoreboard/admin_buttons.lua")
	AddCSLuaFile("sa_scoreboard/cl_tooltips.lua")
	AddCSLuaFile("sa_scoreboard/player_frame.lua")
	AddCSLuaFile("sa_scoreboard/player_infocard.lua")
	AddCSLuaFile("sa_scoreboard/player_row.lua")
	AddCSLuaFile("sa_scoreboard/scoreboard.lua")
	AddCSLuaFile("sa_scoreboard/vote_button.lua")
else
	include("sa_scoreboard/scoreboard.lua")

	local SA_ScoreBoard = nil
	
	timer.Simple(1.5, function()
		function GAMEMODE:CreateScoreboard()
			if ScoreBoard then
				ScoreBoard:Remove()
				ScoreBoard = nil
			end
			
			SA_ScoreBoard = vgui.Create("SA_ScoreBoard")
			
			return true
		end
		
		function GAMEMODE:ScoreboardShow()
			if not SA_ScoreBoard then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			SA_ScoreBoard:SetVisible( true )
			SA_ScoreBoard:UpdateScoreboard( true )
			
			return true
		end
		
		function GAMEMODE:ScoreboardHide()
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			SA_ScoreBoard:SetVisible( false )
			
			return true
		end
	end)
end
