SA.Pyrothium = SA.Pyrothium or {}

function SA.Pyrothium.Boost(ent)
	local pos = ent:GetPos()
	local Ang = ent:GetAngles()
	local trace = {}
	trace.start = pos + (Ang:Forward() * ent:OBBMaxs().z)
	trace.endpos = pos + (Ang:Forward() * ent.BeamLength)
	trace.filter = { ent }
	local tr = util.TraceLine(trace)
	if (tr.Hit) then
		local hitent = tr.Entity
		local boosted = 0
		if hitent.BoostResource then
			boosted = hitent:BoostResource()
		end
		return boosted
	end
	return 0
end


function SA.Pyrothium.FlagAsBoosted(ent)
	local entID = ent:EntIndex()
	ent.boosted = true
	timer.Remove("SA_PyroBoost_" .. entID)
	timer.Create("SA_PyroBoost_" .. entID, 2, 1, function()
		if not (ent:IsValid()) then timer.Remove("SA_PyroBoost_" .. entID) return end
		ent.boosted = false
	end)
end
