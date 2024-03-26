include("shared.lua")
language.Add("pyrothium_injector", "Pyrothium Injector")

DEFINE_BASECLASS("sa_base_rd3_entity")

local mat = Material("trails/laser")
local sprite = Material("sprites/animglow02")
local BeamColor = {Color(255, 0, 0, 255), Color(0, 255, 0, 255), Color(0, 0, 255, 255)}

local function LaserTrace(ent)
	local mins = ent:OBBMins()
	local maxs = ent:OBBMaxs()

	if not ent.BeamLength or not ent:GetNWBool("o") then
		ent.hitPos = nil
		ent:SetRenderBounds(mins, maxs)
		return
	end

	local pos = ent:GetPos()
	local dir = ent:GetForward()

	local tr = util.QuickTrace(pos, dir * ent.BeamLength, ent)

	ent.hitPos = tr.HitPos
	ent.hitStart = ent:GetPos() + (dir * ent:OBBMaxs().x)
	ent.hitTrace = tr

	maxs = maxs + ((ent.BeamLength * tr.Fraction) * Vector(0,0,1))
	ent:SetRenderBounds(mins, maxs)
	return tr
end

function ENT:Initialize()
	self.BeamLength = 1000
end

function ENT:Think()
	BaseClass.Think(self)

	self.LaserColor = Color(255, 0, 0, 255)
	self.LaserWidth = 30

	local trace = LaserTrace(self)
	self.hitIs = trace and IsValid(trace.Entity) and (
		trace.Entity.IsCrystalTower or
		trace.Entity.IsAsteroid or
		trace.Entity.IsIceroid
	)
end

function ENT:Draw()
	BaseClass.Draw(self)

	if not self.hitPos then
		return
	end

	local color = self.LaserColor
	local width = self.LaserWidth
	local width2 = width * 2
	local up = self:GetUp()
	local right = self:GetRight()
	local fow = self:GetForward()

	local endPos = self.hitPos
	local start = self.hitStart

	render.SetMaterial(mat)
	render.DrawBeam(start, endPos, width, 0, width * 4, color)

	render.SetMaterial(sprite)
	render.DrawSprite(start, width2, width2, color)

	if self.hitIs then
		render.DrawSprite(endPos, width2, width2, color)

		local len = start:Distance(endPos) / 19

		local T = RealTime()
		local waves = 2
		local amplitude = 0.5
		local BeamCount = 6

		render.SetMaterial(mat)
		for BeamSet = 1 , 3 do
			local BeamSpeed = (4 - BeamSet) / 3
			for Beam = 1, BeamCount do
				local b_ang = math.rad(((Beam * (360 / BeamCount)) + T * 90 * BeamSpeed) % 360)
				render.StartBeam(20)
				for seg = 1, 20 do
					local segm = seg-1
					local sign = (BeamSet % 2) * 2 - 1
					render.AddBeam(start + (fow * (len * segm)) + ((math.sin(sign * b_ang) * right + math.cos(b_ang) * up):GetNormalized() * (math.sin(math.rad(segm * 9.4736842 * waves)) * len * amplitude * BeamSet)), width2, T, BeamColor[BeamSet])
				end
				render.EndBeam()
			end
		end
	end
end

