/*
	This script contains some utility functions that adapt, overwrite
	or extend some of juju's libraries a bit to my needs.
*/

#region Scribble++
/// @func scribble_measure_text(_string, _font = undefined, _coord2 = undefined)
/// @desc	Get a Coord2 containing the width and height the text needs,
///					if rendered with the specified _font (or the scribble_default_font if omitted)
function scribble_measure_text(_string, _font = undefined, _coord2 = undefined) {
	var scrib = scribble(_string)
			.starting_format((_font == undefined || _font == "undefined") ? scribble_font_get_default() : _font, c_white);
			
	_coord2 ??= new Coord2();
	
	_coord2.set(scrib.get_width(), scrib.get_height());
	
	return _coord2;
}

/// @func	scribble_create(_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined)
/// @desc	scribble shortcut to create a scribble object in one line
function scribble_create(
	_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined) {
	return scribble(string_concat(_align, _string), _unique_key ?? $"scrib_{SUID}")
		.starting_format(_font_name ?? scribble_font_get_default(), _text_color);
}

/// @func	scribble_create_outline(_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined, _outline_color = c_black)
/// @desc	scribble shortcut to create an outlined scribble object in one line
function scribble_create_outline(
	_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined, 
	_outline_color = c_black) {
	return scribble_create(_align, _string, _font_name, _unique_key, _text_color)
		.outline(_outline_color);
}

/// @func	scribble_create_shadow(_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined, _shadow_color = c_black, _shadow_alpha = 0.75)
/// @desc	scribble shortcut to create a shadowed scribble object in one line
function scribble_create_shadow(
	_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined, 
	_shadow_color = c_black, _shadow_alpha = 0.75) {
	return scribble_create(_align, _string, _font_name, _unique_key, _text_color)
		.shadow(_shadow_color, _shadow_alpha);
}

/// @func	scribble_create_outline_shadow(_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined, _outline_color = c_black, _shadow_color = c_black, _shadow_alpha = 0.75)
/// @desc	scribble shortcut to create an outlined and shadowed scribble object in one line
function scribble_create_outline_shadow(
	_align, _string, _font_name = undefined, _text_color = c_white, _unique_key = undefined,
	_outline_color = c_black, _shadow_color = c_black, _shadow_alpha = 0.75) {
	return scribble_create(_align, _string, _font_name, _unique_key, _text_color)
		.outline(_outline_color)
		.shadow(_shadow_color, _shadow_alpha);
}

#endregion

#region Snap++
/*
    0x00  -  terminator
    0x01  -  struct
    0x02  -  array
    0x03  -  string
    0x04  -  f64
    0x05  -  <false>
    0x06  -  <true>
    0x07  -  <undefined>
    0x08  -  s32
    0x09  -  u64
    0x0A  -  pointer
    0x0B  -  instance ID reference
*/

/// @func SnapBufferMeasureBinary(_value)
/// @desc	The number of bytes a buffer should have if this _value would've 
///					been written to a buffer through SnapBufferWriteBinary
/// @param {struct/array} _value	The value to measure
function SnapBufferMeasureBinary(_value)
{
	var len = 0;
    if (is_method(_value)) //Implicitly also a struct so we have to check this first
    {
		len = string_byte_length(_value) + 2;
    }
    else if (is_struct(_value))
    {
        var _struct = _value;        
        var _names	= struct_get_names(_struct);
        var _count	= array_length(_names);
		
		len += 9;
        
        var _i = 0;
        repeat(_count)
        {
            var _name = _names[_i];
            if (!is_string(_name)) show_debug_message("SNAP:\nKeys must be strings\n ", true);
			len += string_byte_length(_name) + 1;
            len += SnapBufferMeasureBinary(_struct[$ _name]);
            
            ++_i;
        }
    }
    else if (is_array(_value))
    {
        var _array = _value;
        var _count = array_length(_array);
        
		len = 9;
        
        var _i = 0;
        repeat(_count)
        {
            len += SnapBufferMeasureBinary(_array[_i]);
            ++_i;
        }
    }
    else if (is_string(_value))
    {
		len = string_byte_length(_value) + 2;
    }
    else if (is_real(_value))
    {
		len = (_value == 0 || _value == 1) ? 1 : 9;
    }
    else if (is_bool(_value))
    {
		len = 1;
    }
    else if (is_undefined(_value))
    {
		len = 1;
    }
    else if (is_int32(_value))
    {
		len = 5;
    }
    else if (is_int64(_value))
    {
		len = 9;
    }
    else if (is_ptr(_value))
    {
		len = 9;
    }
    else if (typeof(_value) == "ref") // is_ref() doesn't exist as of 2022-10-23
    {
		len = 9;
    }
    else
    {
        show_message(string_concat("Datatype \"", typeof(_value), "\" not supported"));
    }
    return len;
}

#endregion

