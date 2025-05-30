/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
*/

/// @func	savegame_save_struct_async(_filename, _data, _cryptkey = "")
/// @desc	This is an alias function, utilizing the undocumented third argument to
///			savegame_save_game, which will change the working style of save_game,
///			to persist only the supplied struct, but no instances, no globaldata, no room info, etc
///			Use this to "just save a struct" which you want to be restored exactly as you left it,
///			with all the comfort of constructors being called and references being restored when loaded
function savegame_save_struct_async(_filename, _data, _cryptkey = "") {
	return savegame_save_game_async(_filename, _cryptkey, _data);
}

/// @func	savegame_save_game_async(_filename, _cryptkey = "")
/// @desc	Saves the entire game state to a file.
function savegame_save_game_async(_filename, _cryptkey = "", _data_only = undefined) {

	if (!string_is_empty(SAVEGAME_FOLDER) && !string_starts_with(_filename, SAVEGAME_FOLDER)) _filename = __ensure_savegame_folder_name() + _filename;
	ilog($"[----- SAVING GAME TO '{_filename}' ({(_cryptkey == "" ? "plain text" : "encrypted")}) {(_data_only != undefined ? "(data only) " : "")}-----]");
	ilog($"SaveGame File Version {SAVEGAME_FILE_VERSION}");
	SAVEGAME_SAVE_IN_PROGRESS = true;
	
	var savegame = {};
	
	// First things first: The Engine data
	var engine = {};
	vsgetx(engine,		__SAVEGAME_ENGINE_VERSION	, SAVEGAME_FILE_VERSION);
	vsgetx(engine,		__SAVEGAME_DATA_FILE		, _data_only != undefined);
	vsgetx(savegame,	__SAVEGAME_STRUCT_HEADER	, _data_only ?? {});
	vsgetx(savegame,	__SAVEGAME_ENGINE_HEADER	, engine);

	if (_data_only == undefined) {
		var instances = {};
		vsgetx(savegame, __SAVEGAME_OBJECT_HEADER, instances);
		// Save everything (classic savegame)
		BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_SAVING);
	
		if (vsget(GAMECONTROLLER, __SAVEGAME_ONSAVING_NAME)) with(GAMECONTROLLER) __SAVEGAME_ONSAVING_FUNCTION();
		if (vsget(ROOMCONTROLLER, __SAVEGAME_ONSAVING_NAME)) with(ROOMCONTROLLER) __SAVEGAME_ONSAVING_FUNCTION();
	
		vsgetx(engine,		__SAVEGAME_ENGINE_SEED		, random_get_seed());
		vsgetx(engine,		__SAVEGAME_ENGINE_ROOM_NAME	, room_get_name(room));
		vsgetx(engine,		__SAVEGAME_ENGINE_COUNTUP_ID, global.__unique_count_up_id);
			
		// save global data
		vsgetx(savegame,	__SAVEGAME_GLOBAL_DATA_HEADER, GLOBALDATA);

		var cnt = 0;
		with (Saveable) {
			if (add_to_savegame) {
				if (vsget(self, __SAVEGAME_ONSAVING_NAME))
					__SAVEGAME_ONSAVING_FUNCTION();
				event_user(savegame_event.onGameSaving);
			
				var instname = __SAVEGAME_INSTANCE_PREFIX + string(cnt);
				var obj = object_get_name(object_index);
				var instdata = {
					__SAVEGAME_OBJ_PROP_OBJ			: obj,
					__SAVEGAME_OBJ_PROP_ID			: real(id),
					__SAVEGAME_OBJ_PROP_SKIN_FLAVOR	: skin_flavor,
					__SAVEGAME_OBJ_PROP_X			: x,
					__SAVEGAME_OBJ_PROP_Y			: y,
					__SAVEGAME_OBJ_PROP_DIR			: direction,
					__SAVEGAME_OBJ_PROP_SPD			: speed,
					__SAVEGAME_OBJ_PROP_LAYER		: (layer == -1 ? -1 : layer_get_name(layer)),
					__SAVEGAME_OBJ_PROP_DEPTH		: depth,
					__SAVEGAME_OBJ_PROP_VIS			: visible,
					__SAVEGAME_OBJ_PROP_PERS		: persistent,
					__SAVEGAME_OBJ_PROP_SOLID		: solid,
					__SAVEGAME_OBJ_PROP_SPRITE_NAME : (sprite_index != -1 ? sprite_get_name(sprite_index) : undefined),
					__SAVEGAME_OBJ_PROP_SPRITE		: sprite_index,
					__SAVEGAME_OBJ_PROP_IMAGE		: (sprite_index != -1 ? (image_index??0) : 0),
					__SAVEGAME_OBJ_PROP_ISPEED		: image_speed,
					__SAVEGAME_OBJ_PROP_ALPHA		: image_alpha,
					__SAVEGAME_OBJ_PROP_ANGLE		: image_angle,
					__SAVEGAME_OBJ_PROP_BLEND		: image_blend,
					__SAVEGAME_OBJ_PROP_XSCALE		: image_xscale,
					__SAVEGAME_OBJ_PROP_YSCALE		: image_yscale,
				}
				
				vsgetx(self, __SAVEGAME_DATA_HEADER, {});
				
				if (is_struct(vsget(self, __SAVEGAME_DATA_HEADER)))
					instdata[$ __SAVEGAME_DATA_HEADER] = data;
				else
					instdata[$ __SAVEGAME_DATA_HEADER] = {};
				
				vsgetx(instances,instname,instdata);
				cnt++;
			}
		}
	}
	
	ilog($"Removing object instance pointers...");
	var refstack = {};
	var struct_to_save = __savegame_remove_pointers(savegame, refstack);
	struct_to_save[$ __SAVEGAME_REFSTACK_HEADER] = refstack;
	
	return file_write_struct_async(_filename, struct_to_save, _cryptkey)
	.__raptor_data("only", _data_only)
	.__raptor_finished(function(res, _buffer, _data) {
		SAVEGAME_SAVE_IN_PROGRESS = false;

		// invoke the post event
		if (_data.only == undefined) {
			with (Saveable) {
				if (add_to_savegame && variable_instance_exists(self, __SAVEGAME_ONSAVED_NAME))
					__SAVEGAME_ONSAVED_FUNCTION(res);
			}
	
			if (vsget(ROOMCONTROLLER, __SAVEGAME_ONSAVED_NAME)) with(ROOMCONTROLLER) __SAVEGAME_ONSAVED_FUNCTION(res);
			if (vsget(GAMECONTROLLER, __SAVEGAME_ONSAVED_NAME)) with(GAMECONTROLLER) __SAVEGAME_ONSAVED_FUNCTION(res);	

			BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_SAVED, { success: res });
		} else		
			BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_DATA_GAME_SAVED, { success: res });
			
		ilog($"[----- SAVING GAME FINISHED -----]");
	})
	.on_failed(function(_data) {
		elog($"[----- SAVING GAME **FAILED** -----]");
	});

}
