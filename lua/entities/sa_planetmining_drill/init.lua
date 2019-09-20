AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	RD.AddResource(self, "energy", 0, 0)
	RD.AddResource(self, "water", 0, 0)
	RD.AddResource(self, "steam", 0, 0)
	for _,k in pairs(SA_PM.Ore.Types) do
		RD.AddResource(self, k.Name, 0, 0)
	end
	self.Active = 0
	//self.HP = 100
	self.Heat = 0
	if (WireAddon) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On", "SetDepth"})
		self.Outputs = Wire_CreateOutputs(self, {"On"})
		WireLib.AdjustSpecialOutputs(self, {"On", "Depth", "Deposit Density", "Deposit Type", "Deposit Distance"}, {"NORMAL", "NORMAL", "NORMAL", "STRING", "NORMAL"})
	end
	
	if (!self:IsValidModel(string.lower(self:GetModel()))) then
		self:SetModel("models/Slyfo/drillplatform.mdl")
	end
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(5000)
		phys:Wake()
	end
	
	self.Active = 0
	self.Owner = self:GetTable().Founder
	
	self.LastPos = self:GetPos()
	self.LastThink = 0
	self.SetDepth = 1
	self.Depth = 0
	self.DrillSize = 118
	
	self.MaxDepth = 0
	self.DrillSpeed = 0.5
	self.RetractSpeed = 3
	self.DrillEffeciency = 1
	self.DrillReliability = 0
	self.WaterRate = ((self.Owner.UserGroup == "planet" or self.Owner.UserGroup == "alliance") and 7500 or 10000)
	self.EnergyRate = 10000
	
	self.RunningSound = CreateSound(self, Sound("ambient/machines/machine2.wav"))
	self.EngineSound = CreateSound(self, Sound("/ambient/machines/big_truck.wav"))
	self.LastRandCheck = 0
	self.TicksWithoutWater = 0
	
	self.ShaftRotSpeed = 0
end

function ENT:IsValidModel(mdl)
	if (SADrillModels[mdl] != nil) then
		return true
	else
		return false
	end
end

function ENT:TriggerInput(name, value)
	if (name == "On") then
		self:SetActive(value)
	elseif (name == "SetDepth") then
		self.SetDepth = math.Clamp(value, 0, self.MaxDepth)
		self.SetDepth = (self.SetDepth)
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		
		self.RunningSound:Play()
		if (!self.EngineSound:IsPlaying()) then
			self.EngineSound:Play()
		end
		
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
		self:SetNetworkedBool("o",true)
	end
end
function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		if WireAddon != nil then
			Wire_TriggerOutput(self, "On", 0)
		end
		self.RunningSound:Stop()
		//self.EngineSound:Stop()
		self:SetOOO(0)
		self:SetNetworkedBool("o",false)
	end
end

function ENT:OnRemove()
	self:KillShafts()
	self.RunningSound:Stop()
	self.EngineSound:Stop()
end
function ENT:KillShafts()
	self:SetNWBool("Broke", true)
	timer.Simple(2, function() self:SetNWBool("Broke", false) end)
end

function ENT:StartTouch(ent)
end
function ENT:EndTouch(ent)
end

function ENT:RandomChance()
	if (self.Depth > 0) then
		local rand = math.random(0, 100000 * ((self.DrillReliability / 50 * 10) + 1))
		if (rand < 5) then
			self:Explode()
		elseif (rand < 50) then
			self:SnapShafts()
		end
	end
end

function ENT:SnapShafts()
	if (self.Depth > 0) then
		self.Depth = 0
		self:SetNWInt("Depth", self.Depth)
		
		self:SetNWBool("Broke", true)
		timer.Simple(2, function() self:SetNWBool("Broke", false) end)
		self:EmitSound("ambient/explosions/explode_4.wav", 400, math.random(100, 200))
	end
	self:TurnOff()
end

