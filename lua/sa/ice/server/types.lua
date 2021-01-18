SA_REQUIRE("ice.main")

SA.Ice.Types = {}

local function RegisterIce(name, col, start, max, regen, refineTable)
	SA.Ice.Types[name] = { col = col, StartIce = start, MaxIce = max, RegenIce = regen, refineTable = refineTable}
end

RegisterIce("blue ice", Color(75, 125, 255, 75), 60, 600, 60, {
	["liquid nitrogen"] = 2500,
	water = 10000,
	["heavy water"] = 50,
	["oxygen isotopes"] = 300,
	["hydrogen isotopes"] = 150,
	["helium isotopes"] = 400,
	["nitrogen isotopes"] = 400,
	["liquid ozone"] = 50,
	["strontium clathrates"] = 25
})
RegisterIce("clear ice", Color(0, 0, 0, 150), 55, 550, 55, {
	["liquid nitrogen"] = 2500,
	water = 10000,
	["heavy water"] = 50,
	["oxygen isotopes"] = 150,
	["hydrogen isotopes"] = 100,
	["helium isotopes"] = 300,
	["nitrogen isotopes"] = 500,
	["liquid ozone"] = 200,
	["strontium clathrates"] = 50
})
RegisterIce("glare crust", Color(125, 125, 125, 150), 50, 500, 50, {
	["liquid nitrogen"] = 10000,
	water = 25000,
	["heavy water"] = 1000,
	["oxygen isotopes"] = 150,
	["hydrogen isotopes"] = 150,
	["helium isotopes"] = 150,
	["nitrogen isotopes"] = 150,
	["liquid ozone"] = 500,
	["strontium clathrates"] = 25
})
RegisterIce("glacial mass", Color(175, 200, 255, 100), 45, 450, 45, {
	["liquid nitrogen"] = 2500,
	water = 10000,
	["heavy water"] = 50,
	["oxygen isotopes"] = 125,
	["hydrogen isotopes"] = 300,
	["helium isotopes"] = 50,
	["nitrogen isotopes"] = 150,
	["liquid ozone"] = 300,
	["strontium clathrates"] = 100
})
RegisterIce("white glaze", Color(200, 200, 200, 100), 40, 400, 40, {
	["liquid nitrogen"] = 2500,
	water = 10000,
	["heavy water"] = 50,
	["oxygen isotopes"] = 200,
	["hydrogen isotopes"] = 200,
	["helium isotopes"] = 200,
	["nitrogen isotopes"] = 300,
	["liquid ozone"] = 250,
	["strontium clathrates"] = 75
})
RegisterIce("gelidus", Color(25, 175, 255, 75), 35, 350, 35, {
	["liquid nitrogen"] = 50000,
	water = 10000,
	["heavy water"] = 250,
	["oxygen isotopes"] = 100,
	["hydrogen isotopes"] = 80,
	["helium isotopes"] = 100,
	["nitrogen isotopes"] = 150,
	["liquid ozone"] = 500,
	["strontium clathrates"] = 150,
})
RegisterIce("krystallos", Color(0, 0, 0, 75), 30, 300, 30, {
	["liquid nitrogen"] = 50000,
	water = 10000,
	["heavy water"] = 100,
	["oxygen isotopes"] = 100,
	["hydrogen isotopes"] = 150,
	["helium isotopes"] = 150,
	["nitrogen isotopes"] = 500,
	["liquid ozone"] = 350,
	["strontium clathrates"] = 75,
})
RegisterIce("dark glitter", Color(0, 0, 0, 255), 25, 275, 27, {
	["liquid nitrogen"] = 10000,
	water = 25000,
	["heavy water"] = 500,
	["oxygen isotopes"] = 75,
	["hydrogen isotopes"] = 75,
	["helium isotopes"] = 75,
	["nitrogen isotopes"] = 75,
	["liquid ozone"] = 800,
	["strontium clathrates"] = 50
})
