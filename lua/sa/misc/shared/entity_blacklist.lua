local BadSENTs = {
	["sent_ball"] = true,

	["prop_thumper"] = true,

	["item_ammo_ar2"] = true,
	["item_ammo_ar2_large"] = true,
	["item_ammo_pistol"] = true,
	["item_ammo_pistol_large"] = true,
	["item_ammo_357"] = true,
	["item_ammo_357_large"] = true,
	["item_ammo_smg1"] = true,
	["item_ammo_smg1_large"] = true,
	["item_ammo_smg1_grenade"] = true,
	["item_ammo_crossbow"] = true,
	["item_box_buckshot"] = true,
	["item_ammo_ar2_altfire"] = true,
	["item_rpg_round"] = true,

	["item_dynamic_resupply"] = true,
	["item_battery"] = true,
	["item_healthkit"] = true,
	["item_healthvial"] = true,
	["item_suitcharger"] = true,
	["item_healthcharger"] = true,
	["item_suit"] = true,

	["prop_thumper"] = true,
	["combine_mine"] = true,
	["npc_grenade_frag"] = true,
	["grenade_helicopter"] = true,

	["weapon_striderbuster"] = true,

	["weapon_stunstick"] = true,
	["weapon_frag"] = true,
	["weapon_crossbow"] = true,
	["weapon_bugbait"] = true,
	["weapon_rpg"] = true,
	["weapon_crowbar"] = true,
	["weapon_shotgun"] = true,
	["weapon_pistol"] = true,
	["weapon_slam"] = true,
	["weapon_smg1"] = true,
	["weapon_ar2"] = true,
	["weapon_357"] = true,

	["weapon_alyxgun"] = true,
	["weapon_annabelle"] = true,

	["manhack_welder"] = true,
	["weapon_fists"] = true,
	["weapon_flechettegun"] = true,
	["weapon_medkit"] = true,
}

local function ReturnFalseIfBlocked(ply, cls)
	if BadSENTs[cls] then
		if ply and ply.ChatPrint then
			ply:ChatPrint("You cannot spawn SWEP " .. cls)
		end
		return false
	end
end

hook.Add("PreRegisterSENT", "SA_Blacklist_PreRegisterSENT", ReturnFalseIfBlocked)
hook.Add("PreRegisterSWEP", "SA_Blacklist_PreRegisterSWEP", ReturnFalseIfBlocked)

hook.Add("PlayerSpawnSENT", "SA_Blacklist_PlayerSpawnSENT", ReturnFalseIfBlocked)

hook.Add("PlayerGiveSWEP", "SA_Blacklist_PlayerGiveSWEP", ReturnFalseIfBlocked)
hook.Add("PlayerSpawnSWEP", "SA_Blacklist_PlayerSpawnSWEP", ReturnFalseIfBlocked)

local function RemoveExisting()
	for cls, _ in pairs(BadSENTs) do
		local obj = scripted_ents.GetStored(cls)
		if obj then
			obj.Spawnable = false
		end

		obj = weapons.GetStored(cls)
		if obj then
			obj.Spawnable = false
		end
	end
end
hook.Add("InitPostEntity", "SA_Blacklist_InitPostEntity", RemoveExisting)
RemoveExisting()
