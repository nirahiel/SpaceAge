AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS("base_gmodentity")

local RD = CAF.GetAddon("Resource Distribution")
local SA_TheWorld

function ENT:SpawnFunction(ply, tr)
	if (not tr.Hit) then return end
	local ent = ents.Create("sa_tibrefinery")
	ent:SetPos(tr.HitPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	if self:KillIfSpawned() then return end

	self.SkipSBChecks = true

	if not SA_TheWorld then
		SA_TheWorld = ents.FindByClass("worldspawn")[1]
	end

	self:SetModel("models/slyfo/sat_rtankstand.mdl")
	self.TouchTable = {}
	--self.TouchNetTable = {}
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if (not phys:IsValid()) then return end
	phys:SetMass(50000)
	phys:EnableMotion(false)
end

function ENT:StartTouch(ent)
	if ent.IsTiberiumStorage and ent:GetResourceAmount("tiberium") >= 0 then
		local attachPlace = SA.Tiberium.FindFreeAttachPlace(ent, self)
		if not attachPlace then return end
		if not SA.Tiberium.AttachStorage(ent, self, attachPlace) then return end
		RD.Unlink(ent)
		ent.TibRefineWeld = constraint.Weld(ent, self, 0, 0, false)
		ent.TibRefineAmount = ent:GetResourceAmount("tiberium")
		ent:ConsumeResource("tiberium", ent.TibRefineAmount)
		self.TouchTable[attachPlace] = ent
	end
end

function ENT:Think()
	BaseClass.Think(self)
	for k, v in pairs(self.TouchTable) do
		if not IsValid(v) or not v.IsTiberiumStorage then
			self.TouchTable[k] = nil
			continue
		end
		RD.Unlink(v)
		local ply = v:CPPIGetOwner()
		if IsValid(ply) and ply:IsPlayer() then
			local taken = v.TibRefineAmount
			if taken > 10000 then
				taken = 10000
			end
			v.TibRefineAmount = v.TibRefineAmount - taken
			if taken <= 0 then
				v.TibRefineAmount = nil
				if IsValid(v.TibStorageWeld) then
					v.TibStorageWeld:Remove()
					v.TibStorageWeld = nil
				else
					v:Remove()
				end
				self.TouchTable[k] = nil
			else
				local creds = math.Round(taken * 25)
				if ply.sa_data.faction_name == "corporation" or ply.sa_data.faction_name == "alliance" then
					creds = math.ceil((creds * 1.33) * 1000) / 1000
				end
				ply.sa_data.credits = ply.sa_data.credits + creds
				ply.sa_data.score = ply.sa_data.score + creds
				SA.SendBasicInfo(ply)
			end
		else
			v:Remove()
			self.TouchTable[k] = nil
		end
	end
	self:NextThink(CurTime() + 0.1)
	return true
end
