include("shared.lua")

language.Add("sa_mining_laser","Mining Laser")

local mat = Material("trails/laser")
local sprite = Material("sprites/animglow02")
local BeamColor = {Color(255,0,0,255),Color(0,255,0,255),Color(0,0,255,255)}

function ENT:Initialize()
	self.length = 2000
end

function ENT:Draw()
	self:DrawModel()
	if self:GetNetworkedBool("o") == true then
		self:DrawLaser()
	end
end

function ENT:DrawLaser()
	local color = self:GetNetworkedColor("c");
	local width = color.a;
	local width2 = width/2
	color.a = 255;
	local ang = self:GetAngles()
	local up = ang:Up()
	local right = ang:Right()
	local fow = ang:Forward()
	local start = self:GetPos()+(up*self:OBBMaxs().z)
	local trace = util.TraceLine({start = start, endpos = start+(up*self.length), filter = { self }})
	
	local End = trace.HitPos
	
	render.SetMaterial( mat )
	render.DrawBeam( start, End, width, 0, width * 4, color )
	
	render.SetMaterial( sprite )
	render.DrawSprite(start,width2,width2,color)
	
	if (ValidEntity(trace.Entity) and trace.Entity:GetClass() == "sa_roid") then
		render.DrawSprite(End,width2,width2,color)
		
		local len = start:Distance(End)/19
		
		local T = RealTime()
		
		render.SetMaterial( mat )
		for Beam=1,3 do
			local ang = math.rad(((Beam*120)+T*90)%360)
			render.StartBeam(20)
			for seg=1,20 do
				local segm = seg-1
				render.AddBeam(start+(up*len*segm)+((math.sin(ang) * right + math.cos(ang) * fow):Normalize()*math.sin(math.rad(segm * 9.4736842))*len/2),width2,T,BeamColor[Beam])
			end
			render.EndBeam()
		end
	end	
end
