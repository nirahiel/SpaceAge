SA.REQUIRE("central.types")

net.Receive("SA_Central_Chat", function()
	local server = net.ReadString()
	local teamChat = net.ReadBool()
	local name = net.ReadString()
	net.ReadUInt(8) --teamId
	local color = net.ReadColor()
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

	table.insert(tab, color)
	table.insert(tab, name)

	table.insert(tab, color_white)
	table.insert(tab, ": " .. text)

	chat.AddText(unpack(tab))
end)

net.Receive("SA_Central_ChatRaw", function()
	local server = net.ReadString()
	local tab = {}

	local elements = net.ReadUInt(32)

	if server ~= "" then
		table.insert(tab, Color(30, 160, 40))
		table.insert(tab, "[" .. server .. "] ")
	end

	for i = 1, elements do
		local typ = net.ReadUInt(8)

		if typ == SA.Central.TYPE_NIL then
			continue
		end
		if typ == SA.Central.TYPE_COLOR then
			table.insert(tab, net.ReadColor())
			continue
		end
		if typ == SA.Central.TYPE_TEXT then
			table.insert(tab, net.ReadString())
			continue
		end
		if typ == SA.Central.TYPE_PLAYER then
			local name = net.ReadString()
			net.ReadUInt(8) --teamId
			net.ReadBool() --alive
			local color = net.ReadColor()
			table.insert(tab, color)
			table.insert(tab, name)
			continue
		end
	end

	chat.AddText(unpack(tab))
end)
