/*
	Utility methods to work with files async.
	Requires juju's SNAP library and gml-raptor Buffers scripts to work.
	
	(c)2022- coldrock.games, @grisgram at github
*/

/// @func	file_read_text_file_absolute_async(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire file and returns the AsyncReader where you must attach your .on_finished callback
function file_read_text_file_absolute_async(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	if (variable_struct_exists(__FILE_CACHE, filename)) {
		return new __FileAsyncCacheHit(filename, struct_get(__FILE_CACHE, filename));
	}
	
	TRY
		return new __FileAsyncReader(filename, cryptkey)
		.__raptor_data("bom", remove_utf8_bom)
		.__raptor_data("cache", add_to_cache)
		.__raptor_data("filename", filename)
		.__raptor_finished(function(_prev, _buffer, data) {
			var bufsize = max(0, buffer_get_size(_buffer));
			vlog($"Loaded {bufsize} bytes from file");
			var _string = undefined;
			TRY
				if (bufsize > 0) {
				    if (data.bom && 
						(buffer_get_size(_buffer) >= 4) && 
						(buffer_peek(_buffer, 0, buffer_u32) & 0xFFFFFF == 0xBFBBEF))
				    {
				        buffer_seek(_buffer, buffer_seek_start, 3);
				    }
    
				    _string = buffer_read(_buffer, buffer_string);
	
					if (data.cache) {
						dlog($"Added file '{data.filename}' to cache");
						struct_set(__FILE_CACHE, data.filename, _string);
					}
				}
			CATCH ENDTRY
			return _string;
		})
		.start();
	CATCH return new __FileAsyncFailedWorker(filename, cryptkey);
	ENDTRY
}

/// @func	file_read_text_file_async(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire file and returns the contents as string
///			checks whether the file exists, and if not, an empty string is returned.
///			crashes, if the file is not a text file
function file_read_text_file_async(filename, cryptkey = "", remove_utf8_bom = true, add_to_cache = false) {
	return file_read_text_file_absolute_async(__FILE_WORKINGFOLDER_FILENAME, cryptkey, remove_utf8_bom, add_to_cache);
}

/// @func	file_read_text_file_lines_async(filename, cryptkey = "", remove_empty_lines = true, remove_utf8_bom = true, add_to_cache = false)
/// @desc	reads an entire file and returns the contents as string array, line by line
///			checks whether the file exists, and if not, an empty string array is returned.
///			crashes, if the file is not a text file
function file_read_text_file_lines_async(filename, cryptkey = "", remove_empty_lines = true, remove_utf8_bom = true, add_to_cache = false) {
	return 			
		file_read_text_file_absolute_async(__FILE_WORKINGFOLDER_FILENAME, cryptkey, remove_utf8_bom, add_to_cache)
		.__raptor_data("remove_empty", remove_empty_lines)
		.__raptor_finished(function(_prev, _buffer, _data) {
			return string_split(string_replace_all(_prev, "\r", ""), "\n", _data.remove_empty);
		});
}

/// @func	file_write_text_file_async(filename, text, cryptkey = "")
/// @desc	Saves a given text as a plain text file. Can write any string, not only json.
function file_write_text_file_async(filename, text, cryptkey = "") {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	TRY
		var buffer = buffer_create(string_byte_length(text) + 1, buffer_fixed, 1);
		buffer_write(buffer, buffer_string, text);
		return new __FileAsyncWriter(__FILE_WORKINGFOLDER_FILENAME, buffer, cryptkey)
		.__raptor_finished(function(_prev, _buffer, _data) {
			return true;
		})
		.start();
	CATCH return new __FileAsyncFailedWorker(filename, cryptkey); ENDTRY
}

/// @func	file_write_text_file_lines_async(filename, text, cryptkey = "", line_delimiter = "\n")
/// @desc	Saves a given string array as a plain text file.
function file_write_text_file_lines_async(filename, lines_array, cryptkey = "", line_delimiter = "\n") {
	return file_write_text_file_async(filename, string_join_ext(line_delimiter, lines_array), cryptkey);
}

/// @func	file_write_struct_async(filename, struct, cryptkey = "")
/// @desc	Saves a given struct to a file, optionally encrypted
function file_write_struct_async(filename, struct, cryptkey = "") {
	if (cryptkey == "")
		return file_write_struct_plain_async(filename, struct)
	else
		return file_write_struct_encrypted_async(filename, struct, cryptkey);
}

/// @func	file_read_struct_async(filename, cryptkey = "", add_to_cache = false)
/// @desc	Reads a given struct from a file, optionally encrypted
function file_read_struct_async(filename, cryptkey = "", add_to_cache = false) {
	if (cryptkey == "")
		return file_read_struct_plain_async(filename, add_to_cache);
	else
		return file_read_struct_encrypted_async(filename, cryptkey, add_to_cache);
}

