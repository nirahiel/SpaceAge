SA.REQUIRE("central.ws")
SA.REQUIRE("central.enums")
SA.REQUIRE("central.encoding")

util.AddNetworkString("SA_Central_Chat")
util.AddNetworkString("SA_Central_ChatRaw")

SA.Central.Handle("chat", function(data, ident)
	net.Start("SA_Central_Chat")
		net.WriteString(ident)
		net.WriteBool(data.teamChat)
		net.WriteString(data.ply.name)
		net.WriteUInt(data.ply.team, 8)
		net.WriteColor(Color(data.ply.color.r, data.ply.color.g, data.ply.color.b, data.ply.color.a))
		net.WriteBool(data.ply.alive)
		net.WriteString(data.text)

	if data.teamChat then
		local rf = RecipientFilter()
		rf:AddRecipientsByTeam(data.ply.team)
		net.Send(rf)
	else
		net.Broadcast()
	end
end)

local function HandleChatRaw(data, ident)
	local msg = data.message or data
	net.Start("SA_Central_ChatRaw")
		net.WriteString(ident)
		net.WriteUInt(#msg, 32)
		for _, v in pairs(msg) do
			SA.Central.WriteMessageElement(v)
		end
	net.Broadcast()
end
SA.Central.Handle("chatraw", HandleChatRaw)

function SA.Central.LocalChatRaw(...)
	HandleCentralMessage({...}, "")
end

SA.Central.Handle("serverjoin", function(data, ident)
	HandleChatRaw({SA.Central.COLOR_NOTIFY_BLUE, "Server came online"}, ident)
end)

SA.Central.Handle("serverleave", function(data, ident)
	HandleChatRaw({SA.Central.COLOR_NOTIFY_BLUE, "Server went offline"}, ident)
end)

function SA.Central.SendChatRaw(...)
	local out = {
		message = {}
	}
	for _, v in pairs({...}) do
		table.insert(out.message, SA.Central.TranslateObjectToCentral(v))
	end
	HandleChatRaw(out, "")
	SA.Central.Broadcast("chatraw", out)
end
