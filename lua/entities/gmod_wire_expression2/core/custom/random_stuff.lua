local Clamp = math.Clamp

e2function string number:format()
	return AddCommasToInt(this)
end

e2function void selectTerminalNode(entity node)
	self.player.SelectedNode = node
end