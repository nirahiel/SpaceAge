if (CLIENT) then return end

AddCSLuaFile("sh_PM.lua")
AddCSLuaFile("cl_PM_ODEDrawer.lua")
include("sh_PM.lua")

SA_PM.Ore.Spawned = {}
SA_PM.Ore.InitiallySpawned = {}

SA_PM.Ore.DEBUG_Spawned = {}

SA_PM.Debugging = false

//resource.AddFile("materials/vgui/sa/battery_fg.vmt")
//resource.AddFile("materials/vgui/sa/battery_fg.vmf")
//resource.AddFile("materials/vgui/sa/battery_bg.vmt")
//resource.AddFile("materials/vgui/sa/battery_bg.vmf")

function SA_PM.LoadOres()
	local Cont = file.Read("Spaceage/PM_Ores/"..game.GetMap()..".txt")
	
	if (Cont == nil) then
		ErrorNoHalt("[SA-PM] Error loading Spaceage PM file... Does it exist?\n")
		return
	end
	
	local Arr = util.KeyValuesToTable(Cont)
	for name,planet in pairs(Arr) do
		SA_PM.SpawnOres(name, planet)
	end
	print("[SA-PM] Loaded PM ore file for this map.")
end
hook.Add("InitPostEntity", "SA_PM_SpawnOres_Init", function() SA_PM.LoadOres() end)

function SA_PM.OnPlayerSpawn(ply)
	ply:Give("sa_planetmining_ode")
end
hook.Add("PlayerSpawn", "SA_PM_PlayerSpawn", function(ply) SA_PM.OnPlayerSpawn(ply) end)

function SA_PM.ReplenishOres()
	for k, v in pairs(SA_PM.Ore.Spawned) do
		if (SA_PM.Debugging) then
			local debugEnt = SA_PM.Ore.DEBUG_Spawned[k]
			if (debugEnt == nil or !IsValid(debugEnt)) then
				debugEnt = ents.Create("sa_planetmining_debug_prop")
				debugEnt:SetPos(v.Pos)
				debugEnt:Spawn()
				
				debugEnt:SetColor(SA_PM.Ore.Types[v.Type].Color)
				debugEnt:SetDensity(v.Density)
				//print(v.Density)
				SA_PM.Ore.DEBUG_Spawned[k] = debugEnt;
			end
		end
		
		local initial = SA_PM.Ore.InitiallySpawned[k]
		if (v.Density < initial.Density) then
			if ((v.Density / initial.Density) < 0.25) then
				local inc = SA_PM.Ore.Types[v.Type].MaxSize / 1000
				v.Density = math.Min(v.Density + inc, initial.Density)
			end
		end
		if (SA_PM.Debugging) then
			local debugEnt = SA_PM.Ore.DEBUG_Spawned[k]
			if (debugEnt == nil or !IsValid(debugEnt)) then
				debugEnt:SetDensity(v.Density)
			end
		end
	end
end
timer.Create("SA_PM_ReplenishOres", 5, 0, SA_PM.ReplenishOres)

function SA_PM.SpawnOres(name, planet)
	local Position = Vector(tonumber(planet.position.x), tonumber(planet.position.y), tonumber(planet.position.z))
	local Rad = planet.radius
	local MaxAlt = planet.alt
	local Ores = planet.ores
	local Min = planet.mincount
	local Max = planet.maxcount
	
	local Total = math.random(Min, Max)
	for ore,perc in pairs(Ores) do
		local Ore = tonumber(ore)
		local Num = (tonumber(perc) * Total)
		local Count = 0
		local Type = SA_PM.Ore.Types[Ore]
		local Depth = math.min(Type.MinDepth, MaxAlt)
		
		while (Count < Num) do
			local density = math.random(Type.MinSize, Type.MaxSize)
			local RandVec = (Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, (-Depth - density - 50) / Rad)):Normalize() * math.random(0, Rad))

			if ((RandVec.z + density) < Depth and RandVec:Length() <= Rad) then
				local pos = Position + RandVec
				table.insert(SA_PM.Ore.Spawned, {Pos = pos, Density = density, Type = Ore})
				table.insert(SA_PM.Ore.InitiallySpawned, {Pos = pos, Density = density, Type = Ore})
				//table.insert(SA_PM.Ore.DEBUG_Spawned, nil)
				Count = Count + 1
			end
		end
	end
