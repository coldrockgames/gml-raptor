/*
	Utility methods to work with strings.
	
	(c)coldrock.games
*/


/// @func	sprintf(str)
/// @desc	Classic C# string.Format command. Up to 15 parameters allowed, use {0}, {1}...
///			Example: string_format("Hello {0}, you have {1} gold", name, balance);
/// @param {string} str	The string to format (+ followed by up to 16 formatargs
///	@returns {string}	The formatted string
function sprintf(str) {
	var rv = str;
	
	for (var i = 1; i < argument_count; i++) {
		rv = string_replace_all(rv, "{" + string(i - 1) + "}", string(argument[i]));
	}
	
	return rv;
}


/// @func	string_format_number(value, int_digits, dec_digits = 0, leading_zeros = false)
/// @desc	Just an alias for string_format_number_right (which is the default)
function string_format_number(value, int_digits, dec_digits = 0, leading_zeros = false) {
	gml_pragma("forceinline");
	return string_format_number_right(value, int_digits, dec_digits, leading_zeros);
}

/// @func	string_format_number_right(value, int_digits, dec_digits = 0, leading_zeros = false)
/// @desc	Format a number to a string, right aligned, optionally with leading zeros
function string_format_number_right(value, int_digits, dec_digits = 0, leading_zeros = false) {
	gml_pragma("forceinline");
	return leading_zeros ?
		string_replace_all(string_format(value, int_digits, dec_digits)," ", "0") :
		string_format(value, int_digits, dec_digits);
}

/// @func	string_format_number_left(value, int_digits = 1, dec_digits = 0)
/// @desc	Format a number to a string, left aligned, no leading zeros or blanks
function string_format_number_left(value, int_digits = 1, dec_digits = 0) {
	gml_pragma("forceinline");
	return string_replace_all(string_format(value, int_digits, dec_digits)," ", "");
}

/// @func	string_skip_start(str, count)
/// @desc	Returns a substring of str that skipped the first {count} characters
/// @param {string} str			The string
/// @param {integer} count		The number of characters to skip.
function string_skip_start(str, count) {
	var len = string_length(str);
	if (count > 0 && len > count)
		return string_copy(str, count + 1, len - count);
		
	return "";
}

/// @func	string_skip_end(str, count)
/// @desc	Returns a substring of str that truncated the last {count} characters
/// @param {string} str			The string
/// @param {integer} count		The number of characters to skip/truncate.
function string_skip_end(str, count) {
	var len = string_length(str);
	if (count > 0 && len > count)
		return string_copy(str, 1, len - count);
		
	return "";
}

/// @func	string_substring(str, start, count = undefined)
/// @desc	standard substring implementation with optional count argument
/// @param {string} str			The string
/// @param {integer} start		The starting point of the substring
/// @param {integer} count		Optional. If omitted, all remaining characters until the end are taken
function string_substring(str, start, count = undefined) {
	gml_pragma("forceinline");
	return string_copy(str, start, count ?? (string_length(str) - start + 1));
}

/// @func	string_first(str, count)
/// @desc	Returns the first <count> characters of a string.
///			If the length of the string is less than count characters, the 
///			entire string is returned
/// @param {string} str			The string
/// @param {integer} count		The number of characters to return.
function string_first(str, count) {
	var len = string_length(str);
	if (count > 0) {
		if (len > count)
			return string_copy(str, 1, count);
		else
			return str;
	}
	return "";
}

/// @func	string_last(str, count)
/// @desc	Returns the last <count> characters of a string.
///			If the length of the string is less than count characters, the 
///			entire string is returned
/// @param {string} str			The string
/// @param {integer} count		The number of characters to return.
function string_last(str, count) {
	var len = string_length(str);
	if (count > 0) {
		if (len > count)
			return string_copy(str, len - count + 1, count);
		else
			return str;
	}
	return "";
}

/// @func	string_contains(str, substr)
/// @desc	returns whether the specified substr is contained in str.
/// @param {string} str
/// @param {string} substr
/// @returns {bool}	y/n
function string_contains(str, substr, startpos = 1) {
	gml_pragma("forceinline");
	return string_pos_ext(substr, str, startpos) > 0;
}

/// @func	string_count_char(str, character, startpos = 1)
/// @desc	Counts the number of occurences of character in str
function string_count_char(str, character, startpos = 1) {
	var rv = 0;
	
    for (var i = startpos, len = string_length(str); i <= len; i++) {
        if (string_char_at(str, i) == character) 
            rv++;
    }
    
    return rv;
}

