include("shared.lua")

language.Add("sa_mining_laser_vi","Mining Laser")

local mat = Material("trails/laser")
local sprite = Material("sprites/animglow02")
local BeamColor = {Color(255,0,0,255),Color(0,255,0,255),Color(0,0,255,255)}

function ENT:Initialize()
	self.color = Color(255,255,255,255)
	self.colord = Color(math.random(-1,-0.5),math.random(-1,-0.5),math.random(-1,-0.5),1)
	self.length = 3000
	self.width = 1
end

function ENT:Think()
	self.color.r = (math.random(1,7) * self.colord.r) + self.color.r
	if self.color.r >= 255 then 
		self.color.r = 255
		self.colord.r = math.random(-1,-0.5)
	elseif self.color.r <= 0 then
		self.color.r = 0
		self.colord.r = math.random(0.5,1)		
	end
	self.color.g = (math.random(1,7) * self.colord.g) + self.color.g
	if self.color.g >= 255 then 
		self.color.g = 255
		self.colord.g = math.random(-1,-0.5)
	elseif self.color.g <= 0 then
		self.color.g = 0
		self.colord.g = math.random(0.5,1)		
	end
	self.color.b = (math.random(1,7) * self.colord.b) + self.color.b
	if self.color.b >= 255 then 
		self.color.b = 255
		self.colord.b = math.random(-1,-0.5)
	elseif self.color.b <= 0 then
		self.color.b = 0
		self.colord.b = math.random(0.5,1)		
	end
	self:NextThink(CurTime()+1)
	return true
end

function ENT:Draw()
	self:DrawModel()
	if self:GetNetworkedBool("o") == true then
		self:DrawLaser()
	end
end

function ENT:GetNetworkedColor(name)
	local int = self:GetNetworkedInt(name);
	return Color((int >> 0) & 255, (int >> 8) & 255, (int >> 16) & 255, (int >> 24) & 255);
end

function ENT:DrawLaser()
	local ang = self:GetAngles()
	local up = ang:Up()
	local right = ang:Right()
	local fow = ang:Forward()
	local start = self:GetPos()+(up*self:OBBMaxs().z)
	local trace = util.TraceLine({start = start, endpos = start+(up*self.length), filter = { self }})
	
	local End = trace.HitPos
	
	render.SetMaterial( mat )
	render.DrawBeam( start, End, self.width, 0, self.width * 4, self.color )
	
	render.SetMaterial( sprite )
	render.DrawSprite(start,self.width/2,self.width/2,self.color)
	
	if (ValidEntity(trace.Entity) and trace.Entity:GetClass() == "sa_roid") then
		render.DrawSprite(End,self.width/2,self.width/2,self.color)

		local len = start:Distance(End)/19
		
		local T = RealTime()
		
		render.SetMaterial( mat )
		for Beam=1,3 do
			local ang = math.rad(((Beam*120)+T*90)%360)
			render.StartBeam(20)
			for seg=1,20 do
				local segm = seg-1
				local dist = math.sin(math.rad(segm * 9.4736842))*len/2
				render.AddBeam(start+(up*len*segm)+((math.sin(ang) *right + math.cos(ang) * fow):Normalize()*dist),self.width/2,T,BeamColor[Beam])
			end
			render.EndBeam()
		end
	end	
end
