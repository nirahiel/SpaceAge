AddCSLuaFile("shared.lua")

SWEP.Author = "Zachar543"
SWEP.Contact = ""
SWEP.Purpose = "Finds Ore pockets below the ground"
SWEP.Instructions = "Left click to toggle usage of the ODE"
SWEP.Category = "Space Age"

SWEP.PrintName = "ODE"
SWEP.Slot = 0
SWEP.SlotPos = 4
SWEP.DrawAmmo = false
SWEP.Weight = 1
SWEP.Spawnable = false
SWEP.AdminSpawnable = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.ViewModel = "models/weapons/v_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"

function SWEP:Initialize()
	self.LastThink = 0
	self.ZoomLevel = 1
end

function SWEP:OwnerChanged()
	if (!self.Owner or !IsValid(self.Owner)) then return end
	
	self.ThinkRate = 0.2
	if (SERVER) then
		self.Active = false
		self.LastBatteryLowBeep = 0
	
		self.MaxBattery = 100
		self.Battery = self.MaxBattery
		self.Progress = -1
		self.RenderSpeed = 10 * self.ThinkRate
		
		self.DepthSelect = 500
		self.LastQ = false
		self.LastE = false
		
		self.ScanXRange = 300
		self.ScanZRange = 500
		self.ScanYRange = 300
		self.Resolution = 16
		timer.Simple(0.1, self.InitVars, self)
	else
		self.MaxBattery = -1
		self.Battery = 0
	end
	self.LastThink = 0
end

function SWEP:InitVars()
	if (!self.Owner.pmodebattery) then
		timer.Simple(1, self.InitVars, self)
		return
	end
	
	self.MaxBattery = (60 * 5 * (1 + self.Owner.pmodebattery)) / self.ThinkRate
	//print((60 * 5 * (1 + self.Owner.pmodebattery)), self.MaxBattery)
	self.Battery = self.MaxBattery
	//				   10
	self.RenderSpeed = 50 * self.ThinkRate * (1 + (self.Owner.pmodespeed * 0.5))
	self.ScanXRange = 200 * (1 + (self.Owner.pmoderange * 0.2))
	self.ScanZRange = 500 * (1 + (self.Owner.pmoderange * 0.2))
	self.ScanYRange = 200 * (1 + (self.Owner.pmoderange * 0.2))
	if (self.Owner.pmoderes == 0) then
		self.Resolution = 8
	elseif (self.Owner.pmoderes == 1) then
		self.Resolution = 6
	elseif (self.Owner.pmoderes == 2) then
		self.Resolution = 4
	elseif (self.Owner.pmoderes == 3) then
		self.Resolution = 2
	else
		self.Resolution = 8
	end
	self:UpdateValues()
end
	
function SWEP:UpdateValues()
	self:SetNWInt("Battery", self.Battery)
	self:SetNWInt("MaxBattery", self.MaxBattery)
	self:SetNWInt("Resolution", self.Resolution)
	self:SetNWInt("ScanXRange", self.ScanXRange)
	self:SetNWInt("ScanYRange", self.ScanYRange)
	self:SetNWInt("ScanZRange", self.ScanZRange)
	self:SetNWFloat("ZoomLevel", 1)
end

if (SERVER) then
	function SWEP:PrimaryAttack()
		if (self.Active) then
			self:Off()
		else
			if (self.Battery > 0) then
				self:On()
			else
				self.Owner:EmitSound("buttons/combine_button_locked.wav", 100, 100)
			end
		end
	end

	function SWEP:SecondaryAttack()
		if (self.Active and self.Progress == -1) then
			self:StartRender()
		end
	end

	function SWEP:Reload()
		if (self.Active and self.Progress != -1) then
			self:SetNWBool("FailedRender", true)
			self:FinishRender(true)
		end
	end

	function SWEP:Holster()
		if (self.Active) then
			self:Off()
		end
		return true
	end

	function SWEP:OnDrop()
		if (self.Active) then
			self:Off()
		end
	end

	function SWEP:On()
		self.Active = true
		self:SetNWBool("Active", self.Active)
		self.Owner:EmitSound("buttons/button1.wav", 100, 100)
	end
	function SWEP:Off()
		if (self.Progress != -1) then
			self:FinishRender(true)
			self:SetNWBool("FailedRender", true)
		end
		self.Active = false
		self:SetNWBool("Active", self.Active)
		self.Owner:EmitSound("buttons/combine_button2.wav", 100, 100)
	end
