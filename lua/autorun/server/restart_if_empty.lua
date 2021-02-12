local convarEnabled = CreateConVar("restart_if_empty", 0)
local convarTime = CreateConVar("restart_if_empty_time", 60 * 10)
local convarMode = CreateConVar("restart_if_empty_mode", "exit")

convarEnabled:SetBool(false)

local function IsServerEmpty()
	return player.GetCount() <= 0
end

local serverEmptyCycles = 0

timer.Create("RestartIfEmpty", 1, 0, function()
	if not convarEnabled:GetBool() then
		serverEmptyCycles = 0
		return
	end

	if not IsServerEmpty() then
		serverEmptyCycles = 0
		return
	end

	serverEmptyCycles = serverEmptyCycles + 1
	local requiredCycles = convarTime:GetInt()
	if serverEmptyCycles <= requiredCycles then
		print("Seconds until restart: ", requiredCycles - serverEmptyCycles)
		return
	end

	local mode = convarMode:GetString()
	if mode == "exit" then
		RunConsoleCommand("exit")
	else
		RunConsoleCommand("changelevel", game.GetMap())
	end
end)
