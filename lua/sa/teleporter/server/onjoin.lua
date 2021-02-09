SA.REQUIRE("teleporter.main")
SA.REQUIRE("teleporter.functions")

local onjoinDb = {}

hook.Add("CheckPassword", "SA_Teleporter_OnJoin", function(sid64, _, _, password)
	local sid = util.SteamIDFrom64(sid64)
	if password:sub(1, 6) == "SA_TP " then
		onjoinDb[sid] = password:sub(7)
	end
end)

hook.Add("PlayerDisconnect", "SA_Teleporter_OnJoin_DC", function(ply)
	onjoinDb[ply:SteamID()] = nil
end)

function SA.Teleporter.TriggerOnJoin(ply)
	local loc = onjoinDb[ply:SteamID()]
	if loc and loc ~= "" then
		print("Join teleport", ply, loc)
		SA.Teleporter.GoTo(ply, loc)
		return true
	end
	return false
end
