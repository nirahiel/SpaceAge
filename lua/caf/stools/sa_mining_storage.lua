TOOL.Category = "SpaceAge"
TOOL.Name = "Mining Storages"
TOOL.DeviceName = "Mining Storage"
TOOL.DeviceNamePlural = "Mining Storages"
TOOL.ClassName = "sa_mining_storage"
TOOL.DevSelect = true
TOOL.Limited = true
TOOL.LimitName = "sa_mining_storage"
TOOL.Limit = 4
CAFToolSetup.SetLang("SpaceAge Mining Storages", "Create Mining Storages attached to any surface.", "Left-Click: Spawn a Device.  Reload: Repair Device.")

local function ranked_dev_func(ent, type, level, devinfo)
	ent:SetNWInt("rank", devinfo.rank)
end

TOOL.Devices = {
	sa_storage_ore = {
		Name = "Asteroid Ore Storages",
		type = "sa_storage_ore",
		class = "sa_storage_ore",
		func = ranked_dev_func,
		devices = {
			i = {
				rank = 1,
				Name = "Small (Level I)",
				model = "models/slyfo/sat_resourcetank.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Medium (Level II)",
				model = "models/Slyfo/nacshortsleft.mdl",
				skin = 0,
				legacy = false,
			},
			iii = {
				rank = 3,
				Name = "Large (Level III)",
				model = "models/Slyfo/nacshuttleright.mdl",
				skin = 0,
				legacy = false,
			},
			iv = {
				rank = 4,
				Name = "Huge (Level IV)",
				model = "models/slyfo/crate_resource_small.mdl",
				skin = 0,
				legacy = false,
			},
			v = {
				rank = 5,
				Name = "Giant (Level V)",
				model = "models/slyfo/crate_resource_large.mdl",
				skin = 0,
				legacy = false,
			}
		},
	},
	sa_storage_ice = {
		Name = "Raw Ice Storages",
		type = "sa_storage_ice",
		class = "sa_storage_ice",
		func = ranked_dev_func,
		devices = {
			i = {
				rank = 1,
				Name = "Small Tank (Level I)",
				model = "models/mandrac/energy_cell/medium_cell.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Medium Tank (Level II)",
				model = "models/mandrac/energy_cell/large_cell.mdl",
				skin = 0,
				legacy = false,
			},
			iii = {
				rank = 3,
				Name = "Large Tank (Level III)",
				model = "models/mandrac/resource_cache/huge_cache.mdl",
				skin = 0,
				legacy = false,
			},
			iv = {
				rank = 4,
				Name = "Huge (Level IV)",
				model = "models/mandrac/nitrogen_tank/nitro_large.mdl",
				skin = 0,
				legacy = false,
			},
			v = {
				rank = 5,
				Name = "Massive (Level V)",
				model = "models/mandrac/resource_cache/colossal_cache.mdl",
				skin = 0,
				legacy = false,
			},
		},
	},
	sa_storage_ice_product = {
		Name = "Ice Product Storages",
		type = "sa_storage_ice_product",
		class = "sa_storage_ice_product",
		func = ranked_dev_func,
		devices = {
			i = {
				rank = 1,
				Name = "Medium Tank (Level I)",
				model = "models/mandrac/hw_tank/hw_tank_large.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Large Tank (Level II)",
				model = "models/mandrac/resource_cache/hangar_container.mdl",
				skin = 0,
				legacy = false,
			},
			iii = {
				rank = 3,
				Name = "Huge (Level III)",
				model = "models/mandrac/water_storage/water_storage_large.mdl",
				skin = 0,
				legacy = false,
			},
			iv = {
				rank = 4,
				Name = "Massive (Level IV)",
				model = "models/mandrac/resource_cache/colossal_cache.mdl",
				skin = 0,
				legacy = false,
			},
			v = {
				rank = 5,
				Name = "Massive Bay (Level V)",
				model = "models/spacebuild/medbridge2_fighterbay3.mdl",
				skin = 0,
				legacy = false,
			},
			vi = {
				rank = 6,
				Name = "Carrier Bay (Level VI)",
				model = "models/slyfo/carrierbay.mdl",
				skin = 0,
				legacy = false,
			},
			vii = {
				rank = 7,
				Name = "2x Carrier Bay (Level VII)",
				model = "models/slyfo/doublecarrier.mdl",
				skin = 0,
				legacy = false,
			},
		},
	},
	sa_storage_tiberium = {
		Name = "Tiberium Storages",
		type = "sa_storage_tiberium",
		class = "sa_storage_tiberium",
		func = ranked_dev_func,
		devices = {
			i = {
				rank = 1,
				Name = "Level I",
				model = "models/slyfo/sat_resourcetank.mdl",
				skin = 0,
				legacy = false,
			},
			ii = {
				rank = 2,
				Name = "Level II",
				model = "models/slyfo/sat_resourcetank.mdl",
				skin = 0,
				legacy = false,
			},
		}
	}
}
