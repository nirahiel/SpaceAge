AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
util.PrecacheSound("apc_engine_start")
util.PrecacheSound("apc_engine_stop")
util.PrecacheSound("common/warning.wav")

DEFINE_BASECLASS("base_sb_environment")

include("shared.lua")
local Energy_Increment = 25

local SB = CAF.GetAddon("Spacebuild")

function ENT:Initialize()
	BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self:CreateEnvironment(1, 1, 1, 0, 0, 0, 0, 0)
	self.currentsize = 1024
	self.maxsize = 1024
	if WireAddon ~= nil then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Radius", "Gravity" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Gravity" })
	else
		self.Inputs = {{ Name = "On" }, { Name = "Radius" }, { Name = "Gravity" }}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self:EmitSound("apc_engine_start")
		self.Active = 1
		self.sbenvironment.size = self.currentsize
		if WireAddon ~= nil then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self:StopSound("apc_engine_start")
		self:EmitSound("apc_engine_stop")
		self.Active = 0
		self.sbenvironment.size = 0
		if WireAddon ~= nil then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Radius") then
		if value >= 0 and value < self.maxsize then
			if self.Active == 1 then
				self.sbenvironment.size = value
			end
			self.currentsize = value
		else
			if self.Active == 1 then
				self.sbenvironment.size = self.maxsize
			end
			self.currentsize = self.maxsize
		end
	elseif (iname == "Gravity") then
		self.sbenvironment.gravity = value
	end
end

function ENT:Damage()
	if (self.damaged == 0) then
		self.damaged = 1
	end
	if ((self.Active == 1) and (math.random(1, 10) <= 3)) then
		self:TurnOff()
	end
end

function ENT:Repair()
	BaseClass.Repair(self)
	self:SetColor(color_white)
	self.damaged = 0
end

function ENT:Destruct()
	SB.RemoveEnvironment(self)
	CAF.GetAddon("Life Support").LS_Destruct(self, true)
end

function ENT:OnRemove()
	SB.RemoveEnvironment(self)
	BaseClass.OnRemove(self)
	self:StopSound("apc_engine_start")
end

function ENT:Think()
	BaseClass.Think(self)
	if (self.Active == 1) then
		local dif = 1
		if self.environment then
			if self.environment:GetSBGravity() < 0.1 then
				dif = 10
			else
				dif = self.sbenvironment.gravity / self.environment:GetSBGravity()
			end
		end
		local eneeded = math.Round((Energy_Increment * self:GetMultiplier()) + (Energy_Increment * dif * self:GetMultiplier()))
		if self:ConsumeResource(self, "energy", eneeded) < eneeded then
			self:EmitSound("common/warning.wav")
			self:TurnOff(true)
		end
	end
	self:NextThink(CurTime() + 1)
	return true
end

--Overrides

function ENT:GetO2Percentage()
	if self.environment then
		return self.environment:GetO2Percentage()
	end
	return 0
end

function ENT:GetEmptyAirPercentage()
	if self.environment then
		return self.environment:GetEmptyAirPercentage()
	end
	return 0
end

function ENT:GetCO2Percentage()
	if self.environment then
		return self.environment:GetCO2Percentage()
	end
	return 0
end

function ENT:GetNPercentage()
	if self.environment then
		return self.environment:GetNPercentage()
	end
	return 0
end

function ENT:GetHPercentage()
	if self.environment then
		return self.environment:GetHPercentage()
	end
	return 0
end

function ENT:ChangeAtmosphere(newatmosphere)
	if self.environment then
		return self.environment:ChangeAtmosphere(newatmosphere)
	end
end

function ENT:GetSBGravity()
	if self.Active == 1 then
		return self.sbenvironment.gravity or 0
	elseif self.environment then
		return self.environment:GetSBGravity()
	end
	return 0
end

function ENT:UpdatePressure(ent)
	if self.environment then
		return self.environment:UpdatePressure(ent)
	end
end

function ENT:Convert(air1, air2, value)
	if self.environment then
		return self.environment:Convert(air1, air2, value)
	end
	return 0
end

function ENT:GetAtmosphere()
	if self.environment then
		return self.environment:GetAtmosphere()
	end
	return 0
end

function ENT:ChangeGravity(newgravity)
	if newgravity and newgravity >= 0 then
		self.sbenvironment.gravity = newgravity
	end
end

function ENT:GetPressure()
	if self.environment then
		return self.environment:GetPressure()
	end
	return 0
end

function ENT:GetTemperature(ent)
	if self.environment then
		return self.environment:GetTemperature(ent)
	end
	return 0
end

function ENT:GetO2()
	if self.environment then
		return self.environment:GetO2()
	end
	return 0
end

function ENT:GetEmptyAir()
	if self.environment then
		return self.environment:GetEmptyAir()
	end
	return 0
end

function ENT:GetCO2()
	if self.environment then
		return self.environment:GetCO2()
	end
	return 0
end

function ENT:GetN()
	if self.environment then
		return self.environment:GetN()
	end
	return 0
end

function ENT:GetH()
	if self.environment then
		return self.environment:GetH()
	end
	return 0
end
