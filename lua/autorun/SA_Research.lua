if SERVER then
	AddCSLuaFile( "autorun/SA_Research.lua" )
end

local Researches = {}
local ResearchGroups = {"Asteroid Mining","Tiberium Mining","Ice Mining", "Planetary Mining", "Miscellaneous"}
local ResearchIcons = {}

function SA_GetResearch()
	return Researches
end

function SA_GetResearchGroups()
	return ResearchGroups
end

local function SA_VerifyResearchXQINT(res)
	for _,v in pairs(res) do
		if v[1] == "faction" then return false end
	end
	return true
end

function SA_AddResearch(name,group,displayname,ranks,variable,cost,costinc,desc,reqtype,prereq,position,classes,image)
	local tbl = {}
	image = image or "SA_Research_Icon"
	tbl["display"] = displayname
	tbl["ranks"] = ranks
	tbl["variable"] = variable
	tbl["cost"] = cost
	tbl["costinc"] = costinc
	tbl["desc"] = desc
	tbl["type"] = reqtype
	tbl["prereq"] = prereq
	tbl["pos"] = position
	tbl["classes"] = classes
	tbl["image"] = image
	
	local resetreq = ranks
	if reqtype == "unlock" then
		if not SA_VerifyResearchXQINT(prereq) then resetreq = 0 end
	elseif reqtype == "perrank" then
		for k,v in pairs(prereq) do
			if not SA_VerifyResearchXQINT(v) then resetreq = (k - 1) end
		end
	end
	tbl["resetreq"] = resetreq
	
	ResearchIcons[image] = true
	if not (Researches[group]) then
		Researches[group] = {}
	end
	Researches[group][name] = tbl
end


/*
SA_AddResearch(	Research Name,
			Research Group,
			Display Name,
			Max rank (0 = infinite),
			Variable,
			Base Cost,
			Price increase (% of base),
			Description,
			Pre-Requisite,
			Position on List,
			Class types to update with new values)
*/

SA_AddResearch(	"mining_yield","Asteroid Mining","Augmented Mining Lasers I",300,"miningyield",10000,25,"Each rank increases the amount of ore mined by the MkI laser by 6.25 a second.","none",{},1,{"sa_mining_laser"})
SA_AddResearch(	"mining_yield_ii","Asteroid Mining","Augmented Mining Lasers II",300,"miningyield_ii",800000,0.625,"Each rank increases the amount of ore mined by the MkII laser by 12.5 a second.","unlock",{{"miningyield",300},{"miningtheory",1}},2,{"sa_mining_laser_ii"})

SA_AddResearch(	"mining_yield_iii","Asteroid Mining","Augmented Mining Lasers III",300,"miningyield_iii",2500000,0.4,"Each rank increases the amount of ore mined by the MkIII laser by 25 a second.","unlock",{{"miningyield_ii",300},{"miningtheory",2}},3,{"sa_mining_laser_iii"})

