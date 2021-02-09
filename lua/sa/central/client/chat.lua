net.Receive("SA_Central_Chat", function()
	local server = net.ReadString()
	local teamChat = net.ReadBool()
	local name = net.ReadString()
	local teamId = net.ReadUInt(8)
	local alive = net.ReadBool()
	local text = net.ReadString()

	local tab = {}

	table.insert(tab, Color(30, 160, 40))
	table.insert(tab, "[" .. server .. "] ")

	if not alive then
		table.insert(tab, Color(255, 30, 40))
		table.insert(tab, "*DEAD* ")
	end

	if teamChat then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, "(TEAM) ")
	end

	table.insert(tab, team.GetColor(teamId))
	table.insert(tab, name)

	table.insert(tab, color_white)
	table.insert(tab, ": " .. text)

	chat.AddText(unpack(tab))

	return true
end)