function ENT:Explode()
	local exp = ents.Create("env_explosion")
	local mins = self:OBBMins()
	local maxs = self:OBBMaxs()
	exp:SetPos(Vector(math.Rand(mins.x, maxs.x), math.Rand(mins.y, maxs.y), math.Rand(mins.z, maxs.z)) + self:GetPos())
	exp:Spawn()
	exp:SetKeyValue("iMagnitude", "500")
	exp:Fire("Explode", 0, 0)
	exp:EmitSound("weapon_AWP.Single", 400, 400)
	timer.Simple(1, self.Remove, self)
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.LastThink + 0.1 < RealTime()) then
		if (self.Owner and self.Owner:IsValid()) then
			self.DrillEffeciency = 1 + (self.Owner.pmdrilleff * 0.1)
			self.DrillSpeed = 0.5 + (self.Owner.pmdrillspeed * 0.03)
			self.RetractSpeed = self.DrillSpeed * 2
			self.MaxDepth = (500 + (self.Owner.pmdrillshafts * 100))
			self.DrillReliability = (self.Owner.pmdrillreliab / 50 * 10000)
		end
		if (self:UseResources()) then
			local Offset = SADrillModels[string.lower(self.Entity:GetModel())].Offset
			local Start = self:LocalToWorld(Offset + Vector(0, 0, -SADrillShaftSizeHalf))
			local End = self:LocalToWorld(Offset + Vector(0, 0, -SADrillShaftSizeHalf) - Vector(0, 0, 50))
			local tracedata = {start = Start, endpos = End, mask = MASK_NPCWORLDSTATIC}
			local trace = util.TraceLine(tracedata)
			if (self.Active == 1) then
				self.ShaftRotSpeed = math.min(self.ShaftRotSpeed + 0.05, 25)
				self.EngineSound:ChangePitch((self.ShaftRotSpeed / 25 * 250) + 5)
				
				if (self.LastPos == self:GetPos() and trace.Hit) then
					if (self.Heat >= 100) then //self.HP <= 0) then
						self:Explode()
					end
					//local Col = math.max((255 * (self.HP / 100)), 50)
					//self:SetColor(Col, Col, Col, 255)
					self:RandomChance()
					self:CheckForOre()
				else
					self.LastPos = self:GetPos()
					self:SnapShafts()
				end
			else
				if (self.Depth == 0) then
					self.LastPos = self:GetPos()
				end
				
				if (self.LastPos != self:GetPos() or !trace.Hit) then
					if (self.Depth > 0) then
						self.LastPos = self:GetPos()
						self:SnapShafts()
					end
				end
			end
		end
		self.LastThink = RealTime()
	end
	local CurEnergy = RD.GetResourceAmount(self, "energy")
	if (CurEnergy >= self.EnergyRate) then
		if (self.Active == 1) then
			if (self.ShaftRotSpeed < 25) then
				self.ShaftRotSpeed = math.min(self.ShaftRotSpeed + 0.05, 25)
				self:SetNWFloat("ShaftRotSpeed", self.ShaftRotSpeed)
			else
				if (self.Depth < self.SetDepth) then
					self.Depth = math.min(self.Depth + self.DrillSpeed, self.SetDepth)
				elseif (self.Depth > self.SetDepth) then
					self.Depth = math.max(self.Depth - self.RetractSpeed, 0)
				end
			end
			self:SetNWInt("Depth", self.Depth)
			Wire_TriggerOutput(self, "Depth", self.Depth)
		else
			if (self.ShaftRotSpeed > 0) then
				self.ShaftRotSpeed = math.max(self.ShaftRotSpeed - 0.05, 0)
				self:SetNWFloat("ShaftRotSpeed", self.ShaftRotSpeed)
			end
		end
		self.EngineSound:ChangePitch((self.ShaftRotSpeed / 25 * 250) + 5)
	end
	
	if (self.ShaftRotSpeed == 0 and self.EngineSound:IsPlaying()) then
		self.EngineSound:Stop()
	end
	
	self:NextThink(CurTime() + 0.05)
	return true
end

