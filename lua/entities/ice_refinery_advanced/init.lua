AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	timer.Simple(0.1,function() self:CalcVars(self:GetTable().Founder) end)
end

function ENT:CalcVars(ply)
	if (ply.icerefinerymod <= 1) then
		return self:Remove()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
end



