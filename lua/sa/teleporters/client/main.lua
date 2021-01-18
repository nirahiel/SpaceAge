if SA.Teleporter then SA.Teleporter.Close() end

SA.Teleporter = {}

local FONT = "Trebuchet24"
local SPHERE_MODEL = "models/holograms/hq_icosphere.mdl"
local SPHERE_MATERIAL = "models/wireframe"
local SPHERE_MODEL_SIZE = 12.0
local ZERO_ANGLE = Angle(0,0,0)
local ZERO_VECTOR = Vector(0,0,0)

local screenW, screenH, screenFOV
local drawTeleporterUI = false
local drawnPlanets = {}
local drawAngle = ZERO_ANGLE
local drawLastTime

local MAX_MAP_SIZE = 300
local BIGGER_THAN_MAP = 9999999999

function LOLANGLE(ang)
	drawAngle = ang
end

local function MakePlanetModel(planetData)
	if planetData.model then
		planetData.model:Remove()
	end

	local mdl = ClientsideModel(SPHERE_MODEL, RENDERGROUP_OTHER)
	mdl:SetNoDraw(true)
	mdl:SetMaterial(SPHERE_MATERIAL)
	mdl:SetPos(planetData.position)
	mdl:SetModelScale(planetData.size / SPHERE_MODEL_SIZE, 0)
	mdl:SetRenderMode(RENDERMODE_TRANSCOLOR)
	planetData.model = mdl
	return mdl
end

function SA.Teleporter.Open(ent)
	screenW = ScrW()
	screenH = ScrH()
	screenFOV = 75 --LocalPlayer():GetFOV()
	lastDrawAngle = nil
	drawLastTime = RealTime()

	drawnPlanets = {}

	local otherLocations = {}
	local planetTeleporters = {}
	local planets = table.Copy(SA.SB.GetPlanets())

	local myPlanet = SA.SB.FindClosestPlanet(ent:GetPos(), false).name

	for _, otherEnt in pairs(ents.FindByClass("teleport_panel")) do
		local otherName = otherEnt:GetNWString("TeleKey")
		if not otherLocations[otherName] then
			local otherPlanet = SA.SB.FindClosestPlanet(otherEnt:GetPos(), false).name
			otherLocations[otherName] = otherPlanet
			planetTeleporters[otherPlanet] = otherName
		end
	end

	--[[
	local stars = SA.SB.GetStars()
	for k, star in pairs(stars) do
		planets[k] = {
			isStar = true,
			radius = star.Radius,
			position = star.Position,
			name = star.name,
		}
	end
	]]

	maxPlanetCoord = Vector(-BIGGER_THAN_MAP,-BIGGER_THAN_MAP,-BIGGER_THAN_MAP)
	minPlanetCoord = Vector(BIGGER_THAN_MAP,BIGGER_THAN_MAP,BIGGER_THAN_MAP)
	for _, planet in pairs(planets) do
		if planet.position.x > maxPlanetCoord.x then
			maxPlanetCoord.x = planet.position.x
		end
		if planet.position.y > maxPlanetCoord.y then
			maxPlanetCoord.y = planet.position.y
		end
		if planet.position.z > maxPlanetCoord.z then
			maxPlanetCoord.z = planet.position.z
		end
		if planet.position.x < minPlanetCoord.x then
			minPlanetCoord.x = planet.position.x
		end
		if planet.position.y < minPlanetCoord.y then
			minPlanetCoord.y = planet.position.y
		end
		if planet.position.z < minPlanetCoord.z then
			minPlanetCoord.z = planet.position.z
		end
	end

	local planetSizeGrid = maxPlanetCoord - minPlanetCoord
	local maxMapDimension = planetSizeGrid.x
	if planetSizeGrid.y > maxMapDimension then
		maxMapDimension  = planetSizeGrid.y
	end
	if planetSizeGrid.z > maxMapDimension then
		maxMapDimension  = planetSizeGrid.z
	end

	local scaleFactor = MAX_MAP_SIZE / maxMapDimension

	local offset = ((maxPlanetCoord + minPlanetCoord) / 2) * scaleFactor

	for _, planet in pairs(planets) do
		if IsValid(planet.ent) and planet.ent:GetColor() == Color(255,0,0,255) then
			continue
		end

		local size = planet.radius * 2.0 * scaleFactor

		local curModelPlanet = drawnPlanets[planet.name]

		if curModelPlanet and curModelPlanet.size >= size then
			continue
		end

		local teleporterName = planetTeleporters[planet.name]

		local isMyPlanet = planet.name == myPlanet

		local planetColor = Color(255,0,0,64)
		if planet.isStar then
			planetColor = Color(255,255,0,128)
		elseif isMyPlanet then
			planetColor = Color(0,0,255,64)
		elseif teleporterName then
			planetColor = Color(0,255,0,64)
		end

		local position = (planet.position * scaleFactor) - offset
		local r = size / 2.0

		local label = planet.name
		if teleporterName then
			label = label .. " (" .. teleporterName .. ")"
		end

		local planetData = {
			position = position,
			size = size,

			r = r,
			r2 = r * r,

			name = planet.name,
			teleporterName = teleporterName,
			canTeleportTo = teleporterName and not isMyPlanet,
			label = label,

			color = planetColor,
		}
		drawnPlanets[planet.name] = planetData
	end

	drawTeleporterUI = true
	gui.EnableScreenClicker(true)
