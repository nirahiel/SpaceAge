function SA.FindClosestEnt(pos, classes)
	local closestEnt
	local closestEntDist = 999999999999

	local allValid = false
	local finder = ents.GetAll
	if #classes == 1 then
		finder = function ()
			return ents.FindByClass(classes[1])
		end
		allValid = true
	end

	for _, ent in pairs(finder()) do
		if not allValid and not table.HasValue(classes, ent:GetClass()) then
			continue
		end
		local dist = ent:GetPos():DistToSqr(pos)
		if dist < closestEntDist then
			closestEnt = ent
			closestEntDist = dist
		end
	end
	return closestEnt
end
