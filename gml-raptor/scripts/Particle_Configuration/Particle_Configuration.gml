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

}