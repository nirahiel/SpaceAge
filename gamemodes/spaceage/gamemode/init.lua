include("shared.lua")

function GM:PlayerSay(ply, text, teamChat)
	if not text or text == "" then
		return text
	end
	local first = text:sub(1, 1)
	if first == "!" or first == "@" then
		return text
	end

	SA.Central.Broadcast("chat", {
		ply = SA.Central.TranslateObjectToCentral(ply),
		text = text,
		teamChat = teamChat,
	})

	return text
end

function GM:PlayerLoadout(ply)
	ply:RemoveAllAmmo()
	ply:Give("gmod_tool")
	ply:Give("gmod_camera")
	ply:Give("weapon_physgun")
	ply:Give("weapon_physcannon")
	ply:Give("weapon_empty_hands")
	ply:SwitchToDefaultWeapon()
	return true
end
