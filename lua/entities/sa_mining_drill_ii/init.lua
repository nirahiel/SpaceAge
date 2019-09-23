AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

-- TODO
function ENT:CalcVars(ply)
	if not (ply.tibdrillmod > 0 and (ply.UserGroup == "legion" or ply.UserGroup == "alliance")) then
		self:Remove()
		return
	end
	local level = ply.tiberiumyield_ii
	local energybase = 1200
	local energycost = ply.miningenergy * 50
	if (energycost > energybase * 0.75) then
		energycost = energybase * 0.75
	end
	self.consume = energybase - energycost
	self.yield = math.floor(3500 + (level * 20)) * 2
	self.oldyield = self.yield
end
