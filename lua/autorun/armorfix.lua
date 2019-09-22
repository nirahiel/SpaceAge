if SERVER then
	AddCSLuaFile()
	local hudaf = {}
	timer.Create("armorfix",0.4,0,function()
		for k,pl in pairs(player.GetAll()) do
			local userid = pl:UniqueID()
			if pl:Armor() ~= hudaf[userid] then
				pl:SetNetworkedInt("armor",pl:Armor())
				hudaf[userid] = pl:Armor()
			end
		end
	end);
	Msg("SERVER: Armor fix running.\n")
end

if CLIENT then
	local meta = FindMetaTable("Player")
	function meta:Armor()
		return self:GetNetworkedInt("armor")
	end
	Msg("Armor fix running.\n")
end
