/*
	Utility methods to work with structs.
	
	(c)coldrock.games
*/

#macro __CONSTRUCTOR_NAME					"##_raptor_##.__constructor"
#macro __PARENT_CONSTRUCTOR_NAME			"##_raptor_##.__parent_constructor"
#macro __INTERFACES_NAME					"##_raptor_##.__interfaces"

#macro __STRUCT_JOIN_CIRCULAR_LEVEL			global.__struct_join_circular_level
#macro __STRUCT_JOIN_CIRCULAR_CACHE			global.__struct_join_circular_cache
#macro __ENSURE_STRUCT_JOIN_CIRCULAR_CACHE	if (!variable_global_exists("__struct_join_circular_cache")) { __STRUCT_JOIN_CIRCULAR_CACHE = []; __STRUCT_JOIN_CIRCULAR_LEVEL = 0; }
__ENSURE_STRUCT_JOIN_CIRCULAR_CACHE;
__STRUCT_JOIN_CIRCULAR_LEVEL = 0;

#macro __CTOR_FUNCTION_NAME					"__ctor"
#macro ctor									__ctor = function() 

/// @func	construct(_class_name_or_asset)
/// @desc	Register a class as a constructible class to raptor.
///			This is used by the file system when loading saved games or any other structures
///			that have been saved through raptor.
///			When loading the file, instead of just assigning the struct, it will invoke
///			the constructor and then perform a struct_join_into with the loaded data, so
///			all members receive their loaded values after the constructor executed.
function construct(_class_name_or_asset) {
	gml_pragma("forceinline");
	if (!is_string(_class_name_or_asset)) _class_name_or_asset = script_get_name(_class_name_or_asset);
	self[$ __PARENT_CONSTRUCTOR_NAME] = string_concat(
		"|",
		_class_name_or_asset,
		vsget(self, __PARENT_CONSTRUCTOR_NAME, "|")
	);

	self[$ __CONSTRUCTOR_NAME] = _class_name_or_asset;
}

/// @func	class_tree(_class_instance)
/// @desc	Gets the entire class hierarchy as an array for the specified instance.
///			At position[0] you will find the _class_instance's name and at the
///			last position of the array you will find the root class name of the tree.
///			NOTE: This function only works if you used the "construct" function of raptor
///			and the argument MUST BE a living instance of the class!
function class_tree(_class_instance) {
	if (_class_instance == undefined || !struct_exists(_class_instance, __PARENT_CONSTRUCTOR_NAME))
		return undefined;
		
	return string_split(_class_instance[$ __PARENT_CONSTRUCTOR_NAME], "|", true);
}

/// @func	is_class_of(_struct, _class_name)
/// @desc	Returns, whether the struct has used the "construct" command 
///			and the type is the specified class_name
function is_class_of(_struct, _class_name) {
	gml_pragma("forceinline");
	if (!is_string(_class_name)) _class_name = script_get_name(_class_name);
	return vsget(_struct, __CONSTRUCTOR_NAME) == _class_name;
}

/// @func	is_child_class_of(_struct, _class_name)
/// @desc	Returns, whether the struct has used the "construct" command 
///			and the type is the specified class_name
///			or the specified _class_name appears anywhere 
///			in the inheritance chain of this _struct
function is_child_class_of(_struct, _class_name) {
	gml_pragma("forceinline");
	if (!is_string(_class_name)) _class_name = script_get_name(_class_name);
	return 
		string_contains(vsget(_struct, __PARENT_CONSTRUCTOR_NAME, ""), $"|{_class_name}|");
}

/// @func	implement(_interface, ...constructor_arguments...)
/// @desc	Works like an interface implementation by copying all members
///			and re-binding all methods from "interface" to "self"
///			Creates a hidden member __raptor_interfaces in this struct which contains
///			all implemented interfaces, so you can always ask "if (implements(interface))..."
///			NOTE: Up to 15 constructor arguments are allowed for "_interface"
///			This function will create one instance and copy/rebind all elements to self.
function implement(_interface) {
	var sname, sclass;
	if (is_string(_interface)) {
		sname = _interface;
		sclass = asset_get_index(sname);
	} else {
		sname = script_get_name(_interface);
		sclass = _interface;
	}
	
	var res;
	switch (argument_count) {
		case  1: res = new sclass(); break;
		case  2: res = new sclass(argument[1]); break;
		case  3: res = new sclass(argument[1],argument[2]); break;
		case  4: res = new sclass(argument[1],argument[2],argument[3]); break;
		case  5: res = new sclass(argument[1],argument[2],argument[3],argument[4]); break;
		case  6: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5]); break;
		case  7: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6]); break;
		case  8: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7]); break;
		case  9: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8]); break;
		case 10: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9]); break;
		case 11: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10]); break;
		case 12: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11]); break;
		case 13: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12]); break;
		case 14: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13]); break;
		case 15: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14]); break;
		case 16: res = new sclass(argument[1],argument[2],argument[3],argument[4],argument[5],argument[6],argument[7],argument[8],argument[9],argument[10],argument[11],argument[12],argument[13],argument[14],argument[15]); break;
	}
	
	struct_join_into(self, res);
	if (!variable_struct_exists(self, __INTERFACES_NAME))
		self[$ __INTERFACES_NAME] = [];
	sname = vsget(res, __CONSTRUCTOR_NAME, sname);
	if (!array_contains(self[$ __INTERFACES_NAME], sname))
		array_push(self[$ __INTERFACES_NAME], sname);
	invoke_if_exists(self, __CTOR_FUNCTION_NAME);
	struct_remove(self, __CTOR_FUNCTION_NAME);
}

