AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")
util.PrecacheSound("tools/ifm/beep.wav")

local function OpenTerminal(ent, ply, founder)
	if CurTime() < ent.NextUse then return end
	ent.NextUse = CurTime() + 1
	if (ent:GetPos():Distance(SA.Terminal.GetStationPos()) > SA.Terminal.GetStationSize() and (not (founder and founder.sa_data.faction_name and founder.sa_data.research.rta[1] and (founder.sa_data.faction_name == "corporation" or founder.sa_data.faction_name == "alliance") and founder.sa_data.research.rta[1] > 1))) then ent:EmitSound("tools/ifm/beep.wav") ply:AddHint("RTA device out of range of station.", NOTIFY_CLEANUP, 5) return end
	if ply:GetPos():Distance(ent:GetPos()) > 1000 then ent:EmitSound("tools/ifm/beep.wav") ply:AddHint("Too far away from RTA device.", NOTIFY_CLEANUP, 5) return end
	if ply.AtTerminal then return end
	if not ply.TempStorage then
		ply.TempStorage = {}
	end
	ply.AtTerminal = true
	SA.Terminal.SetVisible(ply, true)
	ply:Freeze(true)
	ply:ConCommand("sa_terminal_update")
end

function ENT:Initialize()
	self:SetModel("models/slyfo/rover_na_large.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.Inputs = Wire_CreateInputs(self, { "OpenTerminal" })
	self.NextUse = 0
end

function ENT:CAF_PostInit()
	self:CheckCanSpawn(self:GetTable().Founder)
end

function ENT:CheckCanSpawn(ply)
	if (ply.sa_data.research.rta[1] < 1) then
		SA.Research.RemoveEntityWithWarning(self, "rta", 1)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "OpenTerminal") and value ~= 0 then
		local ply = self:GetTable().Founder
		OpenTerminal(self, ply, ply)
	end
end

function ENT:Use(ply, called)
	OpenTerminal(self, ply, self:GetTable().Founder)
end
