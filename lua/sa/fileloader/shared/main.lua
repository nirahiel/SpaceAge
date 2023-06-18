SA.FileLoader = SA.FileLoader or {}

SA.FileLoader.RUN_SERVERSIDE = "serverside"
SA.FileLoader.RUN_CLIENTSIDE = "clientside"
SA.FileLoader.RUN_SHARED = "shared"
SA.FileLoader.RUN_ALL_CLIENTS = "on all clients"

function SA.FileLoader.CanRunAll(ply)
	return ply:IsSuperAdmin()
end

function SA.FileLoader.CanRunClientside(ply)
	return ply:IsAdmin()
end
