/*
	Utility methods to work with files.
	Requires juju's SNAP library and gml-raptor Buffers scripts to work.
	
	*** IMPORTANT NOTE ***
	Some of these functions have a "cryptkey" parameter.
	This is a raptor-pro only feature. The parameter is ignored in this version of raptor.
	It is kept in here to ensure compatibility of the method signatures with the raptor-pro version.
	
	(c)coldrock.games
*/

#macro FILE_CRYPT_KEY	""
#macro __FILE_CACHE		global.__file_cache
__FILE_CACHE = {};

#macro __FILE_WORKINGFOLDER_FILENAME	__clean_file_name(((string_starts_with(filename, "\\\\") || string_contains(filename, ":\\")) \
										? filename : string_concat(working_directory, filename)))

/// @func					file_clear_cache()
/// @desc				clears the entire file cache
function file_clear_cache() {
	__FILE_CACHE = {};
}

/// @func				__ensure_file_cache()	
/// @desc			ensures, the global cache exists
function __ensure_file_cache() {
	if (!variable_global_exists("__file_cache"))
		__FILE_CACHE = {};
}

function __clean_file_name(_filename) {
	while (string_contains(_filename, "//") || string_contains(_filename, "\\/"))
		_filename = 
			string_replace_all(
				string_replace_all(_filename, "\\/", "/"), 
			"//", "/");
	return _filename;
}

/// @func	file_read_text_file_absolute(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire text file from an absolute path and returns the contents as string
///			checks whether the file exists, and if not, undefined is returned.
///			crashes, if the file is not a text file
function file_read_text_file_absolute(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		vlog($"Cache hit for file '{filename}'");
		return struct_get(__FILE_CACHE, filename);
	}
	
	TRY
		vlog($"Loading text file {filename}");
	    var _buffer = buffer_load(filename);
		var bufsize = max(0, buffer_get_size(_buffer));
		vlog($"Loaded {bufsize} bytes from file");
		var _string = undefined;
		if (bufsize > 0) {
		    if (remove_utf8_bom && (buffer_get_size(_buffer) >= 4) && (buffer_peek(_buffer, 0, buffer_u32) & 0xFFFFFF == 0xBFBBEF))
		    {
		        buffer_seek(_buffer, buffer_seek_start, 3);
		    }
    
		    _string = buffer_read(_buffer, buffer_string);
		    buffer_delete(_buffer);
	
			if (add_to_cache) {
				dlog($"Added file '{filename}' to cache");
				struct_set(__FILE_CACHE, filename, _string);
			}
		}
	    return _string;
	CATCH return undefined; 
	ENDTRY
}

/// @func	file_read_binary_absolute(filename, cryptkey = "", add_to_cache = false)
/// @desc	reads an entire binary file from an absolute path and returns the contents as buffer
///			checks whether the file exists, and if not, undefined is returned.
function file_read_binary_absolute(filename, cryptkey = "", add_to_cache = false) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		vlog($"Cache hit for file '{filename}'");
		return struct_get(__FILE_CACHE, filename);
	}
	
	TRY
		vlog($"Loading binary file {filename}");
	    var buffer = buffer_load(filename);
		var bufsize = max(0, buffer_get_size(buffer));
		vlog($"Loaded {bufsize} bytes from file");
		if (bufsize > 0) {
			if (add_to_cache) {
				dlog($"Added file '{filename}' to cache");
				struct_set(__FILE_CACHE, filename, buffer);
			}
		    return buffer;
		}
		return undefined;
	CATCH return undefined; 
	ENDTRY
}

/// @func	file_read_binary(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire binary file and returns the contents as buffer
///			checks whether the file exists, and if not, undefined returned.
///			Returns undefined, if the file is not a text file
function file_read_binary(filename, cryptkey = "", add_to_cache = false) {
	return file_read_binary_absolute(__FILE_WORKINGFOLDER_FILENAME, cryptkey, add_to_cache);
}

/// @func	file_read_text_file(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire file and returns the contents as string
///			checks whether the file exists, and if not, undefined returned.
///			Returns undefined, if the file is not a text file
function file_read_text_file(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false) {
	return file_read_text_file_absolute(__FILE_WORKINGFOLDER_FILENAME, cryptkey, remove_utf8_bom, add_to_cache);
}

/// @func	file_read_text_file_lines(filename, cryptkey = "", remove_empty_lines = true, remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire file and returns the contents as string array, line by line
///			checks whether the file exists, and if not, undefined returned.
///			Returns undefined, if the file is not a text file
function file_read_text_file_lines(filename, cryptkey = "", remove_empty_lines = true, remove_utf8_bom = true, add_to_cache = false) {
	var content = file_read_text_file_absolute(__FILE_WORKINGFOLDER_FILENAME, cryptkey, remove_utf8_bom, add_to_cache);
	return content != undefined ?
			string_split(string_replace_all(content, "\r", ""),	"\n", remove_empty_lines) :
			undefined;
}

