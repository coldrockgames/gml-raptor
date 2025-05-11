/*
    Configure the games' particle effects
	If the current ROOMCONTROLLER has one or more layers defined in its
	"particle_layer_names" instance variable, then this function gets called 
	during the Create event of the ROOMCONTROLLER to set up particles used in this room.
	More Info in the wiki: https://github.com/coldrockgames/gml-raptor/wiki/Particle-Effects
*/

// The Folder, where the ParticleLoader will look for particle effects
#macro PARTICLES_ROOT_FOLDER				"particles/"

// Set this to true to scan the PARTICLES_ROOT_FOLDER at startup and load all effects into memory.
// Set it to false if you want to load manually through PARTSYS.load_particle(...).
#macro PARTICLES_SCAN_ON_STARTUP			true

// If this is true, only global particles and those designed for the current room will be loaded,
// when entering a room. You must follow this file/folder structure:
// datafiles/PARTICLES_ROOT_FOLDER/
//		global/		<-- All particles in "global" will be created in every room
//		rmMain/		<-- Name your folder exactly as the room to have them be created,
//		rmPlay/			when entering a room
#macro PARTICLES_LOAD_PER_ROOM				true

// This callback gets invoked during the Create event of the ROOMCONTROLLER when entering a room.
function setup_particle_types() {
	
	if (room == rmMain) {
		PARTSYS.emitter_get("emSteamBurst", "ptSteamBurst");
		PARTSYS.emitter_set_range("emSteamBurst", -32, 32, -4, 4, ps_shape_rectangle, ps_distr_gaussian);
		var ptSteamBurst = PARTSYS.particle_type_get("ptSteamBurst");
		part_type_blend(ptSteamBurst, 1);
		part_type_shape(ptSteamBurst, pt_shape_cloud);
		part_type_size(ptSteamBurst, 0.12, 0.21, 0.02, 0);
		part_type_scale(ptSteamBurst, 1, 1);
		part_type_color2(ptSteamBurst, make_color_rgb(56,56,56), make_color_rgb(157,157,157));
		//part_type_color3(ptSteamBurst, make_color_rgb(71.82, 70.69, 254.91), make_color_rgb(198.84, 11.09, 11.76), make_color_rgb(216.09, 63.48, 76.47));
		part_type_alpha3(ptSteamBurst, 0.71, 0.47, 0.16);
		part_type_life(ptSteamBurst, 5.63, 12.68);
		part_type_orientation(ptSteamBurst, 0, 359, 1, 0, false);
		part_type_speed(ptSteamBurst, 10, 16, -0.10, 0.01);
		part_type_direction(ptSteamBurst, 170, 190, 0, 0);
		part_type_gravity(ptSteamBurst, 0, 0);
		// PARTSYS.stream("emSteamBurst", 30, "ptSteamBurst"); // where 30 is the number of particles; particle type can be omitted
		// PARTSYS.emitter_move_range_to("emSteamBurst", 0, 0); // This is a x/y coordinate
		
		PARTSYS.emitter_get("emSmoke", "ptSmoke");
		PARTSYS.emitter_set_range("emSmoke", -32, 32, -4, 4, ps_shape_rectangle, ps_distr_gaussian);
		var ptSmoke = PARTSYS.particle_type_get("ptSmoke");
		part_type_blend(ptSmoke, 1);
		part_type_shape(ptSmoke, pt_shape_cloud);
		part_type_size(ptSmoke, 0.49, 1.62, 0, 0.31);
		part_type_scale(ptSmoke, 1, 1);
		part_type_color2(ptSmoke, make_color_rgb(56,56,56), make_color_rgb(157,157,157));
		//part_type_color3(ptSmoke, make_color_rgb(71.82, 70.69, 254.91), make_color_rgb(198.84, 11.09, 11.76), make_color_rgb(216.09, 63.48, 76.47));
		part_type_alpha3(ptSmoke, 0.43, 0.28, 0.00);
		part_type_life(ptSmoke, 29.58, 54.93);
		part_type_orientation(ptSmoke, 0, 0, 0, 0, false);
		part_type_speed(ptSmoke, 1, 1, 0, 0.01);
		part_type_direction(ptSmoke, 70, 110, 0, 0);
		part_type_gravity(ptSmoke, 0.10, 90);
		// PARTSYS.stream("emSmoke", 1, "ptSmoke"); // where 1 is the number of particles; particle type can be omitted
		// PARTSYS.emitter_move_range_to("emSmoke", 0, 0); // This is a x/y coordinate
		
	}

}