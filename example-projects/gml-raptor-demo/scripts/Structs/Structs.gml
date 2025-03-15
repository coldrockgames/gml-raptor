/*
	Utility methods to work with structs.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

#macro __CONSTRUCTOR_NAME					"##_raptor_##.__constructor"
#macro __PARENT_CONSTRUCTOR_NAME			"##_raptor_##.__parent_constructor"
#macro __INTERFACES_NAME					"##_raptor_##.__interfaces"

#macro interface							() constructor

#macro __STRUCT_JOIN_CIRCULAR_LEVEL			global.__struct_join_circular_level
#macro __STRUCT_JOIN_CIRCULAR_CACHE			global.__struct_join_circular_cache
#macro __ENSURE_STRUCT_JOIN_CIRCULAR_CACHE	if (!variable_global_exists("__struct_join_circular_cache")) { __STRUCT_JOIN_CIRCULAR_CACHE = []; __STRUCT_JOIN_CIRCULAR_LEVEL = 0; }
__ENSURE_STRUCT_JOIN_CIRCULAR_CACHE;
__STRUCT_JOIN_CIRCULAR_LEVEL = 0;

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
	
	__STRUCT_JOIN_CIRCULAR_LEVEL++;
	for (var i = 1; i < argument_count; i++) {
		var from = argument[i];
		if (from == undefined) continue;
		
		var names = struct_get_names(from);
		for (var j = 0; j < array_length(names); j++) {
			var name = names[@j];
			var member = from[$ name];
			with (target) {
				if (is_method(member))
					self[$ name] = method(self, member);
				else {
					vsgetx(self, name, member);
					if (member != undefined && 
						is_struct(member) && 
						!array_contains(__STRUCT_JOIN_CIRCULAR_CACHE, member)) {
						array_push(__STRUCT_JOIN_CIRCULAR_CACHE, member);
						struct_join_into(self[$ name], member);
					} else
						self[$ name] = member;
				}
			}
		}
	}
	__STRUCT_JOIN_CIRCULAR_LEVEL--;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
		
	return target;
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
	
	__STRUCT_JOIN_CIRCULAR_LEVEL++;
	for (var i = 1; i < argument_count; i++) {
		var from = argument[i];
		if (from == undefined) continue;
		
		var names = struct_get_names(from);
		for (var j = 0; j < array_length(names); j++) {
			var name = names[@j];
			var member = from[$ name];
			with (target) {
				if (is_method(member))
					self[$ name] = member;
				else {
					vsgetx(self, name, member);
					if (member != undefined && 
						is_struct(member) && 
						!array_contains(__STRUCT_JOIN_CIRCULAR_CACHE, member)) {
						array_push(__STRUCT_JOIN_CIRCULAR_CACHE, member);
						struct_join_into_no_rebind(self[$ name], member);
					} else
						self[$ name] = member;
				}
			}
		}
	}
	__STRUCT_JOIN_CIRCULAR_LEVEL--;
	if (__STRUCT_JOIN_CIRCULAR_LEVEL == 0)
		__STRUCT_JOIN_CIRCULAR_CACHE = [];
		
	return target;
}

/// @func	deep_copy(_struct_or_array)
/// @desc	Perform a deep copy of the given struct or array.
///			Circular dependencies are correctly resolved and rebuilt
///			in the copy, all pointing to the new instances
///			Statics are also transferred, as you would expect
///			Methods in the structs will be rebound to the new struct
function deep_copy(_struct_or_array) {
	if (!is_struct(_struct_or_array) && !is_array(_struct_or_array))
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


#region virtual and override

// This is used by the "virtual" and "override" method pair
#macro __FUNCTION_INHERITANCE		global.__function_inheritance
__FUNCTION_INHERITANCE = {}

/// @func	virtual(_object_type, _function_name, [_function])
/// @desc	You must declare a function as "virtual" to be able to "override" it later.
///			This keeps track of the inheritance chain, and due to the way, how "events"
///			work in GameMaker, you need to tell the engine, who you are, when you "virtualize"
///			the function, by also supplying your object_type.
///	Example: 
///		virtual(_myBaseObject, "my_function", function() {...});
function virtual(_object_type, _function_name, _function = undefined) {
	var key = is_string(_object_type) ? _object_type : object_get_name(_object_type);
	var str = vsgetx(__FUNCTION_INHERITANCE, _function_name, {});
	var arr = vsgetx(str, key, []);
	if (!array_contains(arr, key)) {
		array_push(arr, key);
	}
	if (_function != undefined)
		self[$ _function_name] = method(self, _function);
}

/// @func	override(_object_type, _function_name, _new_function)
/// @desc	NOTE: WORKS FOR OBJECTS ONLY! NOT FOR STRUCTS!
///			Allows a clean override of any function in an object instance and keeps
///			the original function available under the parent objects' name + function_name
///	Example:
/// For 3 inheritance levels, lets call them mother, child and grandchild
/// mother defines		virtual(mother,		 "a", function() {...});
/// child does			override(child,		 "a", function() {...});
/// grandchild does		override(grandchild, "a", function() {...});
/// Now child and grand_child may call mother_a() and grandchild also has child_a() available. 
function override(_object_type, _function_name, _new_function) {
	var str = vsget(__FUNCTION_INHERITANCE, _function_name);
	if (str != undefined) {
		var names = variable_struct_get_names(str);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var rootpar = names[@i];
			if (is_child_of(self, asset_get_index(rootpar))) {
				var arr = vsget(str, rootpar);
				var myname = is_string(_object_type) ? _object_type : object_get_name(_object_type);
				var newname = "";
				if (array_last(arr) != myname) {
					var par = array_last(arr);
					newname = $"{par}_{_function_name}";
					array_push(arr, myname);
				} else {
					var arrlen = array_length(arr);
					if (arrlen > 1) {
						var par = arr[@ arrlen - 2];
						newname = $"{par}_{_function_name}";
					}
				}
				if (newname != "") {
					self[$ newname] = method(self, self[$ _function_name]);
					self[$ _function_name] = method(self, _new_function);
					return;
				}
			}
		}
	}
	// This is a... runtime-compile-error?!?
	throw($"** ERROR ** Function '{_function_name}' can not be overridden as it has not been declared 'virtual'");
}

#endregion
