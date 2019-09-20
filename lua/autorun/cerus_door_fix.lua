if SERVER then
	AddCSLuaFile("autorun/cerus_door_fix.lua")
end

local OldIsValidModel = util.IsValidModel
function util.IsValidModel(path)
    if string.find(path,"/modbridge/misc/doors/",1,true) then return true end
    return OldIsValidModel(path)
end
