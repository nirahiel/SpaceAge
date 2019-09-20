if (SERVER) then return end

include("sh_PM.lua")

local Res = 256
local Off = 32
local RT, Mat

local ScanX = 10000
local ScanY = 10000
local NeedsClear = false
local lastCol = nil

local Ores = {}
local ScreenData = {}

function UpdateScreen()
	if (!LocalPlayer() and !LocalPlayer():IsValid()) then return end
	local Wep = LocalPlayer():GetActiveWeapon()
	if (Wep:GetClass() != "sa_planetmining_ode") then return end
	
	ScreenData = {}
	local Ang = Angle(0, LocalPlayer():EyeAngles().y + 90, 0)
	local Pos = LocalPlayer():GetPos()
	local Dir = Vector(0, 0, 0)
	
	local CountXY = (Res / Wep.Resolution)
	
	for X=0, (Res / Wep.Resolution) - 1 do
		ScreenData[X] = {}
		for Y=0, (Res / Wep.Resolution) - 1 do
			local ScreenXPosWorld = -(((X / CountXY) * (Wep.ScanXRange * 2)) - (Wep.ScanXRange)) //-((((X - 1) / (Res / Wep.Resolution)) * (Wep.ScanXRange * 1)) - (0.5 * Wep.ScanXRange))
			local ScreenYPosWorld = -((Y / CountXY) * (Wep.ScanZRange)) //-(((Y - 1) / (Res / Wep.Resolution)) * (Wep.ScanZRange))
			
			Dir.x = ScreenXPosWorld
			Dir.y = 0
			Dir.z = ScreenYPosWorld
			Dir:Rotate(Ang)
			Dir = Dir + Vector(Pos.x, Pos.y, Pos.z)

			local BR = 0
			local BG = 0
			local BB = 0
			for _,v in pairs(Ores) do
				local Pos2 = v.Pos
				local Density = v.Density
				local XD = (math.abs(Pos2.x - Dir.x) / 1) //(math.abs((Pos2.x - (Density / 2)) - Dir.x) / 1)
				local YD = (math.abs(Pos2.y - Dir.y) / 1) //(math.abs((Pos2.y - (Density / 2)) - Dir.y) / 1)
				local ZD = (math.abs(Pos2.z - Dir.z) / 1) //(math.abs((Pos2.z - (Density / 2)) - Dir.z) / 1)
				if (XD < (Density + Wep.ScanXRange)) then //(Wep.ScanXRange * 2)) then
					if (YD < (Density + Wep.ScanYRange)) then //(Wep.ScanYRange * 2)) then
						if (ZD < (Density + Wep.ScanZRange)) then //(Wep.ScanZRange * 2)) then
							local XDist = XD
							local ZDist = ZD
							local YDist = YD
							//                                math.sqrt
							//local Perc = math.max((Density - (math.sqrt((XDist * XDist) + (YDist * YDist) + (ZDist * ZDist)))) / Density, 0)
							local Dist = math.sqrt((XDist * XDist) + (YDist * YDist) + (ZDist * ZDist))
							local Perc = math.max(1 - (Dist / Density), 0)
							local Type = SA_PM.Ore.Types[v.Type].Color
							BR = math.min(BR + math.max((Perc * (Type.r / 255) / 4), 0), 1)
							BG = math.min(BG + math.max((Perc * (Type.g / 255) / 4), 0), 1)
							BB = math.min(BB + math.max((Perc * (Type.b / 255) / 4), 0), 1)
						end
					end
				end
			end
			ScreenData[X][Y] = Color(math.floor(BR * 255), math.floor(BG * 255), math.floor(BB * 255))
		end
	end
end

local Ang = Angle(0, 0, 0)
local Pos = Vector(0, 0, 0)
local Dir = Vector(0, 0, 0)
local ScreenXPosWorld = 0
local ScreenYPosWorld = 0

Dir.x = ScreenXPosWorld
Dir.y = 0
Dir.z = ScreenYPosWorld
Dir:Rotate(Ang)
Dir = Dir + Vector(Pos.x, Pos.y, Pos.z)

