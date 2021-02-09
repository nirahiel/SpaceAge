SA.REQUIRE("config")
SA.REQUIRE("teleporter.main")

local SA_TeleportLocs = {}

util.PrecacheModel("models/holograms/hq_icosphere.mdl")

function SA.Teleporter.GoTo(ply, key)
	local TeleTBL = SA_TeleportLocs[key]
	if not TeleTBL then ply:ChatPrint("INVALID TELEPORT LOCATION") return end

	local pos = table.Random(TeleTBL)
	ply:SetPos(pos)
	return pos
end

local function InitSATeleporters()
	for k, v in pairs(ents.FindByClass("sa_teleport_panel")) do
		v:Remove()
	end

	SA_TeleportLocs = {}

	local teleporters = SA.Config.Load("teleporters")
	if not teleporters then
		return
	end

	for name, config in pairs(teleporters) do
		local spawns = {}
		for _, spawn in pairs(config.Spawns) do
			table.insert(spawns, Vector(unpack(spawn)))
		end
		SA_TeleportLocs[name] = spawns

		for k, v in pairs(config.Panels) do
			local tele = ents.Create("sa_teleport_panel")
			tele:SetPos(Vector(unpack(v.Position)))
			tele:SetAngles(Angle(unpack(v.Angle)))
			tele:SetNWString("TeleKey", name)
			tele.TeleKey = name
			tele.Autospawned = true
			tele.CDSIgnore = true
			tele:Spawn()
		end
	end
end
timer.Simple(2, InitSATeleporters)

concommand.Add("sa_teleporter_do", function(ply, cmd, args)
	local teleporter = ply.AtTeleporter
	SA.Teleporter.Close(ply)

	if not (ply and ply.IsValid and ply:IsValid() and teleporter and teleporter:IsValid()) then ply:ChatPrint("NOT AT TELEPORTER") return end

	local TeleKey = args[1]
	if not TeleKey then ply:ChatPrint("NO TELEPORT LOCATION") return end

	if teleporter.TeleKey == TeleKey then ply:ChatPrint("CANT TELEPORT SAME") return end

	local oldPos = ply:GetPos()
	local pos = SA.Teleporter.GoTo(ply, TeleKey)

	sound.Play("ambient/levels/citadel/weapon_disintegrate1.wav", oldPos)
	sound.Play("ambient/levels/citadel/weapon_disintegrate1.wav", pos)
end)

function SA.Teleporter.Open(ply, ent)
	ply:Freeze(true)
	ply.AtTeleporter = ent
	net.Start("SA_Teleporter_Open")
		net.WriteEntity(ent)
	net.Send(ply)
end

function SA.Teleporter.Close(ply)
	net.Start("SA_Teleporter_Close")
	net.Send(ply)
	if not ply.AtTeleporter then return end
	ply:Freeze(false)
	ply.AtTeleporter = nil
end

concommand.Add("sa_teleporter_close", function (ply, cmd, args)
	SA.Teleporter.Close(ply)
end)
