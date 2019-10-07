if SERVER then
	AddCSLuaFile()
	return
end

local function IsOkay(ent)
	if SA.ValidEntity(ent) and ent:GetClass() == "iceroid" then
		return false
	end

	return true
end

local function FilterTable(tbl)
	if not tbl then return tbl end

	local out = {}
	for _, ent in pairs(tbl) do
		if IsOkay(ent) then
			table.insert(out, ent)
		end
	end
	return out
end

local function OverwriteTableFunc(idx, tbl)
	if not tbl then tbl = ents end

	local old = tbl[idx]
	tbl[idx] = function(...)
		return FilterTable(old(...))
	end
end

local function OverwriteSingleFunc(idx, tbl)
	if not tbl then tbl = ents end

	local old = tbl[idx]
	tbl[idx] = function(...)
		local ent = old(...)
		if IsOkay(ent) then
			return ent
		end
		return NULL
	end
end

OverwriteTableFunc("FindByModel")
OverwriteTableFunc("FindByClass")
OverwriteTableFunc("FindInBox")
OverwriteTableFunc("FindInCone")
OverwriteTableFunc("FindInSphere")
OverwriteTableFunc("GetAll")

OverwriteSingleFunc("GetByIndex")
OverwriteSingleFunc("Entity", _G)