function UpdateScreenPoint(X, Y)
	if (!LocalPlayer() and !LocalPlayer():IsValid()) then return end
	local Wep = LocalPlayer():GetActiveWeapon()
	if (Wep:GetClass() != "sa_planetmining_ode") then return end
	
	//ScreenData = {}
	//local Ang = Angle(0, LocalPlayer():EyeAngles().y + 90, 0)
	//local Pos = LocalPlayer():GetPos()
	//local Dir = Vector(0, 0, 0)
	
	if (!ScreenData[X]) then
		ScreenData[X] = {}
	end
	
	local ScreenXPosWorld = -(((X - 1) / (Res / Wep.Resolution)) * (Wep.ScanXRange * 1)) + (0.5 * Wep.ScanXRange)
	local ScreenYPosWorld = -(((Y - 1) / (Res / Wep.Resolution)) * (Wep.ScanZRange))
	Dir.x = ScreenXPosWorld
	Dir.y = 0
	Dir.z = ScreenYPosWorld
	Dir:Rotate(Ang)
	Dir = Dir + Vector(Pos.x, Pos.y, Pos.z)
	
	local I = ((((math.floor(X / 2) + math.floor(Y / 2)) % 2) == 0) and 0.1 or 0)
	local BR = I
	local BG = I
	local BB = I
	for _,v in pairs(Ores) do
		local Pos2 = v.Pos
		local Density = v.Density
		local XD = (math.abs((Pos2.x/* + (Density / 2)*/) - Dir.x) / 1)
		local YD = (math.abs((Pos2.y/* + (Density / 2)*/) - Dir.y) / 1)
		local ZD = (math.abs((Pos2.z/* + (Density / 2)*/) - Dir.z) / 1)
		if (XD < Wep.ScanXRange) then
			if (YD < Wep.ScanYRange) then
				if (ZD < Wep.ScanZRange) then
					local XDist = XD
					local ZDist = ZD
					local YDist = YD
					//                                math.sqrt
					local Perc = math.max((Density - (math.sqrt((XDist * XDist) + (YDist * YDist) + (ZDist * ZDist)))) / (Density / 1), 0)
					local Type = SA_PM.Ore.Types[v.Type].Color
					BR = math.min(BR + math.max((Perc * (Type.r / 255) / 1), 0), 1)
					BG = math.min(BG + math.max((Perc * (Type.g / 255) / 1), 0), 1)
					BB = math.min(BB + math.max((Perc * (Type.b / 255) / 1), 0), 1)
				end
			end
		end
	end
	ScreenData[X][Y] = Color(math.floor(BR * 255), math.floor(BG * 255), math.floor(BB * 255))
end

function ReceivePoints(handl, id, en, dec)
	Ores = dec
	//UpdateScreen()
	
	local Wep = LocalPlayer():GetActiveWeapon()
	if (Wep:GetClass() != "sa_planetmining_ode") then return end
	
	//print(table.Count(ScreenData))
	if (table.Count(ScreenData) == 0) then
		for X=1, (Res / Wep.Resolution + 1) do
			ScreenData[X] = {}
			for Y=1, (Res / Wep.Resolution + 1) do
				ScreenData[X][Y] = Color(0, 0, 0, 255)
			end
		end
	end
	
	Ang = Angle(0, LocalPlayer():EyeAngles().y + 90, 0)
	Pos = LocalPlayer():GetPos()
	Dir = Vector(0, 0, 0)
	
	ScanX = 0
	ScanY = 0
	NeedsClear = true
	lastCol = nil
end
datastream.Hook("SA_ODE_Points", ReceivePoints)

local BatteryTexFG
local BatteryTexBG
local BatteryWidth = 64
local BatteryHeight = BatteryWidth / 4
local BGFlashCount = 0
local BGToggle = true

function DrawODEBattery(Weapon)
	BGFlashCount = BGFlashCount + 1
	if (Weapon.Battery < (0.15 * Weapon.MaxBattery) and BGFlashCount >= 50) then
		BGToggle = !BGToggle
		BGFlashCount = 0
	elseif (Weapon.Battery > (0.15 * Weapon.MaxBattery)) then
		BGToggle = true
		BGFlashCount = 0
	end
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(BatteryTexBG)
	surface.DrawTexturedRect(2 + Off, 2, BatteryWidth, BatteryHeight)
	
	if (BGToggle) then
		render.SetScissorRect(Off, 2, BatteryWidth * (Weapon.Battery / Weapon.MaxBattery) + Off, BatteryHeight + 2, true)
		surface.SetDrawColor(50, 250, 50, 255)
		surface.SetTexture(BatteryTexFG)
		surface.DrawTexturedRect(Off, 2, BatteryWidth, BatteryHeight)
	end
	render.SetScissorRect(0, 0, Res, Res, false)
end

