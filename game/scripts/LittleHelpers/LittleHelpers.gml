
/// @func	is_between(val, lower_bound, upper_bound)
/// @desc	test if a value is between lower and upper (both INCLUDING!)
/// @param {real/int} val
/// @param {real/int} lower_bound
/// @param {real/int} upper_bound
/// @returns {bool} y/n
function is_between(val, lower_bound, upper_bound) {
	gml_pragma("forceinline");
	return val >= lower_bound && val <= upper_bound;
}

/// @func	is_between_ex(val, lower_bound, upper_bound)
/// @desc	test if a value is between lower and upper (both EXCLUDING!)
/// @param {real/int} val
/// @param {real/int} lower_bound
/// @param {real/int} upper_bound
/// @returns {bool} y/n
function is_between_ex(val, lower_bound, upper_bound) {
	gml_pragma("forceinline");
	return val > lower_bound && val < upper_bound;
}

/// @func	is_any_of(val, ...)
/// @desc	after val, specify any number of parameters.
///			determines if val is equal to any of them.
/// @param {any} val
/// @returns {bool}	y/n
function is_any_of(val) {
	for (var i = 1; i < argument_count; i++)
		if (val == argument[i]) return true;
	return false;
}

/// @func	percent(val, total)
/// @desc	Gets, how many % "val" is of "total"
/// @param {real} val	The value
/// @param {real} total	100%
/// @returns {real}	How many % of total is val. Example: val 30, total 50 -> returns 60(%)
function percent(val, total) {
	gml_pragma("forceinline");
	return (val/total) * 100;
}

/// @func	percent_mul(val, total)
/// @desc	Gets, how many % "val" is of "total" as multiplier (30,50 => 0.6)
/// @param {real} val
/// @param {real} total
/// @returns {real}	percent value as multiplier (0..1)
function percent_mult(val, total) {
	gml_pragma("forceinline");
	return (val/total);
}

/// @func	is_child_of(child, parent)
/// @desc	True, if the child is parent or derived anywhere from parent.
/// @param {object_index} child An object instance or object_index of the child to analyze
/// @param {object} parent		The object_index (just the type) of the parent to find
/// @returns {bool}
function is_child_of(child, parent) {
	if (is_null(child)) return false;
	if (is_string(child)) child = asset_get_index(child);
	if (!is_string(parent)) parent = typename_of(parent);

	return array_contains(object_tree(child), parent);
}

#macro __OBJECT_TREE_CACHE	global.__object_tree_cache
__OBJECT_TREE_CACHE = {};

#macro __OBJECT_HAS_NO_PARENT	-100
#macro __OBJECT_DOES_NOT_EXIST	-1

/// @func	object_tree(_object_or_instance, _as_strings = true)
/// @desc	Gets the entire object hierarchy as an array for the specified object type or instance.
///			At position[0] you will find the _object_or_instance's object_index and at the
///			last position of the array you will find the root class of the tree.
function object_tree(_object_or_instance, _as_strings = true) {
	if (_object_or_instance == undefined) 
		return undefined;
		
	var ind = is_object_instance(_object_or_instance) ? _object_or_instance.object_index : _object_or_instance;
	var obj_val  = _as_strings ? object_get_name(ind) : ind;
	
	var key = $"{obj_val}";
	var ocache = vsget(__OBJECT_TREE_CACHE, key);
	if (ocache != undefined)
		return ocache;
	
	var rv = [];
	var push_val = undefined;
	while (ind != __OBJECT_HAS_NO_PARENT && ind != __OBJECT_DOES_NOT_EXIST) {
		push_val = _as_strings ? object_get_name(ind) : ind;
		array_push(rv, push_val);
		ind = object_get_parent(ind);
	}
	
	__OBJECT_TREE_CACHE[$ key] = rv;
	return rv;
}

