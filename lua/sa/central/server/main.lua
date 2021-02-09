SA.REQUIRE("api")

require("gwsockets")

SA.Central = {}

local socket

local centralIdent = "UNK"
local ourIdent = "UNK"

local idCallbacks = {}
local cmdCallbacks = {}

local SendCentralMessage

local lastID = 0
local function GetCommandID()
	lastID = lastID + 1
	return "LUA_" .. tostring(lastID)
end

local function SendCommand(command, target, data, callback)
	local id = GetCommandID()
	local cmd = {
		id = id,
		command = command,
		target = target,
		data = data,
	}
	idCallbacks[id] = callback
	SendCentralMessage(cmd)
end

local function ReplyToMessage(msg, data)
	local cmd = {
		id = msg.id,
		command = "reply",
		target = msg.ident,
		data = data,
	}
	SendCentralMessage(cmd)
end

local function HandleCentralMessage(msg)
	if msg.ident == ourIdent then
		return
	end

	if msg.command == "ping" then
		ReplyToMessage(msg)
		return
	end

	local callback = idCallbacks[msg.id]

	if msg.command == "error" then
		if callback then
			callback(false, msg.data, msg.ident)
			idCallbacks[msg.id] = nil
		else
			print("Got error", msg.id, msg.data)
		end
		return
	end

	if msg.command == "reply" then
		if callback then
			callback(true, msg.data, msg.ident)
			idCallbacks[msg.id] = nil
		end
		return
	end

	local handler = cmdCallbacks[msg.command]
	if handler then
		handler(msg.data, msg.ident, function(reply)
			ReplyToMessage(msg, reply)
		end)
	end
end

SendCentralMessage = function(msg)
	if not socket then
		return
	end
	socket:write(util.TableToJSON(msg))
end

local ConnectCentral
local function TimerConnectCentral()
	timer.Simple(1, ConnectCentral)
end

ConnectCentral = function()
	local headers = SA.API.GetHTTPHeaders()

	idCallbacks = {}
	socket = GWSockets.createWebSocket("wss://api.spaceage.mp/ws/central")
	for k, v in pairs(headers) do
		socket:setHeader(k, v)
	end

	function socket:onConnected()
		print("[Central] Link connected...")
	end

	function socket:onDisconnected()
		print("[Central] Link lost...")
		TimerConnectCentral()
	end

	function socket:onMessage(txt)
		local res = util.JSONToTable(txt)
		if res then
			HandleCentralMessage(res)
		end
	end

	socket:open()
end

TimerConnectCentral()

function SA.Central.SendTo(target, command, data, callback)
	SendCommand(command, target, data, callback)
end

function SA.Central.SendToCentral(command, data, callback)
	SendCommand(command, centralIdent, data, callback)
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

SA.Central.Handle("welcome", function(data, from)
	centralIdent = from
	ourIdent = data
	print("[Central] Central is", centralIdent, "; we are ", ourIdent)
end)

timer.Create("SA_Central_Ping", 5, 0, function()
	SA.Central.SendToCentral("ping")
end)
