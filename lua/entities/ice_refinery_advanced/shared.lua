ENT.Type = "anim"
ENT.Base = "ice_refinery_basic"
ENT.PrintName = "Ice Refinery Advanced"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Model = "models/props_citizen_tech/SteamEngine001a.mdl"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.CycleEnergy = 7500
ENT.CycleTime = 10
ENT.CycleVol = 1

ENT.RefineEfficiency = 1.0

ENT.MinIceRefineryMod = 2

list.Set("LSEntOverlayText" , "ice_refinery_advanced", {HasOOO = true, num = 1, strings = {"ICE Refinery Advanced\nEnergy: ", ""}, resnames = {"energy"}})
