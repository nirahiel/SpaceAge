ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName= "Planetary Mining Storage (Product)"
ENT.Author= "Zachar543"

//list.Set( "LSEntOverlayText" , "sa_planetmining_storage_product", {num = -1} )
function ENT:Initialize()
	local Strs = {"Product Storage"}
	local ores = {}
	for _,v in pairs(SA_PM.Ref.Types) do
		table.insert(Strs, "\n"..v.Name..":")
		table.insert(ores, v.Name)
	end

	list.Set( "LSEntOverlayText" , "sa_planetmining_storage_product", {HasOOO = false, num = #ores, strings = Strs,resnames = ores} )
end