/// @func	file_write_text_file(filename, text, cryptkey = "")
/// @desc	Saves a given text as a plain text file. Can write any string, not only json.
function file_write_text_file(filename, text, cryptkey = "") {
	__ensure_file_cache();
	TRY
		var buffer = buffer_create(string_byte_length(text) + 1, buffer_fixed, 1);
		buffer_write(buffer, buffer_string, text);
		buffer_save(buffer, __FILE_WORKINGFOLDER_FILENAME);
		buffer_delete(buffer);
		return true;
	CATCH return false; ENDTRY
}

/// @func	file_write_binary(filename, buffer_to_write, cryptkey = "")
/// @desc	Saves a given buffer as a binary file.
function file_write_binary(filename, buffer_to_write, cryptkey = "") {
	__ensure_file_cache();
	TRY
		var bufsize = buffer_get_size(buffer_to_write);
		dlog($"Saving {bufsize} bytes to binary '{filename}'");
		var buffer = buffer_create(bufsize, buffer_u8, 1);
		buffer_copy(buffer_to_write, 0, bufsize, buffer, 0);
		buffer_save(buffer, __FILE_WORKINGFOLDER_FILENAME);
		buffer_delete(buffer);
		return true;
	CATCH return false; ENDTRY
}

/// @func	file_write_text_file_lines(filename, lines_array, cryptkey = "", line_delimiter = "\n")
/// @desc	Saves a given string array as a plain text file.
function file_write_text_file_lines(filename, lines_array, cryptkey = "", line_delimiter = "\n") {
	return file_write_text_file(filename, string_join_ext(line_delimiter, lines_array), cryptkey);
}

/// @func	file_write_struct(filename, struct, cryptkey = "")
/// @desc	Saves a given struct to a file, optionally encrypted
function file_write_struct(filename, struct, cryptkey = "") {
	return file_write_struct_plain(filename, struct)
}

/// @func	file_read_struct(filename, cryptkey = "", add_to_cache = false)
/// @desc	Reads a given struct from a file, optionally encrypted
function file_read_struct(filename, cryptkey = "", add_to_cache = false) {
	return file_read_struct_plain(filename, add_to_cache);
}

/// @func	file_write_struct_plain(filename, struct, print_pretty = DEBUG_MODE_ACTIVE)
/// @desc	Saves a given struct as a plain text json file.
function file_write_struct_plain(filename, struct, print_pretty = DEBUG_MODE_ACTIVE) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	TRY
		dlog($"Saving plain text struct to '{filename}'");
		file_write_text_file(filename, json_stringify(struct, print_pretty));
		if (variable_struct_exists(__FILE_CACHE, filename)) {
			dlog($"Updated cache for file '{filename}' (struct)");
			struct_set(__FILE_CACHE, filename, deep_copy(struct));
		}
		return true;
	CATCH return false; ENDTRY
}

/// @func	file_read_struct_plain(filename, add_to_cache = false)
/// @desc	Loads the contents of the file and tries to parse it as struct.
function file_read_struct_plain(filename, add_to_cache = false) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	if (file_exists_html_safe(__FILE_WORKINGFOLDER_FILENAME)) {
		if (variable_struct_exists(__FILE_CACHE, filename)) {
			vlog($"Cache hit for file '{filename}'");
			return deep_copy(struct_get(__FILE_CACHE, filename));
		}
		TRY
			dlog($"Loading plain text struct from '{filename}'");
			var contents = file_read_text_file(filename);
			vlog($"Read {(string_is_empty(contents) ? "0" : string_length(contents))} characters from file");
			var rv = undefined;
			if (!string_is_empty(contents)) {
				var indata = (IS_HTML ? SnapFromJSON(contents) : json_parse(contents));
				rv = __file_reconstruct_root(indata);
				if (add_to_cache) {
					dlog($"Added file '{filename}' to cache (struct)");
					struct_set(__FILE_CACHE, filename, deep_copy(rv));
				}
			}
			return rv;
		CATCH 
			if (string_contains(EXCEPTION_MESSAGE, "JSON parse error")) {
				if (CONFIGURATION_DEV && os_type == os_windows)
					show_message($"JSON ERROR IN {filename}:\n\n{EXCEPTION_MESSAGE}");
				throw("JSON PARSE ERROR");
			}
			return undefined;	
		ENDTRY
	} else
		elog($"** ERROR ** File '{__FILE_WORKINGFOLDER_FILENAME}' does not exist!");
	return undefined;
}


