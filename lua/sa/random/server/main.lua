print("Random Load", pcall(require, "random"))

SA.Random = {}

if SecureRandomString then
	SA.Random.String = SecureRandomString
end

if not SA.Random.String then
	local function mkAlphabet(chars)
		local tbl = {}
		local len = chars:len()
		for i = 1, len do
			table.insert(tbl, chars:sub(i, i))
		end
		return tbl, len
	end
	local alphabet, alphabetLen = mkAlphabet("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

	function SA.Random.String(len, allowAllOrAlphabet)
		if allowAllOrAlphabet == true then
			local res = {}
			for i = 1, len do
				local x = math.random(0, 255)
				table.insert(res, string.char(x))
			end
			return table.concat(res)
		end

		local thisAlphabet, thisAlphabetLen = alphabet, alphabetLen
		if allowAllOrAlphabet then
			thisAlphabet, thisAlphabetLen = mkAlphabet(allowAllOrAlphabet)
		end

		local res = {}
		for i = 1, len do
			local x = math.random(1, thisAlphabetLen)
			table.insert(res, thisAlphabet[x])
		end
		return table.concat(res)
	end
end

local function ReseedRandom()
	local seed = os.time() + math.random(-2147483647, 2147483647)
	if SecureRandomNumber then
		seed = seed + SecureRandomNumber(-2147483647, 2147483647)
	end
	math.randomseed(seed)
end
ReseedRandom()
timer.Create("SA_ReseedRandom", 10, 0, ReseedRandom)