function DrawODEHUD(Wep)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect(0 + Off, 0 + Off, Res - 0 - 1 - (Off * 1), Res - 0 - (Off * 1))
	surface.DrawOutlinedRect(1 + Off, 1 + Off, Res - 2 - 1 - (Off * 1), Res - 2 - (Off * 1))
	surface.DrawOutlinedRect(2 + Off, 2 + Off, Res - 4 - 1 - (Off * 1), Res - 4 - (Off * 1))

	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(0, 0, Off, Res)
	surface.DrawRect(0, 0, Res, Off)
	
	surface.SetDrawColor(255, 255, 255, 255)
	
	local numLinesY = 10
	local Inc = ((Res - Off) / (Wep.ScanZRange * 1)) * (Wep.ScanZRange / numLinesY)
	for I=0, (numLinesY - 1) do
		local Depth = (I * (Wep.ScanZRange / numLinesY))
		draw.SimpleText(math.floor(Depth), "UiBold", Off - 2, (Inc * I) - 1 + Off, Color(255,255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
		surface.DrawRect(Off + 2, (Inc * I) - 1 + Off, 10, 2)
	end
	
	local numLinesX = 6
	Inc = ((Res - Off) / (Wep.ScanXRange * 1)) * (Wep.ScanXRange / numLinesX)
	for I=-((numLinesX / 2) - 1), ((numLinesX / 2) - 1) do
		local Depth = (I * (Wep.ScanXRange / numLinesX))
		draw.SimpleText(math.floor(Depth), "UiBold", (Inc * I) - 1 + Off + ((Res / 2) - (Off / 2)), Off, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		surface.DrawRect((Inc * I) - 1 + Off + ((Res / 2) - (Off / 2)), Off + 2, 2, 10)
	end
end


local EvalDots = ""
local EvalDotsTimes = 0
function DrawODEProgressBar(Weapon)
	EvalDotsTimes = EvalDotsTimes + 1
	if (EvalDotsTimes > 80) then
		EvalDotsTimes = 0
		EvalDots = EvalDots .. "."
	end
	if (string.len(EvalDots) > 3) then
		EvalDots = ""
	end
	
	draw.SimpleText("Evaluating" .. EvalDots, "Trebuchet24", math.floor(Res * 0.5), math.floor(Res * 0.75) - 30, Color(255, 255, 255, 255), 1, 0)
	
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawRect(math.floor(Res * 0.25), math.floor(Res * 0.75), math.ceil(Res * 0.5), 16)
	
	surface.SetDrawColor(50, 50, 50, 255)
	surface.DrawRect(math.floor(Res * 0.25) + 1, math.floor(Res * 0.75) + 1, (math.ceil(Res * 0.5) - 2) * (Weapon.Progress / 100), 16 - 2)
end

function DrawODEView()
	if (RT == nil) then
		RT = GetRenderTarget("GModToolgunScreen", Res, Res)
		Mat = Material("models/weapons/v_toolgun/screen")
		Mat:SetMaterialTexture("$basetexture", RT)
		BatteryTexFG = surface.GetTextureID("vgui/sa/battery_fg")
		BatteryTexBG = surface.GetTextureID("vgui/sa/battery_bg")
		print(BatteryTexFG)
		print(BatteryTexBG)
	end
	
	if (!LocalPlayer() or !LocalPlayer():IsValid()) then return end
	local Weapon = LocalPlayer():GetActiveWeapon()
	if (!Weapon or !Weapon:IsValid()) then return end
	if (Weapon:GetClass() != "sa_planetmining_ode") then return end
	
	local SX = ScrW()
	local SY = ScrH()
	local oldRender = render.GetRenderTarget()
	
    render.SetRenderTarget(RT)
	render.SetViewPort(0, 0, Res, Res)
    cam.Start2D()
		if (NeedsClear) then
			render.Clear(0, 0, 0, 255)
			NeedsClear = false
		end
		if (Weapon.Active) then
			if (table.Count(ScreenData) != 0) then
				local steps = (16 / (Weapon.Resolution / 2)) / 2;
				steps = steps * steps
				for I = 1, steps do
					if (ScanX < (Res / Weapon.Resolution)) then
						if (ScanY < (Res / Weapon.Resolution)) then
							UpdateScreenPoint(ScanX, ScanY)
							UpdateScreenPoint(ScanX + 1, ScanY + 1)
							
							local X = ScanX
							local Y = ScanY
							//ErrorNoHalt(X..", "..Y)
							//local arr1 = ScreenData[X + 1]
							//local arr2 = arr1[Y + 1]
							//if (!(arr1 == nil or arr2 == nil)) then
								local Brightness = ScreenData[X + 1][Y + 1]
								if (lastCol != nil) then
									surface.SetDrawColor(lastCol.r, lastCol.g, lastCol.b, 255)
									surface.DrawRect((X - 1) * Weapon.Resolution + Off, (Y - 1) * Weapon.Resolution + Off, Weapon.Resolution, Weapon.Resolution)
								end
								lastCol = Brightness
								surface.SetDrawColor(150, 150, 150, 255) //92, 255, 92, 255)
								surface.DrawRect(X * Weapon.Resolution + Off, Y * Weapon.Resolution + Off, Weapon.Resolution, Weapon.Resolution)
								ScanX = ScanX + 1
								if (ScanX >= (Res / Weapon.Resolution)) then
									ScanX = 0
									ScanY = ScanY + 1
								end
							//end
						end
					end
				end
			end
			if (Weapon.Progress != -1) then
				NeedsClear = true
				DrawODEProgressBar(Weapon)
				LastProgressing = true
			end
			DrawODEHUD(Weapon)
			DrawODEBattery(Weapon)
		else
			NeedsClear = true
		end
	cam.End2D()
	render.SetViewPort(0, 0, SX, SY)
	render.SetRenderTarget(oldRender)
end
hook.Add("RenderScene", "TestDrawODE", DrawODEView)