require("gwsockets")

local stomp = {}

local stompId = 1

local HEARTBEAT_RATE = 5

STOMP_DEFAULT_DURABLE = {
	["x-expires"] = 60 * 1000,
	durable = "true",
	["auto-delete"] = "false",
}

function NewSTOMPSocket(opts)
	local sock = {
		timerId = "STOMP_HeartBeat_" .. stompId,
		connected = false,
		sendQueue = {},
		subscriptionIds = {},
		subscriptions = {},
		maxSubscriptionId = 1,
	}
	stompId = stompId + 1

	for k, v in pairs(opts) do
		sock[k] = v
	end
	sock = setmetatable(sock, {
		__index = stomp,
	})
	return sock
end

function stomp:_onReceive(msg)
	if msg == "\n" then
		return
	end

	local nullByte = msg:find("\0", 1, true)
	if not nullByte then
		return false
	end

	local cmd
	local headers = {}

	local strBegin = 1
	local strEnd = 1
	while true do
		strEnd = msg:find("\n", strBegin, true)
		if strEnd <= 0 then
			break
		end

		local cur = msg:sub(strBegin, strEnd - 1)
		strBegin = strEnd + 1

		if cur == "" then
			if cmd then
				break
			end
			continue
		end
		if not cmd then
			cmd = cur
		else
			local colonPos = cur:find(":", 1, true)
			if not colonPos then
				continue
			end
			headers[cur:sub(1, colonPos - 1)] = cur:sub(colonPos + 1)
		end
	end

	if not cmd then
		self:disconnect()
		return false
	end

	local data = msg:sub(strEnd, nullByte - 1)
	self:_handleData(cmd, headers, data)
end

function stomp:_handleData(cmd, headers, data)
	local handler = self["_handle_" .. cmd:lower()]
	if handler then
		handler(self, data, headers)
	else
		print("Unhandled STOMP command:", cmd)
	end
end

function stomp:_handle_connected(data, headers)
	self.handshakeDone = true
	self:onConnected()
	for id, _ in pairs(self.subscriptions) do
		self:_subscribe(id)
	end
	for _, toSend in pairs(self.sendQueue) do
		self:_command(unpack(toSend))
	end
	self.sendQueue = {}
end

function stomp:_handle_error(data)
	print("Got STOMP error", data)
	if not self.handshakeDone then
		self.ws:close()
	end
end

function stomp:_handle_message(data, headers)
	local id = headers.subscription
	local subInfo = self.subscriptions[id]
	if not subInfo then
		return
	end
	local handler = subInfo.handler
	if not handler then
		return
	end

	if headers["content-type"] == "application/json" then
		data = util.JSONToTable(data)
	end
	handler(data, headers)
end

function stomp:open()
	local sock = self
	self.handshakeDone = false

	timer.Create(sock.timerId, HEARTBEAT_RATE, 0, function()
		sock:_heartbeat()
	end)

	local ws = GWSockets.createWebSocket(self.url)
	self.ws = ws

	function ws:onMessage(msg)
		sock:_onReceive(msg)
	end

	function ws:onConnected()
		sock.connected = true
		local heartbeatMS = HEARTBEAT_RATE * 1000
		sock:_command("CONNECT", "", {
			["accept-version"] = "1.2",
			["heart-beat"] = heartbeatMS .. "," .. heartbeatMS,
			host = sock.vhost,
			login = sock.login,
			passcode = sock.passcode,
		})
	end

	function ws:onDisconnected()
		sock.connected = false
		sock.ws = nil
		sock:onDisconnected()
		if sock.autoReconnect then
			timer.Simple(1, function()
				sock:open()
			end)
		end
	end

	ws:open()
end

function stomp:close()
	self.autoReconnect = false
	timer.Remove(self.timerId)
	self.ws:close()
end

function stomp:_heartbeat()
	if not self.connected then
		return false
	end
	self.ws:write("\n")
	return true
end

function stomp:_command(cmd, data, headers)
	if not self.connected then
		return false
	end

	local msg = {cmd}

	if not headers then
		headers = {}
	end
	headers["content-length"] = data:len()

	for k, v in pairs(headers) do
		table.insert(msg, k .. ":" .. v)
	end

	self.ws:write(table.concat(msg, "\n") .. "\n\n" .. data .. "\0")
	timer.Adjust(self.timerId, HEARTBEAT_RATE)
	return true
end

function stomp:subscribe(destination, handler, config)
	local id = self.login .. "|" .. destination

	if self.subscriptions[id] then
		return
	end

	local sub = {
		handler = handler,
		data = {
			destination = destination,
			ack = "auto",
			id = id,
		}
	}

	for k, v in pairs(config) do
		sub.data[k] = v
	end

	self.subscriptions[id] = sub

	self:_subscribe(id)

	return id
end

function stomp:unsubscribeAll()
	for id, _ in pairs(self.subscriptions) do
		self:_unsubscribe(id)
	end
	self.subscriptions = {}
end

function stomp:unsubscribe(id)
	if not self.subscriptions[id] then
		return
	end
	self:_unsubscribe(id)
	self.subscriptions[id] = nil
end

function stomp:_unsubscribe(id)
	local data = self.subscriptions[id]
	self:_command("UNSUBSCRIBE", "", data.data)
end

function stomp:_subscribe(id)
	local data = self.subscriptions[id]
	self:_command("SUBSCRIBE", "", data.data)
end

function stomp:send(destination, data)
	data = util.TableToJSON(data)
	local headers = {
		destination = destination,
		["user-id"] = self.login,
		["content-type"] = "application/json",
	}
	local res = self:_command("SEND", data, headers)
	if self.autoReconnect and not res then
		table.insert(self.sendQueue, {"SEND", data, headers})
		return true
	end
	return res
end

function stomp:onMessage(msg, destination)
end
function stomp:onConnected()
end
function stomp:onDisconnected()
end
