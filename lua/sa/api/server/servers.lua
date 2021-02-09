SA.REQUIRE("api.main")

local ourNameSet = nil

function SA.API.SetOwnName(name)
	if name == ourNameSet then
		return
	end
	ourNameSet = name
	RunConsoleCommand("hostname", "SpaceAge [" .. name .. "]")
	SetGlobalString("sa_server_name", name)
end
