SA.REQUIRE("central.main")

--[[
local function MakeMessageElement(obj)
	if not obj then
		return
	end

	if obj.IsPlayer and obj:IsPlayer() then
		return {
			type = "player",
			name = obj:GetName(),
			color = team.GetColor(obj:Team()),
			alive = obj:Alive(),
		}
	end

	if obj.r and obj.g and obj.b and obj.a then
		return {
			type = "color",
			r = obj.r,
			g = obj.g,
			b = obj.b,
			a = obj.a,
		}
	end

	return {
		type = "text",
		text = tostring(obj),
	}
end
]]

hook.Add("PlayerSay", "SA_Central_PlayerSay", function (ply, text, teamChat)
	if text == "" then
		return
	end
	local first = text:sub(1, 1)
	if first == "!" or first == "@" then
		return
	end

	SA.Central.Broadcast("chat", {
		ply = {
			name = ply:GetName(),
			team = ply:Team(),
			alive = ply:Alive(),
		},
		text = text,
		teamChat = teamChat,
	})
end)

util.AddNetworkString("SA_Central_Chat")
SA.Central.Handle("chat", function(data, ident)
	net.Start("SA_Central_Chat")
		net.WriteString(ident)
		net.WriteBool(data.teamChat)
		net.WriteString(data.ply.name)
		net.WriteUInt(data.ply.team, 8)
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
