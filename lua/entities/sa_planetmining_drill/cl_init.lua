include("shared.lua")
language.Add("sa_planetmining_drill","Planetary Mining Drill")

local heatWave = Material("spacebuild/Fusion5")

function ENT:Initialize()
	self.Depth = self:GetNWInt("Depth", 0)
	self.Shafts = {}
	self.ShaftRotSpeed = 0
	
	self.Heat = 0
	self.SteamEmitter = ParticleEmitter(self:GetPos(), false)	
end

function ENT:Think()
	local Broke = self:GetNWBool("Broke", false)
	if (Broke) then
		for I=1, (table.Count(self.Shafts) - 1) do
			local shaft = table.remove(self.Shafts, 1)
			if (IsValid(shaft)) then
				shaft:SetParent()
				shaft:Remove()
			end
		end
	end
	
	self.Heat = self:GetNWFloat("Heat", 0)
	
	local YOff = SADrillModels[string.lower(self.Entity:GetModel())].Offset.z
	self.ShaftRotSpeed = self:GetNWFloat("ShaftRotSpeed", 0)
	
	self.Depth = self:GetNWInt("Depth", 0)
	local CurCount = table.Count(self.Shafts)
	local NeededCount = math.max(math.floor((self.Depth + YOff + SADrillShaftSize) / SADrillShaftSize), 1)
	if (NeededCount > CurCount) then
		for I = 1, (NeededCount - CurCount) do
			self:SpawnShaft()
			print("Added Shaft")
		end
	elseif (CurCount > NeededCount) then
		for I = 1, (CurCount - NeededCount) do
			self:RemoveShaft()
			print("Removed Shaft")
		end
	end
	
	for I, shaft in pairs(self.Shafts) do
		if (IsValid(shaft)) then
			shaft:SetPos(self:GetPosition(I))
			shaft:SetAngles(self:LocalToWorldAngles(self:WorldToLocalAngles(shaft:GetAngles()) + Angle(0, self.ShaftRotSpeed, 0)))
		else
			table.remove(self.Shafts, I)
		end
	end
end

function ENT:Draw()
	self.BaseClass.Draw(self)
	self:DrawModel()
	
	if (self.Heat > 0) then
		local r, g, b, a = self:GetColor()
		SetMaterialOverride(heatWave)
		render.SetBlend(self.Heat * 0.0625)
		self:SetModelScale(Vector(1, 1, 1) * 1.025)
		self:DrawModel()
		
		SetMaterialOverride(nil)
		render.SetBlend(1)
		self:SetModelScale(Vector(1, 1, 1))
		
		if (self.Heat > 0.25) then
			local particles = math.floor(self.Heat * 5)
			for I = 1, particles do
				local Min = self:OBBMins()
				local Max = self:OBBMaxs()
				local Offset = Vector(math.random(Min.x, Max.x), math.random(Min.y, Max.y), math.random(Min.z, Max.z))
				local part = self.SteamEmitter:Add(((self.Heat > 0.5 and math.Rand(1, 2) == 1) and "sprites/heatwave" or "particle/particle_smokegrenade"), self:LocalToWorld(Offset))
				part:SetVelocity(Vector(0, 0, 35))
				part:SetGravity(Vector(0, 0, 15))
				part:SetStartAlpha(64)
				part:SetEndAlpha(0)
				part:SetColor(150, 150, 150)
				part:SetDieTime(3)
				part:SetStartSize(particles * 4)
				part:SetEndSize((particles * 4) * 2.0)
				part:SetRoll(math.Rand(0, 360))
				part:SetRollDelta(math.Rand(-1, 1))
				
				self.LastScanRing = RealTime() + 1.0
			end
		end
	end
end

function ENT:OnRemove()
	for _, shaft in pairs(self.Shafts) do
		if (IsValid(shaft)) then
			shaft:Remove()
		end
	end
end

function ENT:GetPosition(Index)
	local Dist = (self.Depth) - ((Index - 1) * SADrillShaftSize)
	return (self:LocalToWorld(SADrillModels[string.lower(self:GetModel())].Offset) + self:GetUp() * -(Dist))
end

function ENT:RemoveShaft()
	if (table.Count(self.Shafts) > 1) then
		table.remove(self.Shafts):Remove()
	end
end

function ENT:SpawnShaft()
	local shaft = ClientsideModel("models/Slyfo/rover_drillshaft.mdl", RENDERGROUP_OPAQUE)
	shaft:SetPos(self:LocalToWorld(SADrillModels[string.lower(self:GetModel())].Offset))
	shaft:SetParent(self)
	shaft:SetAngles(self:GetAngles())
	table.insert(self.Shafts, shaft)
end