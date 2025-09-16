/*
    The settings structure of your game.
	Adapt as needed. A "new GameSettings()" gets called on load attempt of the settings file,
	if none exists.
*/

#macro GAMESETTINGS		global.__game_settings
// load_settings gets called on game start before onGameStarting callback is invoked
// So, when your code in inGameStarting runs, this is already available
GAMESETTINGS = undefined;  

// Add everything you want to be part of the settings file in this struct.
// DO NOT ADD FUNCTIONS HERE! Only data!
function GameSettings() constructor {
	construct(GameSettings);

	first_start				= true;
	remember_position		= REMEMBER_WINDOW_POSITION;
	start_fullscreen		= START_FULLSCREEN;
	borderless_fullscreen	= FULLSCREEN_IS_BORDERLESS;
	audio					= AUDIOSETTINGS;
	use_system_cursor		= false;
	locale					= LG_CURRENT_LOCALE;
	
	if (remember_position) {
		window_width			= window_get_width();
		window_height			= window_get_height();
	}
	
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
	
	on_game_settings_created(self);
}

/// @function load_settings()
function load_settings() {
	dlog($"Loading settings...");
	GAMESETTINGS = file_read_struct(GAME_SETTINGS_FILENAME,FILE_CRYPT_KEY) ?? new GameSettings();
	if (USE_HIGHSCORES && HIGHSCORES != undefined && struct_exists(GAMESETTINGS, "highscoredata"))
		HIGHSCORES.assign_data(GAMESETTINGS.highscoredata);
	AUDIOSETTINGS = GAMESETTINGS.audio;
	LG_init(vsget(GAMESETTINGS, "locale"));
	
	with(GAMESETTINGS) {
		if ( vsgetx(self, "remember_position", REMEMBER_WINDOW_POSITION) &&
			!vsgetx(self, "start_fullscreen", START_FULLSCREEN)) {
			window_set_position(
				vsgetx(self, "window_left",  window_get_x()),
				vsgetx(self, "window_top",   window_get_y())
			);
			window_set_size(
				vsgetx(self, "window_width",  window_get_width()),
				vsgetx(self, "window_height", window_get_height())
			);
		}
		
		// debug colors
		if (CONFIGURATION_DEV) {
			var dbg_views = vsget(self, "debug_views");
			if (dbg_views != undefined) {
				DEBUG_DEFAULT_FRAME_COLOR_WORLD		= dbg_views.frame_world;
				DEBUG_DEFAULT_FRAME_COLOR_UI		= dbg_views.frame_ui;
				DEBUG_DEFAULT_FRAME_COLOR_OVER		= dbg_views.frame_over;
				DEBUG_DEFAULT_FRAME_COLOR_CONTAINER = dbg_views.frame_container;
				DEBUG_SHOW_OBJECT_FRAMES			= dbg_views.show_frames;	
				DEBUG_SHOW_OBJECT_DEPTH				= dbg_views.show_depth;
			}
		}
		
	}

	on_game_settings_loaded(GAMESETTINGS);

	dlog($"Settings loaded");
}

/// @function save_settings()
function save_settings() {
	dlog($"Saving settings...");
	
	on_game_settings_saving(GAMESETTINGS);

	with(GAMESETTINGS) {
	
		locale = LG_CURRENT_LOCALE;
		
		if (vsgetx(self, "remember_position", REMEMBER_WINDOW_POSITION)) {
			window_width		= window_get_width();
			window_height		= window_get_height();
			window_left			= window_get_x();	
			window_top			= window_get_y();	
			start_fullscreen	= window_get_fullscreen();
		}
		
		if (CONFIGURATION_DEV) {
			debug_views = {
				frame_world:		DEBUG_DEFAULT_FRAME_COLOR_WORLD,
				frame_ui:			DEBUG_DEFAULT_FRAME_COLOR_UI,
				frame_over:			DEBUG_DEFAULT_FRAME_COLOR_OVER,
				frame_container:	DEBUG_DEFAULT_FRAME_COLOR_CONTAINER,
				show_frames:		DEBUG_SHOW_OBJECT_FRAMES,
				show_depth:			DEBUG_SHOW_OBJECT_DEPTH,
			}
		}
		
		if (HIGHSCORES != undefined)
			highscoredata = HIGHSCORES.data;
	}
	
	file_write_struct(GAME_SETTINGS_FILENAME, GAMESETTINGS, FILE_CRYPT_KEY)
	dlog($"Settings saved");
}