end

function SA_PM.FindBestOreInArray(pos, arr)
	local lastDist = 999999
	local lastRarity = 0
	local lastOre = nil
	
	for _,v in pairs(arr) do
		local Rarity = SA_PM.Ore.Types[v.Type].Rarity
		if (Rarity > lastRarity) then
			lastRarity = Rarity
		end
	end
	
	for _,v in pairs(arr) do
		local Rarity = SA_PM.Ore.Types[v.Type].Rarity
		if (Rarity == lastRarity) then
			local dist = v.Pos:Distance(pos)
			if (dist < lastDist) then
				lastOre = v
				lastDist = dist
			end
		end
	end
	
	return lastOre
end

function SA_PM.FindOreInSphere(pos, range)
	local Ret = {}
	for _,v in pairs(SA_PM.Ore.Spawned) do
		if (v.Pos:Distance(pos) < range) then
			table.insert(Ret, v)
		end
	end
	return Ret
end
function SA_PM.FindOreInBox(min, max)
	local Ret = {}
	for _,v in pairs(SA_PM.Ore.Spawned) do
		local pos = v.Pos
		if (pos.x > min.x and pos.y > min.y and pos.z > min.z
			and pos.x < max.x and pos.y < max.y and pos.z < max.z) then
			table.insert(Ret, v)
		end
	end
	return Ret
end

function SA_PM.FindPlayersWithODE()
	local Ret = {}
	for _,v in pairs(ents.FindByClass("player")) do
		if (v and v:IsValid()) then
			local Wep = v:GetActiveWeapon()
			if (Wep and Wep:IsValid()) then
				if (Wep:GetClass() == "sa_planetmining_ode" and Wep.Active) then
					table.insert(Ret, v)
				end
			end
		end
	end
	return Ret
end

function SA_PM.SendOreToPlayer(ply, Wep)
	if (ply and ply:IsValid()) then
		local Pos = ply:GetPos()
		local min = Vector(-Wep.ScanXRange * 2, -Wep.ScanYRange * 2, -Wep.DepthSelect * 2) + Pos
		local max = Vector(Wep.ScanXRange * 2, Wep.ScanYRange * 2, 0) + Pos
		local Points = SA_PM.FindOreInBox(min, max)
		datastream.StreamToClients(ply, "SA_ODE_Points", Points)
	end
end

function SA_PM.SendOreToPlayerScreen(ply, screen)
	if (screen and screen:IsValid()) then
		local Pos = screen:GetPos()
		local min = Vector(-screen.ScanXRange, -screen.ScanYRange, -screen.DepthSelect) + Pos
		local max = Vector(screen.ScanXRange, screen.ScanYRange, 0) + Pos
		local Points = SA_PM.FindOreInBox(min, max)
		datastream.StreamToClients(ply, "SA_ODE_Points", Points)
	end
end

function SA_PM.SendOreToPlayerRadar(ent)
	if (ent and ent:IsValid()) then
		local Pos = ent:GetPos()
		local Points = table.Copy(SA_PM.FindOreInSphere(Pos, ent.Range))
		for k, v in pairs(Points) do
			v.Density = v.Density * ((math.Rand(-0.5, 1.0) * ent.OffsetMult) + 1)
			v.Pos = SA_PM.randomOffset(v.Pos, v.Density, v.Density * ((5 * ent.OffsetMult) + 1))
		end
		table.insert(Points, 1, ent:EntIndex())
		datastream.StreamToClients(player.GetAll(), "SA_ODE_Points_Radar", Points)
	end
end

function SA_PM.randomOffset(Pos, Size, DisplaySize)
    Ret = Vector(Pos.x, Pos.y, Pos.z)
    Ret = Ret + (VectorRand() * math.Rand(0, DisplaySize - Size))
    return Ret
end

function SA_PM.GetRefinedResource(raw)
	local Arr = SA_PM.Ref.Types[raw]
	return Arr.Name, Arr.Amount
end