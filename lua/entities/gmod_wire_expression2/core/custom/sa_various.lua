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
