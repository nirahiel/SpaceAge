hook.Add("PlayerInitialSpawn", "FullLoadSetup", function(plyOuter)
	hook.Add("SetupMove", plyOuter, function(self, ply, _, cmd)
		if self == ply and not cmd:IsForced() then
			hook.Run("PlayerFullLoad", self)
			hook.Remove("SetupMove", self)
		end
	end)
end)
