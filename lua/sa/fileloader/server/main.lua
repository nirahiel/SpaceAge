util.AddNetworkString("SA_RunLua")

local function NotifyRun(ply, targetName)
	ply:AddHint("Script ran " .. targetName, NOTIFY_GENERIC, 5)
end

local function RunLuaRecv(_, ply)
	if not ply:IsSuperAdmin() then
		ply:AddHint("Only SuperAdmins can do this", NOTIFY_ERROR, 2)
		return
	end
	local def = net.ReadString()
	local data = net.ReadString()
	if not def or not data then
		return
	end

	local target = nil
	if def == "serverside" or def == "shared" then
		RunString(data)
	elseif def ~= "on all clients" then
		target = player.GetBySteamID(def)
		if not IsValid(target) then
			ply:AddHint("Could not find target for script " .. def, NOTIFY_ERROR, 2)
			return
		end
		def = "on " .. target:GetName()
	end

	if def ~= "serverside" then
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
