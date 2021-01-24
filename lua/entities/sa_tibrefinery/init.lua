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
	if ent.IsTiberiumStorage and (ent:GetResourceAmount("tiberium") >= 0) then
		local attachPlace = SA.Tiberium.FindFreeAttachPlace(ent, self)
		if not attachPlace then return end
		if not SA.Tiberium.AttachStorage(ent, self, attachPlace) then return end
		constraint.Weld(ent, SA_TheWorld, 0, 0, false)
		self.TouchTable[attachPlace] = ent
		--local tmp = RD.GetEntityTable(ent)
		--self.TouchNetTable[ent:EntIndex()] = tmp.network
		RD.Unlink(ent)
	end
end

function ENT:Think()
	BaseClass.Think(self)
	for k, v in pairs(self.TouchTable) do
		if not v.IsTiberiumStorage then
			self.TouchTable[k] = nil
			continue
		end
		RD.Unlink(v)
		local ply = SA.PP.GetOwner(v)
		if ply and ply:IsValid() and ply:IsPlayer() then
			local am = v:GetResourceAmount("tiberium")
			local taken = 10000
			if am < taken then taken = am end
			if taken <= 0 then
				v:Remove()
				self.TouchTable[k] = nil
			else
				v:ConsumeResource("tiberium", taken)
				local creds = math.Round(taken * (math.random(20, 30)))
				if ply.sa_data.faction_name == "corporation" or ply.sa_data.faction_name == "alliance" then
					creds = math.ceil((creds * 1.33) * 1000) / 1000
				elseif ply.sa_data.faction_name == "starfleet" then
					creds = math.ceil((creds * 1.11) * 1000) / 1000
				end
				ply.sa_data.credits = ply.sa_data.credits + creds
				if ply.sa_data.score > 100000000 then
					if ply.sa_data.faction_name  == "legion" then
						creds = creds * 0.5
					else
						creds = creds * 0.4
					end
				end
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
