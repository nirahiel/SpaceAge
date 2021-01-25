ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Asteroid Mining Laser"

list.Set("LSEntOverlayText" , "sa_mining_laser", {HasOOO = true, num = 2, strings = {"Asteroid Mining Laser", "\nEnergy: ", "\nOre: "}, resnames = {"energy", "ore"}})

local MinMiningTheoryTbl = {0,1,2,3,4,5}
local EnergyBaseTbl = {600,1200,1800,2400,3000,5000}
local YieldOffsetTbl = {50,2000,6000,15000,30000,60000}
local YieldIncrementTbl = {6.25,12.5,25,50,200,400}

local BeamLengthTbl = {2000,2250,2500,2750,3000,4000}
local BeamWidthOffsetTbl = {10,20,30,40,50,0}

function ENT:InitializeVars()
	local rank = self:GetNWInt("rank")
	if rank <= 0 then
		if SERVER then self:Remove() end
		return
	end

	self.rank = rank

	self.MinMiningTheory = MinMiningTheoryTbl[rank]
	self.EnergyBase = EnergyBaseTbl[rank]
	self.YieldOffset = YieldOffsetTbl[rank]
	self.YieldIncrement = YieldIncrementTbl[rank]

	self.BeamLength = BeamLengthTbl[rank]
	self.BeamWidthOffset = BeamWidthOffsetTbl[rank]
end
