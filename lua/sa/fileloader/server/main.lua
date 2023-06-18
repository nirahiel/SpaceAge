util.AddNetworkString("SA_RunLua")

local function NotifyRun(ply, targetName)
	ply:AddHint("Script ran " .. targetName, NOTIFY_GENERIC, 5)
end

local function RunLuaRecv(_, ply)
	if not SA.FileLoader.CanRunAll(ply) then
		ply:AddHint("You cannot run Lua remotely", NOTIFY_ERROR, 2)
		return
	end
	local def = net.ReadString()
	local data = net.ReadString()
	if not def or not data then
		return
	end

	local target = nil
	if def == SA.FileLoader.RUN_SERVERSIDE or def == SA.FileLoader.RUN_SHARED then
		RunString(data)
	elseif def ~= SA.FileLoader.RUN_ALL_CLIENTS then
		target = player.GetBySteamID(def)
		if not IsValid(target) then
			ply:AddHint("Could not find target for script " .. def, NOTIFY_ERROR, 2)
			return
		end
		def = "on " .. target:GetName()
	end

	if def ~= SA.FileLoader.RUN_SERVERSIDE then
		net.Start("SA_RunLua")
			net.WriteString(data)

		if target then
			net.Send(target)
		else
			net.Broadcast()
		end
	end

	NotifyRun(ply, def)
end
net.Receive("SA_RunLua", RunLuaRecv)
