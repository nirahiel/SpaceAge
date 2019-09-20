local data, isok, merror

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

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

SA_MaxNameLength = 24
SA_PlayersToShow = 30

local function SendStatsUpdateRes(data, isok, merror, ply)
	if (!isok) then print(merror) return end
	local i = 0
	local imax = table.maxn(data)
	if imax <= 0 then return end
	umsg.Start("sa_statsdrawing",ply)
		umsg.Bool(false)
	umsg.End()
	for i=1,imax do
		umsg.Start("sa_statsupdate",ply)
				umsg.Long(i)
				umsg.String(string.Left(data[i]["name"],SA_MaxNameLength))
				umsg.String(data[i]["score"])
				umsg.String(data[i]["groupname"])
		umsg.End()
	end
	umsg.Start("sa_statsdrawing",ply)
		umsg.Bool(true)
	umsg.End()
end

function SA_SendStatsUpdate(ply)
	MySQL:Query("SELECT name, score, groupname FROM players ORDER BY score DESC LIMIT 0,"..tostring(SA_PlayersToShow), SendStatsUpdateRes, ply)
end