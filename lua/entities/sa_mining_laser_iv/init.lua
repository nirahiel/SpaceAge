AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "common/warning.wav" )
util.PrecacheSound( "ambient/energy/electric_loop.wav" )

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD.AddResource(self, "energy", 0, 0)
	RD.AddResource(self, "ore", 0, 0)
	self.Active = 0
	self.damage = 28
	
	if WireAddon ~= nil then 
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "On", "Output" })	
	end
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(120)
		phys:Wake()
	end
	self.lasersound = CreateSound(self,"ambient/energy/electric_loop.wav")
	
	timer.Simple(0.1,function() self:CalcVars(self:GetTable().Founder) end)
end

function ENT:CalcVars(ply)
	if not (ply.miningtheory > 2) then self:Remove() return end
	local miningmod = 1
	if ply.UserGroup == "miners" or ply.UserGroup == "alliance" then
		miningmod = 1.33
	elseif ply.UserGroup == "starfleet" then
		miningmod = 1.11
	end
	local energybase = 2400
	local energycost = ply.miningenergy * 50
	if (energycost > energybase * 0.75) then
		energycost = energybase * 0.75
	end
	self.consume = energybase - energycost
	local level = ply.miningyield_iv
	self.yield = math.floor((15000 + (level * 50)) * miningmod)*2
	self.beamlength = 2750
	
	self:SetNetworkedInt("w", 40 + math.floor(level / 10))
	self:SetNetworkedColor("c", Color(0, math.floor(level * 0.85), 255))
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		if ( RD.GetResourceAmount(self, "energy") < self.consume ) then
			self:TurnOff()
			return
		end
		self.lasersound:Play()
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
		self:SetNetworkedBool("o",true)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self.lasersound:Stop()
		if not (WireAddon == nil) then 
			Wire_TriggerOutput(self, "On", 0)
		end
		self:SetOOO(0)
		self:SetNetworkedBool("o",false)
	end
end

function ENT:OnRemove()
	self.lasersound:Stop()
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if ( self.Active == 1 ) then
			if ( RD.GetResourceAmount(self, "energy") >= self.consume ) then
				RD.ConsumeResource(self, "energy", self.consume)
				Discharge(self)
				Wire_TriggerOutput(self, "Output", self.yield)
			else
				self:TurnOff()
				Wire_TriggerOutput(self, "Output", 0)
			end
	else
		self:TurnOff()
		Wire_TriggerOutput(self, "Output", 0)
	end
	self:NextThink(CurTime() + 1)
	return true
end