end

function SA.Teleporter.Close(dontNotifyServer)
	if not dontNotifyServer then
		RunConsoleCommand("sa_teleporter_close")
	end

	if not drawTeleporterUI then return end

	drawTeleporterUI = false
	for _, planetData in pairs(drawnPlanets) do
		if planetData.model then
			planetData.model:Remove()
		end
	end
	drawnPlanets = {}

	gui.EnableScreenClicker(false)
end

local dragStartAngle, dragStartX, dragStartY

local function DrawTeleporterUI()
	if not drawTeleporterUI then return end

	local curTime = RealTime()
	local timeDelta = curTime - drawLastTime
	drawLastTime = curTime

	local cursorX, cursorY = gui.MousePos()

	if input.IsMouseDown(MOUSE_RIGHT) then
		local offX = (cursorX / screenW) - 0.5
		local offY = (cursorY / screenH) - 0.5
		if not dragStartAngle then
			dragStartAngle = drawAngle
			dragStartX = offX
			dragStartY = offY
		end
		offX = offX - dragStartX
		offY = offY - dragStartY
		drawAngle = dragStartAngle + Angle(offY * 360, offX * 360, 0)
	else
		dragStartAngle = nil
		drawAngle = Angle(drawAngle.p, drawAngle.y + (timeDelta * 5.0), drawAngle.r)
	end

	local planetMouseOver = nil

	local aimVector = util.AimVector(drawAngle, screenFOV, cursorX, cursorY, screenW, screenH)

	local origin = drawAngle:Forward() * -1000

	-- u = aimVector
	-- c = planetData.position
	-- o = origin

	for _, planetData in pairs(drawnPlanets) do
		local r2 = planetData.r2
		local oc = origin - planetData.position
		local oclen2 = oc:LengthSqr()
		planetData.oclen2 = oclen2

		local uoc = aimVector:Dot(oc)

		local delta = (uoc * uoc) - (oclen2 - r2)

		if planetData.textBoxPos and
			cursorX >= planetData.textBoxPos.x1 and
			cursorX <= planetData.textBoxPos.x2 and
			cursorY >= planetData.textBoxPos.y1 and
			cursorY <= planetData.textBoxPos.y2 then
				delta = 9999
		end

		if delta < 0 then
			continue
		end

		local isPreferred = false
		if planetMouseOver then
			if not planetData.canTeleportTo and planetMouseOver.canTeleportTo then
				continue
			end

			if planetData.canTeleportTo and not planetMouseOver.canTeleportTo then
				isPreferred = true
			end

			if planetMouseOver.oclen2 > oclen2 then
				isPreferred = true
			end
		else
			isPreferred = true
		end

		if isPreferred then
			planetMouseOver = planetData
		end
	end

	cam.Start3D(origin, drawAngle, screenFOV)
		for _, planetData in pairs(drawnPlanets) do
			local bv = Vector(0, 0, -planetData.r)
			bv:Rotate(drawAngle)
			planetData.textCenterPos = (planetData.position + bv):ToScreen()

			local mdl = planetData.model
			if not mdl then
				mdl = MakePlanetModel(planetData)
			end

			local col = planetData.color

			if planetMouseOver == planetData then
				if planetData.canTeleportTo then
					col = Color(255,255,0,64)
				else
					col = Color(255,128,0,64)
				end
			end

			planetData.drawColor = col

			render.SetColorModulation(col.r / 255, col.g / 255, col.b / 255)
			render.SetBlend(col.a / 255)
			mdl:DrawModel()
		end
	cam.End3D()

	surface.SetFont(FONT)
	for _, planetData in pairs(drawnPlanets) do
		local w, h
		if planetData.textSize then
			w = planetData.textSize.w
			h = planetData.textSize.h
		else
			w, h = surface.GetTextSize(planetData.label)
			planetData.textSize = {
				w = w,
				h = h,
			}
		end

		local x = planetData.textCenterPos.x - (w / 2)
		local y = planetData.textCenterPos.y + 10

		local bw = w + 10
		local bh = h + 10
		local bx = x - 5
		local by = y - 5

		planetData.textBoxPos = {
			x1 = bx,
			x2 = bx + bw,
			y1 = by,
			y2 = by + bh,
		}

		draw.RoundedBox(8, bx, by, bw, bh, Color(0,0,0,128))

		surface.SetTextColor(planetData.drawColor.r, planetData.drawColor.g, planetData.drawColor.b)
		surface.SetTextPos(x, y)
		surface.DrawText(planetData.label)
	end

	if input.IsMouseDown(MOUSE_LEFT) then
		if planetMouseOver and planetMouseOver.canTeleportTo then
			SA.Teleporter.Close(true)
			RunConsoleCommand("sa_teleporter_do", planetMouseOver.teleporterName)
		else
			SA.Teleporter.Close()
		end
	end
end
hook.Add("HUDPaint", "SA_HUDPaint_TeleporterUI", DrawTeleporterUI)

net.Receive("SA_Teleporter_Open", function()
	SA.Teleporter.Open(net.ReadEntity())
end)
net.Receive("SA_Teleporter_Close", function()
	SA.Teleporter.Close(true)
end)