/// @func	implements(struct, _interface)
/// @desc	Asks the specified struct whether it implements the specified interface.
function implements(struct, _interface) {
	var sname = is_string(_interface) ? _interface : script_get_name(_interface);
	return variable_struct_exists(struct, __INTERFACES_NAME) && array_contains(struct[$ __INTERFACES_NAME], sname);
}

/// @func	struct_get_unique_key(struct, basename, prefix = "")
/// @desc	Get a free name for a key in a struct with an optional prefix
/// @param  {struct} struct
/// @param  {string} basename
/// @param  {string=""} prefix
/// @returns {string} the new name	
function struct_get_unique_key(struct, basename, prefix = "") {
	var i = 0;
	var newname = prefix + basename;
	while (struct_exists(struct, newname)) {
		newname = string_concat(prefix, basename, i);
		i++;
	}
	return newname;
}

/// @func	struct_move(_source, _target, _members...)
/// @desc	Moves members from the _source struct to the _target struct.
///			member existance is checked before move, only existing will be created in _target.
///			If the first _member argument is an array, it is considered, that this array contains
///			the names of the members to move.
function struct_move(_source, _target) {
	if (argument_count < 2)
		return;
	
	static move = function(_source, _target, _member) {
		var mem = struct_get(_source, _member);
		if (struct_exists(_source, _member)) {
			if (is_method(mem))
				_target[$ _member] = method(_target, mem);
			else
				struct_set(_target, _member, mem);
			struct_remove(_source, _member);
		}
	}
	
	if (is_array(argument[@2])) {
		var arr = argument[@2];
		for (var i = 0, len = array_length(arr); i < len; i++) 
			move(_source, _target, arr[@i]);
	} else {
		for (var i = 2; i < argument_count; i++) 
			move(_source, _target, argument[@i]);
	}

	return _target;
}

/// @func	struct_join(structs...)
/// @desc	Joins two or more structs together into a new struct.
///			NOTE: This is NOT a deep copy! If any struct contains other struct
///			references, they are simply copied, not recursively converted to new references!
///			Methods in the structs will be rebound to the new struct
///			ATTENTION! No static members can be transferred! Best use this for data structs only!
function struct_join(structs) {
	var rv = {};
	for (var i = 0; i < argument_count; i++) 
		struct_join_into(rv, argument[i]);
	return rv;
}

/// @func	struct_join_into(target, sources...)
/// @desc	Integrate all source structs into the target struct by copying
///			all members from source to target.
///			NOTE: This is NOT a deep copy! If source contains other struct
///			references, they are simply copied, not recursively converted to new references!
///			Circular references are handled. It is safe to join child-parent-child references.
///			Methods in the structs will be rebound to the new struct
///			ATTENTION! No static members can be transferred! Best use this for data structs only!
function struct_join_into(target, sources) {
	__ENSURE_STRUCT_JOIN_CIRCULAR_CACHE;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
	
	var from		= undefined;
	var from_cstr	= undefined;
	var target_cstr	= undefined;
	__STRUCT_JOIN_CIRCULAR_LEVEL++;
	for (var i = 1; i < argument_count; i++) {
		from = argument[i];
		if (from == undefined) continue;
		target_cstr = struct_get(target, __CONSTRUCTOR_NAME);
		from_cstr	= struct_get(from, __CONSTRUCTOR_NAME);
		if (target_cstr != from_cstr && from_cstr != undefined) {
			static_set(target, static_get(from));
			if (target_cstr != undefined)
				wlog($"** WARNING ** Static struct mismatch encountered while joining '{from_cstr}' into '{target_cstr}'");
		}
		__struct_join_into(target, from);
	}
	__STRUCT_JOIN_CIRCULAR_LEVEL--;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
		
	return target;
}

