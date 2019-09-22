if SERVER then
	AddCSLuaFile()
end

if not Color then
	function Color(r, g, b, a)
		if not a then a = 255 end
		return {r=r,g=g,b=b,a=a}
	end
end
