/*
    The ListPool is a simple class with an add and remove method.
	It is used by self-managing script classes like Animation and StateMachine
	that manage themselves in lists to be processed by controller objects, like
	the RoomController (which controls animations and state machines).
*/

/// @func	ListPool(_name = "listPool")
/// @desc	Create a new ListPool. 
function ListPool(_name = "listPool") constructor {
	construct(ListPool);
	
	name = _name;
	list = [];
	__listcount = 0;

	/// @func		remove(obj)
	/// @desc	Removes an object from the pool
	/// @param {any} obj	The object to remove
	static remove = function(obj) {
		array_remove(list, obj);
		__listcount = array_length(list);
	}
	
	/// @func remove_where(_predicate, _data = undefined)
	/// @desc Remove all objects from the listpool where the predicate argument
	///				 returns true. This must be a function taking one argument and it
	///				 shall return whether to remove it (true) or not (false)
	/// @param {function} _predicate A function that shall return true, if the item is to remove, otherwise false
	///								 The function receives 2 arguments: (value, _data)
	/// @param {any} _data Any value you want to be passed into the _predicate as 2nd argument
	/// @returns {int}	 The number of entries removed
	static remove_where = function(_predicate, _data = undefined) {
		var removers = [];
		for (var i = 0, len = array_length(list); i < len; i++) {
			var val = list[@i];
			if (_predicate(val, _data))
				array_push(removers, val);
		}
		
		var rv = array_length(removers);
		array_foreach(removers, function(_item, _idx) {
			remove(_item);
		});
		__listcount = array_length(list);
		return rv;
	}
	
	/// @func		add(obj)
	/// @desc	Adds an object to the pool (if it is not already contained)
	/// @param {any} obj	The object to add
	static add = function(obj) {
		if (array_get_index(list, obj) == -1) {
			if (!variable_struct_exists(obj, "__listpool_processible"))
				obj.__listpool_processible = true;
			array_push(list, obj);
			if (DEBUG_LOG_LIST_POOLS)
				vlog($"Listpool '{name}' item added: newSize={size()};");
			__listcount = array_length(list);
		}
	}

	/// @func		size()
	/// @desc	Get the number of elements in the pool
	static size = function() {
		return __listcount;
	}
	
	/// @func		process_all(function_name = "step", ...)
	/// @desc	Invokes the named function on each element in the pool
	///					and forwards any additional parameters specified.
	///					This is done via self[$ function_name]() and NOT through
	///					script_execute, which would be very slow.
	///					NOTE: The function is called SCOPED in a with(list[@i])
	///					statement, which means, "self" in the function is the owner
	///					of the function.
	/// @param {string} function_name The function to invoke on each element
	/// @param {any...} up to 15 additional parameters that will be forwarded to the invoked function.
	static process_all = function(function_name = "step") {
		switch (argument_count) {
			case  1: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](); break;
			case  2: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1]); break;
			case  3: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2]); break;
			case  4: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3]); break;
			case  5: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4]); break;
			case  6: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5]); break;
			case  7: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: for (var i = 0; i < __listcount; i++) with(list[@i]) if (__listpool_processible) self[$ function_name](argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	}
	
	/// @func		clear()
	/// @desc	Remove all elements from the pool
	static clear = function() {
		list = [];
		__listcount = 0;
	}
	
	/// @func		dump()
	/// @desc	For debugging purposes. Prints all objects to the console
	static dump = function() {
		var i = 0;
		ilog($"[--- LIST POOL '{name}' DUMP START ---]");
		repeat(__listcount) {
			ilog($"#{i}: {list[@i]}");
			i++;
		}
		ilog($"[--- LIST POOL '{name}' DUMP  END  ---]");
	}

	/// @func		dump_to_string()
	/// @desc	For debugging purposes. Same as dump(), but returns a string instead of
	///					writing to the console
	static dump_to_string = function() {
		var i = 0;
		var rv = ($"[--- LIST POOL '{name}' DUMP START ---]\n");
		repeat(__listcount) {
			rv += string_concat("#", i, ":", list[@i], "\n");
			i++;
		}
		rv += $"[--- LIST POOL '{name}' DUMP  END  ---]\n";
		return rv;
	}

}

/// @func		__listpool_get_all_owner_objects(_listpool, owner)
/// @desc	INTERNAL FUNCTION. Retrieves all objects from a listpool for
///					a specified owner. Crashes if the objects do not have an "owner" member!
///					NOTE: You may set the "owner" parameter to <undefined> to retrieve ALL objects
function __listpool_get_all_owner_objects(_listpool, owner) {
	var rv = [];
	var lst = _listpool.list;
	for (var i = 0; i < _listpool.__listcount; i++) {
		var item = lst[@i];
		if (owner == undefined || item.owner.id == owner.id)
			array_push(rv, item);
	}

	return rv;
}

