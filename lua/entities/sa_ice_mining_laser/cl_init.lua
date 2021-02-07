include("shared.lua")

DEFINE_BASECLASS("sa_base_rd3_entity")

local laserMat = CreateMaterial("sc_blue_beam02", "UnLitGeneric", {
	["$basetexture"] = "sprites/physbeam",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local beginspotMat = CreateMaterial("sc_blue_ball02", "UnLitGeneric", {
	["$basetexture"] = "effects/bluemuzzle",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local hitspotMat = CreateMaterial("sc_blue_ball01", "UnLitGeneric", {
	["$basetexture"] = "sprites/physcannon_bluecore2b",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

function ENT:Think()
	BaseClass.Think(self)
	local tr = SA.LaserTraceCalc(self)
	self.hitIs = tr and tr.Hit
end

local col = Color(255, 0, 0, 255)
function ENT:Draw()
	BaseClass.Draw(self)

	if not self.hitPos then
		return
	end

	local hitPos = self.hitPos
	local start = self.hitStart
	local rt = RealTime() * 2

	render.SetMaterial(laserMat)
	render.DrawBeam(start, hitPos, 32, rt, rt + 0.002, col)

	render.SetMaterial(beginspotMat)
	render.DrawSprite(start, 64, 64, col)

	if not self.hitIs then
		return
	end

	render.SetMaterial(hitspotMat)
	render.DrawSprite(hitPos, 64, 64, col)
end
