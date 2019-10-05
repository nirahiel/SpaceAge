local API_BASE = "https://api.spaceage.online/v2"
local API_HEADERS = {}

SA.API = {}

local MakeUserAgent

local function CommonUserAgent(side)
	return "SpaceAge/GMod-" .. side .. " " .. game.GetIPAddress()
end

local apiConfig = SA.Config.Load("api", true) or {}
if apiConfig.auth then
	API_HEADERS.Authorization = apiConfig.auth
end
if apiConfig.url then
	API_BASE = apiConfig.url
end

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

timer.Simple(1, function()
	API_HEADERS["Client-ID"] = MakeUserAgent()
end)

local retryBackoffTable = {1, 5, 10, 15, 30, 60}

local function SA_API_Retry(code, url, method, reqBody, callback, retries)
	local delay = retryBackoffTable[retries]
	print("API request to ", method, url, " failed, retrying in ", delay, " seconds")

	if not delay then
		callback(nil, 503)
		return
	end

	timer.Simple(delay, function()
		SA.API.Request(url, method, reqBody, callback)
	end)
end

function SA.API.Request(url, method, reqBody, callback, retries)
	if not retries then
		retries = 0
	end

	local request = {
		failed = function(_err)
			SA_API_Retry(503, url, method, reqBody, callback, retries + 1)
		end,
		success = function(code, body, _headers)
			if code > 499 then
				SA_API_Retry(code, url, method, reqBody, callback, retries + 1)
				return
			end

			if not callback then
				return
			end

			if body then
				body = util.JSONToTable(body)
			end

			callback(body, code)
		end,
		headers = API_HEADERS,
		method = method or "GET",
		url = API_BASE .. url,
		type = "application/json",
		body = reqBody and util.TableToJSON(reqBody) or nil
	}

	HTTP(request)
end

local bodyless = {"Get", "Head", "Delete", "Options"}
local bodyful = {"Post", "Patch", "Put"}

for _, v in pairs(bodyless) do
	local method = v:upper()
	SA.API[v] = function(url, callback, onerror)
		return SA.API.Request(url, method, nil, callback, onerror)
	end
end

for _, v in pairs(bodyful) do
	local method = v:upper()
	SA.API[v] = function(url, body, callback, onerror)
		return SA.API.Request(url, method, body, callback, onerror)
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

-- Basic LIST calls (scoreboard style)
function SA.API.ListPlayers(callback)
	return SA.API.Get("/players", callback)
end

function SA.API.ListFactions(callback)
	return SA.API.Get("/factions", callback)
end

-- PLAYER functions
function SA.API.GetPlayer(ply, callback)
	local url = MakePlayerURL(ply)
	if SERVER then
		url = url .. "/full"
	end
	return SA.API.Get(url, callback)
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
