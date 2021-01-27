print("RandomLoad", pcall(require, "random"))

local function ReseedRandom()
	local seed = os.time()
	if SecureRandomNumber then
		seed = seed + SecureRandomNumber(0, 2147483647)
	end
	math.randomseed(seed)
end
ReseedRandom()
timer.Create("SA_ReseedRandom", 10, 0, ReseedRandom)
