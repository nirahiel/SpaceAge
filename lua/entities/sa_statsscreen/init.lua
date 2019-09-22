AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

require("supernet")

ENT.WireDebugName = "SpaceAge Stats Display"

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local ent = ents.Create("sa_statsscreen")
	ent:SetModel("models/props/cs_assault/Billboard.mdl")
	ent:SetPos(tr.HitPos + Vector(0,0,100))
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
end

function ENT:Use()
end

function ENT:Think()
end

local SA_MaxNameLength = 24
local SA_PlayersToShow = 30

local function SendStatsUpdateRes(data, isok, merror, ply)
	if (!isok) then print(merror) return end
	local i = 0
	local imax = table.maxn(data)
	if imax <= 0 then return end

	supernet.Send(ply, "SA_StatsUpdate", data)
end

function SA_SendStatsUpdate(ply)
	SA.MySQL:Query("SELECT name, score, groupname FROM players ORDER BY score DESC LIMIT 0,"..tostring(SA_PlayersToShow), SendStatsUpdateRes, ply)
end
