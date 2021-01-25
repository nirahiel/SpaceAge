local LimitName = "sa_mining_device"

TOOL.Category = "SpaceAge"
TOOL.Name = "Mining Devices"
TOOL.DeviceName = "Mining Device"
TOOL.DeviceNamePlural = "Mining Devices"
TOOL.ClassName = "sa_mining_device"
TOOL.DevSelect = true
TOOL.Limited = true
TOOL.LimitName = LimitName
TOOL.Limit = 20
CAFToolSetup.SetLang("SpaceAge Mining Devices", "Create Mining Devices attached to any surface.", "Left-Click: Spawn a Device.  Reload: Repair Device.")

local function ranked_dev_func(ent, type, level, devinfo)
	ent:SetNWInt("rank", devinfo.rank)

	local ply = ent:GetTable().Founder
	if not IsValid(ply) then
		ent:Remove()
		return
	end

	if ply:GetCount(LimitName) >= ply.sa_data.advancement_level then
		ply:AddHint("You can only spawn " .. ply.sa_data.advancement_level .. " mining devices!", NOTIFY_ERROR, 5)
		ent:Remove()
	end
end

TOOL.Devices = {
	sa_mining_laser = {
		Name = "Asteroid Mining Lasers",
		type = "sa_mining_laser",
		class = "sa_mining_laser",
		func = ranked_dev_func,
		sortBy = "rank",
		devices = {
			i = {
				rank = 1,
				Name = "Level I",
				model = "models/props_phx/life_support/crylaser_small.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Level II",
				model = "models/props_phx/life_support/crylaser_small.mdl",
				skin = 0,
				legacy = false,
			},
			iii = {
				rank = 3,
				Name = "Level III",
				model = "models/props_phx/life_support/crylaser_small.mdl",
				skin = 0,
				legacy = false,
			},
			iv = {
				rank = 4,
				Name = "Level IV",
				model = "models/props_phx/life_support/crylaser_small.mdl",
				skin = 0,
				legacy = false,
			},
			v = {
				rank = 5,
				Name = "Level V",
				model = "models/props_phx/life_support/crylaser_small.mdl",
				skin = 0,
				legacy = false,
			},
			vi = {
				rank = 6,
				Name = "Level VI",
				model = "models/props_phx/life_support/crylaser_small.mdl",
				skin = 0,
				legacy = false,
			},
		},
	},
	sa_ice_mining_laser = {
		Name = "Ice Mining Lasers",
		type = "sa_ice_mining_laser",
		class = "sa_ice_mining_laser",
		func = ranked_dev_func,
		sortBy = "rank",
		devices = {
			i = {
				rank = 1,
				Name = "Level I",
				model = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Level II",
				model = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl",
				skin = 0,
				legacy = false,
			},
			iii = {
				rank = 3,
				Name = "Level III",
				model = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl",
				skin = 0,
				legacy = false,
			},
		},
	},
	sa_mining_drill = {
		Name = "Tiberium Mining Drills",
		type = "sa_mining_drill",
		class = "sa_mining_drill",
		func = ranked_dev_func,
		sortBy = "rank",
		devices = {
			i = {
				rank = 1,
				Name = "Level I",
				model = "models/slyfo/rover_drillbit.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Level II",
				model = "models/slyfo/rover_drillbit.mdl",
				skin = 0,
				legacy = false,
			},
		}
	},
	sa_ice_refinery = {
		Name = "Ice Refineries",
		type = "sa_ice_refinery",
		class = "sa_ice_refinery",
		func = ranked_dev_func,
		sortBy = "rank",
		devices = {
			i = {
				rank = 1,
				Name = "Basic (Level I)",
				model = "models/props_c17/substation_transformer01b.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Improved (Level II)",
				model = "models/props_c17/substation_transformer01b.mdl",
				skin = 0,
				legacy = false,
			},
			iii = {
				rank = 3,
				Name = "Advanced (Level III)",
				model = "models/props_citizen_tech/SteamEngine001a.mdl",
				skin = 0,
				legacy = false,
			},
		}
	}
}
