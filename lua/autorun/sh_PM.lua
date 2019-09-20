SA_PM = {}
SA_PM.Ore = {}
SA_PM.Ref = {}
SA_PM.Ore.Types = {}
SA_PM.Ref.Types = {}

function SA_PM.AddOre(name, col, price, min, max, refname, refamount, mindepth, rarity)
	table.insert(SA_PM.Ore.Types, {ID = table.Count(SA_PM.Ore.Types) + 1, Name = name, Color = col, Price = price, MinSize = min, MaxSize = max, RefinedName = refname, RefinedAmount = refamount, MinDepth = mindepth, Rarity = rarity})
	SA_PM.Ref.Types[name] = {Name = refname, Amount = refamount, Price = price}
end
SA_PM.AddOre("Base Metal", 		Color(150, 150, 150, 255),	100, 	125, 150, 	"Copper", 			75, -0, 	1) 		// 150
SA_PM.AddOre("Ferrous Metal", 	Color(150, 0, 0, 255), 		2500, 	50, 70, 	"Iron",				75, -150,	2)		// 75
SA_PM.AddOre("Noble Metal", 	Color(0, 150, 0, 255), 		3500, 	55, 75, 	"Platinum", 		75, -150,	3)		// 75
SA_PM.AddOre("Precious Metal", 	Color(150, 150, 0, 255),	3500, 	45, 65, 	"Gold", 			75, -450,	3)		// 75
SA_PM.AddOre("Diamonds", 		Color(0, 150, 150, 255), 	7500, 	25, 50, 	"Cut Diamonds", 	75, -750,	5)		// 50
SA_PM.AddOre("Tairrium", 		Color(150, 0, 150, 255), 	15000, 	15, 30, 	"Refined Tairrium", 75, -1000,	5)		// 50

function SA_PM.GetClosestODEScreen(ply, range)
	local Ret = nil
	local dist = 9999999999
	for _,v in pairs(ents.FindByClass("sa_planetmining_ode_screen")) do
		if (v and v:IsValid()) then
			local curDist = v:GetPos():Distance(ply:GetPos())
			if (curDist < range and curDist < dist) then
				dist = curDist
				Ret = v
			end
		end
	end
	return Ret
end