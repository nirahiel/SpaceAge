TOOL.Tab = "Utilities"
TOOL.Category = "Admin"
TOOL.Name = "Contraption Analyzer"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if CLIENT then
	language.Add("tool.contraption_analyzer.name", "Contraption Analyzer")
	language.Add("tool.contraption_analyzer.desc", "Tells you about freezing/parenting status of props")
	language.Add("tool.contraption_analyzer.left", "Analyze Contraption")
	language.Add("tool.contraption_analyzer.right", "Detailed Analyze Contraption")
	language.Add("tool.contraption_analyzer.reload", "Analyze all people's stuff")
end

local function RunToolBase(tool, tr, categorizer, finder)
	if CLIENT then
		return
	end

	local owner = tool:GetOwner()

	local entities
	if not finder then
		if not IsValid(tr.Entity) then
			owner:ChatPrint("Please point me at something...")
			return false
		end
		entities = constraint.GetAllConstrainedEntities(tr.Entity)
	else
		entities = finder(tr)
	end

	local result = {}
	for _, ent in pairs(entities) do
		local cat = categorizer(ent)
		if not cat then
			continue
		end

		local frozen = true
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			frozen = not phys:IsMotionEnabled()
		end
		local parented = IsValid(ent:GetParent())


		local num = result[cat]
		if not num then
			num = {
				numFree = 0,
				numParented = 0,
				numFrozen = 0,
				numFrozenAndParented = 0,
			}
			result[cat] = num
		end
		if frozen then
			if parented then
				num.numFrozenAndParented = num.numFrozenAndParented + 1
			else
				num.numFrozen = num.numFrozen + 1
			end
		elseif parented then
			num.numParented = num.numParented + 1
		else
			num.numFree = num.numFree + 1
		end
	end

	for cat, num in pairs(result) do
		owner:ChatPrint("[" .. cat .. "] " .. num.numFree .. " free; " .. num.numFrozen .. " just frozen; " .. num.numParented .. " just parented; " .. num.numFrozenAndParented .. " frozen and parented")
	end

	return true
end

local function categorizerGlobal()
	return "Contraption"
end

local function categorizerClass(ent)
	return ent:GetClass()
end

local function categorizerOwner(ent)
	local owner, ownerId = ent:CPPIGetOwner()
	if not ownerId then
		return nil
	end
	if not IsValid(owner) then
		return "Disconnected (" .. tostring(ownerId) .. ")"
	end
	return owner:GetName()
end

local function finderAll()
	return ents.GetAll()
end

function TOOL:LeftClick(tr)
	return RunToolBase(self, tr, categorizerGlobal)
end

function TOOL:RightClick(tr)
	return RunToolBase(self, tr, categorizerClass)
end

function TOOL:Reload(tr)
	local owner = self:GetOwner()
	if not IsValid(owner) then
		return false
	end
	if not owner:IsAdmin() then
		owner:ChatPrint("Admin only feature")
		return false
	end
	return RunToolBase(self, tr, categorizerOwner, finderAll)
end