/// @func	name_of(_instance)
/// @desc	If _instance is undefined, undefined is returned,
///			otherwise MY_NAME or object_get_name of the instance is returned,
///			depending on the _with_ref_id parameter.
///			To cover the undefined scenario, this function is normally used like this:
///			var instname = name_of(my_instance) ?? "my default";
/// @param {object_index} _instance	The instance to retrieve the name of.
function name_of(_instance, _with_ref_id = true) {
	if (!is_null(_instance)) {
		if (is_object_instance(_instance))
			with(_instance) return _with_ref_id ? MY_NAME : object_get_name(object_index);
		else
			return $"{(is_struct(_instance) && struct_exists(_instance, __CONSTRUCTOR_NAME) ? $"{_instance[$ __CONSTRUCTOR_NAME]}{(_with_ref_id ? "-" : "")}" : "")}{(_with_ref_id ? address_of(_instance) : "")}";
	}
	
	return undefined;
}

/// @func	typename_of(_type)
/// @desc	Gets the type name (= asset name) of an asset
function typename_of(_type) {
	if (is_string(_type))
		return _type;

	var str = string(_type);
	
	if (string_starts_with(str, "ref animcurve"	))	return undefined; // gml does not have a function for this
	if (string_starts_with(str, "ref sequence"	))	return undefined; // gml does not have a function for this
	if (string_starts_with(str, "ref room"		))	return room_get_name(_type);	
	if (string_starts_with(str, "ref font"		))	return font_get_name(_type);	
	if (string_starts_with(str, "ref path"		))	return path_get_name(_type);	
	if (string_starts_with(str, "ref sound"		))	return audio_get_name(_type);	
	if (string_starts_with(str, "ref object"	))	return object_get_name(_type);	
	if (string_starts_with(str, "ref script"	))	return script_get_name(_type);
	if (string_starts_with(str, "ref sprite"	))	return sprite_get_name(_type);	
	if (string_starts_with(str, "ref shader"	))	return shader_get_name(_type);	
	if (string_starts_with(str, "ref tileset"	))	return tileset_get_name(_type);	
	if (string_starts_with(str, "ref timeline"	))	return timeline_get_name(_type);

	try {
		var scr = script_get_name(_type);
		if (!is_null(scr) || scr != "<undefined>")
			return scr;
	} catch (_) { }
	
	return undefined;
}

/// @func	address_of(_instance)
/// @desc	Similar to name_of, but returns only the pointer 
///			(a unique, but fake, pointer in html5) of the instance
///			as a string, without its type name or other informations
///			or undefined, when _instance is undefined
function address_of(_instance) {
	if (!is_null(_instance) && !is_string(_instance)) {
		if (IS_HTML) {
			if (!variable_global_exists("__raptor_html_struct_pointers")) {
				__FAKE_GAMECONTROLLER;
				global.__raptor_html_struct_pointers = [];
				global.__raptor_html_struct_pointer_counter = GAME_FRAME;
			}
			var wr = undefined;
			for (var i = 0, len = array_length(global.__raptor_html_struct_pointers); i < len; i++) {
				if (global.__raptor_html_struct_pointers[@i].ref == _instance) {
					wr = global.__raptor_html_struct_pointers[@i];
					break;
				}
			}
			if (wr == undefined) {
				wr = weak_ref_create(_instance);
				wr.__address_fake = SUID;
				array_push(global.__raptor_html_struct_pointers, wr);
			}

			if (GAME_FRAME - global.__raptor_html_struct_pointer_counter >= 300) {
				var removecnt = 0;
				for (var i = 0, len = array_length(global.__raptor_html_struct_pointers); i < len; i++) {
					if (!weak_ref_alive(global.__raptor_html_struct_pointers[@i])) {
						array_delete(global.__raptor_html_struct_pointers, i, 1);
						i--;
						len--;
						removecnt++;
					}
				}
				global.__raptor_html_struct_pointer_counter = GAME_FRAME;
				dlog($"Raptor html weak ref cleanup removed {removecnt} dead refs");
			}
			
			return $"ptr_{wr.__address_fake}";
		} else {
			var i = 1;
			var p = $"{ptr(_instance)}";
			while (string_char_at(p, i) == "0") i++;
			return $"{string_skip_start(p, i - 1)}";
		}
	}
	return undefined;
}

