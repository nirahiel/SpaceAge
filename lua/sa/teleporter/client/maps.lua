SA.REQUIRE("teleporter.main")

local mapData = {}

function SA.Teleporter.GetMapData(map)
	if not map then
		map = game.GetMap()
	end
	local data = mapData[map]
	if not data then
		return
	end

	return {
		planets = table.Copy(data.planets),
	}
end

local function DefineMap(name, data)
	mapData[name] = data
end

DefineMap("sb_forlorn_sb3_r3", { planets = {
	["Chondradirk"] = {
		radius = 1792,
		position = Vector(5854,-3906,6512),
	},
	["Station 457"] = {
		radius = 2600,
		teleporterName = "Terminal station",
		position = Vector(9414,9882,392),
	},
	["Vimana"] = {
		radius = 3122,
		position = Vector(-10696,-6889,-6131),
	},
	["Dunomane"] = {
		radius = 4096,
		teleporterName = "Tiberium planet",
		position = Vector(9092,9314,-8874),
	},
	["Ninurta"] = {
		radius = 3122,
		position = Vector(-8192.90625,8959.34375,7097.5),
	},
	["Shakuras"] = {
		radius = 5120,
		teleporterName = "Spawn planet",
		position = Vector(8566,-7744,-9218),
	},
}})

DefineMap("sb_gooniverse_v4", { planets = {
	["Cerebus"] = {
		radius = 4832,
		teleporterName = "Tiberium planet",
		position = Vector(8192,-10240,-2040),
	},
	["Demeter"] = {
		radius = 3328,
		position = Vector(-8192,8704,10240),
	},
	["Hiigara"] = {
		radius = 4864,
		teleporterName = "Spawn planet",
		position = Vector(-9728,-6144,-8192),
	},
	["Coruscant"] = {
		radius = 1120,
		teleporterName = "Terminal planet",
		position = Vector(2.3125,-1.34375,4620),
	},
	["Kobol"] = {
		radius = 4032,
		position = Vector(9726.875,9216.78125,4360),
	},
	["Endgame"] = {
		radius = 3008,
		position = Vector(1536,7680,-10240),
	},
}})

DefineMap("sb_wuwgalaxy_fix", { planets = {
	["Magmite"] = {
		radius = 3072,
		position = Vector(-6274,-2767,9846),
	},
	["Spawn"] = {
		radius = 1300,
		position = Vector(-80,-335,16313.5),
	},
	["Shakuras"] = {
		radius = 5120,
		teleporterName = "Forlorn",
		position = Vector(9758,-7744,-10112),
	},
	["Asteroid Base"] = {
		radius = 3000,
		teleporterName = "Asteroid",
		position = Vector(-8590,-9865,-11666),
	},
	["Kobol"] = {
		radius = 4032,
		position = Vector(-9180.09375,9216.78125,-1198),
	},
	["Space Station"] = {
		radius = 2500,
		teleporterName = "Terminal station",
		position = Vector(8420,5365,7122),
	},
	["Endgame"] = {
		radius = 3008,
		position = Vector(1536,7680,-10240),
	},
	["Vimana"] = {
		radius = 3122,
		position = Vector(-8824,-9144,204),
	},
	["Shoosh"] = {
		radius = 2048,
		position = Vector(12151,12362,12425),
	},
}})
