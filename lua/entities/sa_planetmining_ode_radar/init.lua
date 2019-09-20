AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include("shared.lua")

resource.AddFile("materials/spaceage/pm/radar.vtf")
resource.AddFile("materials/spaceage/pm/radar.vmt")
resource.AddFile("materials/spaceage/pm/radar_wave.vtf")
resource.AddFile("materials/spaceage/pm/radar_wave.vmt")

//util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound("/ambient/machines/power_transformer_loop_2.wav")
util.PrecacheSound("/ambient/machines/portalgun_rotate_loop1.wav")
util.PrecacheSound("/ambient/machines/thumper_startup1.wav")
util.PrecacheSound("/ambient/machines/teleport1.wav")
util.PrecacheSound("/ambient/machines/teleport3.wav")
util.PrecacheSound("/ambient/machines/teleport4.wav")
util.PrecacheSound("/buttons/button8.wav")

local Sound1 = Sound("/ambient/machines/power_transformer_loop_2.wav")
local Sound2 = Sound("/ambient/machines/portalgun_rotate_loop1.wav")

local RD = CAF.GetAddon("Resource Distribution")

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 32
	local ent = ents.Create("sa_planetmining_ode_radar")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	RD.AddResource(self, "energy", 0, 0)
	
	if (WireAddon) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, {"On", "Scan", "Range"})
		self.Outputs = Wire_CreateOutputs(self, {"On", "Scanning", "Range", "Precision"})
	end
	self:SetModel("models/Slyfo/powercrystal.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:SetMass(500)
		phys:Wake()
	end
	
	self.Active = false
	self.Owner = self:GetTable().Founder
	
	self.EnergyRate = 100
	self.Range = (self.Owner.pmoderange * 60 + 128)
	self:SetNWFloat("Range", self.Range)
	Wire_TriggerOutput(self, "Range", self.Range)
	
	self.ScanTime = 180 - (self.Owner.pmodespeed * 2)
	
	self.Scanning = false
	self.StartTime = 0
	self.EndTime = 0
	self.OffsetMult = 0
	
	self.ThinkNext = RealTime()
	
	self.Sound1 = CreateSound(self, Sound1)
	self.Sound2 = CreateSound(self, Sound2)
	self.Sound2:SetSoundLevel(50)
	
	self.LastPos = self:GetPos()
	
	self:TurnOn()
end

function ENT:TriggerInput(name, value)
	if (name == "On") then
		if (value == 1) then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif (name == "Scan") then
		if (value == 1) then
			self:BeginScan()
		elseif (value == 0) then
			self:FinishScan()
		end
	elseif (name == "Range") then
		self.Range = math.Clamp(value, 128, (self.Owner.pmoderange * 60 + 128))
		self:SetNWFloat("Range", self.Range)
		Wire_TriggerOutput(self, "Range", self.Range)
	end
end

function ENT:BeginScan()
	if (self.Scanning) then return end
	if (!self.Active) then return end
	
	self.Scanning = true
	self.StartTime = RealTime()
	self.EndTime = (RealTime() + self.ScanTime)
	self:SetNetworkedBool("Scanning", self.Scanning)
	self:SetNetworkedFloat("StartScanTime", self.StartTime)
	self:SetNetworkedFloat("EndScanTime", self.EndTime)
	Wire_TriggerOutput(self, "Scanning", 1)
	Wire_TriggerOutput(self, "Precision", 0)
end
function ENT:FinishScan()
	if (!self.Scanning) then return end
	if (!self.Active) then return end
	
	local scanTime = (RealTime() - self.StartTime)
	scanTime = math.min(scanTime, self.ScanTime)
	self.OffsetMult = (1 - math.pow(0.99, (600 - (scanTime * (600 / self.ScanTime)))))
	                  //1 - (0.99^(600 - (x * (600 / 60))))
	
	self.Scanning = false
	self:SetNetworkedBool("Scanning", self.Scanning)
	Wire_TriggerOutput(self, "Scanning", 0)
	Wire_TriggerOutput(self, "Precision", ((1 - self.OffsetMult) * 100))
	
	if (scanTime > (self.ScanTime / 20)) then
		SA_PM.SendOreToPlayerRadar(self)
		local rand = math.random(1, 3)
		if (rand == 1) then
			self:EmitSound("/ambient/machines/teleport1.wav", 75, 100)
		elseif (rand == 2) then
			self:EmitSound("/ambient/machines/teleport3.wav", 75, 100)
		elseif (rand == 3) then
			self:EmitSound("/ambient/machines/teleport4.wav", 75, 100)
		end
	else
		self:EmitSound("/buttons/button8.wav", 75, 100)
	end
end
function ENT:TurnOn()
	if (!self.Active) then
		local CurEnergy = RD.GetResourceAmount(self, "energy")
		local EnRate = (self.EnergyRate) * (self.Scanning and 100 or 1) * 0.1
		if (CurEnergy >= EnRate) then
			self.Active = true
			
			if (WireAddon != nil) then
				Wire_TriggerOutput(self, "On", 1)
			end
			
			self:EmitSound("/ambient/machines/thumper_startup1.wav", 100, 100)
			
			self.Sound1:Play()
			self.Sound2:Play()
			//self:EmitSound("/ambient/machines/portalgun_rotate_loop1.wav", 50, 100)
			//self:EmitSound("/ambient/machines/power_transformer_loop_2.wav", 100, 100)
			
			self:SetOOO(1)
			self:SetNetworkedBool("o",true)
			self:SetNetworkedBool("Active", true)
		else
			self:EmitSound("/buttons/button8.wav", 75, 100)
		end
	end
end
function ENT:TurnOff()
	if (self.Active) then
		self.Active = false
		if WireAddon != nil then
			Wire_TriggerOutput(self, "On", 0)
		end
		
		self.Sound1:Stop()
		self.Sound2:Stop()
		//self:StopSound("portalgun_rotate_loop1")
		//self:StopSound("power_transformer_loop_2")
		
		self:SetOOO(0)
		self:SetNetworkedBool("o",false)
		self:SetNetworkedBool("Active", false)
		
		self.Scanning = false
		self:SetNetworkedBool("Scanning", self.Scanning)
		Wire_TriggerOutput(self, "Scanning", 0)
		Wire_TriggerOutput(self, "Precision", 0)
	end
end

function ENT:OnRemove()
	self:TurnOff()
end

function ENT:StartTouch(ent)
end
function ENT:EndTouch(ent)
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Scanning) then
		if (self.LastPos != self:GetPos()) then
			local dist = self.LastPos:Distance(self:GetPos())
			if (dist > 12) then
				self:FinishScan()
			end
		end
		
		local scanTime = (RealTime() - self.StartTime)
		scanTime = math.min(scanTime, self.ScanTime)
		self.OffsetMult = (1 - math.pow(0.99, (600 - (scanTime * (600 / self.ScanTime)))))
		Wire_TriggerOutput(self, "Precision", (1 - self.OffsetMult) * 100)
		
		if (RealTime() > self.EndTime) then
			self:FinishScan()
		end
	end
	
	if (RealTime() > self.ThinkNext) then
		if (self.Active) then
			if (self:UseResources()) then
				
			end
			self.ThinkNext = RealTime() + 0.1
		end
	end
	
	self.LastPos = self:GetPos()
end

function ENT:UseResources()
	if (self.Active) then
		local CurEnergy = RD.GetResourceAmount(self, "energy")
		local EnRate = (self.EnergyRate) * (self.Scanning and 100 or 1) * 0.1
		if (CurEnergy >= EnRate) then
			RD.ConsumeResource(self, "energy", EnRate)
			return true
		else
			self:TurnOff()
			return false
		end
	end
	return true
end