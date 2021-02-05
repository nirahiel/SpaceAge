SA.REQUIRE("ore.main")

function SA.Ore.Mine(ent)
	local pos = ent:GetPos()
	local Ang = ent:GetAngles()
	local trace = {}
	trace.start = pos + (Ang:Up() * ent:OBBMaxs().z)
	trace.endpos = pos + (Ang:Up() * ent.BeamLength)
	trace.filter = { ent }
	local tr = util.TraceLine(trace)
	if (tr.Hit) then
		local hitent = tr.Entity
		if hitent.IsAsteroid then
			SA.Functions.MineThing(ent, hitent, "ore")
		elseif hitent.IsOreStorage and GetConVar("sa_pirating"):GetBool() then
			local toUse = math.floor(ent.yield * 1.5)
			toUse = hitent:ConsumeResource("ore", toUse)
			ent:SupplyResource("ore", math.floor(toUse * 0.9))
		elseif hitent:IsPlayer() then
			hitent:TakeDamage(25, ent, ent)
		end
	end
end
