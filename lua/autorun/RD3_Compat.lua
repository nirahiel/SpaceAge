timer.Simple(1, function() --Wait to load or it will load before RD3 and fail!
	if not (CAF and CAF.GetAddon("Resource Distribution")) then 
		Msg("\n\n".."====================================\n")
		Msg("== RD2 to RD3 Conversion INACTIVE ==\n") 
		Msg("====================================\n\n")
		return false  
	end

	Msg("\n\n".."==================================\n")
	Msg("== RD2 to RD3 Conversion ACTIVE ==\n") 
	Msg("==================================\n\n")

	local RD = CAF.GetAddon("Resource Distribution")

	function Dev_Unlink_All(ent)
		RD.RemoveRDEntity(ent)	
	end

	function RD_AddResource(ent, resource, maximum, default)
		if resource == "air" then resource = "oxygen" end
		if resource == "coolant" then resource = "liquid nitrogen" end
		RD.AddResource(ent, resource, maximum or 0, default or 0)
	end

	function RD_GetResourceAmount(ent, resource)
		if resource == "air" then resource = "oxygen" end
		if resource == "coolant" then resource = "liquid nitrogen" end
		return RD.GetResourceAmount(ent, resource) or 0
	end

	function RD_ConsumeResource(ent, resource, ammount)
		if resource == "air" then resource = "oxygen" end
		if resource == "coolant" then resource = "liquid nitrogen" end
		return RD.ConsumeResource(ent, resource, ammount or 0)
	end

	function RD_SupplyResource(ent, resource, ammount)
		if resource == "air" then resource = "oxygen" end
		if resource == "coolant" then resource = "liquid nitrogen" end
		RD.SupplyResource(ent, resource, ammount or 0)
	end

	function RD_GetUnitCapacity(ent, resource)
		if resource == "air" then resource = "oxygen" end
		if resource == "coolant" then resource = "liquid nitrogen" end
		return RD.GetUnitCapacity(ent, resource) or 0
	end

	function RD_GetNetworkCapacity(ent, resource)
		if resource == "air" then resource = "oxygen" end
		if resource == "coolant" then resource = "liquid nitrogen" end
		return RD.GetNetworkCapacity(ent, resource) or 0
	end

	function RD_BuildDupeInfo(ent)
		return RD.BuildDupeInfo(ent)	
	end

	function RD_ApplyDupeInfo(Ent, CreatedEntities)
		return RD.ApplyDupeInfo(Ent, CreatedEntities) 
	end

	function LS_RegisterEnt(ent, name)
		return false
	end

end)

