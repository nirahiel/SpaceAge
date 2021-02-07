include("shared.lua")

language.Add("sa_mining_laser", "Mining Laser")

DEFINE_BASECLASS("sa_base_rd3_entity")

local mat = Material("trails/laser")
local sprite = Material("sprites/animglow02")
local BeamColor = {Color(255, 0, 0, 255), Color(0, 255, 0, 255), Color(0, 0, 255, 255)}

local CalcColorTbl = {
	function(level) return Color(255, 255 - math.floor(level * 0.85), 0) end,
	function(level) return Color(255, 0, math.floor(level * 0.85)) end,
	function(level) return Color(255 - math.floor(level * 0.85), 0, 255) end,
	function(level) return Color(0, math.floor(level * 0.85), 255) end,
	function(level) return Color(0, 255, 255 - math.floor(level * 0.85)) end,
	function(level) return Color(math.floor(level * 0.85), 255, math.floor(level * 0.85)) end,
}

function ENT:Think()
	BaseClass.Think(self)

	if not self.rank then
		return
	end

	local level = self:GetNWInt("level")
	if level ~= self.LastLevel then
		self.LastLevel = level
		self.LaserColor = CalcColorTbl[self.rank](level)
		self.LaserWidth = self.BeamWidthOffset + math.floor(level / 10)
	end

	local tr = SA.LaserTraceCalc(self)
	self.hitIs = tr and IsValid(tr.Entity) and tr.Entity:GetClass() == "sa_roid"
end

function ENT:CalcColor(level)
	return Color(255, 255 - math.floor(level * 0.85), 0)
end

function ENT:Draw()
	BaseClass.Draw(self)

	if not self.hitPos then
		return
	end

	local color = self.LaserColor
	local width = self.LaserWidth
	local width2 = width / 2
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

		render.SetMaterial(mat)
		for Beam = 1, 3 do
			local b_ang = math.rad(((Beam * 120) + T * 90) % 360)
			render.StartBeam(20)
			for seg = 1, 20 do
				local segm = seg-1
				render.AddBeam(start + (up * (len * segm)) + ((math.sin(b_ang) * right + math.cos(b_ang) * fow):GetNormalized() * (math.sin(math.rad(segm * 9.4736842)) * len / 2)), width2, T, BeamColor[Beam])
			end
			render.EndBeam()
		end
	end
end
