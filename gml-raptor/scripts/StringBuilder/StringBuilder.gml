/*
    A buffer-oriented implementation of a .net StringBuilder.
	As close as it can get with GML.
*/


/// @func StringBuilder(_initial_size = 64)
function StringBuilder(_initial_size = 64) constructor {
	
	_buffer = buffer_create(_initial_size, buffer_grow, 1);
	
	/// @func append(_val)
	/// @desc	Appends the specified value to the string.
	///			If the value is not a string, it will be converted for you.
	static append = function(_val) {
		buffer_write(_buffer, buffer_text, string(_val));
		return self;
	}
	
	/// @func append_line(_val = "")
	/// @desc	Appends the specified value to the string and adds a newline \n character.
	///			If the value is not a string, it will be converted for you.
	static append_line = function(_val = "") {
		buffer_write(_buffer, buffer_text, string_concat(_val, "\n"));
		return self;
	}
	
	/// @func append_word(_val)
	/// @desc	Appends a blank character and then the specified value to the string.
	///			Convenience function to avoid .append(" ").append(something) chains
	static append_word = function(_val) {
		buffer_write(_buffer, buffer_text, string_concat(" ", _val));
		return self;
	}

	/// @func length()
	static length = function() {
		return string_length(toString(false));
	}
	
	/// @func clear()
	/// @desc Clears (deletes) the buffer and creates a new one with the initial size
	static clear = function() {
		buffer_delete(_buffer);
		_buffer = buffer_create(_initial_size, buffer_grow, 1);
	}
	
	/// @func clean_up()
	/// @desc Deletes the buffer. You must call this to avoid memory leaks, OR
	///		  you can auto-delete it, by invoking the toString() function
	static clean_up = function() {
		if (_buffer == undefined) return;
		buffer_delete(_buffer);
		_buffer = undefined;
	}
	
	/// @func toString(_delete_buffer = true)
	/// @desc	Returns the contents as string and deletes the buffer to avoid memory leak.
	///			You can avoid the buffer deletion by supplying false as the first argument.
	toString = function(_delete_buffer = true) {
		buffer_seek(_buffer, buffer_seek_start, 0);
		var rv = buffer_read(_buffer, buffer_string);
		if (!_delete_buffer)
			buffer_seek(_buffer, buffer_seek_end, 0);
		else {
			buffer_delete(_buffer);
			_buffer = undefined;
		}
		
		return rv;
	}
	
}