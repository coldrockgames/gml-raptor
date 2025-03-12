/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// STATUS/PROGRESS GLOBALS
#macro SAVEGAME_SAVE_IN_PROGRESS		global.__savegame_save_in_progress
#macro SAVEGAME_LOAD_IN_PROGRESS		global.__savegame_load_in_progress
#macro ENSURE_SAVEGAME					if (!variable_global_exists("__savegame_save_in_progress"))	global.__savegame_save_in_progress = false; \
										if (!variable_global_exists("__savegame_load_in_progress"))	global.__savegame_load_in_progress = false;

// Room change on load, state preserve
#macro __SAVEGAME_CONTINUE_LOAD_STATE	global.__savegame_load_state
__SAVEGAME_CONTINUE_LOAD_STATE			= undefined;

// The GLOBALDATA struct is persisted with the savegame
#macro GLOBALDATA			global.__global_data
#macro ENSURE_GLOBALDATA	if (!variable_global_exists("__global_data"))	global.__global_data = {};
ENSURE_GLOBALDATA;

#macro RAPTOR_SAVEGAMEDATA	GLOBALDATA.__raptor_savegamedata
#macro ENSURE_RAPTOR_SAVEGAMEDATA	ENSURE_GLOBALDATA; if (!struct_exists(GLOBALDATA, "__raptor_savegamedata"))	RAPTOR_SAVEGAMEDATA = {};
ENSURE_RAPTOR_SAVEGAMEDATA;

// This macro is used internally on objects that push their own data
// into the savegame. __raptordata is the root of internal data structs
#macro ENSURE_RAPTORDATA	vsgetx(self, "data", {}); vsgetx(data, "__raptordata", {});
#macro __RAPTORDATA			data.__raptordata

// strings in this list will not be persisted in a savegame. see savegame_ignore(...)
#macro __SAVEGAME_IGNORE	"##_raptor_##.__savegame_ignored"

// json headers
#macro __SAVEGAME_GLOBAL_DATA_HEADER	"global_data"
#macro __SAVEGAME_REFSTACK_HEADER		"refstack"
#macro __SAVEGAME_ENGINE_HEADER			"engine"
#macro __SAVEGAME_INSTANCE_PREFIX		"inst"
#macro __SAVEGAME_DATA_HEADER			"data"
#macro __SAVEGAME_OBJECT_HEADER			"instances"
#macro __SAVEGAME_STRUCT_HEADER			"structs"
										
#macro __SAVEGAME_OBJ_PROP_OBJ			"obj"
#macro __SAVEGAME_OBJ_PROP_ID			"__raptor_savegame_ref_id"
#macro __SAVEGAME_OBJ_PROP_X			"x"
#macro __SAVEGAME_OBJ_PROP_Y			"y"
#macro __SAVEGAME_OBJ_PROP_DIR			"direction"
#macro __SAVEGAME_OBJ_PROP_SPD			"speed"
#macro __SAVEGAME_OBJ_PROP_LAYER		"layer"
#macro __SAVEGAME_OBJ_PROP_DEPTH		"depth"
#macro __SAVEGAME_OBJ_PROP_VIS			"visible"
#macro __SAVEGAME_OBJ_PROP_PERS			"persistent"
#macro __SAVEGAME_OBJ_PROP_SOLID		"solid"
#macro __SAVEGAME_OBJ_PROP_SPRITE_NAME	"__raptor_savegame_sprite_name"
#macro __SAVEGAME_OBJ_PROP_SPRITE		"sprite_index"
#macro __SAVEGAME_OBJ_PROP_IMAGE		"img_index"
#macro __SAVEGAME_OBJ_PROP_ISPEED		"image_speed"
#macro __SAVEGAME_OBJ_PROP_ALPHA		"image_alpha"
#macro __SAVEGAME_OBJ_PROP_ANGLE		"image_angle"
#macro __SAVEGAME_OBJ_PROP_BLEND		"image_blend"
#macro __SAVEGAME_OBJ_PROP_XSCALE		"image_xscale"
#macro __SAVEGAME_OBJ_PROP_YSCALE		"image_yscale"
										
#macro __SAVEGAME_ENGINE_SEED			"seed"
#macro __SAVEGAME_DATA_FILE				"data_file"
#macro __SAVEGAME_ENGINE_VERSION		"file_version"
#macro __SAVEGAME_ENGINE_ROOM_NAME		"room_name"
#macro __SAVEGAME_ENGINE_COUNTUP_ID		"countup_id"
										
#macro __SAVEGAME_ONSAVING_NAME			"onGameSaving"
#macro __SAVEGAME_ONSAVED_NAME			"onGameSaved"
#macro __SAVEGAME_ONLOADING_NAME		"onGameLoading"
#macro __SAVEGAME_ONLOADED_NAME			"onGameLoaded"

#macro __SAVEGAME_ONSAVING_FUNCTION		onGameSaving
#macro __SAVEGAME_ONSAVED_FUNCTION		onGameSaved
#macro __SAVEGAME_ONLOADING_FUNCTION	onGameLoading
#macro __SAVEGAME_ONLOADED_FUNCTION		onGameLoaded

#macro __SAVEGAME_REF_MARKER			"##_savegame_ref_##."
#macro __SAVEGAME_STRUCT_REF_MARKER		"##_savegame_structref_##."

enum savegame_event {
	onGameSaving = 14,
	onGameLoaded = 15,
}

#region STRUCTS
/// @func	savegame_ignore(_members...)
/// @desc	Mark members of this struct class to be ignored when saved.
///			Those members will not even persist their name in the savegame.
function savegame_ignore(_members) {
	for (var i = 0; i < argument_count; i++)
		self[$ __SAVEGAME_IGNORE] = string_concat(
			vsget(self, __SAVEGAME_IGNORE, "|"),
			argument[@i], "|"
		);
}

#endregion

/// @func savegame_exists(_filename)
/// @desc	Checks, whether the specified savegame exists. Takes the
///					SAVEGAME_FOLDER configuration path into account
function savegame_exists(_filename) {
	return file_exists_html_safe(string_concat(SAVEGAME_FOLDER, _filename));
}

function __ensure_savegame_folder_name() {
	var adder = "";
	if (!string_is_empty(SAVEGAME_FOLDER) && !string_ends_with(SAVEGAME_FOLDER, "/")) adder = "/";
	return string_concat(SAVEGAME_FOLDER, adder);
}

// initialize the structs and variables
SAVEGAME_LOAD_IN_PROGRESS = false;
SAVEGAME_SAVE_IN_PROGRESS = false;