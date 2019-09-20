TOOL.Category = 'SpaceAge'
TOOL.Name = 'Mining'
TOOL.Command = nil
TOOL.ConfigName = ''
TOOL.Tab = "Custom Addon Framework"

TOOL.ClientConVar['type'] = 'sa_mining_laser'
TOOL.ClientConVar['model'] = 'models/props_phx/life_support/crylaser_small.mdl'

cleanup.Register('mininglasers')

if ( CLIENT ) then
	language.Add( 'Tool_mining_laser_sa_name', 'Mining' )
	language.Add( 'Tool_mining_laser_sa_desc', 'Creates an mining device.' )
	language.Add( 'Tool_mining_laser_sa_0', 'Left click to spawn a mining device.' )

	language.Add( 'Undone_mining_laser_sa', 'Mining Device Undone' )
	language.Add( 'Cleanup_mining_laser_sa', 'Mining Device' )
	language.Add( 'Cleaned_mining_laser_sa', 'Cleaned up all Mining Devices' )
	language.Add( 'SBoxLimit_mining_laser_sa', 'Maximum Mining Devices Reached' )
end

local miningdevice_models = {
	{ 'Asteroid Mining Laser I', 'models/props_phx/life_support/crylaser_small.mdl', 'sa_mining_laser' },
	{ 'Asteroid Mining Laser II', 'models/props_phx/life_support/crylaser_small.mdl', 'sa_mining_laser_ii' },
	{ 'Asteroid Mining Laser III', 'models/props_phx/life_support/crylaser_small.mdl', 'sa_mining_laser_iii' },
	{ 'Asteroid Mining Laser IV', 'models/props_phx/life_support/crylaser_small.mdl', 'sa_mining_laser_iv' },
	{ 'Asteroid Mining Laser V', 'models/props_phx/life_support/crylaser_small.mdl', 'sa_mining_laser_v' },
	{ 'Asteroid Mining Laser VI', 'models/props_phx/life_support/crylaser_small.mdl', 'sa_mining_laser_vi' },
	{ 'Tiberium Mining Drill', 'models/slyfo/rover_drillbit.mdl', 'sa_mining_drill' },
	{ 'Tiberium Mining Drill II', 'models/slyfo/rover_drillbit.mdl', 'sa_mining_drill_ii' },
	{ 'ICE Laser Mark I', 'models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl', 'ice_mining_laser_base' },
	{ 'ICE Laser Mark II', 'models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl', 'ice_mining_laser_2' },
	{ 'ICE Laser Mark III', 'models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl', 'ice_mining_laser_3' },
	{ 'ICE Refinery Level 1: Basic', 'models/props_c17/substation_transformer01b.mdl', 'ice_refinery_basic' },
	{ 'ICE Refinery Level 2: Improved', 'models/props_c17/substation_transformer01b.mdl', 'ice_refinery_improved' },
	{ 'ICE Refinery Level 3: Advanced', 'models/props_citizen_tech/SteamEngine001a.mdl', 'ice_refinery_advanced' },
	
	// PM :D
	
	{ 'PM Refinery: Basic', 'models/props_c17/substation_transformer01b.mdl', 'sa_planetmining_refinery' },
	{ 'PM Refinery: Improved', 'models/Slyfo/refinery_small.mdl', 'sa_planetmining_refinery' },
	{ 'PM Refinery: Advanced', 'models/Slyfo/refinery_large.mdl', 'sa_planetmining_refinery' },
	{ 'PM Drill (Default)', 'models/Slyfo/drillplatform.mdl', 'sa_planetmining_drill' },
	{ 'PM Drill (Model 2)', 'models/Slyfo/drillbase_basic.mdl', 'sa_planetmining_drill' },
	{ 'PM Drill (Mobile)', 'models/Slyfo/rover_drillbase.mdl', 'sa_planetmining_drill' },
	{ 'PM O.D.E. (Ore Density Evaluator)', 'models/Slyfo/powercrystal.mdl', 'sa_planetmining_ode_radar' },
}

local TLNAMEX = "mining_laser_sa"

if SERVER then
	CAF_CallbackFuncs[TLNAMEX] = function( ply, Ang, Pos, type, model, Frozen )
		if ply:GetCount( TLNAMEX ) >= ply.devlimit then return nil end
		local ent = CAF_MakeCAFEnt( ply, Ang, Pos, TLNAMEX, type, model, frozen )
		if not (ent and ent:IsValid()) then return nil end
		ply:AddCount( TLNAMEX, ent )
		return ent
	end
end

CAF_ToolRegister( TOOL, miningdevice_models, nil, TLNAMEX, 1 )
