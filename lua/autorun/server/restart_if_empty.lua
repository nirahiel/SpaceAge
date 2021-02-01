local convarEnabled = CreateConVar("restart_if_empty", 0)
local convarMode = CreateConVar("restart_if_empty_mode", "changelevel")

convarEnabled:SetBool(false)

timer.Create("RestartIfEmpty", 1, 0, function()
	if not convarEnabled:GetBool() then
		return
	end

	if player.GetCount() > 0 then
		return
	end

	local mode = convarMode:GetString()
	if mode == "exit" then
		RunConsoleCommand("exit")
	elseif mode == "changelevel" then
		RunConsoleCommand("changelevel", game.GetMap())
	end
end)
