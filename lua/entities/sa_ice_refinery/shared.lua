ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Ice Refinery"
ENT.Author = "Zup"
ENT.Category = "Asteroid"

ENT.Spawnable = false
ENT.AdminSpawnable = false

local CycleEnergyTbl = {2500,5000,7500}
local CycleTimeTbl = {5,7.5,10}
local CycleVolTbl = {1,1,1}
local RefineEfficiencyTbl = {0.5,0.75,1}
local MinIceRefineryModTbl = {0,1,2}

list.Set("LSEntOverlayText" , "sa_ice_refinery", {HasOOO = true, num = 1, strings = {"Ice Refinery\nEnergy: ", ""}, resnames = {"energy"}})

function ENT:InitializeVars()
	local rank = self:GetNWInt("rank")
	if rank <= 0 then
		return
	end

	self.rank = rank

	self.CycleEnergy = CycleEnergyTbl[rank]
	self.CycleTime = CycleTimeTbl[rank]
	self.CycleVol = CycleVolTbl[rank]
	self.RefineEfficiency = RefineEfficiencyTbl[rank]
	self.MinIceRefineryMod = MinIceRefineryModTbl[rank]
end
