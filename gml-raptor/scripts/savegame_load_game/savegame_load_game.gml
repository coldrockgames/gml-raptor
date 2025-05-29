/*
	Utility methods to work with savegame files.
	All objects that have [Saveable] as their parent in the inheritance chain will be
	saved to the save game as long as the declared instance variable [add_to_savegame] is true (which is the default).
	
	(c)2022- coldrock.games, @grisgram at github
*/

/// @func	savegame_load_struct_async(_filename, cryptkey)
/// @desc	This is the sister-function to savegame_save_struct_async
///			The "data" member of the .on_finished(...) callback is the struct loaded
function savegame_load_struct_async(_filename, cryptkey = "") {
	return savegame_load_game_async(_filename, cryptkey, undefined, true);
}

/// @func	savegame_load_game_async(_filename, cryptkey = "", _room_transition = undefined)
/// @desc	Loads a previously saved game state (see savegame_save_game_async).
function savegame_load_game_async(_filename, cryptkey = "", _room_transition = undefined, _load_data_only = false) {
	
	if (!string_is_empty(SAVEGAME_FOLDER) && !string_starts_with(_filename, SAVEGAME_FOLDER)) 
		_filename = __ensure_savegame_folder_name() + _filename;
		
	ilog($"[----- LOADING GAME FROM '{_filename}' ({(cryptkey == "" ? "plain text" : "encrypted")}) -----]");
	
	var reader = file_read_struct_async(_filename, cryptkey)
	.set_transaction_mode(true)
	.__raptor_data("trans", _room_transition)
	.__raptor_data("load_data_only", _load_data_only)
	.__raptor_data("filename", _filename)
	.__raptor_finished(function(savegame, _buffer, _data) {
		if (savegame == undefined) {
			elog($"** ERROR ** Could not load savegame '{_data.filename}'!");
			return false;
		}
		
		SAVEGAME_LOAD_IN_PROGRESS = true;

		// prepare refstack
		var refstack = vsget(savegame, __SAVEGAME_REFSTACK_HEADER);
		refstack.loaded_version = 0;
		refstack.savegame = savegame;
		refstack.restorestack = {};
		refstack.recover = method(refstack, function(_name, _from = undefined) {
			_from = _from ?? savegame;
			if (!is_string(_name))
				return _name;
			var rv = _from[$ _name];
			if (!is_method(rv)) {
				if (is_string(rv) && string_starts_with(rv, __SAVEGAME_STRUCT_REF_MARKER)) {
					rv = self[$ rv];
					_from[$ _name] = rv;
					var names = struct_get_names(rv);
					for (var i = 0, len = array_length(names); i < len; i++)
						recover(names[@i], rv);
				} else if (is_array(rv)) {
					recover_array(rv);
				} else if (is_struct(rv)) {
					var names = struct_get_names(rv);
					for (var i = 0, len = array_length(names); i < len; i++) 
						recover(rv[$ names[@i]]);
				}
			}
			return rv;
		});
		refstack.recover_array = method(refstack, function(_array) {
			var rv = _array;
			for (var i = 0, len = array_length(_array); i < len; i++) {
				rv = self[$ _array[@i]] ?? _array[@i];
				_array[@i] = rv;
				if (is_method(rv)) 
					continue;
				else if (is_string(rv) && string_starts_with(rv, __SAVEGAME_STRUCT_REF_MARKER)) {
					recover(rv);
				} else if (is_array(rv)) {
					recover_array(rv);
				} else if (is_struct(rv))
					recover_struct(rv);
			}
			return rv;
		});
		refstack.recover_struct = method(refstack, function(_struct) {
			var names = struct_get_names(_struct);
			for (var i = 0, len = array_length(names); i < len; i++) 
				recover(names[@i], _struct);
		});

		// load engine data
		var engine = refstack.recover(__SAVEGAME_ENGINE_HEADER);
		var data_only = _data.load_data_only || vsget(savegame.engine, __SAVEGAME_DATA_FILE, false);
		
		if (data_only)
			ilog($"Loading save game data only");
		else
			BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_LOADING);
			
		var loaded_version = vsgetx(engine, __SAVEGAME_ENGINE_VERSION, 1);
		if (!data_only) {
			random_set_seed(struct_get(engine, __SAVEGAME_ENGINE_SEED));
			global.__unique_count_up_id = vsget(engine, __SAVEGAME_ENGINE_COUNTUP_ID, 0);
		}
		
		refstack.loaded_version = loaded_version;
		ilog($"SaveGame File Version {loaded_version}");
	
		// restore room
		var me = self;
		var current_room_name = room_get_name(room);
		var room_name = vsget(engine, __SAVEGAME_ENGINE_ROOM_NAME, current_room_name);
		if (!data_only && room_name != current_room_name) {
			__SAVEGAME_CONTINUE_LOAD_STATE = {
				_savegame: savegame,
				_refstack: refstack,
				_engine: engine,
				_data_only: data_only,
				_loaded_version: loaded_version,
				_reader: me,
			};
		
			ilog($"Switching to room '{room_name}'");
			if (_data.trans != undefined) {
				_data.trans.target_room = asset_get_index(room_name);
				_data.trans.data ??= {};
				_data.trans.data.was_loading = true;
				ROOMCONTROLLER.transit(_data.trans);
			} else 
				room_goto(asset_get_index(room_name));

			return true;
		} else {
			ilog(data_only ? $"Continuing data file load..." : $"Continuing game load in current room...");
			TRY
				var rv = __continue_load_savegame(savegame, refstack, engine, data_only, loaded_version, self);
				return (data_only ? rv : true);
			CATCH
				invoke_failed();
				if (!data_only) {
					if (vsget(self, "onGameLoadFailed") != undefined)
						onGameLoadFailed(__exception);
					BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_LOADED, { success: false });
				}
				return false;
			ENDTRY

		}
	})
	.on_failed(function() {
		elog($"[----- LOADING GAME **FAILED** -----]");
	});
	
	return reader;
}