/// @function string_index_of(str, substr, startpos = 1)
function string_index_of(str, substr, startpos = 1) {
	gml_pragma("forceinline");
	return string_pos_ext(substr, str, startpos);
}

/// @function string_last_index_of(str, substr, startpos = 1)
function string_last_index_of(str, substr, startpos = 1) {
	var p = 0;
	var p2 = 0;
	do {
		p2 = string_pos_ext(substr, str, p + 1);
		if (p2 > 0) p = p2;
	} until (p2 == 0);
	return p;
}

/// @func	string_match(str, wildcard_str)
/// @desc	Checks whether a string matches a specific wildcard string.
///			Wildcard character is '*' and it can appear anywhere in the string, any number of times.
///			* at the beginning means "ends_with" (hello -> *llo)
///			* at the end means "starts_with" (hello -> he*)
///			* on both ends means "contains" (hello -> *ell*)
///			* somewhere in the middle means "starts with and ends with" (hello -> he*o)
///			You may combine the above in any way you like! ("Hello, World" -> "He*o*Wo*d*")
///			NOTE: if no '*' is in wildcard_str, then a == exact match counts!
///			Examples:
///			string_match("hello", "hel*") -> true
///			string_match("hello", "*hel*") -> true
///			string_match("hello", "*hel") -> false
/// @param {string} str
/// @param {string} wildcard_str
/// @returns {bool}	
function string_match(str, wildcard_str) {
    if (wildcard_str == "*") 
        return true;

	if (string_index_of(wildcard_str, "*") == 0)
		return str == wildcard_str;

	var full_len = string_length(str);
    var parts = string_split(wildcard_str, "*", false);
	var index = 1;
	var found_at = 0;
	var part;
	var part_len;

	for (var i = 0, len = array_length(parts); i < len; i++) {
        part = parts[@i];
		if (part == "") continue;
		
        part_len = string_length(part);
        found_at = string_pos_ext(part, str, index);
        if (found_at == 0) return false;
        if (i == 0 && found_at != 1) return false; // test string start
        if (i == len - 1 && found_at + part_len - 1 != full_len) return false; // test string end

        index = found_at + part_len;
    }
	
    return true;
}

/// @func	string_is_empty(str)
/// @desc	checks if a string is undefined or empty/blank characters only
/// @param {string} str	string to check
/// @returns {bool}		y/n
function string_is_empty(str) {
	gml_pragma("forceinline");
	return (str == undefined || string_trim(str) == "");
}

/// @func	string_to_real(str)
/// @desc	Tries to convert the string to a real. returns undefined, if failed
function string_to_real(str) {
	if (!IS_HTML) {
		try { return real(string_trim(str)); } catch(_) { return undefined; }
	} else {
		var trimmed = string_trim(str);
		var len = string_length(trimmed);
		var i = 1;
		var c;
		var valid = true;
		while (i <= len) {
			c = string_char_at(trimmed, i);
			if (!is_between(ord(c), ord("0"), ord("9")) && !is_any_of(c, ".", "-", "+")) {
				valid = false;
				break;
			}
			i++;
		}
		try { return valid ? real(trimmed) : undefined; } catch(_) { return undefined; }
	}
}

/// @func	string_to_real_ex(str)
/// @desc	Closer examines the string to get a more reliable conversion 
///			with some performance cost. "1,2,3" is an invalid string for this
///			function, while string_to_real will return "1" as it takes only the first number
function string_to_real_ex(str, __allow_decimal = true) {
	if (string_is_empty(str)) 
		return undefined;
	
	str = string_trim(str);
	var len			= string_length(str);
	var valid		= true;
	var have_dec	= false;
	var extracted	= string_starts_with(str, "-") ? "-" : "";
	var startpoint	= string_starts_with(str, "-") ? 2 : 1;
	var char;
	
	for (var i = startpoint; i <= len; i++) {
		char = string_char_at(str, i);
		if (ord(char) >= ord("0") && ord(char) <= ord("9")) {
			extracted += char;
			continue;
		} else if (char == ".") {
			if (!__allow_decimal) {
				valid = false;
				break;
			}
			if (!have_dec) {
				have_dec = true;
				extracted += char;
				continue;
			} else {
				valid = false;
				break;
			}
		} else {
			valid = false;
			break;
		}
	}
	
	return valid ? string_to_real(extracted) : undefined;
}

