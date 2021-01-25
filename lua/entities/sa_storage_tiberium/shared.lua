ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Tiberium Storage"

list.Set("LSEntOverlayText" , "sa_storage_tiberium", {HasOOO = nil, num = 1, strings = {"Tiberium Storage\nTiberium: ", ""}, resnames = {"tiberium"}})

local MinTiberiumStorageModTbl = {0,1}
local StorageOffsetTbl = {50000,1550000}
local StorageIncrementTbl = {5000,10000}

function ENT:InitializeVars()
	local rank = self:GetNWInt("rank")
	if rank <= 0 then
		return
	end

	self.rank = rank

	self.MinTiberiumStorageMod = MinTiberiumStorageModTbl[rank]
	self.StorageOffset = StorageOffsetTbl[rank]
	self.StorageIncrement = StorageIncrementTbl[rank]
end
