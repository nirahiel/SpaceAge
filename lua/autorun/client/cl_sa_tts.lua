local function PlayTTS()
	local url = net.ReadString()
	local pos = net.ReadVector()

	sound.PlayURL(url, "3d noplay", function(station)
		if not IsValid(station)  then
			return
		end

		station:SetPos(pos)
		station:Play()
	end)
end
net.Receive("E2_TTS_PlayURL", PlayTTS)
