supernet = {}

if SERVER then
	AddCSLuaFile("includes/modules/supernet.lua")
end

local tinsert = table.insert
local tremove = table.remove

local SIZE_MAX = 60000
local MSG_START = 0
local MSG_MID = 1
local MSG_END = 2

local queue = {}
local inqueue = {}
local hooks = {}
local msgid = 0

local sendFunc = net.SendToServer
if SERVER then
	sendFunc = net.Send
	util.AddNetworkString("SuperNet_MSG")
end

function supernet.Send(trg, name, data, cb)
	msgid = msgid + 1
	if msgid > 65530 then
		msgid = 1
	end
	local dJSON = util.TableToJSON(data)
	local dComp = util.Compress(dJSON)
	tinsert(queue, {msgid, trg, name, dComp, cb, 1, dComp:len()})
end

function supernet.Hook(name, cb)
	hooks[name] = cb
end

local function NetReceive(len, ply)
	local myqueue = inqueue
	if SERVER then
		myqueue = inqueue[ply]
		if not myqueue then
			myqueue = {}
			inqueue[ply] = myqueue
		end
	end

	local msgType = net.ReadUInt(8)
	local msgId = net.ReadUInt(16)
	if msgType == MSG_START then
		local name = net.ReadString()
		local cb = hooks[name]
		if not cb then
			print("Received supernet for unknown name " .. name .. " from " .. tostring(ply))
			return
		end
		myqueue[msgId] = {cb, {}}
		return
	end

	local data = myqueue[msgId]
	if not data then
		return
	end

	local dLen = net.ReadUInt(16)
	tinsert(data[2], net.ReadData(dLen))

	if msgType == MSG_END then
		myqueue[msgId] = nil
		local str = table.concat(data[2])
		local decomp = util.Decompress(str)
		local tbl = util.JSONToTable(decomp)
		data[1](ply, tbl)
	end
end
net.Receive("SuperNet_MSG", NetReceive)

local current
local function RunQueue()
	--local msgid = current[1]
	--local target = current[2]
	--local name = current[3]

	if not current then
		if #queue < 1 then
			return
		end

		current = tremove(queue, #queue)

		net.Start("SuperNet_MSG")
			net.WriteUInt(MSG_START, 8)
			net.WriteUInt(current[1], 16)
			net.WriteString(current[3])
		sendFunc(current[2])
	end

	--local data = current[4]
	local pos = current[6]
	local left = current[7]

	local msgType = MSG_MID
	local len = SIZE_MAX
	if left <= SIZE_MAX then
		msgType = MSG_END
		len = left
	end

	local dSub = current[4]:sub(pos, (pos + len) - 1)
	net.Start("SuperNet_MSG")
		net.WriteUInt(msgType, 8)
		net.WriteUInt(current[1], 16)
		net.WriteUInt(len, 16)
		net.WriteData(dSub, len)
	sendFunc(current[2])

	if msgType == MSG_END then
		local cb = current[5]
		current = nil
		cb()
		return
	end

	current[6] = pos + SIZE_MAX
	current[7] = left - SIZE_MAX
end
timer.Create("supernet_RunQueue", 0, 0, RunQueue)