/// @func	asset_of(_expression)
/// @desc	Checks whether _expression is the NAME of an asset (like "objEnemy") 
///			and returns asset_get_index(_expression) if yes, otherwise _expression is returned.
function asset_of(_expression) {
	gml_pragma("forceinline");
	return is_string(_expression) ? asset_get_index(_expression) : _expression;
}

/// @func	layer_of(_instance)
/// @desc	retrieve the layer name or depth of _instance
///			if instance is nullish, -1 is returned (gms default for "no layer")
function layer_of(_instance) {
	if (!is_null(_instance))
		with(_instance) return MY_LAYER_OR_DEPTH;
	return -1;
}

/// @func	construct_or_invoke(_script, args...)
/// @desc	Now, that's an ugly one, I know, but at the moment of writing this, GameMaker
///			has no way to tell normal functions apart from constructors.
///			There's not other way, to find out, as to fall in a catch if constructing fails.
function construct_or_invoke(_script) {
	if (_script == undefined || _script == -1 || !is_callable(_script))
		return undefined;
		
	var res;
	try {
		switch (argument_count) {
			case  1: res = new _script(); break;
			case  2: res = new _script(argument[1]); break;
			case  3: res = new _script(argument[1],argument[2]); break;
			case  4: res = new _script(argument[1],argument[2],argument[3]); break;
			case  5: res = new _script(argument[1],argument[2],argument[3],argument[4]); break;
			case  6: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5]); break;
			case  7: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: res = new _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	} catch (_) {
		switch (argument_count) {
			case  1: res = _script(); break;
			case  2: res = _script(argument[1]); break;
			case  3: res = _script(argument[1],argument[2]); break;
			case  4: res = _script(argument[1],argument[2],argument[3]); break;
			case  5: res = _script(argument[1],argument[2],argument[3],argument[4]); break;
			case  6: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5]); break;
			case  7: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: res = _script(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	}
	return res;
}

/// @func	construct_or_invoke_ex(_script, _params_array)
/// @desc	Construct or invoke the method, but uses an array for the arguments instead of direct supplied arguments.
/// @returns {any} The return value of the method or undefined, if the method does not exist
function construct_or_invoke_ex(_script, _pa) {
	if (_script == undefined || _script == -1 || !is_callable(_script))
		return undefined;
		
	var res;
	try {
		if (_pa == undefined) 
			return new _script();
			
		switch (array_length(_pa)) {			
			case  0: res = new _script(); break;
			case  1: res = new _script(_pa[0]); break;
			case  2: res = new _script(_pa[0],_pa[1]); break;
			case  3: res = new _script(_pa[0],_pa[1],_pa[2]); break;
			case  4: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3]); break;
			case  5: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4]); break;
			case  6: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5]); break;
			case  7: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6]); break;
			case  8: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7]); break;
			case  9: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8]); break;
			case 10: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9]); break;
			case 11: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10]); break;
			case 12: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11]); break;
			case 13: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12]); break;
			case 14: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13]); break;
			case 15: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13],_pa[14]); break;
			case 16: res = new _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13],_pa[14],_pa[15]); break;
		}
	} catch (_) {
		if (_pa == undefined) 
			return _script();
			
		switch (array_length(_pa)) {
			case  0: res = _script(); break;
			case  1: res = _script(_pa[0]); break;
			case  2: res = _script(_pa[0],_pa[1]); break;
			case  3: res = _script(_pa[0],_pa[1],_pa[2]); break;
			case  4: res = _script(_pa[0],_pa[1],_pa[2],_pa[3]); break;
			case  5: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4]); break;
			case  6: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5]); break;
			case  7: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6]); break;
			case  8: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7]); break;
			case  9: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8]); break;
			case 10: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9]); break;
			case 11: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10]); break;
			case 12: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11]); break;
			case 13: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12]); break;
			case 14: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13]); break;
			case 15: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13],_pa[14]); break;
			case 16: res = _script(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13],_pa[14],_pa[15]); break;
		}
	}
	return res;
}

