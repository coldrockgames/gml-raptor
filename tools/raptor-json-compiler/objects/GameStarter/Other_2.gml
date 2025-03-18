/// @desc start the game engine(s)

#macro GAME_CHANNEL_STRING	global.__game_channel_string
GAME_CHANNEL_STRING = LG($"=legal/game_channel_{CONFIGURATION_NAME}");

#macro GAME_VERSION_STRING	global.__game_version_string
#macro GAME_VERSION_MAJOR	global.__game_version_major
#macro GAME_VERSION_MINOR	global.__game_version_minor
#macro GAME_VERSION_BUILD	global.__game_version_build


if (!debug_mode)
	randomize();

// Now we have a game controller and can create the real logger
RAPTOR_LOGGER.set_formatter(new LOG_FORMATTER());

// Look for version file
mlog(__LOG_GAME_INIT_START);
if (file_exists_html_safe(working_directory + "version.json")) {
	// can't load this async (yet) as we have no gamecontroller yet
	var verinfo = file_read_struct_plain("version.json");
	GAME_VERSION_STRING = verinfo.version;
	GAME_VERSION_MAJOR	= verinfo.major;
	GAME_VERSION_MINOR	= verinfo.minor;
	GAME_VERSION_BUILD	= verinfo.build;
	mlog($"Game version: {GAME_VERSION_STRING} ({GAME_CHANNEL_STRING})");
} else {
	mlog($"*WARNING*: No version file found!");
	GAME_VERSION_STRING = "0.0.0";
	GAME_VERSION_MAJOR	= 0;
	GAME_VERSION_MINOR	= 0;
	GAME_VERSION_BUILD	= 0;
}

ilog($"Game seed is {random_get_seed()}");
ilog($"Startup arguments are {ARGS.args}");
ilog($"Detecting scribble library: {(IS_SCRIBBLE_LOADED ? "" : "NOT ")}found!");
ilog($"Detecting Canvas library: {(IS_CANVAS_LOADED ? "" : "NOT ")}found!");
ilog($"Detecting SNAP library: {(IS_SNAP_LOADED ? "" : "NOT ")}found!");

ilog($"Checking for Debug mode: {(DEBUG_MODE_ACTIVE ? "ACTIVE" : "DISABLED")}");
check_debug_mode();

if (USE_CRASHDUMP_HANDLER) {
	ilog($"Activating crash dump handler");
	exception_unhandled_handler(Game_Exception_Handler);
} else {
	wlog($"Crash dump handler is disabled");
	exception_unhandled_handler(undefined);
}

load_settings();
if (!IS_HTML && os_type == os_windows) {
	window_enable_borderless_fullscreen(vsgetx(GAMESETTINGS, "borderless_fullscreen", FULLSCREEN_IS_BORDERLESS));
	window_set_fullscreen(vsgetx(GAMESETTINGS, "start_fullscreen", START_FULLSCREEN));
}

mlog(__LOG_GAME_INIT_FINISH);
ilog($"Invoking onGameStart()");
onGameStart();

if (DEBUG_MODE_ACTIVE)
	window_set_size(DEBUG_MODE_WINDOW_WIDTH, DEBUG_MODE_WINDOW_HEIGHT);

