SA.FileBrowser = {}

function SA.FileBrowser.CanRunAll(ply)
	return ply:IsSuperAdmin()
end

function SA.FileBrowser.CanRunClientside(ply)
	return ply:IsAdmin()
end