/// @func	string_to_int(str)
/// @desc	Tries to convert the string to an int64. returns undefined, if failed
function string_to_int(str) {
	if (!IS_HTML) {
		try { return int64(string_trim(str)); } catch(_) { return undefined; }
	} else {
		var trimmed = string_trim(str);
		var len = string_length(trimmed);
		var i = 1;
		var c;
		var valid = true;
		while (i <= len) {
			c = string_char_at(trimmed, i);
			if (!is_between(ord(c), ord("0"), ord("9")) && !is_any_of(c, "-", "+")) {
				valid = false;
				break;
			}
			i++;
		}
		try { return valid ? int64(trimmed) : undefined; } catch(_) { return undefined; }
	}
}

/// @func	string_to_int_ex(str)
/// @desc	Closer examines the string to get a more reliable conversion 
///			with some performance cost. "1,2,3" is an invalid string for this
///			function, while string_to_real will return "1" as it takes only the first number
function string_to_int_ex(str) {
	return string_to_real_ex(str, false);
}

/// @func	string_reverse(str)
/// @desc	Reverse a string back-to-front
/// @param {string} str	string to reverse
/// @returns {string}	the reversed string
function string_reverse(str) {
    var out = "";
    for(var i=string_length(str); i>0; i--) {
        out += string_char_at(str, i);
    }
    return out;
}

/// @func	string_parse_hex(str)
/// @desc	Parses a hex string, ignoring $, # and dashes and stops at the first unknown character
///			Returns a numeric value containing the (decimal) value of the hex in the string
/// @param {string} str	string to parse
/// @returns {int}	the value of the string
function string_parse_hex(str) {
	var rv = 0;
	var upper = string_upper(str);
 
	// special unicode values
	var ZERO	= ord("0");
	var NINE	= ord("9");
	var A		= ord("A");
	var F		= ord("F");
	var DASH	= ord("-");
	var DOLLAR	= ord("$");
	var HASH	= ord("#");
 
	for (var i = 1; i <= string_length(str); i++) {
	    var c = ord(string_char_at(upper, i));

		rv = rv << 4;
		
	    if (c >= ZERO && c <= NINE) {
	        rv += (c - ZERO);
	    } else if (c>=A&&c<=F) {
	        rv += (c - A + 10);
		} else if (c == DASH || c == DOLLAR || c == HASH) {
			continue;
	    } else {
			return rv;
	    }
	}
 
	return rv;
}

/// @func	string_get_hex(str)
/// @desc	Converts a decimal value to a hex string of a specified length.
///			ATTENTION! If you convert numbers that are too large for the specified
///			length, you might lose information! (Like trying to convert 123456789 into a 2-digit hex string)
/// @param {int} decimal	value to convert
/// @param {int} len	length of the result string
/// @param {bool} to_uppercase	use ABCDEF (default) or abcdef for hex digits
/// @returns {string}	the value of the string
function string_get_hex(decimal, len = 2, to_uppercase = true) {
	var rv = "";
	var dig = (to_uppercase ? "0123456789ABCDEF" : "0123456789abcdef");
    while (len-- || decimal) {
        rv = string_char_at(dig, (decimal & $F) + 1) + rv;
        decimal = decimal >> 4;
    }
	return rv;
}

