TOOL.Category = 'Administration'
TOOL.Name = 'Prop Autospawn'
TOOL.Command = nil
TOOL.ConfigName = ''
TOOL.Tab = "Administration"

if ( CLIENT ) then
	language.Add( 'Tool_autospawn_name', 'Autospawn' )
	language.Add( 'Tool_autospawn_desc', 'ASK DORIDIAN TO USE' )
	language.Add( 'Tool_autospawn_0', 'Wut' )
end
function TOOL:LeftClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner.Dev then owner:ChatPrint("You are not authorized to use this.") return false end
	if not owner.AutospawnerList then
		owner.AutospawnerList = {}
	end
		if tr.Entity then
			local ent = tr.Entity
			if ent:IsValid() then
				if ent:GetClass() == "prop_physics" then
					if not ent.Autospawned then
						if not ent.AutospawnSelected then
							local data = {}
							data["x"] = ent:GetPos().x
							data["y"] = ent:GetPos().y
							data["z"] = ent:GetPos().z
							data["pit"] = ent:GetAngles().p
							data["yaw"] = ent:GetAngles().y
							data["rol"] = ent:GetAngles().r
							data["model"] = ent:GetModel()
							owner.AutospawnerList[ent:EntIndex()] = data
							ent:SetColor(0,255,0,150)
							ent.AutospawnSelected = true
							owner:ChatPrint("Selected")
							return true
						else
							owner.AutospawnerList[ent:EntIndex()] = nil
							ent:SetColor(255,255,255,255)
							ent.AutospawnSelected = false
							owner:ChatPrint("Deselected")
							return true
						end
					end
				end
			end
		end
end

function TOOL:RightClick(tr)
	if CLIENT then return end
	local owner = self:GetOwner()
	if not owner.Dev then owner:ChatPrint("You are not authorized to use this.") return false end
	local output = util.TableToKeyValues(owner.AutospawnerList)
	local removelist = owner.AutospawnerList
	if not file.IsDir("Spaceage/Autospawn") then
		file.CreateDir("Spaceage/Autospawn")
	end
	local mapname = string.lower(game.GetMap())
	local filename = "Spaceage/Autospawn/"..mapname..".txt"
	if file.Exists(filename, "DATA") then
		local oldfile = file.Read(filename)
		local olddata = util.KeyValuesToTable(oldfile)
		for k,v in pairs(olddata) do
			table.insert(owner.AutospawnerList,v)
		end
		output = util.TableToKeyValues(owner.AutospawnerList)
		file.Delete(filename)
	end
	file.Write(filename,output)
	for k,v in pairs(removelist) do v:Remove() end
	owner.AutospawnerList = {}
	removelist = {}
	owner:ChatPrint("Saved File")
end
