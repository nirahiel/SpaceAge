ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Ice Miner I"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.LaserModel = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl"
ENT.LaserRange = 1000 --Radius
ENT.LaserExtract = 1000 * 2 -- Extract per cycle m3
ENT.LaserConsume = 2400 * 2 --Energy per cycle
ENT.LaserCycle = 60 --Time is second to complete a cycle

ENT.LaserActive = false

ENT.IceLaserModeMin = 0

list.Set("LSEntOverlayText" , "ice_mining_laser_base", {HasOOO = true, num = 1, strings = {"ICE Mining Laser", "\nEnergy: "}, resnames = {"energy"}})
