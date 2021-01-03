AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("sa_mining_laser")

function ENT:CalcVars(ply)
	if ply.sa_data.faction_name ~= "miners" and ply.sa_data.faction_name ~= "alliance" then
		self:Remove()
		return
	end
	return BaseClass.CalcVars(self, ply)
end
