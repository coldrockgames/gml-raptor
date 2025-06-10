/*
    The settings structure of your game.
	Adapt as needed. A "new GameSettings()" gets called on load attempt of the settings file,
	if none exists.
*/

#macro GAMESETTINGS		global._game_settings
// load_settings gets called on game start before onGameStarting callback is invoked
// So, when your code in inGameStarting runs, this is already available
GAMESETTINGS = undefined;  

// Add everything you want to be part of the settings file in this struct.
// DO NOT ADD FUNCTIONS HERE! Only data!
function GameSettings() constructor {
	construct(GameSettings);

	// --- Custom / additional default settings values ---
	
	// ---------------------------------------------------	

	start_fullscreen		= START_FULLSCREEN;
	borderless_fullscreen	= FULLSCREEN_IS_BORDERLESS;
	audio					= AUDIOSETTINGS;
	use_system_cursor		= false;
	locale					= LG_CURRENT_LOCALE;
	
	if (HIGHSCORES != undefined) 
		highscoredata = HIGHSCORES.data;
		
	/// @func reset()
	/// @desc Reset the settings file to a new, blank GameSettings() instance
	static reset = function() {
		AUDIOSETTINGS = new AudioSettings();
		GAMESETTINGS = new GameSettings();
		ilog($"GameSettings reset");
		save_settings();
	}
}

/// @function load_settings()
function load_settings() {
	dlog($"Loading settings...");
	GAMESETTINGS = file_read_struct(GAME_SETTINGS_FILENAME,FILE_CRYPT_KEY) ?? new GameSettings();
	if (USE_HIGHSCORES && HIGHSCORES != undefined && struct_exists(GAMESETTINGS, "highscoredata"))
		HIGHSCORES.assign_data(GAMESETTINGS.highscoredata);
	AUDIOSETTINGS = GAMESETTINGS.audio;
	LG_init(vsget(GAMESETTINGS, "locale"));
	
	// --- Custom / additional actions after loading settings ---
	
	// ----------------------------------------------------------
	
	dlog($"Settings loaded");
}

/// @function save_settings()
function save_settings() {
	dlog($"Saving settings...");
	
	// --- Custom / additional actions when saving settings ---
	
	// --------------------------------------------------------
	
	GAMESETTINGS.locale = LG_CURRENT_LOCALE;	
	if (HIGHSCORES != undefined)
		GAMESETTINGS.highscoredata = HIGHSCORES.data;
	file_write_struct(GAME_SETTINGS_FILENAME, GAMESETTINGS, FILE_CRYPT_KEY)
	dlog($"Settings saved");
}