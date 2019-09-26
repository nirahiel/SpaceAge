local API_BASE = "https://api.spaceage.online/v1"
local API_HEADERS = {
	["User-Agent"] = "SpaceAge GMod " .. (SERVER and "Server" or "Client")
}

SA.API = {}

local MakeUserAgent

if SERVER then
	AddCSLuaFile()

	local apiConfig = util.JSONToTable(file.Read("spaceage/config/api.txt"))
	if apiConfig.auth then
		API_HEADERS.Authorization = "Server " .. apiConfig.auth
	end
	if apiConfig.url then
		API_BASE = apiConfig.url
	end

	MakeUserAgent = function()
		return "SpaceAge/GMod-Server"
	end
else
	MakeUserAgent = function()
		return "SpaceAge/GMod-Client"
	end
end

API_HEADERS["User-Agent"] = MakeUserAgent()

function SA.API.Request(url, method, reqBody, onok, onerror)
	local request = {
		failed = function(err)
			if not onerror then
				return
			end
			onerror(err)
		end,
		success = function(code, body, headers)
			if not onok then
				return
			end

			if body then
				body = util.JSONToTable(body)
			end
			onok(body, code)
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
	SA.API[v] = function(url, onok, onerror)
		return SA.API.Request(url, method, nil, onok, onerror)
	end
end

for _, v in pairs(bodyful) do
	local method = v:upper()
	SA.API[v] = function(url, body, onok, onerror)
		return SA.API.Request(url, method, body, onok, onerror)
	end
end
