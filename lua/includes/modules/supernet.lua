supernet = {}

if SERVER then
	AddCSLuaFile("includes/modules/supernet.lua")
end

local tinsert = table.insert
local tremove = table.remove

local TOTAL_SIZE_MAX = SERVER and 2000000 or nil
local SIZE_MAX = 60000
local MSGCOUNT_MAX = TOTAL_SIZE_MAX and math.floor(TOTAL_SIZE_MAX / SIZE_MAX) or nil

local queue = {}
local inqueue = {}
local hooks = {}
local msgid = 0

print("supernet, TOTAL_SIZE_MAX = ", TOTAL_SIZE_MAX, ", SIZE_MAX = ", SIZE_MAX, ", MSGCOUNT_MAX = ", MSGCOUNT_MAX)

local sendFunc = net.SendToServer
if SERVER then
	sendFunc = net.Send
	util.AddNetworkString("SuperNet_MSG")
end

function supernet.Send(trg, name, data, cb)
	msgid = msgid + 1
	if msgid > 4095 then
		msgid = 1
	end
	local dJSON = util.TableToJSON(data)
	local dComp = util.Compress(dJSON)
	tinsert(queue, {msgid, trg, name, dComp, cb, 1, dComp:len()})
end

function supernet.Hook(name, cb)
	hooks[name] = cb
end

local function callCB(cb, str)
	local decomp = util.Decompress(str, TOTAL_SIZE_MAX)
	if not decomp then
		return
	end
	local tbl = util.JSONToTable(decomp)
	cb(ply, tbl)
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

	local isNew = net.ReadBool()
	local isEnd = net.ReadBool()
	local msgId = net.ReadUInt(14)

	local name
	if isNew then
		name = net.ReadString()
	end

	local dLen = net.ReadUInt(16)
	local dBin = net.ReadData(dLen)

	local data

	if isNew then
		if not name then
			print("No name got from " .. tostring(ply))
			return
		end

		local cb = hooks[name]
		if not cb then
			print("Received supernet for unknown name " .. name .. " from " .. tostring(ply))
			return
		end

		if isEnd then
			callCB(cb, dBin)
			return
		end

		data = {cb, {dBin}, name}
		myqueue[msgId] = data
	else
		data = myqueue[msgId]
		tinsert(data[2], dBin)
	end

	local bits = data[2]
	if MSGCOUNT_MAX and #bits > MSGCOUNT_MAX then
		print("Ignoring message " .. data[3] .. " from " .. tostring(ply) .. ": Exceeded maximum message count!")
		myqueue[msgId] = nil
		return
	end

	if isEnd then
		myqueue[msgId] = nil
		callCB(data[1], table.concat(bits))
	end
end
net.Receive("SuperNet_MSG", NetReceive)

local current
local function RunQueue()
	local isNew = false

	if not current then
		if #queue < 1 then
			return
		end

		isNew = true
		current = tremove(queue, #queue)
	end

	--local msgid = current[1]
	--local target = current[2]
	--local name = current[3]
	--local data = current[4]
	local pos = current[6]
	local left = current[7]

	local isEnd = false
	local len = SIZE_MAX
	if left <= SIZE_MAX then
		isEnd = true
		len = left
	end

	local dSub = current[4]:sub(pos, (pos + len) - 1)
	net.Start("SuperNet_MSG")
		net.WriteBool(isNew)
		net.WriteBool(isEnd)
		net.WriteUInt(current[1], 14)
		if isNew then
			net.WriteString(current[3])
		end
		net.WriteUInt(len, 16)
		net.WriteData(dSub, len)
	sendFunc(current[2])

	if isEnd then
		local cb = current[5]
		current = nil
		cb()
		return
	end

	current[6] = pos + SIZE_MAX
	current[7] = left - SIZE_MAX
end
timer.Create("supernet_RunQueue", 0, 0, RunQueue)
