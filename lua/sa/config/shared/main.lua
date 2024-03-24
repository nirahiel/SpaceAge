SA.Config = SA.Config or {}

function SA.Config.Load(typ, isGlobal)
	if not isGlobal then
		typ = "maps/" .. game.GetMap() .. "/" .. typ
	end
	local path = "data_static/sa_config/" .. typ .. ".json"
	local data = file.Read(path, "GAME")
	if not data then
		return
	end
	return util.JSONToTable(data)
end
