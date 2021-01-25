TOOL.Category = "SpaceAge"
TOOL.Name = "Other Devices"
TOOL.DeviceName = "Other Device"
TOOL.DeviceNamePlural = "Other Devices"
TOOL.ClassName = "sa_other_devices"
TOOL.DevSelect = true
TOOL.Limited = true
TOOL.LimitName = "sa_other_devices"
TOOL.Limit = 10
CAFToolSetup.SetLang("SpaceAge Other Devices", "Create Miscellaneous Devices attached to any surface.", "Left-Click: Spawn a Device.  Reload: Repair Device.")

TOOL.Devices = {
	sa_asteroid_scanner = {
		Name = "Asteroid Scanners",
		type = "sa_asteroid_scanner",
		class = "sa_asteroid_scanner",
		devices = {
			standard = {
				Name = "Standard",
				model = "models/jaanus/wiretool/wiretool_beamcaster.mdl",
				skin = 0,
				legacy = false,
			}
		}
	},
	sa_rta = {
		Name = "RTA (Remote Terminal Access) Devices",
		type = "sa_rta",
		class = "sa_rta",
		devices = {
			standard = {
				Name = "Standard",
				model = "models/slyfo/rover_na_large.mdl",
				skin = 0,
				legacy = false,
			}
		}
	},
	sa_terraformer = {
		Name = "Terraformer",
		class = "sa_terraformer",
		type = "sa_terraformer",
		devices = {
			standard = {
				Name = "Standard",
				model = "models/chipstiks_ls3_models/Terraformer/terraformer.mdl",
				skin = 0,
				legacy = false,
			}
		}
	},
	sa_storage_terraform = {
		Name = "Terraforming Storage",
		class = "sa_storage_terraform",
		type = "sa_storage_terraform",
		devices = {
			standard = {
				Name = "Standard",
				model = "models/Slyfo/barrel_unrefined.mdl",
				skin = 0,
				legacy = false,
			}
		}
	}
}
