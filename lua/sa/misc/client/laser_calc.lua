function SA.LaserTraceCalc(ent)
	local mins = ent:OBBMins()
	local maxs = ent:OBBMaxs()

	if not ent.BeamLength or not ent:GetNWBool("o") then
		ent.hitPos = nil
		ent:SetRenderBounds(mins, maxs)
		return
	end

	local pos = ent:GetPos()
	local up = ent:GetUp()

	local tr = util.QuickTrace(pos, up * ent.BeamLength, ent)

	ent.hitPos = tr.HitPos
	ent.hitStart = ent:GetPos() + (up * ent:OBBMaxs().z)
	ent.hitTrace = tr

	maxs = maxs + ((ent.BeamLength * tr.Fraction) * Vector(0,0,1))
	ent:SetRenderBounds(mins, maxs)
	return tr
end
