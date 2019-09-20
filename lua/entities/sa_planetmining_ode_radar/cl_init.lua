include("shared.lua")

local radarCircle = surface.GetTextureID("spaceage/pm/radar")
local radarMat = Material("spaceage/pm/radar")
local glowMat = Material("sprites/light_glow02_add")

function ENT:Initialize()
	self.HoloCone = nil
	self.Ores = {}
	self.OreHolograms = {}
	self.Miners = {}
	self.MinerHolograms = {}
	self.MinerShaftHolograms = {}
	
	self.RingRadius = 64
	self.HeightOffset = 32
	self.ViewRange = 512
	self.ViewScale = Vector(0.015, 0.015, 0.015)
	
	self.Active = false
	self.Scanning = false
	self.StartScanTime = 0
	self.EndScanTime = 0
	
	self.LastScanRing = 0
	
	self.Emitter = ParticleEmitter(self:GetPos(), true)
	
	self.LastEntFind = RealTime()
end

local function recieveOres(hndl, id, encoded, decoded)
	local ID = table.remove(decoded, 1)
	print(ID)
	local Ent = ents.GetByIndex(ID)
	print(tostring(Ent))
	if (IsValid(Ent)) then
		Ent:ReceiveOres(decoded)
	end
end
datastream.Hook("SA_ODE_Points_Radar", recieveOres)

function ENT:ReceiveOres(decoded)
	local curCount = table.Count(self.OreHolograms)
	local newCount = table.Count(decoded)
	if (newCount > curCount) then // There are not enough holograms.
		for I = 1, (newCount - curCount) do
			local ore = ClientsideModel("models/holograms/icosphere3.mdl", RENDERGROUP_OPAQUE)
			ore:SetAngles(Angle(0, 0, 0))
			//ore:SetMaterial("models/alyx/emptool_glow")
			ore:SetKeyValue("renderfx", 16)
			ore:SetColor(255, 255, 255, 0)
			ore:SetPos(self:GetPos())
			ore:SetModelScale(self.ViewScale)
			table.insert(self.OreHolograms, ore)
		end
	elseif (newCount < curCount) then // There are more holograms then needed.
		for I = 1, (curCount - newCount) do
			local ore = table.remove(self.OreHolograms)
			ore:Remove()
		end
	end
	self.Ores = decoded
end

function ENT:OnRemove()
	self:SetActive(false)
end

function ENT:SetActive(Active)
	if (Active and !self.Active) then
		self.HoloCone = ClientsideModel("models/holograms/hq_cone.mdl", RENDERGROUP_TRANSLUCENT)
		self.HoloCone:SetPos(self:GetAttachmentPos() - Vector(0, 0, (self.HeightOffset / 2) + 1))
		self.HoloCone:SetAngles(Angle(180, 0, 0))
		self.HoloCone:SetMaterial("models/alyx/emptool_glow")
		self.HoloCone:SetColor(100, 200, 100, 35) // 100, 100, 155, 25
		self.HoloCone:SetModelScale(Vector(self.RingRadius / 2, self.RingRadius / 2, self.HeightOffset / 2) / 6)
		self.HoloCone:SetKeyValue("renderfx", 16 + 2)
		
		if (table.Count(self.Ores) > 0) then
			self:ReceiveOres(self.Ores)
		end
	elseif (!Active and self.Active) then
		if (IsValid(self.HoloCone)) then
			self.HoloCone:Remove()
		end
		
		//self.Ores = {}
		for _, v in pairs(self.OreHolograms) do
			if (IsValid(v)) then
				v:Remove()
			end
		end
		self.OreHolograms = {}
		
		self.Miners = {}
		for _, v in pairs(self.MinerHolograms) do
			if (IsValid(v)) then
				v:Remove()
			end
		end
		self.MinerHolograms = {}
		for _,v in pairs(self.MinerShaftHolograms) do
			for _, shaft in pairs(v) do
				if (IsValid(shaft)) then
					shaft:Remove()
				end
			end
		end
		self.MinerShaftHolograms = {}
	end
	
	self.Active = Active
end

function ENT:GetAttachmentPos()
	return (self:GetPos() + self:GetUp() * 23.75)
end