function seconds_to_frames(_seconds) {
	gml_pragma("forceinline");
	return (_seconds * room_speed);
}

function ms_to_frames(_milliseconds) {
	gml_pragma("forceinline");
	return (_milliseconds / 1000 * room_speed);
}

function frames_to_ms(_frames) {
	gml_pragma("forceinline");
	return _frames / room_speed * 1000;
}

function frames_to_seconds(_frames) {
	gml_pragma("forceinline");
	return _frames / room_speed;
}

/// @func	run_delayed(owner, delay, func, data = undefined)
/// @desc	Executes a specified function in <delay> frames from now.
///			Behind the scenes this uses the __animation_empty function which
///			is part of the ANIMATIONS ListPool, so if you clear all animations,
///			or use animation_run_ex while this is waiting for launch, 
///			you will also abort this one here.
///			Keep that in mind.
/// @param {instance} owner	The owner of the delayed runner
/// @param {int} delay		Number of frames to wait
/// @param {func} func		The function to execute
/// @param {struct} data	An optional data struct to be forwarded to func. Defaults to undefined.
/// @returns {Animation}	The animation processing the delay
function run_delayed(owner, delay, func, data = undefined) {
	var anim = __animation_empty(owner, delay, 0).add_finished_trigger(function(data) { data.func(data.args); });
	anim.data.func = func;
	anim.data.args = data;
	return anim;
}

/// @func	run_delayed_ex(owner, delay, func, data = undefined)
/// @desc	Executes a specified function EXCLUSIVELY in <delay> frames from now.
///			Exclusively means in this case, animation_abort_all is invoked before
///			starting the delayed waiter.
///			Behind the scenes this uses the __animation_empty function which
///			is part of the ANIMATIONS ListPool, so if you clear all animations,
///			or use animation_run_ex while this is waiting for launch, 
///			you will also abort this one here.
///			Keep that in mind.
/// @param {instance} owner	The owner of the delayed runner
/// @param {int} delay		Number of frames to wait
/// @param {func} func		The function to execute
/// @param {struct} data	An optional data struct to be forwarded to func. Defaults to undefined.
/// @returns {Animation}	The animation processing the delay
function run_delayed_ex(owner, delay, func, data = undefined) {
	animation_abort_all(owner);
	return run_delayed(owner, delay, func, data);
}

/// @func	run_delayed_exf(owner, delay, func, data = undefined)
/// @desc	Read _exf as "exclusive with finish"
///			Executes a specified function EXCLUSIVELY in <delay> frames from now.
///			Exclusively means in this case, animation_finish_all is invoked before
///			starting the delayed waiter.
///			Behind the scenes this uses the __animation_empty function which
///			is part of the ANIMATIONS ListPool, so if you clear all animations,
///			or use animation_run_ex while this is waiting for launch, 
///			you will also abort this one here.
///			Keep that in mind.
/// @param {instance} owner	The owner of the delayed runner
/// @param {int} delay		Number of frames to wait
/// @param {func} func		The function to execute
/// @param {struct} data	An optional data struct to be forwarded to func. Defaults to undefined.
/// @returns {Animation}	The animation processing the delay
function run_delayed_exf(owner, delay, func, data = undefined) {
	animation_finish_all(owner);
	return run_delayed(owner, delay, func, data);
}

/// @func	if_null(value, value_if_null)
/// @desc	Tests if the specified value is undefined or noone, or,
///			if it is a string, is empty.
///			In any of those cases value_if_null is returned, otherwise
///			value is returned.
/// @param {any} value	The value to test
/// @param {any} value_if_null	the value to return, if value is null.
/// @returns {any}	value or value_if_null
function if_null(value, value_if_null) {
	if (value == undefined || value == noone)
		return value_if_null;
	if (is_string(value))
		return string_is_empty(value) ? value_if_null : value;
	return value;
}

/// @func	is_null(value)
/// @desc	Tests if the specified value is undefined or noone, or,
///			if it is a string, is empty.
///			In any of those cases true is returned, otherwise
///			false is returned.
/// @param {any} value	The value to test
/// @returns {bool}	value is nullish or not
function is_null(value) {
	if (value == undefined || value == noone)
		return true;
	if (is_string(value))
		return string_is_empty(value);
	return false;
}

