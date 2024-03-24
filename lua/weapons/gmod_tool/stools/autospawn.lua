TOOL.Tab = "Utilities"
TOOL.Category = "Admin"
TOOL.Name = "Autospawn"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" }
}

if (CLIENT) then
	language.Add("tool.autospawn.name", "Autospawn Special")
	language.Add("tool.autospawn.desc", "ASK DORIDIAN TO USE")
	language.Add("tool.autospawn.left", "Select entity")
	language.Add("tool.autospawn.right", "Add entities to autospawn")
	language.Add("tool.autospawn.reload", "Clear selection")
end
function TOOL:LeftClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsSuperAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if not owner.Autospawner2List then
		owner.Autospawner2List = {}
	end
		if tr.Entity then
			local ent = tr.Entity
			if ent:IsValid() and not ent.Autospawned and not ent.AutospawnSelected then
				local data = {
					x = ent:GetPos().x,
					y = ent:GetPos().y,
					z = ent:GetPos().z,
					pit = ent:GetAngles().p,
					yaw = ent:GetAngles().y,
					rol = ent:GetAngles().r,
					class = ent:GetClass(),
					model = ent:GetModel()
				}

				owner.Autospawner2List[ent:EntIndex()] = data
				ent:SetColor(Color(0, 255, 0, 150))
				ent.AutospawnSelected = true
				owner:ChatPrint("Selected")
				return true
			else
				owner.Autospawner2List[ent:EntIndex()] = nil
				ent:SetColor(color_white)
				ent.AutospawnSelected = false
				owner:ChatPrint("Deselected")
				return true
			end
		end
end

function TOOL:RightClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner:IsSuperAdmin() then owner:ChatPrint("You are not authorized to use this.") return false end
	if not file.IsDir("autospawn_tmp", "DATA") then
		file.CreateDir("autospawn_tmp")
	end
	local mapname = game.GetMap():lower()
	local filename = "autospawn_tmp/" .. mapname .. ".txt"

	local oldConfig = nil
	if file.Exists(filename, "DATA") then
		local oldfile = file.Read(filename, "DATA")
		oldConfig = util.JSONToTable(oldfile)
	else
		oldConfig = SA.Config.Load("autospawn")
	end
	if oldConfig then
		for _, v in pairs(oldConfig) do
			table.insert(owner.Autospawner2List, v)
		end
	end
	file.Write(filename, util.TableToJSON(owner.Autospawner2List))
	owner.Autospawner2List = {}
	owner:ChatPrint("Saved File")
end

function TOOL:Reload(tr)
	local owner = self:GetOwner()
	for k, v in pairs(owner.Autospawner2List) do if (v and v:IsValid()) then v:SetColor(color_white) end end
	owner.Autospawner2List = {}
	owner:ChatPrint("Cleared selection")
end
