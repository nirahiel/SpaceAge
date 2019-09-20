AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

local SA_RefModels = {}
SA_RefModels['models/slyfo/refinery_large.mdl'] = 2
SA_RefModels['models/slyfo/refinery_small.mdl'] = 1
SA_RefModels['models/props_c17/substation_transformer01b.mdl'] = 0

function ENT:Initialize()
	//self:SetModel(self.Model)
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
	
	for _,t in pairs(SA_PM.Ore.Types) do
		RD.AddResource(self, t.Name, 0)
	end
	for _,t in pairs(SA_PM.Ore.Types) do
		RD.AddResource(self, SA_PM.Ref.Types[t.Name].Name, 0)
	end
	
	self:SetOverlayText(self.PrintName.."\n".."Progress: 0%")
	
	self.Inputs = Wire_CreateInputs( self, { "Activate" } ) 
	self.Outputs = Wire_CreateOutputs( self, { "Active", "Progress" } )
	
	self.ShouldRefine = false;
	self.CurrentRef = nil;
	self.Volume = 0;
	self.NextCycle = 0;
	self.Speed = 1
	self.Took = 0
	
	timer.Simple(0.1,function() self:CalcVars(self:GetTable().Founder) end)
end

function ENT:CalcVars(ply)
	local reqLvl = SA_RefModels[string.lower(self:GetModel())]
	if (reqLvl == nil) then
		ply:ChatPrint("Invalid Model!")
		self:Remove()
		return
	end
	if (ply.pmrefspeed < reqLvl) then
		ply:ChatPrint("You do not have the required level for this model!")
		self:Remove()
		return
	end
	self.Speed = ((reqLvl + 1) * (reqLvl + 1)) * 250
	self.CycleEnergy = 2500 * ((reqLvl + 1) * (reqLvl + 1))
	//self.Volume = 250 * ((reqLvl + 1) * (reqLvl + 1))
	self.CycleVol = 1
	self.CycleTime = 10
end

function ENT:Refine()
	local CurEnergy = RD.GetResourceAmount(self, "energy")
	local EnergyReq = (self.CycleEnergy/self.CycleTime) * self.Speed / 100
	local reqLvl = SA_RefModels[string.lower(self:GetModel())]
	local mult = 1
	if (reqLevel == 2) then
		mult = 1
	elseif (reqLevel == 1) then
		mult = 0.5
	elseif (reqlevel == 0) then
		mult = 0.25
	end
	
	if (CurEnergy >= EnergyReq) then
		if (self.CurrentRef == nil and self.ShouldRefine) then
			for I = 1, table.Count(SA_PM.Ore.Types) do
				local Type = SA_PM.Ore.Types[(table.Count(SA_PM.Ore.Types) + 1) - I]
				local Avail = RD.GetResourceAmount(self, Type.Name)
				if (Avail > 0) then
					self.CurrentRef = Type.Name
					self.Volume = 1000 //((reqLvl + 1) * (reqLvl + 1)) * 1000
					self.Took = math.min(self.Speed, Avail)
					RD.ConsumeResource(self, Type.Name, self.Took)
					Wire_TriggerOutput(self, "Active", 1)
					break
				end
			end
		end
		if (self.CurrentRef) then
			RD.ConsumeResource(self, "energy", EnergyReq * self.Took)
			
			local RefSpeed = (self.CycleVol / self.CycleTime) * 1000
			self.Volume = self.Volume - RefSpeed
			local Progress = math.Clamp((1000 - self.Volume) / 10, 0, 100)
			Wire_TriggerOutput(self, "Progress", Progress)
			self:SetOverlayText(self.PrintName.."\nProgress: "..tostring(Progress).."%")
			if (self.Volume <= 0) then
				local Arr = SA_PM.Ref.Types[self.CurrentRef]
				local Gives = Arr.Name
				local Amount = Arr.Amount * self.Took * mult
				RD.SupplyResource(self, Gives, Amount)
				self.CurrentRef = nil
				Wire_TriggerOutput(self,"Active",0)
				Wire_TriggerOutput(self,"Progress",0)
				self:SetOverlayText(self.PrintName.."\nProgress: 0%")
			end
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	if (self.NextCycle < CurTime()) then
		self:Refine()	
		self.NextCycle = CurTime() + 1
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "Activate") then
		if value == 1 then
			self.ShouldRefine = true
		else
			self.ShouldRefine = false
			Wire_TriggerOutput(self,"Active",0)
			Wire_TriggerOutput(self,"Progress",0)
			self:SetOverlayText(self.PrintName.."\nProgress: 0%")
		end
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
		self.Owner = Player	
		Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
	end
end