function ENT:Think()
	local Active = self:GetNWBool("Active", false)
	self.Scanning = self:GetNWBool("Scanning", false)
	self.StartScanTime = self:GetNWFloat("StartScanTime", 0)
	self.EndScanTime = self:GetNWFloat("EndScanTime", 0)
	
	self:SetActive(Active)
	if (self.Active) then
		self.HoloCone:SetPos(self:GetAttachmentPos() + Vector(0, 0, (self.HeightOffset / 2) + 1))
	
		if (RealTime() > self.LastEntFind) then
			local Drills = ents.FindByClass("sa_planetmining_drill")
			// Loop threw drills to find new and old drills
			for _, v in pairs(Drills) do
				if (v:GetPos():Distance(self:GetPos()) <= self.ViewRange) then // The Drill is now or already was in range.
					if (!IsValid(self.Miners[v:EntIndex()])) then // The drill does not exist as a hologram already.
						local NewMiner = ClientsideModel(v:GetModel(), RENDERGROUP_OPAQUE)
						NewMiner:SetModelScale(self.ViewScale)
						self.MinerHolograms[v:EntIndex()] = NewMiner
						self.Miners[v:EntIndex()] = v
					end
				else // The drill is now or already was out of range.
					if (self.Miners[v:EntIndex()] != nil) then // The drill exists as a hologram currently.
						self.Miners[v:EntIndex()] = nil //table.remove(self.Miners, v:EntIndex())
						
						for _, shaft in pairs(self.MinerShaftHolograms[v:EntIndex()]) do
							if (IsValid(shaft)) then
								shaft:Remove()
							end
						end
						self.MinerShaftHolograms[v:EntIndex()] = {}
						
						local Removed = self.MinerHolograms[v:EntIndex()] //table.remove(self.MinerHolograms, v:EntIndex())
						if (IsValid(Removed)) then
							Removed:Remove()
						end
						self.MinerHolograms[v:EntIndex()] = nil
					end
				end
			end
			
			// Remove old Drill Holograms that no longer exist.
			
			for ID, holo in pairs(self.MinerHolograms) do
				local miner = ents.GetByIndex(ID)
				if (!IsValid(miner)) then
					// Remove old drill shaft holograms
					for _, shaft in pairs(self.MinerShaftHolograms[ID]) do
						if (IsValid(shaft)) then
							shaft:Remove()
						end
					end
					self.MinerShaftHolograms[ID] = nil
					
					self.Miners[ID] = nil //table.remove(self.Miners, miner:EntIndex())
					local Removed = self.MinerHolograms[ID]
					if (IsValid(Removed)) then
						Removed:Remove()
					end
					self.MinerHolograms[ID] = nil //table.remove(self.MinerHolograms, miner:EntIndex())
				end
			end
			
			self.LastEntFind = RealTime() + 1.0
		end
	
		// Update the position of Drill Holograms
		for _, miner in pairs(self.Miners) do
			if (self.MinerShaftHolograms[miner:EntIndex()] == nil) then
				self.MinerShaftHolograms[miner:EntIndex()] = {}
			end
			
			if (IsValid(miner)) then
				// Check if we need more or have too many holograms for drill shafts
				local newCount = table.Count(miner.Shafts or {})
				local curCount = table.Count(self.MinerShaftHolograms[miner:EntIndex()] or {})
				if (newCount > curCount) then // There are not enough holograms.
					for I = 1, (newCount - curCount) do
						local shaft = miner.Shafts[1]
						local newShaft = ClientsideModel(shaft:GetModel(), RENDERGROUP_OPAQUE)
						newShaft:SetAngles(shaft:GetAngles())
						newShaft:SetPos(self:WorldToScreen3D(shaft:GetPos()))
						newShaft:SetModelScale(self.ViewScale)
						table.insert(self.MinerShaftHolograms[miner:EntIndex()], newShaft)
					end
				elseif (newCount < curCount) then // There are more holograms then needed.
					for I = 1, (curCount - newCount) do
						local Shaft = table.remove(self.MinerShaftHolograms[miner:EntIndex()])
						Shaft:Remove()
					end
				end
				
				// Update positions of hologram shafts.
				for k, shaft in pairs(miner.Shafts) do
					local holoShaft = self.MinerShaftHolograms[miner:EntIndex()][k]
					if (IsValid(holoShaft)) then
						holoShaft:SetPos(self:WorldToScreen3D(shaft:GetPos()))
						holoShaft:SetAngles(shaft:GetAngles())
					end
				end
				
				// Update Position of Drill Holograms
				if (self.MinerHolograms[miner:EntIndex()] != nil) then
					local drill = self.MinerHolograms[miner:EntIndex()]
					if (IsValid(drill)) then
						drill:SetPos(self:WorldToScreen3D(miner:GetPos()))
						drill:SetAngles(miner:GetAngles())
					end
				end
			end
		end
		
		// Update position of ore holograms
		for ID, ore in pairs(self.Ores) do
			// Update Position, Color, and Size of Ore Holograms
			local holo = self.OreHolograms[ID]
			if (IsValid(holo)) then
				holo:SetPos(self:WorldToScreen3D(ore.Pos))
				local col = SA_PM.Ore.Types[ore.Type].Color
				local Dist = (self.ViewScale * (ore.Pos - self:GetPos())):Length()
				Dist = Dist - ((self.RingRadius / 2) * 0.75)
				Dist = math.max(Dist, 0)
				local Opacity = (1 - (Dist / ((self.RingRadius / 2) * 0.25))) * 128
				Opacity = math.Clamp(Opacity, 0, 255)
				
				holo:SetColor(Color(col.r, col.g, col.b, Opacity)) //64))
				holo:SetNoDraw(Opacity == 0)
				holo:SetModelScale(Vector(1, 1, 1) * (ore.Density / 6) * self.ViewScale)
			end
		end
	end