/// @func	string_interpret_compare(_str, _instance, _with_inheritance = true)
/// @desc	Interprets a string that may contain dot-notation, like
///			"myinst.data.name:value" and compares this against the supplied instance.
///			If _str does not contain a dot-notation, name_of(_instance,false) is compared against _str.
///			If _str ends with "()", the last part of the chain is considered a function and will be invoked
///			on the instance. ONLY PARAMETERLESS FUNCTIONS ARE SUPPORTED! (like ".get_name()")
///			If _with_inheritance is true, interpret also succeeds if the _instance is a child of the
///			type name of _str. It is automatically detected, whether _instance is an object or class instance.
///			Example: 
///			- You are ("self") an object or an instance of type Enemy 
///			  that contains .data.name with a value of "Mummy"
///			- You call string_interpret_compare("Enemy.data.name:Mummy", self) and it returns true, because
///           your .data.name == "Mummy"
///			- Would you call it with ("Enemy.data.name:Scarab", self) it would return false.
///			This function is very useful to connect variables/members of objects in strings, like when
///			you read data from json and want to compare it with runtime data of your living objects.
///			Boolean conversion is automatically in place, ":true" and ":false" are compared with "1" and "0"
///			(which is gml default)
function string_interpret_compare(_str, _instance, _with_inheritance = true) {
	if (is_null(_str))
		return false;
		
	if (string_contains(_str, ".")) {
		if (string_contains(_str, ":")) {
			var colon = string_index_of(_str, ":");
			var dotpart = string_substring(_str, 1, colon - 1);
			var sa = string_split(dotpart, ".");
			
			// early exit, if type name of instance and first entry do not match
			var next = array_shift(sa);
			if (_with_inheritance) {
				if (is_object_instance(_instance)) {
					if (!is_child_of(_instance, next))
						return false;
				} else {
					if (!is_child_class_of(_instance, next))
						return false;
				}
			} else
				if (next != name_of(_instance, false))
					return false;
			
			var valuepart = string_substring(_str, colon + 1);
			if (valuepart == "true") valuepart = 1; else if (valuepart == "false") valuepart = 0;
			var last = string_trim(array_pop(sa));
			var is_func = string_ends_with(last, "()");
			if (is_func) last = string_skip_end(last, 2);
			
			next = _instance;
			while (array_length(sa) > 0) 
				next = next[$ array_shift(sa)];
			
			if (is_func)
				return string(next[$ last]()) == valuepart;
			else
				return string(next[$ last]) == valuepart;
		} else
			throw("String interpreter with dot-notation requires ':' for value separation");
	} else
		return _str == name_of(_instance, false);
}

/// @func	string_interpret_execute(_str, _instance)
/// @desc	Interprets a string that may contain dot-notation, like
///			"myinst.data.name" and executes/accesses this on the supplied instance.
///			In contrast to string_interpret_compare, this function does not return a bool,
///			it returns the _value of the instance.
///			Example: You string_interpret_execute("data.name", objPlayer), then this function will
///			will return the value of data.name of the player.
///			If _str ends with "()", the last part of the chain is considered a function and will be invoked
///			on the instance. ONLY PARAMETERLESS FUNCTIONS ARE SUPPORTED! (like ".get_name()")
///			If _with_inheritance is true, interpret also succeeds if the _instance is a child of the
///			type name of _str. It is automatically detected, whether _instance is an object or class instance.
///			This function is very useful to connect variables/members of objects in strings, like when
///			you read data from json and want to execute them at runtime data on your living objects.
///			NOTE: This function may cause an exception, if the path to the value does not exist
///			on the instance
function string_interpret_execute(_str, _instance) {
	if (is_null(_str))
		return undefined;
	
	var sa = string_split(_str, ".");

	// early exit, if type name of instance and first entry do not match
	var next			= _instance;
	var last			= string_trim(array_pop(sa));
	var is_func			= string_ends_with(last, "()");
	if (is_func) last	= string_skip_end(last, 2);
	
	while (array_length(sa) > 0) 
		next = next[$ array_shift(sa)];
			
	if (is_func)
		return next[$ last]();
	else
		return next[$ last];
		
}

/// @func	string_quote(_str, _quote = "\"")
/// @desc	Encloses a string in quotes or any bracket.
///			By default, double quotes ("") are used, but the function accepts
///			any character as quote and is smart enough to detect, whether you want braces
///			to enclose the string.
///			Examples, set _quote to:
///			":  Hello -> "Hello"
///			':  Hello -> 'Hello'
///			[ or ( or {: Hello -> [Hello] or (Hello) or {Hello}
///			Any 2-letter combination, like []: Hello -> [Hello]
///			But fany combinations also possible: [> Hello -> [Hello>
function string_quote(_str, _quote = "\"") {
	if (string_length(_quote) == 1) {
		switch(_quote) {
			case "[":	return $"[{_str}]";
			case "(":	return $"({_str})";
			case "{":	return string_concat("{", _str, "}");
			default:	return $"{_quote}{_str}{_quote}";
		}
	} else if (string_length(_quote) == 2) {
		return $"{string_char_at(_quote, 1)}{_str}{string_char_at(_quote, 2)}";
	} else
		return $"{_quote}{_str}{_quote}";
}

/// @func	string_unquote(_str)
/// @desc	"Unquotes" a string by removing the first and last character of the string,
///			but only, if it starts and ends with the same quote character (" or ').
function string_unquote(_str) {
	if (string_starts_with(_str, "\"") && string_ends_with(_str, "\"") ||
		string_starts_with(_str, "'") && string_ends_with(_str, "'"))
		return string_skip_end(string_skip_start(_str, 1), 1);
	
	return _str;
}