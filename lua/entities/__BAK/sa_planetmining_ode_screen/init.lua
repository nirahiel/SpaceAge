AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self:SetModel("models/Slyfo/consolescreenmed.mdl")
	self:PhysicsInit( SOLID_VPHYSICS ) 	
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS ) 
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:EnableCollisions(true)
		phys:EnableMotion(true)
	end
	
	RD.AddResource(self, "energy", 0)
	
	self.Entity:SetOverlayText(self.PrintName.."\n".."Progress: 0%")
	
	self.Inputs = Wire_CreateInputs( self, {"Activate", "Zoom"} ) 
	self.Outputs = Wire_CreateOutputs( self, {"Active", "Progress"} )
	
	timer.Simple(0.1,function() self:CalcVars(self:GetTable().Founder) end)
end

function ENT:CalcVars(ply)
	self.ThinkRate = 0.2
	
	self.Progress = -1
	self.RenderSpeed = 10 * self.ThinkRate
	
	self.DepthSelect = 500
	
	self.ScanXRange = 300
	self.ScanZRange = 500
	self.ScanYRange = 300
	self.Resolution = 16
	timer.Simple(0.1, self.InitVars, self)
	
	self.NextEntThink = 0
	
	self.Rendering = false
end

function ENT:InitVars()
	local owner = self:GetTable().Founder
	if (!owner.pmodebattery) then
		timer.Simple(1, self.InitVars, self)
		return
	end
	
	self.RenderSpeed = 50 * self.ThinkRate * (1 + (owner.pmodespeed * 0.5))
	self.ScanXRange = 200 * (1 + (owner.pmoderange * 0.2))
	self.ScanZRange = 500 * (1 + (owner.pmoderange * 0.2))
	self.ScanYRange = 200 * (1 + (owner.pmoderange * 0.2))
	if (owner.pmoderes == 0) then
		self.Resolution = 16
	elseif (owner.pmoderes == 1) then
		self.Resolution = 8
	elseif (owner.pmoderes == 2) then
		self.Resolution = 4
	elseif (owner.pmoderes == 3) then
		self.Resolution = 2
	else
		self.Resolution = 16
	end
	self:InitNWValues()
end

function ENT:InitNWValues()
	self:SetNWInt("Resolution", self.Resolution)
	self:SetNWInt("ScanXRange", self.ScanXRange)
	self:SetNWInt("ScanYRange", self.ScanYRange)
	self:SetNWInt("ScanZRange", self.ScanZRange)
	self:SetNWFloat("Zoom", 1)
end

function ENT:Update()
	local CurEnergy = RD.GetResourceAmount(self, "energy")
	if (self.Enabled) then
		if (CurEnergy >= self.EnergyReq) then
			RD.ConsumeResource(self, "energy", self.EnergyReq)
			
			if (self.Rendering) then
				if (self.Progress < 100) then
					self.Progress = self.Progress + self.RenderSpeed
					Wire_TriggerOutput(self,"Progress", self.Progress)
				else
					self.Progress = 0
					self.Rendering = false
					umsg.Start("SA_PM_ODE_SCREEN_Render_"..self.Entity:EntIndex())
						umsg.Char('S') // Start Render
					umsg.End()
				end
			else
				self.Rendering = true
			end
		else
			self:TurnOff()
		end
	end
end

function ENT:TurnOn()
	self.Enabled = true
	Wire_TriggerOutput(self,"Active", 1)
	self.Entity:SetNWBool("Active", self.Enabled)
	
	self.Owner:EmitSound("buttons/combine_button_locked.wav", 100, 100)
end
function ENT:TurnOff()
	if (self.Rendering) then
		self.Progress = 0
		self.Rendering = false
		umsg.Start("SA_PM_ODE_SCREEN_Render_"..self.Entity:EntIndex())
			umsg.Char('C') // Cancel Render
		umsg.End()
	end
	
	self.Enabled = false
	Wire_TriggerOutput(self,"Active", 0)
	Wire_TriggerOutput(self,"Progress", 0)
	self.Entity:SetNWBool("Active", self.Enabled)
end


function ENT:Think()
	if (self.NextEntThink < RealTime()) then
		self:Update()
		self.NextEntThink = RealTime() + 0.25
	end
end

function ENT:TriggerInput(key, value)
	if (key == "Activate") then
		if (value == 1) then
			local CurEnergy = RD.GetResourceAmount(self, "energy")
			if (CurEnergy >= self.EnergyReq) then
				self:TurnOn()
			else
				// Play error sound
			end
		else
			self:TurnOff()
		end
	elseif (key == "Zoom") then
		self.Zoom = math.Min(math.Max(value, 0), 1)
		self.Entity:SetNWFloat("Zoom", self.Zoom)
	end
end

function ENT:PreEntityCopy()
	RD.BuildDupeInfo(self)
	local DupeInfo = self:BuildDupeInfo()
	if(DupeInfo) then
		duplicator.StoreEntityModifier(self,"WireDupeInfo",DupeInfo)
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	RD.ApplyDupeInfo(Ent, CreatedEntities)
	if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
		self:GetTable().Founder = Player	
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end