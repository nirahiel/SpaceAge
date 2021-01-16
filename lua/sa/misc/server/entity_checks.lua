local EntityMeta = FindMetaTable("Entity")

function EntityMeta:KillIfSpawned()
	local myPl = self:GetTable().Founder
	if myPl and myPl:IsPlayer() and not myPl:IsSuperAdmin() then
		myPl:Kill()
		self.RespawnDelay = 0
		self:Remove()
	end
end
