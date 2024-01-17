local isFullLoaded = false
function SA.RunOnLoaded(name, func)
	if isFullLoaded then
		func(LocalPlayer())
	end
	hook.Add("SA_PlayerLoaded", name, func)
end
local function SA_CheckLoad()
	local ply = LocalPlayer()
	if (not IsValid(ply)) or (not ply:GetNWBool("isloaded")) then
		timer.Simple(1, SA_CheckLoad)
		return
	end
	isFullLoaded = true
	hook.Run("SA_PlayerLoaded", ply)
end
SA_CheckLoad()