function __struct_join_into(target, from) {
	var names	= struct_get_names(from);
	var name	= undefined;
	var member	= undefined;
	for (var j = 0; j < array_length(names); j++) {
		name = names[@j];
		member = from[$ name];
		with (target) {
			if (is_method(member))
				self[$ name] = method(self, member);
			else {
				vsgetx(self, name, member);
				if (member != undefined && 
					is_struct(member) && 
					!array_contains(__STRUCT_JOIN_CIRCULAR_CACHE, member)) {
					if (!is_struct(self[$ name])) {
						if (vsget(self, name) != undefined)
							wlog($"** WARNING ** Type mismatch encountered while joining '{name}'");
						self[$ name] = member;
					} else {
						array_push(__STRUCT_JOIN_CIRCULAR_CACHE, member);
						struct_join_into(self[$ name], member);
					}
				} else
					self[$ name] = member;
			}
		}
	}
}

/// @func	struct_join_no_rebind(structs...)
/// @desc	Similar to struct_join, but will not rebind methods. They will just be copied
function struct_join_no_rebind(structs) {
	var rv = {};
	for (var i = 0; i < argument_count; i++) 
		struct_join_into_no_rebind(rv, argument[i]);
	return rv;
}

/// @func	struct_join_into_no_rebind(target, sources...)
/// @desc	Similar to struct_join_into, but will not rebind methods. They will just be copied
function struct_join_into_no_rebind(target, sources) {
	__ENSURE_STRUCT_JOIN_CIRCULAR_CACHE;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
	
	var from		= undefined;
	var from_cstr	= undefined;
	var target_cstr	= undefined;
	__STRUCT_JOIN_CIRCULAR_LEVEL++;
	for (var i = 1; i < argument_count; i++) {
		from = argument[i];
		if (from == undefined) continue;
		target_cstr = struct_get(target, __CONSTRUCTOR_NAME);
		from_cstr	= struct_get(from, __CONSTRUCTOR_NAME);
		if (target_cstr != from_cstr && from_cstr != undefined) {
			static_set(target, static_get(from));
			if (target_cstr != undefined)
				wlog($"** WARNING ** Static struct mismatch encountered while joining '{from_cstr}' into '{target_cstr}'");
		}
		__struct_join_into_no_rebind(target, from);
	}
	__STRUCT_JOIN_CIRCULAR_LEVEL--;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
		
	return target;
}

function __struct_join_into_no_rebind(target, from) {
	var names	= struct_get_names(from);
	var name	= undefined;
	var member	= undefined;
	for (var j = 0; j < array_length(names); j++) {
		name = names[@j];
		member = from[$ name];
		with (target) {
			if (is_method(member))
				self[$ name] = member;
			else {
				vsgetx(self, name, member);
				if (member != undefined && 
					is_struct(member) && 
					!array_contains(__STRUCT_JOIN_CIRCULAR_CACHE, member)) {
					if (!is_struct(self[$ name])) {
						if (vsget(self, name) != undefined)
							wlog($"** WARNING ** Type mismatch encountered while joining '{name}'");
						self[$ name] = member;
					} else {
						array_push(__STRUCT_JOIN_CIRCULAR_CACHE, member);
						struct_join_into_no_rebind(self[$ name], member);
					}
				} else
					self[$ name] = member;
			}
		}
	}
}

/// @func	struct_enrich(structs...)
/// @desc	Enriches two or more structs together into a new struct.
///			Methods in the structs will be rebound to the new struct
///			ATTENTION! No static members can be transferred! Best use this for data structs only!
function struct_enrich(structs) {
	var rv = {};
	for (var i = 0; i < argument_count; i++) 
		struct_join_into(rv, argument[i]);
	return rv;
}

/// @func	struct_enrich_into(target, sources...)
/// @desc	Integrate all source structs into the target struct by copying
///			all members from source to target but only non-existing members.
///			Circular references are handled. It is safe to join child-parent-child references.
///			Methods in the structs will be rebound to the new struct
///			ATTENTION! No static members can be transferred! Best use this for data structs only!
function struct_enrich_into(target, sources) {
	__ENSURE_STRUCT_JOIN_CIRCULAR_CACHE;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
	
	var from		= undefined;
	var from_cstr	= undefined;
	var target_cstr	= undefined;
	__STRUCT_JOIN_CIRCULAR_LEVEL++;
	for (var i = 1; i < argument_count; i++) {
		from = argument[i];
		if (from == undefined) continue;
		target_cstr = struct_get(target, __CONSTRUCTOR_NAME);
		from_cstr	= struct_get(from, __CONSTRUCTOR_NAME);
		if (target_cstr != from_cstr && from_cstr != undefined) {
			static_set(target, static_get(from));
			if (target_cstr != undefined)
				wlog($"** WARNING ** Static struct mismatch encountered while joining '{from_cstr}' into '{target_cstr}'");
		}
		__struct_enrich_into(target, from);
	}
	__STRUCT_JOIN_CIRCULAR_LEVEL--;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
		
	return target;
}

