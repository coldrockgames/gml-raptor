/*
    This code is 95% identical with SNAP's deep_copy but it handles methods
	and instance ids differently as both can not be persisted to the savegame file.
	
	methods are simply skipped and instance ids are replaced with their real(id) value
	only but in a special syntax that can be detected by savegame_load_game when this
	file gets restored.
*/

/// @func		__savegame_remove_pointers(_struct, refstack)
/// @desc
/// @arg {struct} struct	The struct to clone and remove pointers
function __savegame_remove_pointers(_struct, refstack) {
	return new __savegame_deep_copy_remove(_struct, refstack).copy;
}

/// @func		__savegame_deep_copy_remove(source, _refstack)
/// @desc	Derived from SNAP deep_copy this takes cares of methods (skip)
///					and instance id's that will not be copied but replaced with their id only
function __savegame_deep_copy_remove(source, _refstack) constructor {
	refstack	= _refstack;
    copy		= undefined;

	static is_ignored = function(_struct, _name) {
		return string_contains(
			vsget(_struct, __SAVEGAME_IGNORE, ""),
			string_concat("|", _name, "|")
		);
	}

	static to_refstack = function(_struct) {
		var refname = string_concat(__SAVEGAME_STRUCT_REF_MARKER, name_of(_struct));
		if (!vsget(refstack, refname)) {
			vlog($"Adding '{refname}' to refstack");
			refstack[$ refname]	 = true; // Temp-add "true" struct member to avoid endless loop
			refstack[$ refname]	 = copy_struct(_struct);
		}
		return refname;
	}

	static replace_ref = function(_value) {
		// so IN THEORY this could be an object, but yoyo's finite wisdom decided
		// to make objects undetectable in gml, so we look deeper and proceed in a 
		// "best guess" manner, if this could REALLY be an object.
		var rv = {};
		rv.value = _value;
		rv.success = false;
		
		try {
			if (is_object_instance(_value)) {
				var strid = string(real(_value.id));
				vlog($"Replacing instance '{name_of(_value)}' for savegame");
				rv.value = string_concat(__SAVEGAME_REF_MARKER, strid);
				rv.success = true;				
			} else if (is_struct(_value)) {
				vlog($"Replacing struct ref '{name_of(_value)}' for savegame");
				rv.value = to_refstack(_value);
				rv.success = true;
			}
		} catch(_ignored) {
			// not an object...
			wlog($"** WARNING ** False positive object reference detected. Assuming normal real value.");
		}
		return rv;
	}

    static copy_struct = function(_source)
    {
        var _copy = {};
        
        var _names = struct_get_names(_source);
        var _i = 0;
		var res;
        repeat(array_length(_names))
        {
            var _name = _names[_i];
            var _value = struct_get(_source, _name);
			
            if (is_method(_value) || is_ignored(_source, _name)) {
				_i++;
				continue;
			}
			else if (typeof(_value) != "ref" && (is_real(_value) || is_string(_value)))
			{
				// do nothing, just avoid false positives with object instances
			}
            else if (is_object_instance(_value))
			{
				res = replace_ref(_value);
				if (res.success)
					_value = res.value;
				else
					elog($"** ERROR ** Failed to replace instance '{name_of(_value)}'");
			} 
			else if (is_dead_object_instance(_value))
			{
				wlog($"** WARNING ** Data integrity warning, removed dead object instance of '{_name}' ({_value}) before saving!");
				_value = undefined;
			}
			else if (is_array(_value))
            {
                _value = copy_array(_value);
            }
            else if (is_struct(_value))
            {
				_value = to_refstack(_value);
            }

			struct_set(_copy, _name, _value);
            
            ++_i;
        }
        
        return _copy;
    };

    static copy_array = function(_source)
    {
        var _length = array_length(_source);
        var _copy = array_create(_length,);
        
        var _i = 0;
		var res;
        repeat(_length)
        {
            var _value = _source[_i];
            
            if (is_method(_value)) {
				_i++;
				continue;
			}
			else if (typeof(_value) != "ref" && (is_real(_value) || is_string(_value)))
			{
				// do nothing, just avoid false positives with object instances
			}
            else if (is_object_instance(_value))
			{
				res = replace_ref(_value);
				if (res.success)
					_value = res.value;
				else
					elog($"** ERROR ** Failed to replace instance '{name_of(_value)}'");
			} 
			else if (is_dead_object_instance(_value))
			{
				wlog($"** WARNING ** Data integrity warning, removed dead object instance #'{_i}' in array before saving!");
				_value = undefined;
			}
            else if (is_struct(_value))
            {
				_value = to_refstack(_value);
            }
            else if (is_array(_value))
            {
                _value = copy_array(_value);
            }
            
            _copy[@ _i] = _value;
            
            ++_i;
        }
        
        return _copy;
    };

    if (is_struct(source))
    {
        copy = copy_struct(source);
    }
    else if (is_array(source))
    {
        copy = copy_array(source);
    }
    else
    {
        copy = source;
    }

}