/// @func	file_write_struct_plain_async(filename, struct, print_pretty = true)
/// @desc	Saves a given struct as a plain text json file.
function file_write_struct_plain_async(filename, struct, print_pretty = true) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	TRY
		return file_write_text_file_async(filename, SnapToJSON(struct, print_pretty))
		.__raptor_data("filename", filename)
		.__raptor_data("struct", struct)
		.__raptor_finished(function(_prev, _buffer, _data) {
			if (variable_struct_exists(__FILE_CACHE, _data.filename)) {
				dlog($"Updated cache for file '{_data.filename}' (struct)");
				struct_set(__FILE_CACHE, _data.filename, deep_copy(_data.struct));
			}
			return true;
		});
	CATCH return new __FileAsyncFailedWorker(filename, ""); ENDTRY
}

/// @func	file_read_struct_plain_async(filename, add_to_cache = false)
/// @desc	Loads the contents of the file and tries to parse it as struct.
function file_read_struct_plain_async(filename, add_to_cache = false) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	if (file_exists_html_safe(__FILE_WORKINGFOLDER_FILENAME)) {
		if (variable_struct_exists(__FILE_CACHE, filename)) {
			return new __FileAsyncCacheHit(filename, deep_copy(struct_get(__FILE_CACHE, filename)));
		}
		TRY
			return file_read_text_file_async(filename, "", add_to_cache)
			.__raptor_data("filename", filename)
			.__raptor_data("add_to_cache", add_to_cache)
			.__raptor_finished(function(_prev, _buffer, _data) {
				vlog($"Read {(string_is_empty(_prev) ? "0" : string_length(_prev))} characters from file");
				var rv = undefined;
				TRY
					if (!string_is_empty(_prev)) {
						var indata = SnapFromJSON(_prev);
						rv = __file_reconstruct_root(indata);
						if (_data.cache) {
							dlog($"Added file '{_data.filename}' to cache (struct)");
							struct_set(__FILE_CACHE, _data.filename, deep_copy(rv));
						}
					}
				CATCH ENDTRY
				return rv;
			})
			.start();
		CATCH return new __FileAsyncFailedWorker(filename, "");	ENDTRY
	} else
		elog($"** ERROR ** File '{__FILE_WORKINGFOLDER_FILENAME}' does not exist!");
	return new __FileAsyncFailedWorker(filename, "");
}

/// @func	file_write_struct_encrypted_async(filename, struct, cryptkey)
/// @desc	Encrypts the binary representation of the given struct with a key
///			and saves this to a file.
function file_write_struct_encrypted_async(filename, struct, cryptkey) {
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	TRY
		var len = SnapBufferMeasureBinary(struct);
		var buffer = buffer_create(len, buffer_grow, 1);
		buffer_fill(buffer, 0, buffer_u8, 0, len);
		buffer = SnapBufferWriteBinary(buffer, struct);
		
		return new __FileAsyncWriter(__FILE_WORKINGFOLDER_FILENAME, buffer, cryptkey)
		.__raptor_data("filename", filename)
		.__raptor_data("struct", struct)
		.__raptor_data("cryptkey", cryptkey)
		.__raptor_finished(function(_prev, _buffer, _data) {
			if (variable_struct_exists(__FILE_CACHE, _data.filename)) {
				dlog($"Updated cache for file '{_data.filename}' (encrypted struct)");
				struct_set(__FILE_CACHE, _data.filename, deep_copy(_data.struct));
			}
			return true;
		})
		.start();
		
	CATCH return new __FileAsyncFailedWorker(filename, cryptkey); ENDTRY
}

/// @func	file_read_struct_encrypted_async(filename, cryptkey, add_to_cache = false)
/// @desc	Decrypts the data in the specified file with the specified key.
function file_read_struct_encrypted_async(filename, cryptkey, add_to_cache = false) {	
	__ensure_file_cache();
	filename = __clean_file_name(filename);
	
	if (file_exists_html_safe(__FILE_WORKINGFOLDER_FILENAME)) {
		if (variable_struct_exists(__FILE_CACHE, filename)) {
			return new __FileAsyncCacheHit(filename, deep_copy(struct_get(__FILE_CACHE, filename)));
		}
		TRY
			return new __FileAsyncReader(__FILE_WORKINGFOLDER_FILENAME, cryptkey)
			.__raptor_data("filename", filename)
			.__raptor_data("cryptkey", cryptkey)
			.__raptor_data("cache", add_to_cache)
			.__raptor_finished(function(_prev, _buffer, _data) {
				var bufsize = max(0, buffer_get_size(_buffer));
				vlog($"Read {bufsize} bytes into the buffer");
				var rv = undefined;
				TRY
					if (bufsize > 0) {
						var indata = SnapBufferReadBinary(_buffer, 0);
						rv = __file_reconstruct_root(indata);
						if (_data.cache) {
							dlog($"Added file '{_data.filename}' to cache (encrypted struct)");
							struct_set(__FILE_CACHE, _data.filename, deep_copy(rv));
						}
					}
				CATCH ENDTRY
				return rv;
			})
			.start();
		CATCH return new __FileAsyncFailedWorker(filename, cryptkey); ENDTRY
	} else
		elog($"** ERROR ** File '{__FILE_WORKINGFOLDER_FILENAME}' does not exist!");
	return new __FileAsyncFailedWorker(filename, cryptkey);
}