/// @func	eq(inst1, inst2)
/// @desc	Compare, whether two object instances are the same instance
///			Due to a html bug you can not simply compare inst1==inst2,
///			but you have to compare their ids instead.
function eq(inst1, inst2) {
	try { return name_of(inst1) == name_of(inst2); } catch (_) { return false; }
}

/// @func	with_tag(_tag, _func, _data = undefined)
/// @desc	Executes the specified function for all object instances
///			that are tagged with the specified tag.
///			NOTE: The function is temporary bound to the instance, so
///			the code IN the function will run in the scope of the instance!
///			You may also specify any _data object to be sent into each of 
///			the invoked functions
function with_tag(_tag, _func, _data = undefined) {
	var tagged = tag_get_asset_ids(_tag, asset_object);
	for (var i = 0, len = array_length(tagged); i < len; i++) {
		with(tagged[@i]) {
			var tmpfunc = method(self, _func);
			tmpfunc(_data);
		}
	}
}

/// @func	method_exists(_instance, _method)
/// @desc	Checks, whether a method with the specified name exists in _instance
/// @returns {bool}	True, if a method with that name exists, otherwise false
function method_exists(_instance, _method) {
	gml_pragma("forceinline");
	return is_callable(vsget(_instance, _method));
}

/// @func	invoke_if_exists(_instance, _method, ...)
/// @desc	Invoke the method, if it exists, with all arguments specified after the
///			_instance and _method arguments.
///			NOTE: GameMaker supports a maximum of 16 arguments, 2 are already used for
///			_instance and _method, so this leaves a maximum of 14 arguments for your call.
/// @returns {any} The return value of the method or undefined, if the method does not exist
function invoke_if_exists(_instance, _method) {
	var meth = is_callable(_method) ? _method : vsget(_instance, _method);
	if (is_callable(meth)) {
		with(_instance)
		switch (argument_count) {
			case  2: return meth(); break;
			case  3: return meth(argument[2]); break;
			case  4: return meth(argument[2],argument[3]); break;
			case  5: return meth(argument[2],argument[3],argument[4]); break;
			case  6: return meth(argument[2],argument[3],argument[4],argument[5]); break;
			case  7: return meth(argument[2],argument[3],argument[4],argument[5],argument[6]); break;
			case  8: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
			case  9: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
			case 10: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
			case 11: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
			case 12: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
			case 13: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
			case 14: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
			case 15: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
			case 16: return meth(argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
		}
	}
	return undefined;
}

/// @func	invoke_if_exists_ex(_instance, _method, _params_array)
/// @desc	Invoke the method, but uses an array for the arguments instead of direct supplied arguments.
/// @returns {any} The return value of the method or undefined, if the method does not exist
function invoke_if_exists_ex(_instance, _method, _pa) {
	var meth = is_callable(_method) ? _method : vsget(_instance, _method);
	
	if (is_callable(meth)) {
		with(_instance) {
			if (_pa == undefined) 
				return meth();
			
			if (!is_array(_pa))
				_pa = [ _pa ];
			
			switch (array_length(_pa)) {
				case  0: return meth(); break;
				case  1: return meth(_pa[0]); break;
				case  2: return meth(_pa[0],_pa[1],); break;
				case  3: return meth(_pa[0],_pa[1],_pa[2]); break;
				case  4: return meth(_pa[0],_pa[1],_pa[2],_pa[3]); break;
				case  5: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4]); break;
				case  6: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5]); break;
				case  7: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6]); break;
				case  8: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7]); break;
				case  9: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8]); break;
				case 10: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9]); break;
				case 11: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10]); break;
				case 12: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11]); break;
				case 13: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12]); break;
				case 14: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13]); break;
				case 15: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13],_pa[14]); break;
				case 16: return meth(_pa[0],_pa[1],_pa[2],_pa[3],_pa[4],_pa[5],_pa[6],_pa[7],_pa[8],_pa[9],_pa[10],_pa[11],_pa[12],_pa[13],_pa[14],_pa[15]); break;
			}
		}
	}
	return undefined;
}

