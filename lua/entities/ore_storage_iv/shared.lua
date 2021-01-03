ENT.Type = "anim"
ENT.Base = "ore_storage"
ENT.PrintName = "Ore Storage"

list.Set("LSEntOverlayText" , "ore_storage_iv", {HasOOO = nil, num = 1, strings = {"Ore Storage\nOre: ", ""}, resnames = {"ore"}})

ENT.ForcedModel = "models/slyfo/crate_resource_small.mdl"
ENT.MinOreManage = 3
ENT.StorageOffset = 9600000
ENT.StorageIncrement = 40000
