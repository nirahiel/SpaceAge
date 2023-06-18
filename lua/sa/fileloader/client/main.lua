local function RunOn(def, path, pathType)
	local checkFunc = SA.FileLoader.CanRunAll
	if def == SA.FileLoader.RUN_CLIENTSIDE then
		checkFunc = SA.FileLoader.CanRunClientside
	end
	if not checkFunc(LocalPlayer()) then
		return
	end

	local data = file.Read(path, pathType or "GAME")
	if not data then
		return
	end
	if def == SA.FileLoader.RUN_CLIENTSIDE then
		notification.AddLegacy("Script ran " .. def, NOTIFY_GENERIC, 5)
		RunString(data)
		return
	end

	net.Start("SA_RunLua")
		net.WriteString(def)
		net.WriteString(data)
	net.SendToServer()
end

net.Receive("SA_RunLua", function()
	local str = net.ReadString()
	if not str then
		return
	end
	RunString(str)
end)

local function OpenFileBrowser()
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 250)
	frame:SetSizable(true)
	frame:SetDraggable(true)
	frame:Center()
	frame:MakePopup()
	frame:SetTitle("SpaceAge File Browser")

	local browser = vgui.Create("DFileBrowser", frame)
	browser:Dock(FILL)

	browser:SetPath("GAME")
	browser:SetBaseFolder("")
	browser:SetOpen(true)
	browser:SetCurrentFolder("lua")

	function browser:OnRightClick(path, pnl)
		local menu = DermaMenu()
		local function AddSendOption(str)
			menu:AddOption("Run " .. str, function() RunOn(str, path) end)
		end
		AddSendOption(SA.FileLoader.RUN_CLIENTSIDE)
		if SA.FileLoader.CanRunAll(LocalPlayer()) then
			AddSendOption(SA.FileLoader.RUN_SERVERSIDE)
			AddSendOption("shared")
			AddSendOption("on all clients")
			menu:AddSpacer()
			for _, ply in pairs(player.GetHumans()) do
				local pid = ply:SteamID()
				menu:AddOption("Run on " .. ply:GetName(), function() RunOn(pid, path) end)
			end
			menu:Open()
		end
	end
end

hook.Add("InitPostEntity", "SA_FileLoader_Load", function()
	RunOn(SA.FileLoader.RUN_CLIENTSIDE, "sa_clientlua_autoload.lua", "LUA")
end)

concommand.Add("sa_open_file_browser", function()
	if not SA.FileLoader.CanRunClientside(LocalPlayer()) then
		return
	end
	OpenFileBrowser()
end)

local targetRemaps = {
	client = SA.FileLoader.RUN_CLIENTSIDE,
	["local"] = SA.FileLoader.RUN_CLIENTSIDE,
	["self"] = SA.FileLoader.RUN_CLIENTSIDE,
	me = SA.FileLoader.RUN_CLIENTSIDE,

	server = SA.FileLoader.RUN_SERVERSIDE,

	everyone = SA.FileLoader.RUN_ALL_CLIENTS,

	all = SA.FileLoader.RUN_SHARED,
	["global"] = SA.FileLoader.RUN_SHARED,
}

concommand.Add("sa_load_file", function(_, _, args)
	if #args < 2 then
		return
	end

	local target = args[1]
	target = targetRemaps[target] or target
	RunOn(target, args[2], args[3])
end)
