/*
    RACE - The RAndom Content Engine
	
	A weightened rnd system for GameMaker
	(c)2022- coldrock.games, grisgram@github
*/

show_debug_message("RACE - The (RA)ndom (C)ontent (E)ngine loaded.");

#macro __RACE_CACHE				global.__race_cache
#macro __RACE_CACHE_CURRENT		__RACE_CACHE[$ __cache_name]

#macro ENSURE_RACE				if (!variable_global_exists("__race_cache"))  __RACE_CACHE  = {};
ENSURE_RACE;

#macro __RACE_TEMP_TABLE_PREFIX	"##_racetemp_##."

/// @func	Race(_filename, _load_async = true, _add_file_to_cache = RACE_CACHE_FILE_DEFAULT)
/// @desc	Create a new random content engine, optionally loading the file async
///			NOTE: When you load the file async, you may NOT use this race instance immediately after
///			creating it! Instead, you should add a callback through the on_load_finished(...) function
///			of this Race instance
///			Async loading should be the default and it should be done during game-startup
///			in the onLoadingScreen callback of the Game_Configuration script.
///			This callback handles all waiting and async management for you.
///			Recommendation: Load _all_ your Race files at startup async.
function Race(_filename = "", _load_async = true, _add_file_to_cache = RACE_CACHE_FILE_DEFAULT) constructor {
	construct(Race);

	tables = {}; // Holds the runtime tables for this Race
	
	__async_init_done = undefined;
	
	if (is_null(_filename)) {
		__cache_name = $"__#race_manual_instance#__{SUID}";
		vsgetx(__RACE_CACHE,  __cache_name, {}); // ensure, the file is created in the cache
		return; // if we come from savegame, no file is given
	}
	
	__filename = _filename;
	if (!string_starts_with(__filename, RACE_ROOT_FOLDER)) __filename = $"{RACE_ROOT_FOLDER}{__filename}";
	if (!string_ends_with(__filename, DATA_FILE_EXTENSION)) __filename += DATA_FILE_EXTENSION;
	
	__filename = __clean_file_name(__filename);
	if (!file_exists_html_safe(__filename)) {
		elog($"** ERROR ** race table file '{__filename}' not found!");
		return;
	}

	__cache_name	= string_replace_all(string_replace_all(__filename, "/", "_"), "\\", "_");
	vsgetx(__RACE_CACHE,  __cache_name, {}); // ensure, the file is created in the cache

	if (_load_async) {
		file_read_struct_async(__filename, FILE_CRYPT_KEY, _add_file_to_cache)
		.__raptor_data("inst", self)
		.__raptor_finished(function(_prev, _buffer, _data) {
			with(_data.inst) {
				__process_table_file(_prev);
				invoke_if_exists(self, __async_init_done);
			}
		});
	} else {
		var tablefile = file_read_struct(__filename, FILE_CRYPT_KEY, _add_file_to_cache);
		__process_table_file(tablefile);
	}

	/// @func __process_table_file(tablefile)
	static __process_table_file = function(tablefile) {
		if (tablefile != undefined) {
			var names = struct_get_names(tablefile);
			var tablecnt = array_length(names);
			
			if (DEBUG_LOG_RACE)
				ilog($"Successfully loaded {tablecnt} table(s) from '{__filename}'");
			for (var i = 0; i < tablecnt; i++) {
				var name = names[@i];
				var table = struct_get(tablefile, name);
				__put_to_cache(name, table);
				add_table(__clone_from_cache(name));
			}
		} else
			elog($"** ERROR ** Failed to load race table file '{__filename}'!")
	}

	/// @func	on_load_finished(_callback)
	/// @desc	Register a function to be invoked when the async loading of this instance
	///			is finished.
	static on_load_finished = function(_callback) {
		__async_init_done = _callback;
		return self;
	}
	
	/// @func __is_in_cache(_name)
	static __is_in_cache = function(_name) {
		return vsget(__RACE_CACHE_CURRENT, _name) != undefined;
	}
	
	/// @func __put_to_cache(_name, _table)
	static __put_to_cache = function(_name, _table) {
		struct_set(__RACE_CACHE_CURRENT, _name, _table);
	}
	
	/// @func __clone_from_cache(_name)
	static __clone_from_cache = function(_name) {
		var cpy = deep_copy(vsget(__RACE_CACHE_CURRENT, _name));
		return new RaceTable(_name, cpy);
	}
	
	/// @func add_table(_race_table, _overwrite_if_exists = true)
	/// @desc Add a class instance of type RaceTable to the tables of this Race
	static add_table = function( _race_table, _overwrite_if_exists = true) {
		if (_overwrite_if_exists || vsget(tables, _race_table.name) == undefined) {
			_race_table.race = self;
			struct_set(tables, _race_table.name, _race_table);
		} else {
			elog($"** ERROR ** add_table('{_race_table.name}') failed. A table with that name already exists!");
		}
		return self;
	}
	
	/// @func get_table(_name)
	static get_table = function(_name) {
		return vsget(tables, _name);
	}
	
	/// @func remove_table(_name, _clear_global_cache = false)
	/// @desc Remove the specified table from this Race
	static remove_table = function(_name, _clear_global_cache = false) {
		if (table_exists(_name)) {
			tables[$ _name].race = undefined; // clear the circular pointer
			struct_remove(tables, _name);
			if (_clear_global_cache)
				struct_remove(__RACE_CACHE_CURRENT, _name);
			if (DEBUG_LOG_RACE)
				vlog($"Race table '{_name}' has been removed");
		}
		return self;
	}
	
	/// @func reset_table(_name, _recursive = true)
	/// @desc Reset the specified table to its original state it had, when it was loaded from the file
	static reset_table = function(_name, _recursive = true) {
		if (string_starts_with(_name, __RACE_TEMP_TABLE_PREFIX)) {
			elog($"** ERROR ** Cloned temp race table '{_name}' can not be reset!");
			return self;
		}
		
		if (!__is_in_cache(_name)) {
			elog($"** ERROR ** Manually added race table '{_name}' can not be reset!");
			return self;
		}

		var items = tables[$ _name].items;
		var names = struct_get_names(items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var name = names[@ i];
			var typename = items[$ name].type;
			if (_recursive && string_starts_with(typename, "=")) 
				reset_table(string_skip_start(typename, 1), _recursive);
			if (string_starts_with(name, __RACE_TEMP_TABLE_PREFIX))
				struct_remove(tables, name);
		}
		
		add_table(__clone_from_cache(_name));
		if (DEBUG_LOG_RACE)
			vlog($"Race table '{_name}' has been reset{(_recursive ? " (recursive)" : "")}");

		return self;
	}

	/// @func __get_unique_clone_name(_name)
	static __get_unique_clone_name = function(_name) {
		var i = 0;
		var newname;
		do {
			newname = string_concat(__RACE_TEMP_TABLE_PREFIX, _name, i);
			i++;
		} until (!table_exists(newname));
		return newname;
	}
	
	/// @func clone_table(_name)
	/// @desc Clones the specified table to a TEMP table with a unique name. 
	///		  This new table is returned and you can get the name from the .name property of the table.
	static clone_table = function(_name) {
		var newname = __get_unique_clone_name(_name);
		// remove the race pointer to avoid endless loop (circular reference)
		tables[$ _name].race = undefined;
		var cpy = deep_copy(tables[$ _name]);
		tables[$ _name].race = self;
		
		cpy.race = self;
		cpy.name = newname;
		add_table(cpy);
		if (DEBUG_LOG_RACE)
			vlog($"Race table '{_name}' has been cloned into '{newname}'");
		return cpy;
	}
	
	/// @func table_exists(_name)
	/// @desc Checks whether a table with the specified name exists in this Race
	static table_exists = function(_name) {
		return vsget(tables, _name) != undefined;
	}
	
	/// @func clear(_clear_global_cache = false)
	/// @desc Removes all tables from this Race and, optionally, from the global cache
	static clear = function(_clear_global_cache = false) {
		var names = struct_get_names(tables);
		for (var i = 0, len = array_length(names); i < len; i++)
			remove_table(names[@ i], _clear_global_cache);
	}

	/// @func	query_table(_name, _layer_name_or_depth = undefined, _pool_name = "")
	/// @desc	Perform a loot query on the specified table
	/// @returns {array}	Returns the "loot". This is an array of RaceItem instances.
	///			Each RaceItem offers these properties:
	///				instance	= The dropped instance (or undefined, if no layer was given)
	///				table_name	= The name of the table, where it came from
	///				item_name	= The item name in the table
	///				item		= The item struct (also contains the .attributes)
	///				
	///			* All contained instances already exist on the layer.
	///			* Their onCreate events have already been executed.
	///			* If no drop was generated, instance contains undefined.
	/// @param  {string} _name		The race table to query
	/// @param  {string=""} _layer_name_or_depth	Optional. 
	///			If not supplied, no items will be dropped by the query and all "instance"
	///			members of the returned RaceItems will be undefined.
	///			LOOT IS STILL GENERATED! There are just no items spawned.
	/// @param {string=""} pool_name	Optional. If supplied, objects will be taken from the
	///									specified ObjectPool, so less new instances are created.
	static query_table = function(_name, _layer_name_or_depth = undefined, _pool_name = "") {
		with(tables[$ _name]) return query(_layer_name_or_depth, _pool_name);
	}
	
	toString = function() {
		return $"Race '{__filename}'";
	}
}