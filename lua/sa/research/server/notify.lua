SA_REQUIRE("research.main")

function SA.Research.RemoveEntityWithWarning(ent, research, requiredLevel)
	local ply = ent:GetTable().Founder
	local rank = ent:GetNWInt("rank")
	local name = ent.PrintName
	ent:Remove()
	if IsValid(ply) then
		local researchObj = SA.Research.GetByName(research)
		local researchName = researchObj.display
		local msg = "You cannot spawn " .. name .. " at rank " .. rank .. " (You need level " .. requiredLevel .. " in " .. researchName .. ")"
		ply:AddHint(msg, NOTIFY_ERROR, 5)
	end
end
