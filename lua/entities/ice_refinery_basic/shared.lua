ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Ice Refinery Basic"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Model = "models/props_c17/substation_transformer01b.mdl"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.CycleEnergy = 2500
ENT.CycleTime = 5
ENT.CycleVol = 1

ENT.RefineEfficiency = 0.5

ENT.MinIceRefineryMod = 0

list.Set("LSEntOverlayText" , "ice_refinery_basic", {HasOOO = true, num = 1, strings = {"ICE Refinery Basic\nEnergy: ", ""}, resnames = {"energy"}})
