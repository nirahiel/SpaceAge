ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Ore Storage"

list.Set("LSEntOverlayText" , "ore_storage", {HasOOO = nil, num = 1, strings = {"Ore Storage\nOre: ", ""}, resnames = {"ore"}})

ENT.ForcedModel = "models/slyfo/sat_resourcetank.mdl"
ENT.MinOreManage = 0
ENT.StorageOffset = 50000
ENT.StorageIncrement = 5000
