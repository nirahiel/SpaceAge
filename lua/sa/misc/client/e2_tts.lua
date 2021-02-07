local playingSounds = {}

local MAX_TTS_DIST = 2000

MAX_TTS_DIST = MAX_TTS_DIST * MAX_TTS_DIST -- squared distance!

local function CleanupTTS()
	local stillPlaying = {}
	for _, v in pairs(playingSounds) do
		if v:GetState() ~= GMOD_CHANNEL_STOPPED then
			table.insert(stillPlaying, v)
		end
	end
	playingSounds = stillPlaying
end
timer.Create("SA_TTS_Cleanup", 10, 0, CleanupTTS)

local function PlayTTS()
	local url = net.ReadString()
	local is3d = net.ReadBool()

	local pos
	if is3d then
		pos = net.ReadVector()
	end

	if pos:DistToSqr(LocalPlayer():GetPos()) > MAX_TTS_DIST then
		return
	end

	local mode = "noplay"
	if is3d then
		mode = "3d noplay"
	end

	sound.PlayURL(url, mode, function(station)
		if not IsValid(station)  then
			return
		end

		if is3d then
			station:SetPos(pos)
		end
		station:Play()

		table.insert(playingSounds, station)
	end)
end
net.Receive("SA_TTS_PlayURL", PlayTTS)