SA_AddResearch(	"mining_yield_iv","Asteroid Mining","Augmented Mining Lasers IV",300,"miningyield_iv",6250000,0.32,"Each rank increases the amount of ore mined by the MkIV laser by 50 a second.","unlock",{{"miningyield_iii",300},{"miningtheory",3}},4,{"sa_mining_laser_iv"})
SA_AddResearch(	"mining_yield_v","Asteroid Mining","Augmented Mining Lasers V",300,"miningyield_v",12500000,0.32,"Each rank increases the amount of ore mined by the MkV laser by 100 a second.","unlock",{{"miningyield_iv",300},{"miningtheory",4}},5,{"sa_mining_laser_v"})
SA_AddResearch(	"mining_yield_vi","Asteroid Mining","Augmented Mining Lasers VI",300,"miningyield_vi",25000000,0.32,"Each rank increases the amount of ore mined by the MkVI laser by 200 a second.","unlock",{{"miningyield_v",300},{"miningtheory",5},{"faction",{"miners","alliance"}}},6,{"sa_mining_laser_vi"})
SA_AddResearch(	"mining_theory","Asteroid Mining","Mining Theory",5,"miningtheory",5000000,100,"Unlocks the use of more powerful Mining Lasers.","perrank",{{{"miningyield",300}},{{"miningyield_ii",300}},{{"miningyield_iii",300}},{{"miningyield_iv",300}},{{"miningyield_v",300},{"faction",{"miners","alliance"}}}},7,{})				
SA_AddResearch(	"mining_energy","Asteroid Mining","Mining Power Reduction",45,"miningenergy",10000,50,"Each rank reduces the amount of energy consumed by the mining laser by 25 a second.\n(Energy reduction cannot drop below 1/4th base.)","none",{},8,{"sa_mining_laser","sa_mining_laser_ii","sa_mining_laser_iii","sa_mining_laser_iv","sa_mining_laser_v","sa_mining_laser_vi"})				
SA_AddResearch(	"ore_storage","Asteroid Mining","Increased Ore Capacity - Small",300,"oremod",5000,25,"Each rank increases the capacity of the small ore storage container by 5000.","none",{},9,{"ore_storage"})
SA_AddResearch(	"ore_storage_ii","Asteroid Mining","Increased Ore Capacity - Medium",300,"oremod_ii",400000,0.625,"Each rank increases the capacity of the medium ore storage container by 10000.","unlock",{{"oremod",300},{"oremanage",1}},10,{"ore_storage_ii"})
SA_AddResearch(	"ore_storage_iii","Asteroid Mining","Increased Ore Capacity - Large",300,"oremod_iii",1250000,0.4,"Each rank increases the capacity of the large ore storage container by 20000.","unlock",{{"oremod_ii",300},{"oremanage",2}},11,{"ore_storage_iii"})

SA_AddResearch(	"ore_storage_iv","Asteroid Mining","Increased Ore Capacity - Huge",300,"oremod_iv",2500000,0.32,"Each rank increases the capacity of the huge ore storage container by 40000.","unlock",{{"oremod_iii",300},{"oremanage",3}},12,{"ore_storage_iv"})

SA_AddResearch(	"ore_storage_v","Asteroid Mining","Increased Ore Capacity - Giant",300,"oremod_v",5000000,0.32,"Each rank increases the capacity of the giant ore storage container by 80000.","unlock",{{"oremod_iv",300},{"oremanage",4},{"faction",{"miners","starfleet","alliance"}}},13,{"ore_storage_v"})			
SA_AddResearch(	"oremanage","Asteroid Mining","Ore Management",4,"oremanage",2500000,100,"Unlocks the use of bigger ore containers.","perrank",{{{"oremod",300}},{{"oremod_ii",300}},{{"oremod_iii",300}},{{"oremod_iv",300},{"faction",{"miners","starfleet","alliance"}}}},14,{})

SA_AddResearch(	"tiberiumyield","Tiberium Mining","Augmented Mining Drill",300,"tiberiumyield",12000,25,"Each rank increases the amount of tiberium mined by the drill by 10 a second.","none",{},1,{"sa_mining_drill"})

