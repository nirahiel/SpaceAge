print("FFI Load", pcall(require, "ffi"))

SA.Random = {}

local function mkAlphabet(chars)
	local tbl = {}
	local len = chars:len()
	for i = 1, len do
		table.insert(tbl, chars:sub(i, i))
	end
	return tbl, len
end
local alphabet, alphabetLen = mkAlphabet("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/")

local randomres, randomresSize
if ffi then
	ffi.cdef [[
		struct RandomResult { int32_t value; };
		size_t getrandom(void *buf, size_t buflen, unsigned int flags);
	]]

	if ffi.C.getrandom then
		randomres = ffi.new("struct RandomResult")
		randomresSize = ffi.sizeof(randomres)

		function SA.Random.String(len)
			local res = {}
			local buf = ffi.new("char[" .. len .. "]")
			ffi.C.getrandom(buf, len, 0)
			for i = 1, len do
				local x = (buf[i] % alphabetLen) + 1
				table.insert(res, alphabet[x])
			end
			return table.concat(res)
		end
	end
end

if not SA.Random.String then
	function SA.Random.String(len)
		local res = {}
		for i = 1, len do
			local x = math.random(1, alphabetLen)
			table.insert(res, alphabet[x])
		end
		return table.concat(res)
	end
end

local function ReseedRandom()
	local seed = os.time() + math.random(-2147483647, 2147483647)
	if randomres then
		ffi.C.getrandom(randomres, randomresSize, 0)
		seed = seed + randomres.value
	end
	math.randomseed(seed)
end
ReseedRandom()
timer.Create("SA_ReseedRandom", 10, 0, ReseedRandom)
