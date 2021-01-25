ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Mining Drill"

list.Set("LSEntOverlayText" , "sa_mining_drill", {HasOOO = true, num = 2, strings = {"Mining Drill", "\nEnergy: ", "\nTiberium: "}, resnames = {"energy", "tiberium"}})

local EnergyBaseTbl = {600,1200}
local YieldOffsetTbl = {50,100}
local YieldIncrementTbl = {10,20}
local MinTibDrillModTbl = {0,1}

function ENT:InitializeVars()
	local rank = self:GetNWInt("rank")
	if rank <= 0 then
		if SERVER then self:Remove() end
		return
	end

	self.rank = rank

	self.EnergyBase = EnergyBaseTbl[rank]
	self.YieldOffset = YieldOffsetTbl[rank]
	self.YieldIncrement = YieldIncrementTbl[rank]
	self.MinTibDrillMod = MinTibDrillModTbl[rank]
end

