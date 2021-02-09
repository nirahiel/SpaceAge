SA.REQUIRE("api.main")

local serverList = {}

function SA.API.GetServerList()
	return serverList
end

function SA.API.GetServerByName(name)
	for _, srv in pairs(serverList) do
		if srv.name == name then
			return srv
		end
	end
end

function SA.API.RefreshServerList(cb)
	SA.API.ListServers(function(data)
		serverList = data

		local name = SA.API.GetServerName()
		if name and not SA.API.GetServerByName(name) then
			table.insert(serverList, {
				name = name,
				map = game.GetMap(),
				location = "N/A",
			})
		end

		if cb then
			cb(data)
		end
	end)
end

SA.API.RefreshServerList()
