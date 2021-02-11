local function PlyAFKSet(enabled)
	if enabled then
		hook.Add("HUDPaint", "SA_AFK_HUDPaint", function()
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
		hook.Remove("HUDPaint", "SA_AFK_HUDPaint")
	end
end

net.Receive("SA_AFK_Set", function()
	PlyAFKSet(net.ReadBool())
end)
