if (SERVER) then
	AddCSLuaFile("Anti-Ice-Detect.lua")
elseif (CLIENT) then
	local FBM = ents.FindByModel
	function ents.FindByModel(str)
		local Table = FBM(str)
		if !Table then return {} end
		for k,v in pairs(Table) do
			if ValidEntity(v) and v:GetClass() == "iceroid" then
				Table[k] = nil
			end
		end
		return Table
	end

	local FBC = ents.FindByClass
	function ents.FindByClass(str)
		local Table = FBC(str)
		if !Table then return {} end
		for k,v in pairs(Table) do
			if ValidEntity(v) and v:GetClass() == "iceroid" then
				Table[k] = nil
			end
		end
		return Table
	end

	local FIB = ents.FindInBox
	function ents.FindInBox(min, max)
		local Table = FIB(min, max)
		if !Table then return {} end
		for k,v in pairs(Table) do
			if ValidEntity(v) and v:GetClass() == "iceroid" then
				Table[k] = nil
			end
		end
		return Table
	end

	local FIC = ents.FindInCone
	function ents.FindInCone(pos, dir, dist, radius)
		local Table = FIC(pos, dir, dist, radius)
		if !Table then return {} end
		for k,v in pairs(Table) do
			if ValidEntity(v) and v:GetClass() == "iceroid" then
				Table[k] = nil
			end
		end
		return Table
	end

	local FIS = ents.FindInSphere
	function ents.FindInSphere(center, radius)
		local Table = FIS(center, radius)
		if !Table then return {} end
		for k,v in pairs(Table) do
			if ValidEntity(v) and v:GetClass() == "iceroid" then
				Table[k] = nil
			end
		end
		return Table
	end

	local GA = ents.GetAll
	function ents.GetAll()
		local Table = GA()
		if !Table then return {} end
		for k,v in pairs(Table) do
			if ValidEntity(v) and v:GetClass() == "iceroid" then
				Table[k] = nil
			end
		end
		return Table
	end

	local GBI = ents.GetByIndex
	function ents.GetByIndex(index)
		Ent = GBI(index)
		if ValidEntity(Ent) && Ent:GetClass() == "iceroid" then
			return NullEntity()
		end
		return Ent
	end

	local E = Entity
	function Entity(idx)
		Ent = E(idx)
		if ValidEntity(Ent) && Ent:GetClass() == "iceroid" then
			return NullEntity()
		end
		return Ent
	end
end