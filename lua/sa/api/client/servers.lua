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
		if name then
			if not selfServer then
				selfServer = {
					idx = #serverIndexedList + 1,
					name = name,
					location = "N/A",
				}
				serverList[name] = selfServer
				table.insert(serverIndexedList, selfServer)
			end

			selfServer.isself = true
			selfServer.map = game.GetMap()
			selfServer.ipport = game.GetIPAddress()
			selfServer.online = true
		end

		if cb then
			cb(data)
		end
	end)
end

SA.API.RefreshServerList()
