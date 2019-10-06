SA.API = {}

local MakeUserAgent

local function CommonUserAgent(side)
	return "SpaceAge/GMod-" .. side .. " " .. game.GetIPAddress()
end

local apiConfig = SA.Config.Load("api", true) or {}
apiConfig.url = apiConfig.url or "https://api.spaceage.online/v2"

if SERVER then
	AddCSLuaFile()

	MakeUserAgent = function()
		return CommonUserAgent("Server")
	end
else
	MakeUserAgent = function()
		return CommonUserAgent("Client")
	end
end

local clientID = MakeUserAgent()
timer.Simple(1, function()
	clientID = MakeUserAgent()
end)

local requestQueue = {}
local requestInProgress = false

local failureCount = 0
local backoffTimings = {1, 5, 10, 15, 30}
local backoffMax = backoffTimings[#backoffTimings]

local function processNextRequest()
	if requestInProgress then
		return
	end
	local request = table.remove(requestQueue, 1)
	if not request then
		return
	end
	requestInProgress = true
	HTTP(request)
end

local function successRequest(request)
	failureCount = 0
	requestInProgress = false
	timer.Simple(0, processNextRequest)
end

local function requeueRequest(request)
	failureCount = failureCount + 1
	local timing = backoffTimings[failureCount] or backoffMax
	print("Requeueing ", request.url, request.method, " for ", timing, " seconds after ", failureCount, " failures")
	requestInProgress = false
	table.insert(requestQueue, 1, request)
	timer.Simple(timing, processNextRequest)
end

function SA.API.Request(url, method, reqBody, options, callback, retries)
	if not retries then
		retries = 0
	end
	if not options then
		options = {}
	end

	local headers = {}
	if not options.noauth then
		headers.Authorization = apiConfig.auth
	end
	headers["Client-ID"] = clientID or "N/A"

	local request = {
		headers = headers,
		method = method or "GET",
		url = apiConfig.url .. url,
		type = "application/json",
		body = reqBody and util.TableToJSON(reqBody) or nil
	}

	request.failure = function(_err)
		requeueRequest(request)
	end

	request.success = function(code, body, _headers)
		if code > 499 then
			return requeueRequest(request)
		end

		successRequest(request)

		if not callback then
			return
		end

		if body then
			body = util.JSONToTable(body)
		end

		callback(body, code)
	end

	table.insert(requestQueue, request)

	processNextRequest()
end

local bodyless = {"Get", "Head", "Delete", "Options"}
local bodyful = {"Post", "Patch", "Put"}

for _, v in pairs(bodyless) do
	local method = v:upper()
	SA.API[v] = function(url, callback, options)
		return SA.API.Request(url, method, nil, options, callback)
	end
end

for _, v in pairs(bodyful) do
	local method = v:upper()
	SA.API[v] = function(url, body, callback, options)
		return SA.API.Request(url, method, body, options, callback)
	end
end

local function MakePlayerURL(ply)
	return "/players/" .. ply:SteamID()
end

local function MakePlayerResURL(ply, res)
	return MakePlayerURL(ply) .. "/" .. res
end

local function MakePlayerResIDURL(ply, res, id)
	return MakePlayerResURL(ply, res) .. "/" .. id
end

local function MakeFactionURL(faction)
	return "/factions/" .. faction
end

local function MakeFactionResURL(faction, res)
	return MakeFactionURL(faction) .. "/" .. res
end

local function MakeFactionResIDURL(faction, res, id)
	return MakeFactionResURL(faction, res) .. "/" .. id
end

local OPTIONS_NOAUTH = { noauth = true }

-- Basic LIST calls (scoreboard style)
function SA.API.ListPlayers(callback)
	return SA.API.Get("/players", callback, OPTIONS_NOAUTH)
end

function SA.API.ListFactions(callback)
	return SA.API.Get("/factions", callback, OPTIONS_NOAUTH)
end

-- PLAYER functions
function SA.API.GetPlayer(ply, callback)
	return SA.API.Get(MakePlayerURL(ply), callback, OPTIONS_NOAUTH)
end

function SA.API.GetPlayerFull(ply, callback)
	return SA.API.Get(akePlayerURL(ply) .. "/full", callback)
end

function SA.API.UpsertPlayer(ply, callback)
	return SA.API.Put(MakePlayerURL(ply), ply.sa_data, callback)
end

-- PLAYER -> APPLICATION functions
function SA.API.GetPlayerApplication(ply, callback)
	return SA.API.Get(MakePlayerResURL(ply, "application"), callback)
end

function SA.API.UpsertPlayerApplication(ply, body, callback)
	return SA.API.Put(MakePlayerResURL(ply, "application"), body, callback)
end

-- PLAYER -> GOODIE functions
function SA.API.GetPlayerGoodies(ply, callback)
	return SA.API.Get(MakePlayerResURL(ply, "goodies"), callback)
end

function SA.API.DeletePlayerGoodie(ply, id, callback)
	return SA.API.Delete(MakePlayerResIDURL(ply, "goodies", id), callback)
end

-- FACTION -> APPLICATION functions
function SA.API.ListFactionApplications(faction, callback)
	return SA.API.Get(MakeFactionResURL(faction, "applications"), callback)
end

function SA.API.DeleteFactionApplication(faction, steamid, callback)
	return SA.API.Delete(MakeFactionResIDURL(faction, "applications", steamid), callback)
end

function SA.API.AcceptFactionApplication(faction, steamid, callback)
	return SA.API.Post(MakeFactionResIDURL(faction, "applications", steamid) .. "/accept", {}, callback)
end
