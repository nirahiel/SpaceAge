local convarEnabled = CreateConVar("restart_if_empty", 0)
local convarTime = CreateConVar("restart_if_empty_time", 60 * 10)
local convarTimeAFK = CreateConVar("restart_if_empty_time_afk", 60 * 30)
local convarMode = CreateConVar("restart_if_empty_mode", "close")

convarEnabled:SetBool(false)

local serverEmptyCycles = 0

timer.Simple(0, function()
	SA.Central.Handle("restart_if_empty", function()
		convarEnabled:SetBool(true)
	end)
end)

timer.Create("RestartIfEmpty", 1, 0, function()
	if not convarEnabled:GetBool() then
		serverEmptyCycles = 0
		return
	end

	local players = player.GetHumans()

	local requiredCyclesCV = convarTime
	for _, ply in pairs(players) do
		requiredCyclesCV = convarTimeAFK
		if not ply.IsAFK then
			requiredCyclesCV = nil
			break
		end
	end

	if not requiredCyclesCV then
		serverEmptyCycles = 0
		return
	end

	local requiredCycles = requiredCyclesCV:GetInt()

	serverEmptyCycles = serverEmptyCycles + 1
	if serverEmptyCycles <= requiredCycles then
		local str = "Seconds until restart: " .. tostring(requiredCycles - serverEmptyCycles)
		print(str)
		for _, ply in pairs(players) do
			ply:ChatPrint(str)
		end
		return
	end

	local mode = convarMode:GetString()
	if mode == "close" then
		RunConsoleCommand("close")
	else
		RunConsoleCommand("changelevel", game.GetMap())
	end
end)
