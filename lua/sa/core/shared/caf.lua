local valuables = {}

function SA.GetValuableResources()
	return valuables
end

local function AddValuableResource(name, fancyName)
	valuables[name] = true
	SA.RD.AddProperResourceName(name, fancyName)
end

function SA.CAFInit()
	SA.RD = CAF.GetAddon("Resource Distribution")
	SA.SB = CAF.GetAddon("Spacebuild")
	SA.LS = CAF.GetAddon("Life Support")

	timer.Simple(0, function()
		AddValuableResource("valuable minerals", "Valuable Minerals")
		AddValuableResource("dark matter", "Dark Matter")
		AddValuableResource("terracrystal", "Terracrystal")
		AddValuableResource("permafrost", "Permafrost")
		AddValuableResource("ore", "Ore")
		AddValuableResource("tiberium", "Tiberium")
		AddValuableResource("metals", "Metals")

		AddValuableResource("oxygen isotopes", "Oxygen Isotopes")
		AddValuableResource("hydrogen isotopes", "Hydrogen Isotopes")
		AddValuableResource("helium isotopes", "Helium Isotopes")
		AddValuableResource("nitrogen isotopes", "Nitrogen Isotopes")
		AddValuableResource("carbon isotopes", "Carbon Isotopes")
		AddValuableResource("strontium clathrates", "Strontium Clathrates")

		AddValuableResource("blue ice", "Blue Ice")
		AddValuableResource("clear ice", "Clear Ice")
		AddValuableResource("glacial mass", "Glacial Mass")
		AddValuableResource("white glaze", "White Glaze")
		AddValuableResource("dark glitter", "Dark Glitter")
		AddValuableResource("glare crust", "Glare Crust")
		AddValuableResource("gelidus", "Gelidus")
		AddValuableResource("krystallos", "Krystallos")
	end)

	hook.Run("SA_CAFInitComplete")
end
