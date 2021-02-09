SA.REQUIRE("api.main")

local serverList = {}
local serverIndexedList = {}

function SA.API.GetServerList()
	return serverIndexedList
end

function SA.API.GetServerByIndex(idx)
	return serverIndexedList[idx]
end

function SA.API.GetServerByName(name)
	return serverList[name]
end

function SA.API.RefreshServerList(cb)
	SA.API.ListServers(function(data)
		serverList = {}

		for k, srv in pairs(data) do
			srv.idx = k
			serverList[srv.name] = srv
		end

		serverIndexedList = data

		local name = SA.API.GetServerName()
		local selfServer = SA.API.GetServerByName(name)
		if name and not selfServer then
			local dummy = {
				idx = #serverIndexedList + 1,
				name = name,
				map = game.GetMap(),
				location = "N/A",
				ipport = game.GetIPAddress(),
			}
			serverList[name] = dummy
			table.insert(serverIndexedList, dummy)
		elseif selfServer.ipport == "" then
			selfServer.ipport = game.GetIPAddress()
		end

		if cb then
			cb(data)
		end
	end)
end

SA.API.RefreshServerList()
