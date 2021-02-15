AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)
	if not tr.Hit then return end
	local SpawnPos = tr.HitPos + Vector(0, 0, 100)
	local ent = ents.Create("sa_doorchecker")
	ent:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	ent:SetVisible(true)
	return ent
end

function ENT:FindEnvironment()
	if not IsValid(self.xenvironment) then
		local closestEnvironment = SA.FindClosestEnt(self:GetPos(), {"base_sb_environment_collider"})
		if not IsValid(closestEnvironment) then
			return
		end
		self.xenvironment = closestEnvironment.sbenv
	end
	return self.xenvironment
end

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self:SetVisible(false)

	self.isopen = false
	self.fullyopen = false
	self.fullyclosed = false
	self.blocked = false

	local xuuid = "sa_dchecker_" .. tostring(CurTime())

	self:Fire("addoutput", "targetname " .. xuuid, 0)

	local closestDoor = SA.FindClosestEnt(self:GetPos(), {"func_door", "func_movelinear"})

	if not IsValid(closestDoor) then
		print(self, "no door found!")
		self:Remove()
		return
	end

	closestDoor:Fire("addoutput", "OnAnimationBegun " .. xuuid .. ",xtabegun", 0)
	closestDoor:Fire("addoutput", "OnAnimationDone " .. xuuid .. ",xtadone", 0)
	closestDoor:Fire("addoutput", "OnOpen " .. xuuid .. ",xtopen", 0)
	closestDoor:Fire("addoutput", "OnClose " .. xuuid .. ",xtclose", 0)
	closestDoor:Fire("addoutput", "OnBlockedOpening " .. xuuid .. ",xtbopen", 0)
	closestDoor:Fire("addoutput", "OnBlockedClosing " .. xuuid .. ",xtbclose", 0)
	closestDoor:Fire("addoutput", "OnUnblockedOpening " .. xuuid .. ",xtubopen", 0)
	closestDoor:Fire("addoutput", "OnUnblockedClosing " .. xuuid .. ",xtubclose", 0)
	closestDoor:Fire("addoutput", "OnFullyOpen " .. xuuid .. ",xtfopen", 0)
	closestDoor:Fire("addoutput", "OnFullyClosed " .. xuuid .. ",xtfclose", 0)

	self.xent = closestDoor
	self.xenvironment = nil

	self:SetFully(false, true)
	self:SetBlocked(false)
end

function ENT:SetVisible(shown)
	if shown then
		self:SetNotSolid(false)
		self:DrawShadow(true)
		self:SetNoDraw(false)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
	else
		self:PhysicsInit(SOLID_NONE)
		self:SetMoveType(MOVETYPE_NONE)
		self:SetSolid(SOLID_NONE)
		self:SetNotSolid(true)
		self:DrawShadow(false)
		self:SetNoDraw(true)
	end
end

local InputSwitch = {
	xtopen = function(s) s:SetOpen(true) end,
	xtclose = function(s) s:SetOpen(false) end,
	xtbopen = function(s) s:SetOpen(false) s:SetBlocked(true) end,
	xtbclose = function(s) s:SetOpen(true) s:SetBlocked(true) end,
	xtubopen = function(s) s:SetOpen(true) s:SetBlocked(false) end,
	xtubclose = function(s) s:SetOpen(false) s:SetBlocked(false) end,
	xtfopen = function(s) s:SetFully(true) end,
	xtfclose = function(s) s:SetFully(false) end,
	xtabegun = function(s) s:SetOpen(not s.isopen) end,
	xtadone = function(s) s:SetFully(s.isopen) end,
}

function ENT:AcceptInput(name, activator, caller)
	local case = InputSwitch[name]
	if case then
		case(self)
	end
end

function ENT:SetOpen(val, norefresh)
	self.fullyopen = false
	self.fullyclosed = false

	self.isopen = val

	if not norefresh then self:RefreshAtmo() end
end

function ENT:SetFully(val, norefresh)
	self:SetOpen(val, true)
	if val then
		self.fullyopen = true
	else
		self.fullyclosed = true
	end

	self:SetBlocked(false)

	if not norefresh then self:RefreshAtmo() end
end

function ENT:SetBlocked(val)
	self.blocked = val
end

function ENT:RefreshAtmo()
	local env = self:FindEnvironment()
	if not env then return end
	if self.isopen then
		SA.Planets.MakeSpace(env)
	elseif self.fullyclosed then
		SA.Planets.MakeHabitable(env)
	end
end