function __continue_load_savegame(savegame, refstack, engine, data_only, loaded_version, reader) {
	if (!data_only) {
		if (vsget(GAMECONTROLLER, __SAVEGAME_ONLOADING_NAME)) with(GAMECONTROLLER) __SAVEGAME_ONLOADING_FUNCTION();
		if (vsget(ROOMCONTROLLER, __SAVEGAME_ONLOADING_NAME)) with(ROOMCONTROLLER) __SAVEGAME_ONLOADING_FUNCTION();
	}

	// recover structs and globaldata into the savegame
	if (data_only)
		struct_set(savegame, __SAVEGAME_STRUCT_HEADER, refstack.recover(__SAVEGAME_STRUCT_HEADER));
	else
		struct_set(savegame, __SAVEGAME_GLOBAL_DATA_HEADER, refstack.recover(__SAVEGAME_GLOBAL_DATA_HEADER));

	var created_instances	= [];
	var instance_id_map		= {};
	// If data_only is specified, we do skip over the instance part
	var restorestack	= {};
	if (!data_only) {
		// recreate object instances
		with (Saveable) if (add_to_savegame) instance_destroy();
	
		var instances		= refstack.recover(__SAVEGAME_OBJECT_HEADER);
		var names			= struct_get_names(instances);
		
		for (var i = 0, len = array_length(names); i < len; i++) {
			var inst	= vsget(instances, names[i]);
			var obj		= vsget(inst, __SAVEGAME_OBJ_PROP_OBJ);
			// since 2023.1 there's an empty struct added silently to each serialized file.
			// we need to skip this empty mess
			if (obj == undefined || obj == -1) continue; 
			
			var lname	= vsget(inst, __SAVEGAME_OBJ_PROP_LAYER);
			var ldepth  = vsget(inst, __SAVEGAME_OBJ_PROP_DEPTH, 0);
			var xpos	= vsget(inst, __SAVEGAME_OBJ_PROP_X, 0);
			var ypos	= vsget(inst, __SAVEGAME_OBJ_PROP_Y, 0);
		
			var asset_idx = asset_get_index(obj);
		
			var created = (lname != -1 && !is_null(lname)) ? 
				instance_create_layer(xpos,ypos,lname,asset_idx) : 
				instance_create_depth(xpos,ypos,ldepth,asset_idx);
		
			array_push(created_instances, created);
		
			with (created) {
				direction		= vsget(inst, __SAVEGAME_OBJ_PROP_DIR, 0);
				speed			= vsget(inst, __SAVEGAME_OBJ_PROP_SPD, 0);
				var sprname		= vsget(inst, __SAVEGAME_OBJ_PROP_SPRITE_NAME);
				sprite_index	= sprname != undefined ?
								  asset_get_index(sprname) :
								  vsget(inst, __SAVEGAME_OBJ_PROP_SPRITE);
				image_index		= vsget(inst, __SAVEGAME_OBJ_PROP_IMAGE, 0); 
				image_speed		= vsget(inst, __SAVEGAME_OBJ_PROP_ISPEED, 1);
				image_alpha		= vsget(inst, __SAVEGAME_OBJ_PROP_ALPHA, 1); 
				image_angle		= vsget(inst, __SAVEGAME_OBJ_PROP_ANGLE, 0); 
				image_blend		= vsget(inst, __SAVEGAME_OBJ_PROP_BLEND, c_white);
				image_xscale	= vsget(inst, __SAVEGAME_OBJ_PROP_XSCALE, 1); 
				image_yscale	= vsget(inst, __SAVEGAME_OBJ_PROP_YSCALE, 1);
				visible			= vsget(inst, __SAVEGAME_OBJ_PROP_VIS, true);
				persistent		= vsget(inst, __SAVEGAME_OBJ_PROP_PERS, false);
				solid			= vsget(inst, __SAVEGAME_OBJ_PROP_SOLID, false);

				// all instances add themselves to the instance list for link restore
				var cid = struct_get(inst, __SAVEGAME_OBJ_PROP_ID);
				struct_set(instance_id_map, string(cid), self); // add me to the loaded list

				var loaded_data = struct_get(inst, __SAVEGAME_DATA_HEADER);
				__file_reconstruct_class(data, loaded_data, restorestack);

				if (vsget(self, __SAVEGAME_ONLOADING_NAME))
					__SAVEGAME_ONLOADING_FUNCTION();
				
			}		
		}
	}

	var names = struct_get_names(instance_id_map);
	for (var i = 0, len = array_length(names); i < len; i++) {
		var n = names[@i];
		with (n) __savegame_restore_pointers(data, restorestack, instance_id_map);
	}
	
	// Now all instances are loaded... restore object links
	ilog($"Restoring object instance pointers...");
	struct_remove(savegame, __SAVEGAME_REFSTACK_HEADER);
	refstack = {};
	savegame = __file_reconstruct_root(savegame, restorestack);
	
	// Now replace the global pointers with the restored ones
	if (!data_only)
		GLOBALDATA	= vsget(savegame, __SAVEGAME_GLOBAL_DATA_HEADER);
		
	var instancenames = struct_get_names(instance_id_map);
	for (var i = 0, len = array_length(instancenames); i < len; i++) {
		var ini = instance_id_map[$ instancenames[@i]];
		__savegame_restore_pointers(ini.data, restorestack, instance_id_map);
	}

	// Savegame versioning
	if (SAVEGAME_FILE_VERSION > loaded_version) {
		// First, upgrade all data structs, as instances might depend on them
		BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_SAVEGAME_VERSION_CHECK, {
			file_version: loaded_version
		});
		// Then, upgrade all instances
		var method_name;
		for (var j = 0, jen = array_length(created_instances); j < jen; j++) {
			with(created_instances[@j]) {
				for (var i = loaded_version + 1; i <= SAVEGAME_FILE_VERSION; i++) {
					method_name = sprintf(SAVEGAME_UPGRADE_METHOD_PATTERN, i);
					if (variable_instance_exists(self, method_name) &&
						variable_instance_get(self, method_name) != undefined) {
						ilog($"{MY_NAME} Upgrading object to version {i}");
						self[$ method_name]();
					}
				}
			}
		}
	}
	
	SAVEGAME_LOAD_IN_PROGRESS = false;

	var rv = true;
	if (!data_only) {
		// invoke the post event
		for (var i = 0; i < array_length(instancenames); i++) {
			var inst = instance_id_map[$ instancenames[@i]];
			with (inst) {
				event_user(savegame_event.onGameLoaded);
				if (variable_instance_exists(self, __SAVEGAME_ONLOADED_NAME)) 
					__SAVEGAME_ONLOADED_FUNCTION();
			}
		}
		if (vsget(ROOMCONTROLLER, __SAVEGAME_ONLOADED_NAME)) with(ROOMCONTROLLER) __SAVEGAME_ONLOADED_FUNCTION();
		if (vsget(GAMECONTROLLER, __SAVEGAME_ONLOADED_NAME)) with(GAMECONTROLLER) __SAVEGAME_ONLOADED_FUNCTION();	
		
		BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_GAME_LOADED);
		reader.invoke_finished(); // full restore just tells you "savegame load ok"
	} else {
		rv = vsget(savegame, __SAVEGAME_STRUCT_HEADER, {});
		BROADCASTER.send(GAMECONTROLLER, __RAPTOR_BROADCAST_DATA_GAME_LOADED, { data: rv });
		reader.invoke_finished(rv); // data mode restore delivers the loaded structs data
	}
	ilog($"[----- LOADING GAME FINISHED -----]");

	return rv;
}
