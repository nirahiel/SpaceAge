SA.REQUIRE("config")

local function SA_RefreshApplications(ply1, ply2)
	local plys
	if ply1 and ply2 then
		plys = {ply1, ply2}
	elseif ply1 then
		plys = ply1
	elseif ply2 then
		plys = ply2
	else
		return
	end

	net.Start("SA_Applications_Refresh")
	net.Send(plys)
end

local function SA_RefreshFactionApplications(steamid, faction, fromcentral)
	local ply1 = player.GetBySteamID(steamid)
	local ply2
	for _, ply in pairs(player.GetHumans()) do
		if ply.sa_data and ply.sa_data.is_faction_leader and ply.sa_data.faction_name == faction then
			ply2 = ply
			break
		end
	end
	SA_RefreshApplications(ply1, ply2)

	if not fromcentral then
		SA.Central.Broadcast("applicationreload", {
			steamid = steamid,
			faction = faction,
		})
	end
end
SA.Central.Handle("applicationreload", function(data)
	SA_RefreshFactionApplications(data.steamid, data.faction, true)
end)

local function SetFactionSpawn(tbl)
	local ent = {}
	for _, pos in ipairs(tbl) do
		local entx = ents.Create("info_player_start")
		entx:SetPos(Vector(unpack(pos)))
		entx:Spawn()
		entx.IsSpaceAge = true
		table.insert(ent, entx)
	end
	return ent
end
local function InitSAFactions()
	for _, v in pairs(ents.FindByClass("info_player_start")) do
		if v.IsSpaceAge then v:Remove() end
	end

	local spawns = SA.Config.Load("faction_spawns")
	if not spawns then
		return
	end

	for name, fSpawns in pairs(spawns) do
		SA.Factions.Table[SA.Factions.IndexByShort[name]][6] = SetFactionSpawn(fSpawns)
	end
end
timer.Simple(0, InitSAFactions)

local function SA_SetSpawnPos(ply)
	ply.HasAlreadySpawned = true

	local idx = SA.Factions.IndexByShort["noload"]
	if ply.sa_data and ply.sa_data.loaded then
		idx = ply:Team()
	end

	local modelIdx = 4
	if ply.sa_data and ply.sa_data.is_faction_leader then
		modelIdx = 5
	end
	timer.Simple(2, function()
		if IsValid(ply) then
			ply:SetModel(SA.Factions.Table[idx][modelIdx])
		end
	end)

	if SA.Factions.Table[idx][6] then
		return table.Random(SA.Factions.Table[idx][6])
	end
end
hook.Add("PlayerSelectSpawn", "SA_ChooseSpawn", SA_SetSpawnPos)

local function SA_FriendlyFire(vic, atk)
	if not vic:IsPlayer() or not atk:IsPlayer() then
		return true
	end

	if ((vic:Team() == atk:Team()) and not GetConVar("sa_friendlyfire"):GetBool()) then
		return false
	else
		return true
	end
end
hook.Add("PlayerShouldTakeDamage", "SA_FriendlyFire", SA_FriendlyFire)

local function DoApplyFactionResRes(ply, faction, code)
	if code > 299 then
		return
	end

	SA_RefreshFactionApplications(ply:SteamID(), faction)

	ply:SendLua("SA.Application.Close()")
end

local function SA_DoApplyFaction(len, ply)
	local text = net.ReadString()
	local faction = net.ReadString()

	local ffid = SA.Factions.IndexByShort[faction]
	if not ffid then return end
	local faction_data = SA.Factions.Table[ffid]
	if not faction_data then return end

	local can_apply = faction_data[8]
	if not can_apply then return end

	SA.API.UpsertPlayerApplication(ply, {
		text = text,
		faction_name = faction,
	}, function(_body, status) DoApplyFactionResRes(ply, faction, status) end)
end
net.Receive("SA_DoApplyFaction", SA_DoApplyFaction)

local function SA_DoAcceptPlayer(ply, cmd, args)
	if #args ~= 1 then return end
	if not ply.sa_data.is_faction_leader then return end

	local steamId = args[1]
	local factionName = ply.sa_data.faction_name
	local trgPly = player.GetBySteamID(steamId)

	SA.API.AcceptFactionApplication(factionName, steamId, function(_body, code)
		SA_RefreshFactionApplications(steamId, factionName)

		-- TODO: Reload player on error codes
		if code > 299 then
			return
		end

		SA.Central.Broadcast("factionchange", {
			steamid = steamId,
			faction = factionName,
		})

		if not trgPly then
			return
		end

		trgPly:AssignFaction(factionName)
	end)
end
concommand.Add("sa_application_accept", SA_DoAcceptPlayer)

SA.Central.Handle("factionchange", function (data, ident)
	local steamId = data.steamid
	local factionName = data.faction

	local trgPly = player.GetBySteamID(steamId)
	if IsValid(trgPly) then
		trgPly:AssignFaction(factionName)
	end
end)

local function SA_DoDenyPlayer(ply, cmd, args)
	if #args ~= 1 then return end
	if not ply.sa_data.is_faction_leader then return end

	local steamId = args[1]
	local factionName = ply.sa_data.faction_name

	SA.API.DeleteFactionApplication(factionName, steamId, function(_body, _code)
		SA_RefreshFactionApplications(steamId, factionName)
	end)
end
concommand.Add("sa_application_deny", SA_DoDenyPlayer)

local function SA_DoKickPlayer(ply, cmd, args)
	if args ~= 1 then return end
	if not ply.sa_data.is_faction_leader then return end

	local steamId = args[1]
	local trgPly = player.GetBySteamID(steamId)

	if not trgPly or not trgPly:IsValid() or trgPly == ply or trgPly.sa_data.is_faction_leader or trgPly.sa_data.faction_name ~= ply.sa_data.faction_name then
		return
	end

	trgPly:AssignFaction("freelancer")
end
concommand.Add("sa_faction_kick", SA_DoKickPlayer)
