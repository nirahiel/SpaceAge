--glualint:ignore-file
E2Lib.RegisterExtension("sa_tts", false)

local TTS_MAX_LENGTH = 256

__e2setcost(50)
e2function void playTTS(string text)
	if text:len() > TTS_MAX_LENGTH then
		error("TTS is limited to 256 characters!", 2)
		return
	end

	http.Post("https://api.spaceage.mp/tts/mp3", { q = text }, function (body, length, headers, code)
		if code ~= 200 then
			return
		end
		local url = body

		net.Start("SA_TTS_PlayURL")
			net.WriteString(url)
			net.WriteVector(self.entity:GetPos())
		net.Broadcast()
	end)
end

util.AddNetworkString("SA_TTS_PlayURL")
