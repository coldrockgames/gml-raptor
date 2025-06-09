/*
    Configure the games' particle effects
	If the current ROOMCONTROLLER has one or more layers defined in its
	"particle_layer_names" instance variable, then this function gets called 
	during the Create event of the ROOMCONTROLLER to set up particles used in this room.
	More Info in the wiki: https://github.com/coldrockgames/gml-raptor/wiki/Particle-Effects
*/

// The Folder, where the ParticleLoader will look for particle effects
#macro PARTICLES_ROOT_FOLDER				"particles/"

// The folder beneath PARTICLES_ROOT_FOLDER, where all common particles are stored
#macro PARTICLES_GLOBAL_FOLDER				"global/"

// Set this to true to scan the PARTICLES_ROOT_FOLDER at startup and load all effects into memory.
// Set it to false if you want to load manually through PARTSYS.load_particle(...).
// NOTE: If this is true, when entering a room, particles and particle systems will automatically be
//		 created for you.
// You must follow this file/folder structure:
// datafiles/PARTICLES_ROOT_FOLDER/
//		global/		<-- All particles in PARTICLES_GLOBAL_FOLDER will be created in every room
//		rmMain/		<-- Name your folder exactly as the room to have them be created,
//		rmPlay/			when entering a room
#macro PARTICLES_SCAN_ON_STARTUP			true

/// @func	setup_particle_types()
/// @desc	Invoked AFTER particle loading upon room start.
function setup_particle_types() {

}