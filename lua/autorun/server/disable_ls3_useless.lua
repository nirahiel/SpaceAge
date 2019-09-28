timer.Simple(1, function()
	local RD = CAF.GetAddon("Resource Distribution")
	if not SA_OLD_REG then
	                SA_OLD_REG = RD.RegisterNonStorageDevice
	end
	if not SA_OLD_REG then
	        error("WAT")
	end
	function RD.RegisterNonStorageDevice(ent)
	        if ent.caf.custom.resource == "oxygen" then
	                ent:Remove()
	                return
	        end
	        SA_OLD_REG(ent)
	end
end)