end

function ENT:Draw()
	self.BaseClass.Draw(self)
	self:DrawModel()
	
	if (self.Active) then
		local newRange = self:GetNWFloat("Range", 512)
		if (newRange != self.ViewRange) then
			self.ViewRange = newRange
			self.ViewScale = (Vector(1, 1, 1) * ((self.RingRadius / 2) / self.ViewRange))//Vector(0.015, 0.015, 0.015)
		end
	
		render.SetMaterial(radarMat)
		render.DrawQuadEasy(self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 1), Vector(0, 0, 1), (self.RingRadius), (self.RingRadius), Color(255, 255, 255, 128), 0)
		render.DrawQuadEasy(self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 1), Vector(0, 0, -1), (self.RingRadius), (self.RingRadius), Color(255, 255, 255, 128), 0)
		
		//render.DrawQuadEasy(self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 1), Vector(0, 1, 0), (self.RingRadius), (self.RingRadius), Color(255, 255, 255, 128), 0)
		//render.DrawQuadEasy(self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 1), Vector(0, -1, 0), (self.RingRadius), (self.RingRadius), Color(255, 255, 255, 128), 0)
		
		//render.DrawQuadEasy(self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 1), Vector(1, 0, 0), (self.RingRadius), (self.RingRadius), Color(255, 255, 255, 128), 0)
		//render.DrawQuadEasy(self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 1), Vector(-1, 0, 0), (self.RingRadius), (self.RingRadius), Color(255, 255, 255, 128), 0)
		
		
		render.SetMaterial(glowMat)
		local size = ((16 * ((math.sin(RealTime() / 2 * (3.14159265)) + 1.0) / 2.0)) + 16)
		render.DrawQuadEasy(self:GetAttachmentPos(), -(EyeAngles():Forward()), size, size, Color(150, 150, 255, 128), 0)
		
		if (self.Scanning) then
			self.Emitter:SetPos(self:GetPos())
			if (RealTime() > self.LastScanRing) then
				self:EmitSound("/ambient/machines/thumper_top.wav", 75, 100)
				local part = self.Emitter:Add("spaceage/pm/radar_wave", self:GetPos() + self:GetUp() * -23)
				part:SetAngles(Angle(-90, 0, 0))
				part:SetVelocity(Vector(0, 0, 0))
				part:SetStartAlpha(64)
				part:SetEndAlpha(0)
				part:SetColor(100, 255, 255)
				part:SetDieTime(3)
				part:SetStartSize(1)
				part:SetEndSize(128)
				
				self.LastScanRing = RealTime() + 1.0
			end
		end
	end
end

function ENT:WorldToScreen3D(World)
	local Screen = ((self:GetAttachmentPos() + Vector(0, 0, self.HeightOffset + 0.75)) + (self.ViewScale * (World - (self:GetPos() + (self:GetUp() * -23.75)))))
    return Screen
end