ENSURE_RAPTORDATA;
event_inherited();

/// @desc Docs inside! You MUST call this when overriding!
/*
	By default, all saveable objects will be part of the savegame file.
	Use the declared instance variable add_to_savegame and set it to false
	if you want to skip specific instances from being saved.
	
	The raptor platform defines these objects as children of Saveable:
	- LGTextObject (and from there the entire UI subsystem)
	- StatefulObject (All your game objects)

	Engine data saved:
	"seed"				The current seed of the randomizer.
	
	For each object instance, that has [Saveable] as parent in the inheritance
	chain, these properties will automatically be saved in and restored from the
	savegame:
	
	INSTANCE FIELDS
	"obj", "id"							The object type and id (for restore reference)
	"x", "y"							The current position
	"direction", "speed"				The direction and speed
	"layer"								The name of the layer where it exists
	
	OBJECT FIELDS
	"visible", "persistent", "solid"	Object flags
	
	SPRITE/IMAGE FIELDS
	"sprite_index", "image_index"		Sprite and frame number
	"image_speed"						Sprite animation speed
	"image_alpha", "image_blend"		Transparency and color blend
	"image_angle", "image_xscale",
	"image_yscale"						Rotation and scaling
	
	IN ADDITION: All instance variables of raptor platform objects 
	will automatically save their states and even restore their instance links.
	
	NOTE: The user event 14 (onGameSaving) will be invoked before the contents of
	the data variable (or whatever onGameSaving returns, if you override it)
	are written to the savegame file.
	The function onGameSaving below will be called by the savegame
	scripts when the game gets saved. Override this event and (re)declare that
	function and return any struct you like. It will be part of the savegame!
	Use it to store more important data than the default properties saved by
	the savegame script.
	
	NOTE: If you create a instance variable called "data", it will be automatically
	saved and loaded, as long as it's a struct.
	
	The same is true for the onGameLoaded function and user event 13 (onGameLoaded). 
	It receives the exact struct you returned from onGameSaving.
	
	In addition, there is a post-save function onGameSaved which gets invoked after
	ALL data has been written to the file and an onGameLoading function which will
	by default assign the struct from the savegame to the data variable.
	Override an re-declare this function if you need another behavior.
	
	The callback/event order is:
	Saving								|	Loading
	-------------------------------------------------------------------------------
	SAVEGAME_SAVE_IN_PROGRESS = true	|	SAVEGAME_LOAD_IN_PROGRESS = true
	onGameSaving (user event)			|	onGameLoading (function)
	onGameSaving (function)				|	SAVEGAME_LOAD_IN_PROGRESS = false
	SAVEGAME_SAVE_IN_PROGRESS = false	|	onGameLoaded  (function)
	onGameSaved  (function)				|	onGameLoaded  (user event)
	-------------------------------------------------------------------------------
	
	NOTE: The "...ing" (savING, loadING) functions and events are invoked
	on a per-object basis during the save process!
	The "...ed" (savED, loadED) are bulk-invoked on all objects AFTER
	ALL DATA has been saved/loaded.
*/

/// @func	onGameSaving()
/// @desc	invoked per instance during game save
onGameSaving = function() {
};

/// @func	onGameSaved(_result)
/// @desc	Invoked AFTER saving 
///			_result is a bool containing the success state
onGameSaved = function(_result) {
}

/// @func	onGameLoading()
/// @desc	occurs when this object has been loaded
onGameLoading = function() {
}

/// @func	onGameLoaded(_result)
/// @desc	occurs after all objects have been loaded
///			_result is a bool containing the success state
onGameLoaded = function(_result) {
}

/// @func onRaceDrop(_item)
/// @desc occurs if this is dropped by a Race query
onRaceDrop = function(_item) {	
}
