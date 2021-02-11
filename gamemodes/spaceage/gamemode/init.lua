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
