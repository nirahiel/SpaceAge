--glualint:ignore-file
AddCSLuaFile("autorun/client/cl_sa_tts.lua")

E2Lib.RegisterExtension("sa_tts", false)

__e2setcost(50)
e2function void playTTS(string text)
	http.Post("https://tts.spaceage.mp/make.php", { q = text }, function (body, length, headers, code)
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
