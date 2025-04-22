/*
    button clicks
*/
function startStateDemoButton_click() {
	room_goto(rmPlay);
}

function startRaceDemoButton_click() {
	room_goto(rmRace);
}

function startPlaygroundButton_click() {
	//var file = get_open_filename_ext("all|*.*","", working_directory, "bla");get_save_filename_ext
	//ilog($"sandbox: {GM_is_sandboxed} {file}");
	//ui_demo_load();
	room_goto(rmDevPlayground);
}

function startUiDemoButton_click() {
	room_goto(rmUiDemo);
}

function exitButton_click() {
	EXIT_GAME
}

/*
    hotswap languages
*/
function languageButton_click(sender) {
	LG_hotswap(sender.locale_name, function() {
		ilog("Async reload of locale finished.");
	});
}

/*
	savegame system
*/
#macro SAVE_FILE_NAME_PLAIN		"demosave_plain.json"
#macro SAVE_FILE_NAME_ENC		"demosave_encrypted.dat"
#macro SAVE_FILE_CRYPT_KEY		"~this.is.any_l0ng_string.used.as-kind-of-SALT.to.encrypt.the.data!"


function save_plain_text() {
	savegame_save_game_async(SAVE_FILE_NAME_PLAIN);
	cmdLoad.set_enabled(true);
}

function save_encrypted() {
	savegame_save_game_async(SAVE_FILE_NAME_ENC, SAVE_FILE_CRYPT_KEY);
	cmdLoadEncrypted.set_enabled(true);
}

function load_plain_text() {
	savegame_load_game_async(SAVE_FILE_NAME_PLAIN);
}

function load_encrypted() {
	savegame_load_game_async(SAVE_FILE_NAME_ENC, SAVE_FILE_CRYPT_KEY);
}

function activate_default_theme() {
	UI_THEMES.activate_theme("default");
	room_restart();
}

function activate_blue_theme() {
	UI_THEMES.activate_theme("coldrock");
	room_restart();
}

function activate_raptor_theme() {
	UI_THEMES.activate_theme("raptor");
	room_restart();
}

function activate_purple_theme() {
	UI_THEMES.activate_theme("purple");
	room_restart();
}

function activate_default_skin() {
	UI_SKINS.activate_skin("demo");
}

function activate_wood_skin() {
	UI_SKINS.activate_skin("wood");
}
