/*
	raptor's "rich json" implementation allows you to reference in-game assets,
	load files (like an #include command), join several structs and use references in json.
	
	There are some keywords involved.
	
	If the value of an item is a string and starts with...
	
	"#ref:"		you reference another key in the same file, like "#ref:global/strings/hello"
	"#file:"	load a file into this member, like "#file:game_files/mycontent.json"
	"#asset:"	reference an ingame asset, like "#asset:sprBackgroundForest"
	"#join:"	a comma-separated list of elements in the same file (refs) to join together
*/

#macro __RICH_JSON_CIRCULAR_LEVEL			global.__rich_json_circular_level
#macro __RICH_JSON_CIRCULAR_CACHE			global.__rich_json_circular_cache
#macro __ENSURE_RICH_JSON_CIRCULAR_CACHE	if (!variable_global_exists("__rich_json_circular_cache")) { __RICH_JSON_CIRCULAR_CACHE = []; __RICH_JSON_CIRCULAR_LEVEL = 0; }
__ENSURE_RICH_JSON_CIRCULAR_CACHE;
__RICH_JSON_CIRCULAR_LEVEL = 0;

/// @func __struct_apply_rich_json(_cryptkey = "", _add_to_cache, _struct_or_array, _root)
function __struct_apply_rich_json(_cryptkey = "", _add_to_cache, _struct_or_array, _root) {
	__ENSURE_RICH_JSON_CIRCULAR_CACHE;
	if (__RICH_JSON_CIRCULAR_LEVEL == 0)
		__RICH_JSON_CIRCULAR_CACHE = {
			stack: {},
		};
		
	__RICH_JSON_CIRCULAR_LEVEL++;
	
	var isstruct	= is_struct(_struct_or_array);
	var names		= isstruct ? struct_get_names(_struct_or_array) : _struct_or_array;
	var member		= undefined;
	var command		= undefined;
	
	for (var i = 0, len = array_length(names); i < len; ++i) {
	    member = isstruct ? struct_get(_struct_or_array, names[@i]) : _struct_or_array[@i];
		if (is_callable(member))
			continue;
		if (is_struct(member) || is_array(member)) {
			if (vsget(__RICH_JSON_CIRCULAR_CACHE.stack, address_of(member)) == undefined) {
				__RICH_JSON_CIRCULAR_CACHE.stack[$ address_of(member)] = member;
				__struct_apply_rich_json(_cryptkey, _add_to_cache, member, _root);
			}
		}
		else if (is_string(member) && string_match(member, "#*:*")) {
			member	= string_split(member, ":",, 1);
			command = string_trim(member[0]);
			member	= string_trim(member[1]);
			member	= __rich_json_switch_command(_cryptkey, _add_to_cache, _root, command, member);
			if (isstruct)
				struct_set(_struct_or_array, names[@i], member);
			else
				names[@i] = member;			
		}
	}
	
	__RICH_JSON_CIRCULAR_LEVEL--;
	if (__RICH_JSON_CIRCULAR_LEVEL == 0)
		__RICH_JSON_CIRCULAR_CACHE = {};
	
	return _struct_or_array;
}

/// @func __rich_json_switch_command(_cryptkey, _add_to_cache, _root, _command, _member)
function __rich_json_switch_command(_cryptkey, _add_to_cache, _root, _command, _member) {
	switch (_command) {
		case "#file":
			TRY
				_member = __rich_json_handle_file(_member, _cryptkey, _add_to_cache);
			CATCH
				throw($"RichJSON #file could not be resolved in {_member}.");
			ENDTRY
			break;
		case "#join":
			TRY
				_member = __rich_json_handle_join(_cryptkey, _add_to_cache, _root, _member);
			CATCH
				throw($"RichJSON #join could not be resolved in {_member}.");
			ENDTRY
			break;
		case "#ref":
			TRY
				_member = __rich_json_handle_ref(_cryptkey, _add_to_cache, _root, _member);
			CATCH
				throw($"RichJSON #ref could not be resolved in {_member}.");
			ENDTRY
			break;
		case "#asset":
			TRY
				_member = __rich_json_handle_asset(_member);
			CATCH
				throw($"RichJSON #asset could not be resolved in {_member}.");
			ENDTRY
			break;
	}
	return _member;
}

/// @func __rich_json_handle_file(_filename, _cryptkey, _add_to_cache)
function __rich_json_handle_file(_filename, _cryptkey, _add_to_cache) {
	return file_read_struct(_filename, _cryptkey, _add_to_cache);
}

/// @func __rich_json_handle_join(_cryptkey, _add_to_cache, _root, _join)
function __rich_json_handle_join(_cryptkey, _add_to_cache, _root, _join) {
	_join = string_split(_join, ",");
	var struct = {};
	for (var i = 0, len = array_length(_join); i < len; ++i) {
	    struct_join_into(struct, __rich_json_handle_ref(_cryptkey, _add_to_cache, _root, string_trim(_join[i])));
	}
	return struct;
}

/// @func __rich_json_handle_ref(_cryptkey, _add_to_cache, _root, _ref)
function __rich_json_handle_ref(_cryptkey, _add_to_cache, _root, _ref) {
	var last	= undefined;
	var member	= _root;	
	_ref = string_split(_ref, "/");
	for (var i = 0, len = array_length(_ref); i < len; ++i) {
		last	= member;
	    member = struct_get(member, string_trim(_ref[@i]));
	}
	if (is_string(member)) {
		if (string_match(member, "#*:*")) {
			if (vsget(__RICH_JSON_CIRCULAR_CACHE.stack, address_of(last)) == undefined)
				__RICH_JSON_CIRCULAR_CACHE.stack[$ address_of(last)] = last;				
			__struct_apply_rich_json(_cryptkey, _add_to_cache, last, _root);
			return struct_get(last, string_trim(array_last(_ref)));
		}
	}
	else if (vsget(__RICH_JSON_CIRCULAR_CACHE.stack, address_of(member)) == undefined) {
		__RICH_JSON_CIRCULAR_CACHE.stack[$ address_of(member)] = member;
		__struct_apply_rich_json(_cryptkey, _add_to_cache, member, _root);
	}
	else
		member = __RICH_JSON_CIRCULAR_CACHE.stack[$ address_of(member)];
	return member;
}

/// @func __rich_json_handle_asset(_asset)
function __rich_json_handle_asset(_asset) {
	return asset_get_index(_asset);
}