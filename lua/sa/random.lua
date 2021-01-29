print("FFI Load", pcall(require, "ffi"))

local randomres, randomresSize
if ffi then
	ffi.cdef [[
		struct RandomResult { int32_t value; };
		size_t getrandom(void *buf, size_t buflen, unsigned int flags);
	]]

	randomres = ffi.new("struct RandomResult")
	randomresSize = ffi.sizeof(randomres)
end

local function ReseedRandom()
	local seed = os.time() + math.random(-2147483647, 2147483647)
	if ffi then
		ffi.C.getrandom(randomres, randomresSize, 0)
		seed = seed + randomres.value
	end
	math.randomseed(seed)
end
ReseedRandom()
timer.Create("SA_ReseedRandom", 10, 0, ReseedRandom)
