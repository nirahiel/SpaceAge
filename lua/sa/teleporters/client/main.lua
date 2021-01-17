if SA.Teleporter then SA.Teleporter.Close() end

SA.Teleporter = {}

local screenW, screenH, screenFOV
local drawTeleporterUI = false
local drawnPlanets = {}
local lastMouseOverPlanet = nil

local MAX_MAP_SIZE = 300
local BIGGER_THAN_MAP = 9999999999

local SPHERE_MODEL = "models/holograms/hq_icosphere.mdl"
local SPHERE_MATERIAL = "models/wireframe"
local SPHERE_MODEL_SIZE = 12.0
local ZERO_ANGLE = Angle(0,0,0)
local ZERO_VECTOR = Vector(0,0,0)

local function MakePlanetModel(planetData)
	if planetData.model then
		planetData.model:Remove()
	end

	local mdl = ClientsideModel(SPHERE_MODEL, RENDERGROUP_OTHER)
	mdl:SetNoDraw(true)
	mdl:SetMaterial(SPHERE_MATERIAL)
	mdl:SetColor(planetData.color)
	mdl:SetPos(planetData.position)
	mdl:SetModelScale(planetData.size / SPHERE_MODEL_SIZE, 0)
	mdl:SetRenderMode(RENDERMODE_TRANSCOLOR)
	planetData.model = mdl
	return mdl
end

function SA.Teleporter.Open(ent)
	screenW = ScrW()
	screenH = ScrH()
	screenFOV = LocalPlayer():GetFOV()
	lastMouseOverPlanet = nil

	drawnPlanets = {}

	local otherLocations = {}
	local planetTeleporters = {}
	local planets = SA.SB.GetPlanets()

	local myPlanet = SA.SB.FindClosestPlanet(ent:GetPos(), false).name

	for _, otherEnt in pairs(ents.FindByClass("teleport_panel")) do
		local otherName = otherEnt:GetNWString("TeleKey")
		if not otherLocations[otherName] then
			local otherPlanet = SA.SB.FindClosestPlanet(otherEnt:GetPos(), false).name
			otherLocations[otherName] = otherPlanet
			planetTeleporters[otherPlanet] = otherName
		end
	end

	local maxPlanetCoord = Vector(-BIGGER_THAN_MAP,-BIGGER_THAN_MAP,-BIGGER_THAN_MAP)
	local minPlanetCoord = Vector(BIGGER_THAN_MAP,BIGGER_THAN_MAP,BIGGER_THAN_MAP)
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
	offset.x = (minPlanetCoord.x * scaleFactor) - 1000

	for _, planet in pairs(planets) do
		local size = planet.radius * 2.0 * scaleFactor

		local curModelPlanet = drawnPlanets[planet.name]

		if curModelPlanet and curModelPlanet.size >= size then
			continue
		end

		local teleporterName = planetTeleporters[planet.name]

		local isMyPlanet = planet.name == myPlanet

		local planetColor = Color(255,0,0,64)
		if isMyPlanet then
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
			oc = -position,
			oclen2 = position:LengthSqr(),

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

local function DrawTeleporterUI()
	if not drawTeleporterUI then return end

	local planetMouseOver = nil
	local planetMouseOverName = nil

	local cursorX, cursorY = gui.MousePos()
	local aimVector = util.AimVector(ZERO_ANGLE, screenFOV, cursorX, cursorY, screenW, screenH)

	-- u = aimVector
	-- c = planetData.position
	-- o = 0,0,0

	for _, planetData in pairs(drawnPlanets) do
		local r2 = planetData.r2
		local oc = planetData.oc
		local oclen2 = planetData.oclen2

		local uoc = aimVector:Dot(oc)

		local delta = (uoc * uoc) - (oclen2 - r2)
		if delta >= 0 then
			planetMouseOver = planetData
			planetMouseOverName = planetMouseOver.name
		end
	end

	if planetMouseOverName ~= lastMouseOverPlanet then
		lastMouseOverPlanet = planetMouseOverName
		if planetMouseOver then
			if planetMouseOver.canTeleportTo then
				surface.PlaySound("buttons/button15.wav")
			else
				surface.PlaySound("buttons/button10.wav")
			end
		end
	end

	cam.Start3D(ZERO_VECTOR, ZERO_ANGLE, screenFOV)
		for _, planetData in pairs(drawnPlanets) do
			if not planetData.textCenterPos then
				planetData.textCenterPos = (planetData.position + Vector(0, 0, -planetData.r)):ToScreen()
			end

			local mdl = planetData.model
			if not mdl then
				mdl = MakePlanetModel(planetData)
			end

			local col = mdl:GetColor()

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

	surface.SetFont("Trebuchet24")
	for _, planetData in pairs(drawnPlanets) do
		if not planetData.textPos then
			local w, h = surface.GetTextSize(planetData.label)
			local x = planetData.textCenterPos.x - (w / 2)
			local y = planetData.textCenterPos.y + 10
			planetData.textPos = {
				x = x,
				y = y,
				bx = x - 5,
				by = y - 5,
				bw = w + 10,
				bh = h + 10,
			}
		end

		draw.RoundedBox(8, planetData.textPos.bx, planetData.textPos.by, planetData.textPos.bw, planetData.textPos.bh, Color(0,0,0,128))

		surface.SetTextColor(planetData.drawColor.r, planetData.drawColor.g, planetData.drawColor.b)
		surface.SetTextPos(planetData.textPos.x, planetData.textPos.y)
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