function __struct_enrich_into(target, from) {
	var names	= struct_get_names(from);
	var name	= undefined;
	var member	= undefined;
	for (var j = 0; j < array_length(names); j++) {
		name = names[@j];
		member = from[$ name];
		with (target) {
			if (struct_exists(self, name))
				continue;
			if (is_method(member))
				self[$ name] = method(self, member);
			else {
				vsgetx(self, name, member);
				if (member != undefined && 
					is_struct(member) && 
					!array_contains(__STRUCT_JOIN_CIRCULAR_CACHE, member)) {
					if (!is_struct(self[$ name])) {
						wlog($"** WARNING ** Type mismatch encountered while joining '{name}'");
						self[$ name] = member;
					} else {
						array_push(__STRUCT_JOIN_CIRCULAR_CACHE, member);
						struct_enrich_into(self[$ name], member);
					}
				} else
					self[$ name] = member;
			}
		}
	}
}

/// @func	struct_clear(_struct, _members_to_keep = [])
/// @desc	Removes all members from a struct, except the
///			##raptor## internal members (constructors and inheritance meta data)
///			but keeps the struct reference intact.
///			The optional second argument may contain a string array of member names
///			to keep when clearing the struct.
///			These members may contain wildcards, like "arg*"
function struct_clear(_struct, _members_to_keep = []) {
	if (!is_struct(_struct)) {
		wlog($"** WARNING ** struct_clear called with an argument that is not a struct!");
		return;
	}
	
	var names = struct_get_names(_struct);
	var n;
	var found = false;
	for (var i = 0, len = array_length(names); i < len; i++) {
		n = names[@i];
		if (!is_any_of(n, __CONSTRUCTOR_NAME, __PARENT_CONSTRUCTOR_NAME)) {
			found = false;
			for (var j = 0, jen = array_length(_members_to_keep); j < jen; j++) {
				found = string_match(n, _members_to_keep[@j]);
				if (found) break;
			}
			
			if (!found) struct_remove(_struct, n);
		}
	}
}

/// @func	deep_copy(_struct_or_array)
/// @desc	Perform a deep copy of the given struct or array.
///			Circular dependencies are correctly resolved and rebuilt
///			in the copy, all pointing to the new instances
///			Statics are also transferred, as you would expect
///			Methods in the structs will be rebound to the new struct
function deep_copy(_struct_or_array) {
	if (is_null(_struct_or_array) || (!is_struct(_struct_or_array) && !is_array(_struct_or_array)))
		return _struct_or_array;
		
	__ENSURE_STRUCT_JOIN_CIRCULAR_CACHE;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = {
			str: is_struct(_struct_or_array),
			rv: (is_struct(_struct_or_array) ? {} : []),
			next: undefined,
			stack: {},
		};
	
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE.next = __STRUCT_JOIN_CIRCULAR_CACHE.rv;
		
	__STRUCT_JOIN_CIRCULAR_LEVEL++;
	
	var target = __STRUCT_JOIN_CIRCULAR_CACHE.next;
	if (is_struct(_struct_or_array)) {
        static_set(target, static_get(_struct_or_array));
		var names = struct_get_names(_struct_or_array);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var name = names[@i];
			var member = _struct_or_array[$ name];
			if (is_method(member)) {
				target[$ name] = method(target, member);
			} else if (typeof(member) != "ref" && (is_real(member) || is_string(member)) || is_object_instance(member)) {
				target[$ name] = member;
			} else if (is_struct(member) || is_array(member)) {
				if (vsget(__STRUCT_JOIN_CIRCULAR_CACHE.stack, address_of(member)) == undefined) {
					var newstr = (is_struct(member)) ? {} : [];
					__STRUCT_JOIN_CIRCULAR_CACHE.str = is_struct(member);
					__STRUCT_JOIN_CIRCULAR_CACHE.stack[$ address_of(member)] = newstr;
					__STRUCT_JOIN_CIRCULAR_CACHE.next = newstr;
					target[$ name] = deep_copy(member);
				} else
					target[$ name] = __STRUCT_JOIN_CIRCULAR_CACHE.stack[$ address_of(member)];
			} else {
				target[$ name] = member;
			}
		}
	} else {
		for (var i = 0, len = array_length(_struct_or_array); i < len; i++) {
			var member = _struct_or_array[@ i];
			if (typeof(member) != "ref" && (is_real(member) || is_string(member)) || is_object_instance(member)) {
				array_push(target, member);
			} else if (is_struct(member) || is_array(member)) {
				if (vsget(__STRUCT_JOIN_CIRCULAR_CACHE.stack, address_of(member)) == undefined) {
					var newstr = (is_struct(member)) ? {} : [];
					__STRUCT_JOIN_CIRCULAR_CACHE.str = is_struct(member);
					__STRUCT_JOIN_CIRCULAR_CACHE.stack[$ address_of(member)] = newstr;
					__STRUCT_JOIN_CIRCULAR_CACHE.next = newstr;
					array_push(target, deep_copy(member));
				} else
					array_push(target, __STRUCT_JOIN_CIRCULAR_CACHE.stack[$ address_of(member)]);
			} else {
				array_push(target, member);
			}
		}
	}
	
	__STRUCT_JOIN_CIRCULAR_LEVEL--;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = {};
	
	return target;
}

