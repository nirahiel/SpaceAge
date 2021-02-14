SA.REQUIRE("api")
SA.REQUIRE("central.core")

require("stomp")

local socket
local ourIdent
local cmdCallbacks = {}
local SendCentralMessage

local function SendCommand(command, target, data)
	local cmd = {
		command = command,
		data = data,
	}
	SendCentralMessage(cmd, target)
end

local function HandleCentralMessage(msg, headers)
	local ident = headers["user-id"]
	if (not ident) or (ident == ourIdent) then
		return
	end

	if msg.command == "error" then
		print("Got error", msg.id, msg.data)
		return
	end

	local handler = cmdCallbacks[msg.command]
	if handler then
		handler(msg.data, ident)
	end
end

SendCentralMessage = function(msg, target)
	if not socket then
		return
	end
	socket:send((target or "broadcast"):lower(), msg)
end

local ConnectCentral
local function TimerConnectCentral()
	timer.Simple(1, ConnectCentral)
end

ConnectCentral = function()
	ourIdent = SA.API.GetServerName()
	local ourKey = SA.API.GetServerToken()

	if not ourIdent then
		TimerConnectCentral()
		return
	end

	socket = NewSTOMPSocket({
		url = "wss://live.spaceage.mp/ws/stomp",
		vhost = "spaceage",
		login = ourIdent,
		passcode = ourKey,
		autoReconnect = true,
	})
	socket:subscribe("broadcast", HandleCentralMessage)
	socket:subscribe(ourIdent:lower(), HandleCentralMessage)

	function socket:onConnected()
		print("[Central] Link connected...")
		if not SA.Central.StartupSent then
			if not SA.API.IsServerHidden() then
				SA.Central.Broadcast("serverjoin")
			end
			SA.Central.StartupSent = true
		end
	end

	function socket:onDisconnected()
		print("[Central] Link lost...")
	end

	socket:open()
end

TimerConnectCentral()

function SA.Central.SendTo(target, command, data)
	SendCommand(command, target, data)
end

function SA.Central.Broadcast(command, data)
	SendCommand(command, nil, data)
end

function SA.Central.Handle(command, callback)
	if cmdCallbacks[command] then
		print("[Central] WARNING: Overwriting old handler for " .. command)
	end
	cmdCallbacks[command] = callback
end