function ENT:UseResources()
	if (self.Active == 1) then
		local CurEnergy = RD.GetResourceAmount(self, "energy")
		local CurWater = RD.GetResourceAmount(self, "water")
		if (CurEnergy >= self.EnergyRate * 0.1) then
			RD.ConsumeResource(self, "energy", self.EnergyRate * 0.1)
			if (CurWater >= self.WaterRate * 0.1) then
				RD.ConsumeResource(self, "water", self.WaterRate * 0.1)
				if (self.Heat > 0) then
					self.Heat = math.max(self.Heat - 1, 0)
					self:SetNWFloat("Heat", (self.Heat / 100))
				end
				if (self.Heat < 75 and (self.Heat + 1) >= 75) then
					if (self:IsOnFire()) then
						self:Extinguish()
					end
				end
			else
				RD.ConsumeResource(self, "water", CurWater)
				RD.SupplyResource(self, "steam", CurWater * (0.1 + ((self.Owner.pmdrilleff / 50) * 0.4)))
				//self.HP = math.max(self.HP - 1, 0)
				self.Heat = math.min(self.Heat + 0.25, 100)
				self:SetNWFloat("Heat", (self.Heat / 100))
				
				if (self.Heat > 75) then
					if (!self:IsOnFire()) then
						self:Ignite(99999, (((self.Heat / 100) - 0.75) * 4) * 50)
					end
				end
			end
			return true
		else
			self:TurnOff()
			return false
		end
	else
		if (self.Heat > 0) then
			local CurWater = RD.GetResourceAmount(self, "water")
			local Rate = 0.15
			local WaterRate = (self.WaterRate * (self.Heat / 100) * 0.1)
			if (CurWater >= WaterRate) then
				RD.ConsumeResource(self, "water", WaterRate)
				Rate = 1
			end
			self.Heat = math.max(self.Heat - Rate, 0)
			self:SetNWFloat("Heat", (self.Heat / 100))
			if (self.Heat < 75 and (self.Heat + Rate) >= 75) then
				if (self:IsOnFire()) then
					self:Extinguish()
				end
			end
		end
	end
	return true
end

function ENT:CheckForOre()
	
	if (!self.TestProp or !self.TestProp:IsValid()) then
		self.TestProp = ents.Create("prop_physics")
		self.TestProp:SetModel("models/Holograms/hq_sphere.mdl")
		self.TestProp:SetMoveType(MOVETYPE_NONE)
		self.TestProp:Spawn()
	end
	local Off = SADrillModels[string.lower(self:GetModel())].Offset
	local DrillPos = (/*self:GetPos()*/self:LocalToWorld((Off - Vector(0, 0, (self.Depth + SADrillShaftSizeHalf))))) // + (self.OffsetSpawn * 2)))
	self.TestProp:SetPos(DrillPos)
	
	local Ores = SA_PM.FindOreInSphere(DrillPos, 500)
	local Check = {}
	for _,ore in pairs(Ores) do
		local Dist = ore.Pos:Distance(DrillPos)
		if (Dist <= ore.Density) then
			table.insert(Check, ore)
		end
	end
	
	local ore = SA_PM.FindBestOreInArray(DrillPos, Check)
	if (ore != nil) then
		local Dist = ore.Pos:Distance(DrillPos)
		local Perc = math.max((1 - (Dist / ore.Density)), 0)
		ore.Density = math.max(ore.Density - (Perc / 25), 0)
		RD.SupplyResource(self, SA_PM.Ore.Types[ore.Type].Name, Perc * self.DrillEffeciency)
		Wire_TriggerOutput(self, "Deposit Density", ore.Density)
		Wire_TriggerOutput(self, "Deposit Type", SA_PM.Ore.Types[ore.Type].Name)
		Wire_TriggerOutput(self, "Deposit Distance", Dist)
		
		return
	end
	
	Wire_TriggerOutput(self, "Deposit Density", 0)
	Wire_TriggerOutput(self, "Deposit Type", "N/A")
	Wire_TriggerOutput(self, "Deposit Distance", 0)
end