if SERVER then
	hook.Add("PlayerInitialSpawn", "FullLoadSetup", function(plyOuter)
		hook.Add("SetupMove", plyOuter, function(self, ply, _, cmd)
			if self == ply and not cmd:IsForced() then
				hook.Run("PlayerFullLoad", self)
				hook.Remove("SetupMove", self)
			end
		end)
	end)
end

if CLIENT then
	local function SA_CheckLoad()
		local ply = LocalPlayer()
		if not ply or not ply:GetNWBool("isloaded") then
			timer.Simple(1, SA_CheckLoad)
			return
		end
		hook.Run("SA_PlayerLoaded", ply)
	end
	SA_CheckLoad()
end
