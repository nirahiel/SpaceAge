local function PlyAFKSet(enabled)
	if enabled then
		hook.Add("SA_HUDPaintDirect", "SA_AFK_HUDPaintDirect", function()
			local scrW = ScrW()
			local scrH = ScrH()

			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(0,0,scrW,scrH)

			local afkText = "You have been marked AFK. Move around to return."
			surface.SetFont("DermaLarge")
			surface.SetTextColor(255,0,0,255)
			local tw, th = surface.GetTextSize(afkText)
			surface.SetTextPos((scrW - tw) / 2, (scrH - th) / 2)
			surface.DrawText(afkText)
		end)
	else
		hook.Remove("SA_HUDPaintDirect", "SA_AFK_HUDPaintDirect")
	end
end

net.Receive("SA_AFK_Set", function()
	PlyAFKSet(net.ReadBool())
end)
