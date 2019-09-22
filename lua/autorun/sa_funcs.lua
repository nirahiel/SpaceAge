if SERVER then
	AddCSLuaFile()
end

function SA.AddCommasToInt(str)
	str = string.reverse(tostring(math.floor(tonumber(str))))
	local len = string.len(str)
	local ret = ""
	for i=1,len do
		ret = ret .. string.sub(str,i,i)
		if((i%3) == 0) then
			ret = ret .. ","
		end
	end
	return string.reverse(ret)
end

function SA.GetPlayerByName(name)
	return nil
end

function SA.FormatTime(time)
	return "" .. time
end

function ValidEntity(ent)
	return ent and ent:IsValid()
end
