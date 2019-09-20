ENT.Type = "anim"
ENT.Base = "base_rd3_entity"
ENT.PrintName = "Planetary Mining Drill"
ENT.Author = "Zachar543"

list.Set( "LSEntOverlayText", "sa_planetmining_drill", {HasOOO = true, num = 3, strings = {"Mining Drill","\nEnergy: ","\nWater: ","\nSteam: "},resnames = {"energy","water","steam"}} )

SADrillModels = {}
SADrillModels["models/slyfo/drillplatform.mdl"] = {Offset = Vector(0, 0, 117.95)}
SADrillModels["models/slyfo/drillbase_basic.mdl"] = {Offset = Vector(0, 0, 60)}
SADrillModels["models/slyfo/rover_drillbase.mdl"] = {Offset = Vector(-40, 0, 100)}

SADrillShaftSize = (117.95 * 2)
SADrillShaftSizeHalf = (117.95)