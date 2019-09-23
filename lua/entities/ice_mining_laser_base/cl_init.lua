include("shared.lua")

local laserMat = CreateMaterial("sc_blue_beam02","UnLitGeneric",{
	["$basetexture"] = "sprites/physbeam",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local beginspotMat = CreateMaterial("sc_blue_ball02","UnLitGeneric",{
	["$basetexture"] = "effects/bluemuzzle",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local hitspotMat = CreateMaterial("sc_blue_ball01","UnLitGeneric",{
	["$basetexture"] = "sprites/physcannon_bluecore2b",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local col = Color(255,0,0,255)
function ENT:Draw()
	if (self:GetNWBool("o")) then
		local Trace = util.QuickTrace(self:GetPos(),self:GetUp() * self.LaserRange,self)
		if (Trace.Hit) then
			local Start = self:GetPos() + self:GetUp() * 24
			local HitPos = Trace.HitPos
			local rt = RealTime() * 2

			self:SetRenderBoundsWS(self:GetPos(),HitPos)

			render.SetMaterial(laserMat)
			render.DrawBeam(Start,HitPos,32,rt,rt + 0.002,col)

			render.SetMaterial(beginspotMat)
			render.DrawSprite(Start,64,64,col)

			render.SetMaterial(hitspotMat)
			render.DrawSprite(HitPos,64,64, col)
		end
	end
	self:DrawModel()
end