SA_AddResearch(	"tiberiumyield_ii","Tiberium Mining","Augmented Mining Drill II",300,"tiberiumyield_ii",24000,25,"Each rank increases the amount of tiberium mined by the drill II by 20 a second.","unlock",{{"tiberiumyield",300},{"tibdrillmod",1},{"faction",{"legion","alliance"}}},2,{"sa_mining_drill_ii"})			
SA_AddResearch(	"tibdrillmod","Tiberium Mining","Tiberium Drills",1,"tibdrillmod",25000000,100,"Unlocks the use of better tiberium drills.","perrank",{{{"tiberiumyield",300},{"faction",{"legion","alliance"}}}},3,{})
SA_AddResearch(	"tiberiummod","Tiberium Mining","Increased Tiberium Capacity",300,"tiberiummod",5000,16,"Each rank increases the capacity of the tiberium storage container by 5000.","none",{},4,{"tiberium_storage"})			
SA_AddResearch(	"tiberiummod_ii","Tiberium Mining","Increased Tiberium Capacity II",300,"tiberiummod_ii",10000,16,"Each rank increases the capacity of the tiberium storage container II by 10000.","unlock",{{"tiberiumyield",300},{"tibstoragemod",1},{"faction",{"legion","alliance"}}},5,{"tiberium_storage_ii"})				
SA_AddResearch(	"tibstoragemod","Tiberium Mining","Tiberium Storages",1,"tibstoragemod",20000000,100,"Unlocks the use of bigger tiberium containers.","perrank",{{{"tiberiummod",300},{"faction",{"legion","alliance"}}}},6,{})
SA_AddResearch(	"rta_device","Miscellaneous","Remote Terminal Access",2,"rta",50000000,200,"Allows use of the R.T.A. (Remote Terminal Access) device.","perrank",{{},{{"faction",{"corporation","alliance"}}}},2,{})
SA_AddResearch(	"ice_refinery","Ice Mining","Ice Refineries",2,"icerefinerymod",750000000,150,"Allows using better ice refineries.","none",{},1,{})
SA_AddResearch(	"ice_laser","Ice Mining","Ice Lasers",2,"icelasermod",1000000000,150,"Allows using better ice lasers.","none",{},2,{})
SA_AddResearch(	"ice_storage","Ice Mining","Ice Storages",4,"icerawmod",300000000,150,"Allows using better raw Ice Storages.","none",{},3,{})
SA_AddResearch(	"ice_product_storage","Ice Mining","Ice Product Storages",6,"iceproductmod",300000000,150,"Allows using better ice product storages.","none",{},4,{})		

// PM :D

SA_AddResearch(	"sa_planetmining_drill_depth","Planetary Mining","Max Drill Depth",45,"pmdrillshafts",150000000,10,"Allows for deaper drilling.","none",{},1,{})
SA_AddResearch(	"sa_planetmining_drill_speed","Planetary Mining","Drill Speed",50,"pmdrillspeed",100000000,5,"Allows faster drilling. (0.03 each time)","none",{},2,{})
SA_AddResearch(	"sa_planetmining_drill_efficiency","Planetary Mining","Drill Efficiency",50,"pmdrilleff",120000000,5,"Allows more efficient drilling. (0.1 each time)","none",{},3,{})
SA_AddResearch(	"sa_planetmining_drill_reliability","Planetary Mining","Drill Reliability",50,"pmdrillreliab",200000000,5,"Allows more a more reliable drill. (-5% each time)","none",{},4,{})
SA_AddResearch(	"sa_planetmining_ref_speed","Planetary Mining","Refinery Level",2,"pmrefspeed",3000000000,100,"Allows for better and faster refineries.","none",{},5,{})

SA_AddResearch(	"sa_planetmining_storage","Planetary Mining","Raw Storages",4,"pmrawlevel",1000000000,100,"Allows using better PM Raw Storages.","none",{},6,{})
SA_AddResearch(	"sa_planetmining_storage_product","Planetary Mining","Product Storages",4,"pmprodlevel",1000000000,100,"Allows using better PM Product Storages.","none",{},7,{})
//SA_AddResearch(	"sa_planetmining_ode_res","Planetary Mining","ODE Resolution",2,"pmoderes",5000000000,100,"Allows for a higher resolution screen.","none",{},8,{})
SA_AddResearch(	"sa_planetmining_ode_speed","Planetary Mining","ODE Scan Speed",60,"pmodespeed",300000000,5,"Decreases max scan time. (-2 sec each time)","none",{},8,{})
SA_AddResearch(	"sa_planetmining_ode_range","Planetary Mining","ODE Scan Range",32,"pmoderange",300000000,5,"Allows for a broader scan.","none",{},9,{})
SA_AddResearch(	"sa_planetmining_ode_battery","Planetary Mining","ODE Energy Cost",5,"pmodebattery",100000000,15,"Decreases the energy usage of the ODE. (-5% each time)","none",{},10,{})


for k,v in pairs(ResearchIcons) do
	resource.AddFile("materials/spaceage/"..k..".vmt")
	resource.AddFile("materials/spaceage/"..k..".vmf")
end