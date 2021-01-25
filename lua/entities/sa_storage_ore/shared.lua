ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Ore Storage"

list.Set("LSEntOverlayText", "sa_storage_ore", {HasOOO = nil, num = 1, strings = {"Ore Storage\nOre: ", ""}, resnames = {"ore"}})

local ValuesByModel = {
	["models/slyfo/sat_resourcetank.mdl"] = {
		MinOreManage = 0,
		StorageOffset = 50000,
		StorageIncrement = 5000
	},
	["models/Slyfo/nacshortsleft.mdl"] = {
		MinOreManage = 1,
		StorageOffset = 1600000,
		StorageIncrement = 10000
	},
	["models/Slyfo/nacshuttleright.mdl"] = {
		MinOreManage = 2,
		StorageOffset = 4600000,
		StorageIncrement = 20000
	},
	["models/slyfo/crate_resource_small.mdl"] = {
		MinOreManage = 3,
		StorageOffset = 9600000,
		StorageIncrement = 40000
	},
	["models/slyfo/crate_resource_large.mdl"] = {
		MinOreManage = 4,
		StorageOffset = 19600000,
		StorageIncrement = 80000
	}
}

function ENT:InitializeVars()
	local data = ValuesByModel[self:GetModel()]
	if not data then
		return false
	end
	self.MinOreManage = data.MinOreManage
	self.StorageOffset = data.StorageOffset
	self.StorageIncrement = data.StorageIncrement
	return true
end
