print("RandomLoad", pcall(require, "random"))
local seed = os.time()
if SecureRandomNumber then
	seed = seed + SecureRandomNumber(0, 2147483647)
end
print("RandomSeed", seed)
math.randomseed(seed)
