SA.Factions = SA.Factions or {}

SA.Factions.Table = {
	{
		display_name = "Freelancers",
		name = "freelancer",
		color = Color(158, 134, 97, 255),
		model = "models/player/Group01/male_02.mdl",
		model_leader = "models/player/Group01/male_02.mdl",
		pronoun = "have",
	},
	{
		display_name = "I.C.E.",
		name = "ice",
		color = Color(210, 210, 210, 255),
		model = "models/player/police.mdl",
		model_leader = "models/player/combine_super_soldier.mdl",
		pronoun = "has",
		can_apply = true,
	},
	{
		display_name = "The Legion",
		name = "legion",
		color = Color(85, 221, 34, 255),
		model = "models/player/Hostage/Hostage_01.mdl",
		model_leader = "models/player/breen.mdl"
		pronoun = "has",
		can_apply = true,
	},
	{
		display_name = "Major Miners",
		name = "miners",
		color = Color(128, 64, 0, 255),
		model = "models/player/Group03/male_01.mdl",
		model_leader = "models/player/Group03/male_06.mdl",
		pronoun = "have",
		can_apply = true,
	},
	{
		display_name = "The Corporation",
		name = "corporation",
		color = Color(0, 150, 255, 255),
		model = "models/player/Hostage/Hostage_02.mdl",
		model_leader = "models/player/gman_high.mdl",
		pronon = "has",
		can_apply = true,
	},
	{
		display_name = "Error",
		name = "error",
		color = Color(75, 75, 75, 255),
		model = "models/player/Group01/male_02.mdl",
		model_leader = "models/player/Group01/male_02.mdl",
		pronoun = "",
		is_invalid = true,
	},
}

local name_to_index = {}
local display_name_to_index = {}

for k, v in pairs(SA.Factions.Table) do
	v.index = k

	name_to_index[v.name] = k
	display_name_to_index[v.display_name] = k

	team.SetUp(k, v.name, v.color)
end

local error_faction = SA.Factions.Table[name_to_index["error"]]

function SA.Factions.GetByIndex(idx)
	if not idx then
		return error_faction
	end
	return SA.Factions.Table[idx] or error_faction
end

function SA.Factions.GetByName(name)
	if not name then
		return error_faction
	end
	return SA.Factions.GetByIndex(name_to_index[name])
end

function SA.Factions.GetByDisplayName(display_name)
	if not display_name then
		return error_faction
	end
	return SA.Factions.GetByIndex(display_name_to_index[display_name])
end

function SA.Factions.GetByPlayer(ply)
	if not IsValid(ply) then
		return error_faction
	end
	return SA.Factions.GetByIndex(ply:Team())
end

function SA.Factions.GetError()
	return error_faction
end

function SA.Factions.GetDefault()
	return SA.Factions.GetByName("freelancer")
end
