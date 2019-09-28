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