end

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos + ang:Right() * -6
	pos = pos + ang:Forward() * -10
	pos = pos + ang:Up() * -8
	ang = ang + Angle(-25, 0, 0)
	return pos, ang
end

function SWEP:Think()
	if (SERVER) then
		if (self.LastThink + self.ThinkRate > RealTime()) then 
			return
		else
			self.LastThink = RealTime()
		end
		
		if (self.Owner:KeyDown(IN_SPEED)) then
			self.ZoomLevel = math.min(self.ZoomLevel + 0.05, 1)
			self:SetNWFloat("ZoomLevel", self.ZoomLevel)
			//self.DepthSelect = math.min(self.ScanZRange, self.DepthSelect + 100)
			//self:SetNWInt("ScanZRange", self.DepthSelect)
		end
		if (self.Owner:KeyDown(IN_WALK)) then
			self.ZoomLevel = math.max(self.ZoomLevel - 0.05, 0.01)
			self:SetNWFloat("ZoomLevel", self.ZoomLevel)
			//self.DepthSelect = math.max(100, self.DepthSelect - 100)
			//self:SetNWInt("ScanZRange", self.DepthSelect)
		end
		
		if (self.Active) then
			self.Battery = self.Battery - 1
			self:SetNWInt("Battery", self.Battery)
			if (self.Battery < self.MaxBattery * 0.05) then
				if (self.LastBatteryLowBeep + 1.5 < RealTime()) then
					self.LastBatteryLowBeep = RealTime()
					self:BatteryLow()
				end
			end
			
			if (self.Battery <= 0) then
				self.Owner:EmitSound("buttons/combine_button2.wav", 100, 100)
				self.Active = false
				self:SetNWBool("Active", self.Active)
			end
			
			if (self.Progress != -1) then
				self.Progress = self.Progress + self.RenderSpeed
				self:SetNWInt("Progress", self.Progress)
				if (self.Progress >= 100) then
					self:SetNWBool("FailedRender", false)
					self:FinishRender(false)
				end
			end
		end
	else
		if (self.LastThink + 0.1 > RealTime()) then 
			return
		else
			self.LastThink = RealTime()
		end
		
		self.Active = self:GetNWBool("Active", false)
		self.Battery = self:GetNWInt("Battery", 0)
		self.Progress = self:GetNWInt("Progress", -1)
		self.FailedRender = self:GetNWBool("FailedRender", false)
		
		self.Resolution = self:GetNWInt("Resolution", 32)
		self.ZoomLevel = self:GetNWFloat("ZoomLevel", 1)
		self.ScanXRange = self:GetNWInt("ScanXRange", 0) * self.ZoomLevel
		self.ScanYRange = self:GetNWInt("ScanYRange", 0) * self.ZoomLevel
		self.ScanZRange = self:GetNWInt("ScanZRange", 0) * self.ZoomLevel
		
		//if (self.MaxBattery == -1) then
			self.Battery = self:GetNWInt("Battery", 0)
			self.MaxBattery = self:GetNWInt("MaxBattery", -1)
		//end
	end
end

if (SERVER) then
	function SWEP:StartRender()
		self:SetNWBool("FailedRender", false)
		self.Progress = 0
		self:SetNWInt("Progress", self.Progress)
	end

	function SWEP:FinishRender(Failed)
		self.Progress = -1
		self:SetNWInt("Progress", self.Progress)
		
		self.Owner:EmitSound("buttons/blip1.wav", 100, 100)
		if (!Failed) then SA_PM.SendOreToPlayer(self.Owner, self) end
	end

	function SWEP:BatteryLow()
		self.Owner:EmitSound("buttons/blip2.wav", 100, 100)
	end

	function SWEP:Deploy()
		self:InitVars()
		return true
	end
end