/// @func	dump_array(_array, _to_console = true, _single_line = false)
/// @desc	Dumps an array to a string (returned) and to console (optional)
function dump_array(_array, _to_console = true, _single_line = false) {
	var rv = $"{(_single_line ? "[" : "")}{string_join_ext(_single_line ? "," : "\n", _array)}{(_single_line ? "]" : "")}";
	if (_to_console) {
		if (!_single_line) dlog($"[--- ARRAY DUMP START ---]");
		dlog(rv);
		if (!_single_line) dlog($"[--- ARRAY DUMP  END  ---]");
	}
	return rv;
}

/// @func	rgb_of(_color)
/// @desc	Shortcut/convenience function to make_color_rgb of the channels
///			on the supplied _color. Marked as #pragme inline
function rgb_of(_color) {
	gml_pragma("forceinline");
	return make_color_rgb(
		color_get_red(_color),
		color_get_green(_color),
		color_get_blue(_color)
	);
}

/// @func	extract_init(_struct, _remove = false, _init_struct_name = "init")
/// @desc	Extracts an "init" member of the specified struct, if it exists,
///			and returns it. Optionally, the "init" is also removed from the _struct.
///			This is especially useful for instance creation, when you read data 
///			from json configuration files, that might or might-not contain init structs.
///			Use it like "instance_create(...., extract_init(json));
function extract_init(_struct, _remove = false, _init_struct_name = "init") {
	var rv = vsget(_struct, _init_struct_name);
	if (is_struct(rv)) {
		if (_remove)
			struct_remove(_struct, _init_struct_name);
		return rv;
	}
	return undefined;
}

/// @func	asset_from_string(_asset_name_or_type)
/// @desc	Recreates the asset index from a type name read from json or a savegame
function asset_from_string(_asset_name) {
	return 
		is_null(_asset_name) ? 
		undefined :
		(is_string(_asset_name) ? asset_get_index(_asset_name) : _asset_name);
}

/// @func	asset_to_string(_asset)
/// @desc	Convert an asset (or object) name to a string to be saved to json or a savegame
function asset_to_string(_asset) {
	return
		is_null(_asset) ?
		undefined :
		(is_string(_asset) ? _asset : typename_of(_asset));
}

/// @func	color_from_array(_rgb_array)
/// @desc	Reads a 3-element-array into an rgb color from a json array
function color_from_array(_rgb_array) {
	if (is_array(_rgb_array) && array_length(_rgb_array) == 3) {
		return make_color_rgb(_rgb_array[@0], _rgb_array[@1], _rgb_array[@2]);
	}
	return _rgb_array;
}

/// @func	color_to_array(_color)
/// @desc	Converts any color to a 3-element-array, which can be stored in a json
function color_to_array(_color) {
	return 
		!is_null(_color) ? 
		[
			color_get_red(_color),
			color_get_green(_color),
			color_get_blue(_color)
		] :
		[255, 255, 255];
}

/// @func color_from_hexcode(_hexcode)
/// @desc Converts a hexcode to a color. (supports rgb and bgr)
function color_from_hexcode(_hexcode) {
	var c0 = string_first(_hexcode, 1);
	var c1 = string_parse_hex(string_substring(_hexcode, 2, 2));
	var c2 = string_parse_hex(string_substring(_hexcode, 4, 2));
	var c3 = string_parse_hex(string_substring(_hexcode, 6, 2));
	
	switch (c0) {
		case "#": 
			return make_color_rgb(c1, c2, c3);
			break;
		case "$": 
			return make_color_bgr(c1, c2, c3);
			break;
		default:
			throw($"Hexcode '{_hexcode}' could not be converted. (Missing '#' or '$')");
			break;
	}
}

/// @func make_color_bgr(_blue, _green, _red)
function make_color_bgr(_blue, _green, _red) {
	return make_color_rgb(_red, _green, _blue);
}

