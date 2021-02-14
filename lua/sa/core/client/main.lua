local ToRemove = {
	sb_forlorn_sb3_r3 = {"sb_forlorn/stnatmo"}
}

local function RemoveMaterial(name)
	local mat = Material(name)
	mat:SetInt("$flags", bit.bor(mat:GetInt("$flags"), 4)) -- 4 = $no_draw
end

hook.Add("InitPostEntity", "SA_RemoveMaterials", function()
	local rem = ToRemove[game.GetMap():lower()]
	if not rem then
		return
	end
	for _, name in pairs(rem) do
		RemoveMaterial(name)
	end
end)
