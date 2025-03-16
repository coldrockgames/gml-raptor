/*
    Management class for one single loot table of the Race system
*/

/// @func RaceTable(_name, _table_struct)
function RaceTable(_name = "", _table_struct = undefined) constructor {
	construct(RaceTable);
	
	// the member "items" comes from the json file - it is not declared here
	race = undefined;
	name = _name;

	if (_table_struct != undefined) { // if we come from savegame, no struct is given
		struct_join_into(self, RACE_LOOT_DATA_DEEP_COPY ? deep_copy(_table_struct) : _table_struct);
		// create attributes as empty struct if they don't exist
		var names = struct_get_names(items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			vsgetx(items[$ names[@i]], "attributes", {});
			items[$ names[@i]].name = names[@i];
		}
		vsgetx(self, "loot_count", 1);
	}
	
	#region query
	/// @func	query(_layer_name_or_depth = undefined, _pool_name = "")
	/// @desc	Perform a loot query.
	///			NOTE: If you do not supply a _layer_name_or_depth, NO INSTANCES
	///			will be created by the query() function!
	///			You can batch-create all instances from the result set through
	///			create_instances(queryresult) on this table afterwards.
	static query = function(_layer_name_or_depth = undefined, _pool_name = "") {
		var drop_instances = !is_null(_layer_name_or_depth);
		loot_count = max(0, loot_count);

		var unique_drops = [];
		var rv = [];

		__query_recursive(rv, unique_drops);
		if (drop_instances) {
			for (var i = 0, len = array_length(rv); i < len; i++) 
				if (!is_null(rv[@i].item.type))
					__drop_item(rv[@i], _layer_name_or_depth, _pool_name);
		}
	
		return rv;
	}

	/// @func	create_instances(_query_result, _layer_name_or_depth, _pool_name)
	/// @desc	Creates object instances from a given query result.
	///			If the item structs already contain instances, they are overwritten.
	///			This method has two use cases:
	///			1) You queried a table without a layer, just to prepare a result,
	///			   then you changed room to the action scene and _now_ want the instances
	///			2) You kept this result to be used multiple times.
	///			Returns an array of instances. The "onRaceDrop" callback has already been executed.
	static create_instances = function(_query_result, _layer_name_or_depth, _pool_name) {
		var rv = [];
		for (var i = 0, len = array_length(_query_result); i < len; i++) {
			if (!is_null(_query_result[@i].item.type))
				array_push(rv, __drop_item(_query_result[@i], _layer_name_or_depth, _pool_name));
		}
		return rv;
	}

	/// @func __query_recursive(result, uniques)
	static __query_recursive = function(_result, _uniques) {
		// first, all enabled elements that are set to "always" will be part of the drop
		var names = struct_get_names(items);
		var always_enabled_count = 0;
		var itemname;
		var item;
		for (var i = 0, len = array_length(names); i < len; i++) {
			itemname = names[i];
			item = items[$ itemname];
			if (item.enabled && item.always) {
				if (DEBUG_LOG_RACE)
					vlog($"Adding always-enabled item to loot result: {itemname}");
				always_enabled_count++;
				__add_to_result(_result, _uniques, itemname, item);
			}
		}
		// calculate the real drop count 
		// (this is, the remaining items to drop after all always-enabled have been added)
		var real_drop_count = loot_count - always_enabled_count;
	
		for (var drop_i = 0; drop_i < real_drop_count; drop_i++) {
			// Find all items that CAN drop now
			// (that are all those that are enabled but NOT always, have a chance > 0 and
			// are EITHER not unique OR unique but not already part of the uniques list)
			var dropables = [];
			var look_for;
			for (var i = 0, len = array_length(names); i < len; i++) {
				itemname = names[i];
				item = items[$ itemname];
				look_for = string_concat(itemname, "@", name);
				if (  item.enabled && 
					(!item.always  || !item.unique) && 
					  item.chance  > 0 &&
					(!item.unique  || !array_contains(_uniques, look_for))) {
						array_push(dropables, itemname);
				}
			}
		
			// get the chance sum (that is the sum of all chances of all dropable items)
			var chance_sum = 0.0;
			for (var i = 0, len = array_length(dropables); i < len; i++) {
				item = items[$ dropables[@i]];
				chance_sum += item.chance;
			}
		
			// this value determines, which item will drop!
			var hit_value = random(chance_sum);
			var running_value = 0;
			for (var i = 0, len = array_length(dropables); i < len; i++) {
				itemname = dropables[@i];
				item = items[$ itemname];
				running_value += item.chance
				if (hit_value < running_value) {
					__add_to_result(_result, _uniques, itemname, item);
					break;
				}
			}
		}
	}

	/// @func __add_to_result(_result, _uniques, _name, _item)
	static __add_to_result = function(_result, _uniques, _name, _item) {
		if (_item.unique)
			array_push(_uniques, string_concat(_name, "@", name));
	
		var typename = _item.type;
		if (string_starts_with(typename, "=")) {
			// go into recursion
			typename = string_skip_start(typename, 1);
			// ATTENTION! The split in several local variables is for HTML
			// It breaks with the nested struct access
			var tbls = race.tables;
			var tbl = tbls[$ typename];
			tbl.__query_recursive(_result, _uniques);
			//race.tables[$ typename].__query_recursive(_result, _uniques);
		} else if (string_starts_with(typename, "+")) {
			// deep copy, THEN go into recursion
			typename = string_skip_start(typename, 1);
			// ATTENTION! The split in several local variables is for HTML
			// It breaks with the nested struct access
			var deepcopy = race.clone_table(typename);
			var newname = deepcopy.name;
			// find a free new name for the deep copy
			_item.type = $"={newname}";
			if (DEBUG_LOG_RACE)
				vlog($"Added dynamic global race table: '{newname}'");
			var tbls = race.tables;
			var tbl = tbls[$ newname];
			tbl.__query_recursive(_result, _uniques);
		} else {
			array_push(_result, new RaceResult(_item, _name, name));
		}
	}

	/// @func __drop_item(_drop, _layer_name_or_depth, _pool_name)
	static __drop_item = function(_drop, _layer_name_or_depth, _pool_name) {
		var itemtype = _drop.item.type;
		if (DEBUG_LOG_RACE)
			vlog($"Dropping item: object='{itemtype}'; layer='{_layer_name_or_depth}'; pool='{_pool_name};");
		var dropx = vsget(self, "x", 0);
		var dropy = vsget(self, "y", 0);
		_drop.instance = undefined;
		if (is_null(_pool_name))
			_drop.instance = instance_create(
				dropx ?? 0, 
				dropy ?? 0, 
				_layer_name_or_depth, 
				asset_get_index(itemtype),
				vsget(_drop.item, "init")
			);
		else {
			_drop.instance = pool_get_instance(
				_pool_name, 
				asset_get_index(itemtype), 
				_layer_name_or_depth,
				vsget(_drop.item, "init")
			);
			_drop.instance.x = dropx ?? 0;
			_drop.instance.y = dropy ?? 0;
		}
	
		_drop.instance.data.race_item = _drop.item;
		invoke_if_exists(_drop.instance, "onRaceDrop", _drop.item);
		
		if (DEBUG_LOG_RACE) 
			dlog($"Dropped item: instance='{name_of(_drop.instance)}'; object='{itemtype}'; layer='{_layer_name_or_depth}';");
		
		return _drop.instance;
	}

	#endregion
	
	#region batch methods and filtering
	
	/// @func	reset(_recursive = true)
	/// @desc	Reset this table to the state when it was loaded from file.
	///			NOTE: Temp tables and manually added tables can not be reset!
	static reset = function(_recursive = true) {
		race.reset_table(name, _recursive);
		return self;
	}
	
	/// @func filter_items(_items = undefined)
	/// @desc Returns a new RaceItemFilter builder for all items of this table,
	///       or for a subset of pre-filtered items, if you supply a filter result as argument
	static filter_items = function(_items = undefined) {
		return new RaceItemFilter(_items ?? items);
	}
	
	/// @func set_all_enabled(_enabled, _items = undefined)
	/// @desc Sets all items, or optionally a filtered item set, to the specified enabled value
	static set_all_enabled = function(_enabled, _items = undefined) {
		_items ??= items;
		var names = struct_get_names(_items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			_items[$ names[@i]].enabled = _enabled;
		}
	}
	
	/// @func set_all_unique(_unique, _items = undefined)
	/// @desc Sets all items, or optionally a filtered item set, to the specified unique value
	static set_all_unique = function(_unique, _items = undefined) {
		_items ??= items;
		var names = struct_get_names(_items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			_items[$ names[@i]].unique = _unique;
		}
	}

	/// @func set_all_always(_always, _items = undefined)
	/// @desc Sets all items, or optionally a filtered item set, to the specified always value
	static set_all_always = function(_always, _items = undefined) {
		_items ??= items;
		var names = struct_get_names(_items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			_items[$ names[@i]].always = _always;
		}
	}

	/// @func set_all_chances(_chance, _items = undefined)
	/// @desc Sets all items, or optionally a filtered item set, to the specified chance value
	static set_all_chances = function(_chance, _items = undefined) {
		_items ??= items;
		var names = struct_get_names(_items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			_items[$ names[@i]].chance = _chance;
		}
	}

	/// @func set_all_chances_modify_by(_delta, _items = undefined)
	/// @desc Modifies all chances, or optionally a filtered item set, by the specified delta
	static set_all_chances_modify_by = function(_delta, _items = undefined) {
		_items ??= items;
		var names = struct_get_names(_items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			_items[$ names[@i]].chance += _delta;
		}
	}

	/// @func set_all_chances_multiply_by(_multiply, _items = undefined)
	/// @desc Multiplies all chances, or optionally a filtered item set, by the specified multiplier
	static set_all_chances_multiply_by = function(_multiply, _items = undefined) {
		_items ??= items;
		var names = struct_get_names(_items);
		for (var i = 0, len = array_length(names); i < len; i++) {
			_items[$ names[@i]].chance *= _multiply;
		}
	}
	
	#endregion
}

/// @func	RaceTableStruct(_loot_count = 1) constructor
/// @desc	Create a new, empty race table struct
function RaceTableStruct(_loot_count = 1) constructor {
	// DO NOT USE THE construct(...) COMMAND HERE!
	// THIS STRUCT MAY NOT HAVE ADDITIONAL MEMBERS!
	loot_count	= _loot_count;
	items		= {};
}