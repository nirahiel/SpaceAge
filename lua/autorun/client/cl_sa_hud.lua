local alwaysshowtemp = CreateClientConVar("cl_sa_always_show_temperature",0,true,false)

local function hidehud(name)
	if name == "CHudHealth" or name == "CHudBattery" or name == "CHudAmmo" or name == "CHudSecondaryAmmo" or name == "CustFiremode" then
		return false
	end
end
hook.Add("HUDShouldDraw", "hidehud", hidehud)

local GlobalTemp_Min = 0
local GlobalTemp_Max = 600
local FairTemp_Min = 283
local FairTemp_Max = 308
local ls_habitat = 0
local ls_air = 0
local ls_tmp = 0
local ls_coolant = 0
local ls_energy = 0

local function LS_umsg_hook1( um )
	ls_habitat = um:ReadFloat()
	ls_air = um:ReadShort()
	ls_tmp = um:ReadShort()
	ls_coolant = um:ReadShort()
	ls_energy = um:ReadShort()
end

local function LS_umsg_hook2( um )
	ls_air = um:ReadShort()
end

local function CheckHookIn()
	if not ConVarExists("LS_Display_HUD") then
		return
	end
	RunConsoleCommand("LS_Display_HUD", "0")
	usermessage.Hook("LS_umsg1", LS_umsg_hook1)
	usermessage.Hook("LS_umsg2", LS_umsg_hook2)
	timer.Destroy("SA_CheckHUDHookIn")
	print("SA HUD loaded...")
end
timer.Create("SA_CheckHUDHookIn", 1, 0, CheckHookIn)

local HUDFont = "Default"

local SA_HUDBlink = true
timer.Create("SA_HUDBlink",0.5,0,function() SA_HUDBlink = not SA_HUDBlink end)

timer.Destroy("SA_HealthBarRed")
local SA_HealthBarRed = 0
timer.Create("SA_HealthBarRed",0.01,0,function() 
	if SA_HealthBarRed > 0 then
		SA_HealthBarRed = SA_HealthBarRed - 2
		if SA_HealthBarRed < 0 then SA_HealthBarRed = 0 end
	end
end)
local SA_LastHealth = 0

