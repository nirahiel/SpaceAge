include("shared.lua")
language.Add("pyrothium_injector", "Pyrothium Injector")

DEFINE_BASECLASS("sa_base_rd3_entity")

local mat = Material("trails/laser")
local sprite = Material("sprites/animglow02")

local segmentCount = 50


-- Function to interpolate colors between two given colors
local function interpolateColors(colorStart, colorEnd, segments)
	-- Extract color components for start color
	local rStart, gStart, bStart, aStart = colorStart:Unpack()

	-- Extract color components for end color
	local rEnd, gEnd, bEnd, aEnd = colorEnd:Unpack()

	-- Initialize table to store interpolated colors
	local interpolatedColors = {}

	-- Calculate incremental change for each color component
	local rIncrement = (rEnd - rStart) / segments
	local gIncrement = (gEnd - gStart) / segments
	local bIncrement = (bEnd - bStart) / segments
	local aIncrement = (aEnd - aStart) / segments

	-- Generate interpolated colors for each segment
	for i = 0, segments - 1 do
		local r = rStart + (i * rIncrement)
		local g = gStart + (i * gIncrement)
		local b = bStart + (i * bIncrement)
		local a = aStart + (i * aIncrement)

		-- Round the color components to integers
		r = math.Round(r)
		g = math.Round(g)
		b = math.Round(b)
		a = math.Round(a)

		-- Add interpolated color to the table
		table.insert(interpolatedColors, Color(r, g, b, a))
	end

	return interpolatedColors
end

local BeamColors = interpolateColors(Color(255, 0, 0, 255), Color(255, 255, 0), segmentCount)

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
	self.segmentCount = 30
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

local function cyclic_counter(current_time, max_value)
    local cycle_length = max_value * 2 - 2
    local current_cycle_position = current_time % cycle_length
    if current_cycle_position < max_value then
        return current_cycle_position + 1
    else
        return max_value - (current_cycle_position - max_value)
    end
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

		local len = start:Distance(endPos) / (segmentCount - 1)

		local T = RealTime()
		local waves = 1
		local amplitude = 2
		local BeamCount = 6

		render.SetMaterial(mat)
		for Beam = 1, BeamCount do
				render.StartBeam(segmentCount)
				for seg = 1, segmentCount do
					local b_ang = math.rad(((Beam * (360 / BeamCount)) + T * 45 - seg * 10) % 360)
					local segm = seg-1
					render.AddBeam(start + (fow * (len * segm)) + ((math.sin(b_ang) * right + math.cos(b_ang) * up):GetNormalized() * (math.sin(math.rad(segm * (180 / segmentCount) * waves)) * len * amplitude)), width2, T, BeamColors[cyclic_counter(math.floor(T * 20) - segm, segmentCount)])
				end
				render.EndBeam()
			end
	end
end

