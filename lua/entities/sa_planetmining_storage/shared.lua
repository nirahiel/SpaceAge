ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName= "Planetary Mining Storage"
ENT.Author= "Zachar543"

//list.Set( "LSEntOverlayText" , "sa_planetmining_storage", {num = -1} )
local Strs = {"Raw Storage"}
local ores = {}
for _,v in pairs(SA_PM.Ore.Types) do
	table.insert(Strs, "\n"..v.Name..":")
	table.insert(ores, v.Name)
end
//PrintTable(Strs)
//PrintTable(ores)
list.Set( "LSEntOverlayText" , "sa_planetmining_storage", {HasOOO = false, num = #ores, strings = Strs,resnames = ores} )
