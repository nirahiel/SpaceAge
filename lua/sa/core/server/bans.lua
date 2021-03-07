SA.REQUIRE("api")
SA.REQUIRE("central")

local PlayerBans = {}

local function time_is_perm(time)
	return time == nil or time <= 0
end

local function default_bandata(reason, admin)
	reason = reason or "N/A"

	local adminId = "CONSOLE"
	if IsValid(admin) then
		adminId = admin:SteamID()
	end

	return reason, adminId
end

local function kickall(steamid, reason)
	local data = {
		steamid = steamid,
		reason = reason,
	}
	SA.Central.Broadcast("kick", data)
end

local function onkickall(data)
	local ply = player.GetBySteamID(data.steamid)
	if not IsValid(ply) then
		return
	end
	ply:Kick(data.reason or "N/A")
end
SA.Central.Handle("kick", onkickall)

local function ulib_ban(ply, time, reason, admin)
	if not time_is_perm(time) then
		return ULib.real_ban(ply, time, reason, admin)
	end

	if not IsValid(ply) then
		return
	end

	local realReason, adminId = default_bandata(reason, admin)

	ply.sa_data.is_banned = true
	ply.sa_data.ban_reason = realReason
	ply.sa_data.banned_by = adminId

	SA.SaveUser(ply, true)
	kickall(ply:SteamID(), realReason)
	ply:Kick(realReason)
end

local function ulib_addBan(steamid, time, reason, name, admin)
	if not time_is_perm(time) then
		return ULib.real_addBan(steamid, time, reason, name, admin)
	end

	local ply = player.GetBySteamID(steamid)
	if IsValid(ply) then
		return ulib_ban(ply, time, reason, admin)
	end

	local realReason, adminId = default_bandata(reason, admin)
	SA.API.BanPlayer(steamid, realReason, adminId)
	kickall(steamid, realReason)
end

timer.Simple(0, function()
	ULib.real_ban = ULib.real_ban or ULib.ban
	ULib.real_addBan = ULib.real_addBan or ULib.addBan

	ULib.ban = ulib_ban
	ULib.kickban = ulib_ban
	ULib.addBan = ulib_addBan
end)

local function CheckPassword(sid64)
	local steamid = util.SteamIDFrom64(sid64)
	local plyBan = PlayerBans[steamid]
	if not plyBan then
		return
	end

	return false, "Banned: " .. (plyBan.ban_reason or "N/A")
end
hook.Add("CheckPassword", "SA_Ban_CheckPassword", CheckPassword)

local function GotBans(body, code)
	if code ~= 200 then
		return
	end

	PlayerBans = {}
	for _, ply in pairs(body) do
		PlayerBans[ply.steamid] = ply
	end
end
local function RefreshBans()
	SA.API.ListBannedPlayers(GotBans)
end
timer.Create("SA_RefreshBans", 10, 0, RefreshBans)
timer.Simple(0, RefreshBans)
