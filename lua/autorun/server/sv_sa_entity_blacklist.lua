timer.Simple(1, function()
	local RD = CAF.GetAddon("Resource Distribution")
	local SA_OLD_REG = RD.RegisterNonStorageDevice
	function RD.RegisterNonStorageDevice(ent)
		if ent.caf.custom.resource == "oxygen" then
			ent:Remove()
			return
		end
		SA_OLD_REG(ent)
	end
end)

local BadSENTs = {"sent_ball"}

hook.Add("PlayerSpawnSENT", "SA_StopBadProps", function(ply, ent)
	for k, v in  pairs(BadSENTs) do
		if v == ent then
			ply:ChatPrint ("Sorry you can't spawn this SENT "  .. v)
			return false
		end
	end
end)
