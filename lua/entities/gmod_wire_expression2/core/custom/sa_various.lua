--glualint:ignore-file
E2Lib.RegisterExtension("sa_various", false)

local Clamp = math.Clamp

__e2setcost(1)
e2function string number:format()
	return SA.AddCommasToInt(this)
end

e2function void selectTerminalNode(entity node)
	self.player.SelectedNode = node
end

__e2setcost(10)
e2function number entity:playtime()
	if not (this and IsValid(this) and this:IsPlayer() and this.sa_data.playtime) then return -1 end
	return this.sa_data.playtime
end

e2function number playtime()
	return self.player.sa_data.playtime
end
