SA.REQUIRE("api.main")

local ourNameSet = nil
local weAreHidden = nil

function SA.API.GetServerName()
	return ourNameSet
end

function SA.API.SetOwnInfo(info)
	local name = info.name
	weAreHidden = info.hidden
	if name == ourNameSet then
		return
	end
	ourNameSet = name
	RunConsoleCommand("hostname", "SpaceAge [" .. name .. "]")
	SetGlobalString("sa_server_name", name)
end

function SA.API.IsServerHidden()
	return weAreHidden
end
