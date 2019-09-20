TOOL.Category = 'Administration'
TOOL.Name = 'Prop Autospawn Special'
TOOL.Command = nil
TOOL.ConfigName = ''
TOOL.Tab = "Administration"

if ( CLIENT ) then
	language.Add('Tool_autospawn2_name', 'Autospawn Special')
	language.Add('Tool_autospawn2_desc', 'ASK DORIDIAN TO USE')
	language.Add('Tool_autospawn2_0', 'Wut')
end
function TOOL:LeftClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner.Dev then owner:ChatPrint("You are not authorized to use this.") return false end
	if not owner.Autospawner2List then
		owner.Autospawner2List = {}
	end
		if tr.Entity then
			local ent = tr.Entity
			if ent:IsValid() then
				if not ent.Autospawned then
					if not ent.Autospawn2Selected then
						local data = {}
						data["x"] = ent:GetPos().x
						data["y"] = ent:GetPos().y
						data["z"] = ent:GetPos().z
						data["pit"] = ent:GetAngles().p
						data["yaw"] = ent:GetAngles().y
						data["rol"] = ent:GetAngles().r
						data["class"] = ent:GetClass()
						data["model"] = ent:GetModel()
						owner.Autospawner2List[ent:EntIndex()] = data
						ent:SetColor(0,255,0,150)
						ent.Autospawn2Selected = true
						owner:ChatPrint("Selected")
						return true
					else
						owner.Autospawner2List[ent:EntIndex()] = nil
						ent:SetColor(255,255,255,255)
						ent.Autospawn2Selected = false
						owner:ChatPrint("Deselected")
						return true
					end
				end
			end
		end
end

function TOOL:RightClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner.Dev then owner:ChatPrint("You are not authorized to use this.") return false end
	local output = util.TableToKeyValues(owner.Autospawner2List)
	--local removelist = owner.Autospawner2List
	if not file.IsDir("Spaceage/Autospawn2") then
		file.CreateDir("Spaceage/Autospawn2")
	end
	local mapname = string.lower(game.GetMap())
	local filename = "Spaceage/Autospawn2/"..mapname..".txt"
	if file.Exists(filename) then
		local oldfile = file.Read(filename)
		local olddata = util.KeyValuesToTable(oldfile)
		for k,v in pairs(olddata) do
			table.insert(owner.Autospawner2List,v)
		end
		output = util.TableToKeyValues(owner.Autospawner2List)
		file.Delete(filename)
	end
	file.Write(filename,output)
	--for k,v in pairs(removelist) do if(v and v:IsValid()) then v:Remove() end end
	owner.Autospawner2List = {}
	removelist = {}
	owner:ChatPrint("Saved File")
end

function TOOL:Reload(tr)
	local owner = self:GetOwner()
	for k,v in pairs(owner.Autospawner2List) do if (v and v:IsValid()) then v:SetColor(255,255,255,255) end end
	owner.Autospawner2List = {}
	owner:ChatPrint("Cleared selection")
end
