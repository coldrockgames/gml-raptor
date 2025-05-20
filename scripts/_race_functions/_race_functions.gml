/*
    global race supporting functions
*/

/// @func	race_read_tree_async(_folder = RACE_ROOT_FOLDER)
/// @desc	Reads an entire tree of race files recursively.
///			The folder read by default is the RACE_ROOT_FOLDER you set in the Race_Configuration file.
///			You receive a struct as return value but keep in mind, that this struct will
///			be filled async across several frames until all files are loaded and compiled,
///			but you should use it to store it in some global variable to gain access to all
///			race tables in one place.
function race_read_tree_async(_folder = RACE_ROOT_FOLDER) {
	var rv = {};
	var files = directory_list_files(_folder, string_concat("*", DATA_FILE_EXTENSION), true, fa_none);
	for (var i = 0, len = array_length(files); i < len; i++) {
		var fn = files[@i];
		var name = string_skip_end(
			string_skip_start(fn, string_index_of(fn, "/")),
			string_length(DATA_FILE_EXTENSION)
		);
		
		struct_set(rv, name, new Race(fn));
		
	}
	return rv;
}
