/*
    compile raptor json files to encrypted jx files
*/

// set this to true to use hardcoded folder/config values
#macro IDE_MODE			CONFIGURATION_DEV
#macro IDE_MODE_PATH	"C:\\Work\\dev\\github\\gml-raptor\\tools\\raptor-json-compiler\\"
#macro IDE_MODE_CONFIG	"beta"

global.run_in		= "";
global.config		= "";
global.default_ext	= "";
global.default_key	= "";
global.config_ext	= "";
global.config_key	= "";

function get_commandline_arguments() {
	if (IDE_MODE) {
		global.run_in = IDE_MODE_PATH;
		global.config = IDE_MODE_CONFIG;
	} else {
		if (parameter_count() != 3)
			return false;
	
		global.run_in = parameter_string(1);
		global.config = parameter_string(2);
		
		if (!string_ends_with(global.run_in, "\\"))
			global.run_in += "\\";
	}

	if (string_is_empty(global.config) || global.config == "Default")
		return false;

	return directory_exists(global.run_in);
}

function __find_macro(content, macro) {
	if (string_contains(content, macro)) {
		var pos		= string_pos_ext(macro, content, 1);
		var posend	= string_pos_ext("\n", content, pos);
		
		var line = string_copy(content, pos, posend - pos);
		if (string_ends_with(line, "\\\n") || string_ends_with(line, "\\\r") || string_ends_with(line, "\\")) {
			posend	= string_pos_ext("}", content, pos);
			line	= string_split_ext(string_copy(content, pos, posend - pos), ["\r", "\n"], true);			
		}
		return __grep_macro_value(line, macro);
	}
	return undefined;
}

function __grep_macro_value(line, macro) {
	if (is_array(line)) {
		array_shift(line);
		for (var i = 0, len = array_length(line); i < len; i++) {
			line[@i] = string_trim(
				string_split(
					string_replace_all(
						string_replace_all(
							string_replace_all(line[@i], 
							"\\", ""),
						",", ""), 
					"\"", ""), 
				":")[@1]);
		}
		return line;
	} else
		return
			string_trim(
				string_replace_all(
					string_replace(line, macro, ""), "\"", "")
			);			
}

function compile_jsons(folder) {
	// first, scan for subfolders
	ilog($"Compiling folder {folder}");
	var list = [];
	var f = file_find_first(string_concat(folder, "\\*"), fa_directory);
	var fullpath;
	while (f != "") {
		fullpath = string_concat(folder, "\\", f);
		if (directory_exists(fullpath))
			array_push(list, fullpath);
		f = file_find_next();
	}
	file_find_close();
	
	// then go into recursion for them
	for (var i = 0, len = array_length(list); i < len; i++)
		compile_jsons(list[@i]);
	

	// then add all files to the result set
	f = file_find_first(string_concat(folder, "\\*", global.default_ext), 0);
	var outpath;
	while (f != "") {
		if (f != "version.json") {
			fullpath = string_concat(folder, "\\", f);
			outpath = string_concat(string_skip_end(fullpath, string_length(global.default_ext)), global.config_ext);
			var infile = file_read_struct(fullpath, global.default_key);
			if (infile != undefined) {
				ilog($"Compiling file {f}");
				file_write_struct(outpath, infile, global.config_key);
			} else
				ilog($"Skipped empty file {fullpath}");
		}
		f = file_find_next();
	}
	file_find_close();
}

function read_project() {

	var content1 = file_read_text_file_absolute($"{global.run_in}scripts\\Game_Configuration\\Game_Configuration.gml");
	var	content2 = file_read_text_file_absolute($"{global.run_in}scripts\\file_extensions\\file_extensions.gml");

	if (content1 == undefined || content2 == undefined) {
		show_message("Error loading Game_Configuration and file_extensions scripts.\nIs this really a raptor project?");
		return;
	}
	
	var content = string_concat(content1, "\n", content2);
	var keyok = false;
	while (!keyok) {
		var forkey = ((string_is_empty(global.config) || global.config == "Default") ? "" : $"{global.config}:");

		var macro_default_key	= "#macro FILE_CRYPT_KEY";
		var macro_default_ext	= "#macro __RUNTIME_FILE_EXTENSIONS";
		var macro_config_key	= $"#macro {forkey}FILE_CRYPT_KEY";
		var macro_config_ext	= $"#macro {forkey}__RUNTIME_FILE_EXTENSIONS";

		global.default_ext	= __find_macro(content, macro_default_ext);
		global.default_key	= __find_macro(content, macro_default_key);
		global.config_ext	= __find_macro(content, macro_config_ext);
		global.config_key	= __find_macro(content, macro_config_key);

		if (is_null(global.config_key) && global.config == "beta") {
			global.config = "release";
		} else
			keyok = true;
	}
	
	if (global.default_ext != undefined && global.config_ext != undefined && global.config_key != undefined) {
		if (!is_array(global.default_ext)) global.default_ext = [ global.default_ext ];
		if (!is_array(global.config_ext))  global.config_ext  = [ global.config_ext ];
		
		var def = global.default_ext;
		var cfg = global.config_ext;
		
		if (array_length(def) == array_length(cfg)) {
			ilog($"Input key is  '{global.default_key}'");
			ilog($"Output key is '{global.config_key}'");
			
			for (var i = 0, len = array_length(def); i < len; i++) {
				global.default_ext	= def[@i];
				global.config_ext	= cfg[@i];
				ilog($"Processing extension '{global.default_ext}' -> '{global.config_ext}'");
				if (global.default_ext != global.config_ext)
					compile_jsons(string_concat(global.run_in, "datafiles"));
				else
					ilog($"{global.config_ext}: No encryption necessary");
			}
		} else
			show_message("Error analyzing extensions in file_extensions script.\nIs this really a raptor project?");
	} else
		show_message("Error finding crypt key and extensions in Game_Configuration and file_extensions scripts.\nIs this really a raptor project?");
}

ENSURE_LOGGER;

ilog($"raptor-json-compiler starting");
try {
	if (!get_commandline_arguments()) {
		show_message("Parameter error:\n\nYou must supply 2 parameters: <project_folder> <configuration>\n\n<configuration> is normally the content of the\n%YYconfig% environment variable when running from a batch script.");
	} else
		read_project();
} catch (_ex) {
	show_message($"raptor-json-compiler error:\n\n{_ex.message}");
} finally {
	ilog("raptor-json-compiler finished");
	game_end();
}