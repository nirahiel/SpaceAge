local convarTimeout = CreateConVar("sa_afk_timeout", "3600")

util.AddNetworkString("SA_AFK_Set")

local function PlySetAFK(ply, afk)
	if afk == ply.IsAFK then
		return
	end

	if afk then
		print(ply, "went AFK")
	else
		print(ply, "returned from AFK")
	end
	ply.IsAFK = afk
	net.Start("SA_AFK_Set")
		net.WriteBool(afk)
	net.Send(ply)
end

local function PlyMoveSet(ply, buttons)
	if ply.AFKLastButtons ~= buttons then
		ply.AFKLastAction = CurTime()
		ply.AFKLastButtons = buttons
		PlySetAFK(ply, false)
	end
end

hook.Add("PlayerInitialSpawn", "SA_AFK_Init", function(ply)
	PlyMoveSet(ply, 0)
end)

hook.Add("SetupMove", "SA_AFK_SetupMove", function(ply, _, cmd)
	local buttons = cmd:GetButtons()
	if buttons == 0 then
		return
	end
	PlyMoveSet(ply, buttons)
end)

timer.Create("SA_AFK_Check", 1, 0, function()
	local minTime = CurTime() - convarTimeout:GetInt()

	for _, ply in pairs(player.GetHumans()) do
		PlySetAFK(ply, ply.AFKLastAction < minTime)
	end
end)