local function DrawLSBar(BarNum,CaptionX,Value,ScH,ScW,ColBack,ColText)
	local Caption = CAF.GetLangVar(CaptionX)
	local BarHei = 30
	local BarSpace = 5
	local BarWid = 440
	local RealBarWid = BarWid - 70
	local Hei = (ScH - 120) - (BarNum * (BarHei + BarSpace))
	local XMinX = (ScW - BarWid) / 2
	
	draw.RoundedBox(4, XMinX, Hei, BarWid, BarHei, ColBack)
	draw.SimpleText(Caption, HUDFont, XMinX + 8, Hei + (BarHei / 2), ColText, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	local Perc = Value / 4000
	
	local ValCol = Color(255*(1-Perc),255*Perc,0,255)
	
	if Value > 0 then
		local XWid = (BarWid - 154)  * Perc
		XWid = math.Max(XWid,4)
		draw.RoundedBox(4, XMinX + 150, Hei + 4, XWid, BarHei - 8, ValCol)
		draw.SimpleText(tostring(Perc*100).." %", HUDFont, XMinX + 70, Hei + (BarHei / 2), ValCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	else
		if not SA_HUDBlink then ValCol = Color(0,0,0,0) end
		draw.SimpleText("EMPTY", HUDFont, XMinX + 70, Hei + (BarHei / 2), ValCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	end
end

local WeaponMaxAmmo = {}
WeaponMaxAmmo["weapon_pistol"] = 18
WeaponMaxAmmo["weapon_357"] = 6
WeaponMaxAmmo["weapon_smg1"] = 45
WeaponMaxAmmo["weapon_ar2"] = 30
WeaponMaxAmmo["weapon_shotgun"] = 6
WeaponMaxAmmo["weapon_crossbow"] = 1
WeaponMaxAmmo["weapon_frag"] = 0
WeaponMaxAmmo["weapon_rpg"] = 0
WeaponMaxAmmo["weapon_crowbar"] = 0
WeaponMaxAmmo["weapon_physcannon"] = 0
WeaponMaxAmmo["weapon_physgun"] = 0

local function GetMaxAmmo(SWEP)
	if SWEP.Primary and SWEP.Primary.ClipSize then
		return SWEP.Primary.ClipSize
	end
	
	local MAmmo = WeaponMaxAmmo[SWEP:GetClass()]
	if MAmmo then return MAmmo end
	
	LocalPlayer():ChatPrint("UNKOWN WEAPON: "..SWEP:GetClass() .. "|" .. tostring(SWEP:Clip1()))
	
	return SWEP:Clip1()
end

local function SA_CustomHUDPaint()
	if GetConVarNumber("cl_drawhud") == 0 then return end
	if not LocalPlayer():Alive() then return end
	local SWEP = LocalPlayer():GetActiveWeapon()
	if not (SWEP and SWEP.IsValid and SWEP:IsValid()) then return end
	if SWEP:GetClass() == "gmod_camera" then return end
	
	local ScH = ScrH()
	local ScW = ScrW()
	
	local primAmmo = LocalPlayer():GetAmmoCount(SWEP:GetPrimaryAmmoType())
	local secAmmo = LocalPlayer():GetAmmoCount(SWEP:GetSecondaryAmmoType())
	local primMaxAmmo = GetMaxAmmo(SWEP)
	
	if LocalPlayer():Health() < SA_LastHealth then
		SA_HealthBarRed = 255
	end
	SA_LastHealth = LocalPlayer():Health()
	
	local HUDGrey = Color(0,0,0,175)
	local HUDHealth = Color(SA_HealthBarRed,255-SA_HealthBarRed,0,255)
	local HUDArmor = Color(255,0,0,255)
	local HUDAmmo1 = Color(255,255,0,255)
	local HUDAmmo2 = Color(255,128,0,255)
	
	draw.RoundedBox(4, ScW - 80, ScH - 340, 60, 320, HUDGrey)
	if primMaxAmmo > 0 then
		draw.RoundedBox(4, ScW - 142, ScH - 240, 60, 220, HUDGrey)
	elseif primAmmo > 0 and secAmmo > 0 then
		draw.RoundedBox(4, ScW - 142, ScH - 60, 60, 40, HUDGrey)
	elseif primAmmo > 0 then
		draw.RoundedBox(4, ScW - 142, ScH - 40, 60, 20, HUDGrey)
	end
	
	--BEGIN OF HEALTH AND ARMOR
	
	local HeightMul = 290
	local Inset = 40
	if LocalPlayer():Armor() > 0 then
		HeightMul = 274
		Inset = 56
	end
	
	local PlRelX = LocalPlayer():Health() / 100
	if PlRelX > 1 then PlRelX = 1 end
	local PlHeightX = math.Max(PlRelX * HeightMul, 4)
	draw.RoundedBox(4, ScW - 70, (ScH - Inset) - PlHeightX, 40, PlHeightX, HUDHealth)
	draw.SimpleText(LocalPlayer():Health(), HUDFont, ScW - 50, ScH - 38, HUDHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	if(LocalPlayer():Armor() > 0) then
		local PlRelX = LocalPlayer():Armor() / 100
		if PlRelX > 1 then PlRelX = 1 end
		local PlHeightX = math.Max(PlRelX * HeightMul, 4)	
		draw.RoundedBox(2, ScW - 70, (ScH - Inset) - PlHeightX, 10, PlHeightX, HUDArmor)
		draw.SimpleText(LocalPlayer():Armor(), HUDFont, ScW - 50, ScH - 54, HUDArmor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	--END OF HEALTH AND ARMOR
	
	--BEGIN OF AMMO
	local HeightMul = 190
	local Inset = 40
	if secAmmo > 0 then
		HeightMul = 174
		Inset = 56
	end
	local primAmmoX = SWEP:Clip1()
	if primMaxAmmo > 0 and primAmmoX > 0 then
		local OneAmmoH = (HeightMul / primMaxAmmo) - 3
		local i = 0
		surface.SetDrawColor(HUDAmmo1)
		for i = 1,primAmmoX,1 do
			local PlRelX = i / primMaxAmmo
			if PlRelX > 1 then PlRelX = 1 end
			local PlHeightX = PlRelX * HeightMul
			surface.DrawRect(ScW - 132, (ScH - Inset) - PlHeightX, 40, OneAmmoH)
		end
	end
	if primAmmo > 0 or secAmmo > 0 or primAmmoX > 0 then
		draw.SimpleText(primAmmo, HUDFont, ScW - 112, ScH - 38, HUDAmmo1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	if secAmmo > 0 then
		draw.SimpleText(secAmmo, HUDFont, ScW - 112, ScH - 54, HUDAmmo2, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	--END OF AMMO

	local ls_current_unhabitable
	if ls_habitat < 5 then
		ls_current_unhabitable = true
	else
		if ls_tmp <= 0 then
			ls_current_unhabitable = false
		else
			if ls_tmp < FairTemp_Min then
				ls_current_unhabitable = true
			elseif ls_tmp > FairTemp_Max then
				ls_current_unhabitable = true
			else
				ls_current_unhabitable = false
			end
		end
	end
	
	--BEGIN OF TEMPERATURE
	if ls_current_unhabitable or alwaysshowtemp:GetBool() then
		local tempUnit = " K"
		
		local GlobalTemp_Max = 600
		local FairTemp_Mid = (FairTemp_Min + FairTemp_Max) / 2
		
		local coolTemp = Color(0,0,255,255)
		local hotTemp = Color(255,0,0,255)
		local goodTemp = Color(0,255,0,255)
		
		local XMinX = (ScW - 388) / 2
		draw.RoundedBox(4, XMinX - 26, ScH - 120, 440, 100, HUDGrey)
		
		local Perc = math.Clamp(FairTemp_Mid / GlobalTemp_Max, 0, 1)
		local Wid = Perc * 390
		draw.RoundedBox(4, (ScW - 390) / 2, ScH - 90, Wid, 40, coolTemp)
		draw.RoundedBox(4, Wid + XMinX, ScH - 90, 390 - Wid, 40, hotTemp)

		local Perc = math.Clamp(FairTemp_Min / GlobalTemp_Max, 0, 1)
		local Wid = Perc * 390
		local Perc2 = math.Clamp(FairTemp_Max / GlobalTemp_Max, 0, 1)
		local Wid2 = math.Clamp(Perc2 - Perc, 0, 1) * 390
		
		surface.SetDrawColor(goodTemp)
		surface.DrawRect(XMinX + Wid, ScH - 90, Wid2, 40)
		
		local textSlider = surface.GetTextureID("vgui/slider")
		surface.SetTexture(textSlider)
		surface.SetDrawColor(255,255,255,255)
		
		local Perc = math.Clamp(ls_tmp / GlobalTemp_Max, 0, 1)
		local Wid = Perc * 390
		local XWidX = XMinX + Wid
		
		surface.DrawTexturedRect(XWidX - 8, ScH - 98, 16, 16)
		
		local xMyTemp = goodTemp
		if ls_tmp < FairTemp_Min then xMyTemp = coolTemp
		elseif ls_tmp > FairTemp_Max then xMyTemp = hotTemp end
		draw.SimpleText(tostring(ls_tmp)..tempUnit, HUDFont, XWidX, ScH - 115, xMyTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		
		draw.SimpleText(tostring(GlobalTemp_Min)..tempUnit, HUDFont, XMinX, ScH - 45, coolTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		draw.SimpleText(tostring(GlobalTemp_Max)..tempUnit, HUDFont, (XMinX + 390), ScH - 45, hotTemp, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
	end
	--END OF TEMPERATURE
	
	local BarNum = 0
	local ColText = Color(255,255,0,255)
	if ls_current_unhabitable or LocalPlayer():WaterLevel() > 2 then
		BarNum = BarNum + 1
		DrawLSBar(BarNum,"Air",ls_air,ScH,ScW,HUDGrey,ColText)
		if ls_tmp < FairTemp_Min then
			BarNum = BarNum + 1
			DrawLSBar(BarNum,"Energy",ls_energy,ScH,ScW,HUDGrey,ColText)
		elseif ls_tmp > FairTemp_Max then
			BarNum = BarNum + 1
			DrawLSBar(BarNum,"Coolant",ls_coolant,ScH,ScW,HUDGrey,ColText)
		end
	end
end
hook.Add("HUDPaint", "SA_CustomHUDPaint", SA_CustomHUDPaint)
