/*
	Utility macros that make life a bit easier.
	
	(c)coldrock.games
*/

/// this macro ends the game if the platform supports it
#macro EXIT_GAME			try { GAMECONTROLLER.exit_game(); } catch(_){ try{game_end(0);}catch(_){} }

#macro IS_HTML				(browser_not_a_browser != os_browser)
#macro IS_MOBILE			is_any_of(os_type, os_android, os_ios)
#macro IS_DESKTOP_OS		(is_any_of(os_type, os_windows, os_linux, os_macosx) && !IS_HTML)
#macro IS_CONSOLE			is_any_of(os_type, os_ps4, os_ps5, os_switch, os_gdk, os_xboxone, os_xboxseriesxs)

// detect if the scribble library is loaded
#macro IS_SCRIBBLE_LOADED	script_exists(asset_get_index("scribble"))
#macro SCRIBBLE_COLORS		__scribble_config_colours()
#macro SCRIBBLE_REFRESH		scribble_refresh_everything()

// detect if the canvas library is loaded
#macro IS_CANVAS_LOADED		script_exists(asset_get_index("Canvas"))
#macro CANVAS_SCREENSHOT	(IS_CANVAS_LOADED ? CanvasGetAppSurf(true) : undefined)

// detect if the SNAP library is loaded
#macro IS_SNAP_LOADED		script_exists(asset_get_index("SnapToJSON"))

/// stringify data of "self"
#macro MY_ID				string(real(id))
#macro MY_NAME				string_concat(object_get_name(object_index), "-", real(id))
#macro MY_CLASS_NAME		name_of(self, false)
#macro MY_OBJECT_NAME		object_get_name(object_index)
#macro MY_LAYER_OR_DEPTH	((layer == -1) ? depth : layer_get_name(layer))

/// stringify data of "other"
#macro OTHER_ID				string(real(other.id))
#macro OTHER_NAME			string_concat(object_get_name(other.object_index), real(other.id))
#macro OTHER_LAYER_OR_DEPTH	((other.layer == -1) ? other.depth : layer_get_name(other.layer))

#macro ROOM_NAME				room_get_name(room)
#macro SECONDS_TO_FRAMES		* room_speed
#macro FRAMES_TO_SECONDS		/ room_speed

#macro TODAY_ISO_STR	$"{current_year}-{(string_replace_all(string_format(current_month, 2, 0), " ", "0"))}-{(string_replace_all(string_format(current_day, 2, 0), " ", "0"))}"

// An empty function can be used in various places, like as a disabling override on enter/leave states in the statemachine
#macro EMPTY_FUNC		function(){}

#macro ARGS_TO_ARRAY	var args = array_create(argument_count); for (var __i = 0; __i < argument_count; __i++) args[__i] = argument[__i];

// A simple counting-up unique id system
global.__unique_count_up_id	= 0;
#macro UID		(++global.__unique_count_up_id)
#macro SUID		string(++global.__unique_count_up_id)

// undocumented feature: a sprite-less object counts the frames - gamecontroller likely never has a sprite!
#macro GAME_FRAME	GAMECONTROLLER.image_index

// Those macros define all situations that can lead to an invisible element on screen
#macro __LAYER_OR_OBJECT_HIDDEN		(!visible || (layer != -1 && !layer_get_visible(layer)) || vsget(self, "is_window_hidden", EMPTY_FUNC)())
#macro __HIDDEN_BEHIND_POPUP		(GUI_POPUP_VISIBLE && depth > GUI_POPUP_MIN_DEPTH)
#macro __INSTANCE_UNREACHABLE		(__LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP)

// All controls skip their events, if this is true
#macro SKIP_EVENT_MOUSE				(is_mouse_over_debug_overlay() || __INSTANCE_UNREACHABLE)
#macro SKIP_EVENT_NO_MOUSE			(__INSTANCE_UNREACHABLE)
#macro SKIP_EVENT_UNTARGETTED		(__INSTANCE_UNREACHABLE || !SELF_IS_ENABLED)

// Instead of repeating the same if again and again in each mouse event, just use this macro;
#macro GUI_EVENT_MOUSE				if (SKIP_EVENT_MOUSE) exit;
#macro GUI_EVENT_NO_MOUSE			if (SKIP_EVENT_NO_MOUSE) exit;
#macro GUI_EVENT_UNTARGETTED		if (SKIP_EVENT_UNTARGETTED) exit;

// Check conditions for self draw on all raptor objects, especially controls
#macro GUI_EVENT_DRAW				if ( SELF_DRAW_ON_GUI) exit;
#macro GUI_EVENT_DRAW_GUI			if (!SELF_DRAW_ON_GUI) exit;

#macro DEPTH_BOTTOM_MOST			 15998
#macro DEPTH_TOP_MOST				-15998

// Used by the MouseCursor object but must exist always, as the RoomController checks it
#macro MOUSE_CURSOR					global.__mouse_cursor
MOUSE_CURSOR = undefined;

#macro CENTER_MOUSE					window_mouse_set(window_get_width() / 2, window_get_height() / 2)

// try/catch/finally support
#macro TRY		try {
#macro CATCH	} catch (__exception) {					\
					if (is_string(__exception))			\
						elog(__exception);				\
					else {								\
						elog(__exception.message);		\
						elog(__exception.longMessage);	\
						elog(__exception.script);		\
						for (var __st_i = 0; __st_i < array_length(__exception.stacktrace);__st_i++) \
							elog(__exception.stacktrace[@ __st_i]); \
					}
#macro FINALLY	} finally {
#macro ENDTRY   }

// STATUS/PROGRESS GLOBALS
#macro SAVEGAME_SAVE_IN_PROGRESS		global.__savegame_save_in_progress
#macro SAVEGAME_LOAD_IN_PROGRESS		global.__savegame_load_in_progress
#macro ENSURE_SAVEGAME					if (!variable_global_exists("__savegame_save_in_progress"))	global.__savegame_save_in_progress = false; \
										if (!variable_global_exists("__savegame_load_in_progress"))	global.__savegame_load_in_progress = false;
ENSURE_SAVEGAME;