/// @func	vsgetx(_struct, _key, _default_if_missing = undefined, _create_if_missing = true)
/// @desc	Save-gets a struct member, returning a default if it does not exist,
///			and even allows you to create that member in the struct, if it is missing
function vsgetx(_struct, _key, _default_if_missing = undefined, _create_if_missing = true) {
	gml_pragma("forceinline");
	if (_struct == undefined) 
		return _default_if_missing;
		
	if (_create_if_missing && !struct_exists(_struct, _key))
        _struct[$ _key] = _default_if_missing;
		
    return struct_exists(_struct, _key) ? _struct[$ _key] : _default_if_missing;
}

/// @func	vsget(_struct, _key, _default_if_missing = undefined)
/// @desc	Save-gets a struct member, returning a default if it does not exist,
///			but does not create the missing member in the struct
function vsget(_struct, _key, _default_if_missing = undefined) {
	gml_pragma("forceinline");
	return (_struct != undefined && struct_exists(_struct, _key)) ? _struct[$ _key] : _default_if_missing;
}


/// @func	struct_get_names_ex(_struct, _ordered = true)
/// @desc	Same as the native struct_get_names, but delivers the array ordered by name
///			by default.
function struct_get_names_ex(_struct, _ordered = true) {
	gml_pragma("forceinline");
	var rv = struct_get_names(_struct);
	if (_ordered) array_sort(rv, true);
	return rv;
}

/// @func	struct_is_empty(_struct)
/// @desc	Convenience shortcut function to ask a struct whether it has members
function struct_is_empty(_struct) {
	gml_pragma("forceinline");
	return array_length(struct_get_names(_struct)) == 0;
}

/// @func	override(_typename, _function_name, _new_function)
///			Allows a clean override of any function in an object instance or struct and keeps
///			the original function available under the parent objects' name + function_name
///			NOTE: Supply the current class/object name AS STRING as first parameter.
///			This is due to GameMaker's not-so-really-object-oriented behavior, because
///			the event_inherited() function is not really a function and a Create event
///			always runs exclusively in the top inheritance level. A Create event can not
///			get the type name of its own class, just the typename of final child object.
///	Example:
/// For 3 inheritance levels, lets call them mother, child and grandchild
/// mother defines		virtual ("mother",     "a", function() {...});
/// child does			override("child",      "a", function() {...});
/// grandchild does		override("grandchild", "a", function() {...});
/// Now child and grand_child may call mother_a() and grandchild also has child_a() available. 
function override(_typename, _function_name, _new_function) {
	var tree = is_object_instance(self) ? object_tree(self) : class_tree(self);
	if (!is_string(_typename)) _typename = typename_of(_typename);
	
	// we need only the name of our direct parent, i.e. tree[myindex+1]
	var myidx = array_index_of(tree, _typename);
	if (is_between(myidx, 0, array_length(tree) - 2)) {
		if (is_callable(self[$ _function_name])) {
			var parent = tree[@ myidx + 1];
			var newname = $"{parent}_{_function_name}";
		
			self[$ newname] = method(self, self[$ _function_name]);
			self[$ _function_name] = method(self, _new_function);
			return;
		}
	}
	// This is a... runtime-compile-error?!?
	throw($"** ERROR ** Function '{_function_name}' override failed, it does not exist or is not callable in base object/class '{_typename}'");
}
