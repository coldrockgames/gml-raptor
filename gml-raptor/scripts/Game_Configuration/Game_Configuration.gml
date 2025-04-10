/*
	These callbacks get invoked from the GameStarter object in the
	GameStart and GameEnd events respectively.
	
	They have been created to encapsulate one-time-startup/-shutdown actions in
	an isolated script file, so you do not need to modify the GameStarter object directly
	in each game.
	
	onGameStart runs AFTER the ci_colors have been initialized.
	It is recommended, to set at least the app_theme in the onGameStart function, so 
	scribble gets initialized with the correct set of ci_colors.
		
	------------------------------------------------------
	NOTE: HTML5 games never receive an onGameEnd callback!
	------------------------------------------------------

	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/

// You need to set a global prefix for each of the raptor-files generated, because
// in HTML, especially for itch.io games, you need a UNIQUE filename over all your products,
// as the html-file-engine uses local storage, which only has one folder with all files from
// all your products in it.
#macro GAME_FILE_PREFIX					"gml_raptor"
#macro DATA_FILE_EXTENSION				".json"
#macro release:DATA_FILE_EXTENSION		".jx"

// Replace the production crypt key with a good salty key of your own!
#macro FILE_CRYPT_KEY					""
#macro release:FILE_CRYPT_KEY			"replace-this-string-for-your-own-safety"

// The name of your settings file. ATTENTION FOR ITCH.IO: This name must be UNIQUE across
// all your games! Do NOT reuse the same name over and over again!
#macro GAME_SETTINGS_FILENAME			$"{GAME_FILE_PREFIX}_game_settings{DATA_FILE_EXTENSION}"

// Global functionality setup for the game

// Set fullscreen mode
// This is set by the GameStarter object upon game start,
// when the game STARTS FOR THE FIRST TIME.
// After that, this setting is taken from the GameSettings.
// This is to allow you easily changing the startup values through your
// Settings dialog in the window, so the user can choose, what he prefers.
#macro		   START_FULLSCREEN		false
#macro release:START_FULLSCREEN		true
#macro FULLSCREEN_IS_BORDERLESS		true

// If you set this to true, ROOMCONTROLLER will store the game window size
// 10 times a second in the WINDOW_SIZE_* variables, so you can track changes
// to the window size. 
// This normally only makes sense in tool apps, that run in windowed mode
#macro WATCH_FOR_WINDOW_SIZE_CHANGE	true

// Startup Room - The value of this constant is taken by the GameStarter object
// Set the constant to undefined to use the instance variable of GameStarter in rmStartup
// The min_wait_time constant is measured in frames. Default is 90 (1.5secs) to show loading spinner
// The fade_in time for the first room is also measured in frames
#macro		   ROOM_AFTER_STARTER	rmMain
#macro release:ROOM_AFTER_STARTER	rmMain

#macro		   STARTER_ASYNC_MIN_WAIT_TIME	1
#macro release:STARTER_ASYNC_MIN_WAIT_TIME	90

#macro		   STARTER_FIRST_ROOM_FADE_IN	1
#macro release:STARTER_FIRST_ROOM_FADE_IN	45

/// @func	onGameStart()
/// @desc	When this runs, load_settings() has already been called and 
///			you can access your settings through the GAMESETTINGS macro.
function onGameStart() {

	// Debug/Dev configuration
	DEBUG_SHOW_OBJECT_FRAMES	= false;
	DEBUG_SHOW_OBJECT_DEPTH		= false;
	DEBUG_MODE_WINDOW_WIDTH		= 1280;
	DEBUG_MODE_WINDOW_HEIGHT	= 720;

	// Skin & Theme
	//UI_THEMES.add_theme(new your_game_theme_name(), true);
	//UI_SKINS.add_skin(new your_game_skin_name(), true);

	// Setup Scribble
	// ------------------------------------------------------------------
	//scribble_font_bake_outline_and_shadow("acme28","acme28_out",0,0,SCRIBBLE_OUTLINE.EIGHT_DIR,2,true);
	//scribble_font_set_default("acme28");

	// Custom named scribble colors - use the format that fits best for you!
	// In version 3.0 and later, the recommended way is to set up your THEME here
	// https://github.com/Grisgram/gml-raptor/wiki/App-Theming
	//SCRIBBLE_COLORS.my_col1 = make_color_rgb(0xE5,0xE5,0xE5); // 0x... hex, can also use 165,165,165 - doesn't matter
	//SCRIBBLE_COLORS.my_col2 = #E5E5E5; // #RRGGBB
	//SCRIBBLE_COLORS.my_col3 = $FFE5E5E5; // $AABBGGRR
	
	SCRIBBLE_REFRESH;

	// Audio setup for rooms
	//set_room_default_audio(rmMain, mus_theme, amb_theme);
	//set_room_default_audio(rmPlay, mus_theme, amb_theme);

}

/// @func   onLoadingScreen(task, frame)
/// @desc   Use this function while the loading screen is visible 
///		    to perform "async-like" tasks. Store your state in the task
///		    struct, it will be sent to you every frame, as long as you 
///		    return true from this function.
///			If you return false (or nothing), and there are no more async
///			file operations running, the GameStarter considers your
///		    startup-loading actions as finished.
///		    The frame parameter increases by 1 each time this is invoked and starts with 0.
///			------------------------
///			What you SHOULD do here:
///			- LOAD ALL YOUR RACE INSTANCES, THEY ARE ASYNC AND THIS FUNCTION TAKES CARE OF IT
///			- LOAD ALL YOU ADDITIONAL LOCALE FILES, THEY ARE ALSO ASYNC
function onLoadingScreen(task, frame) {

	// Load async start data IN THE FIRST FRAME
	// Example lines to show that you can load your startup files here
	// Loading screen only disappears when NO MORE ASYNC operations run
	// AND this function did not return true.
	// ------------------------------------------------------------------
	if (frame == 0) {
		//SOME_GLOBAL_THING = file_read_struct_plain_async(GLOBAL_THING_FILE_NAME, FILE_CRYPT_KEY);
		//global.loot_system = new Race(RACE_FILE_NAME);
		//LG_add_file_async("dialogs");
	}
	
	// If you do other async things here, don't forget to RETURN TRUE until they are
	// are finished (return code means something like "still busy?", so return true while working)
	//return true;
}

/// @func	onLoadingScreenFinished()
/// @desc	Invoked, when all async tasks are done and before game proceeds to first room
function onLoadingScreenFinished() {
	// Use this callback to finish all your initialization steps
	// that were depending/waiting for the async loading screen to finish
	// When you reach this function, everything from onLoadingScreen is loaded and ready
}

/// @func	onGameEnd()
/// @desc   Invoked when the game ends. NEVER OCCURS IN HTML GAMES.
function onGameEnd() {
	
}

