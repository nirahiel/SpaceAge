TOOL.Tab = "Utilities"
TOOL.Category = "Admin"
TOOL.Name = "Contraption Analyzer"
TOOL.Command = nil
TOOL.ConfigName = ""

if (CLIENT) then
	language.Add("tool.contraption_analyzer.name", "Contraption Analyzer")
	language.Add("tool.contraption_analyzer.desc", "Tells you about freezing/parenting status of props")
	language.Add("tool.contraption_analyzer.0", "Left Click: Analyze Contraption. Right Click: Detailed Analyze Contraption.")
end

local function RunToolBase(tool, tr, categorizer)
	if CLIENT then
		return
	end

	local owner = tool:GetOwner()
	if not owner:IsAdmin() then
		owner:ChatPrint("You are not authorized to use this.")
		return false
	end

	if not IsValid(tr.Entity) then
		owner:ChatPrint("Please point me at something...")
		return false
	end

	local entities = constraint.GetAllConstrainedEntities(tr.Entity)

	local result = {}
	for _, ent in pairs(entities) do
		local frozen = true
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			frozen = not phys:IsMotionEnabled()
		end
		local parented = ent:GetParent() ~= nil

		local cat = categorizer(ent)

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
end

local function categorizerGlobal()
	return "Contraption"
end

local function categorizerClass(ent)
	return ent:GetClass()
end

function TOOL:LeftClick(tr)
	local res = RunToolBase(self, tr, categorizerGlobal)
	if not res then
		return res
	end
end

function TOOL:RightClick(tr)
	local res = RunToolBase(self, tr, categorizerClass)
	if not res then
		return res
	end
end
