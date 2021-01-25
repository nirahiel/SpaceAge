ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Ice Mining Laser"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.LaserModel = "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl"

list.Set("LSEntOverlayText" , "sa_ice_mining_laser", {HasOOO = true, num = 1, strings = {"Ice Mining Laser\nEnergy: ", ""}, resnames = {"energy"}})

local LaserRangeTbl = {1000, 1200, 1500}
local LaserExtractTbl = {1000 * 2, 1000 * 2, 1000 * 2}
local LaserConsumeTbl = {2400 * 2, 5625 * 2, 7245 * 2}
local LaserCycleTbl = {60, 45, 30}
local IceLaserModMinTbl = {0, 1, 2}

function ENT:InitializeVars()
	local rank = self:GetNWInt("rank")
	if rank <= 0 then
		return
	end

	self.rank = rank

	self.LaserRange = LaserRangeTbl[rank]
	self.LaserExtract = LaserExtractTbl[rank]
	self.LaserConsume = LaserConsumeTbl[rank]
	self.LaserCycle = LaserCycleTbl[rank]
	self.IceLaserModMin = IceLaserModMinTbl[rank]
end
