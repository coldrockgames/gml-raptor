/*
	GUI and Control configuration settings.
	Adapt them to your needs for the current game in the onGameStart callback
	of the Game_Configuration script (in the _GAME_SETUP_ folder)
	
	(c)2022- coldrock.games aka @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT	
*/

// This enum is used in all ui controls for the
// "adopt_object_properties" instance variable
enum adopt_properties {
	none	= 0,
	alpha	= 1,
	full	= 2,
}

#macro GUI_RUNTIME_CONFIG		global.gui_configuration

#macro __TEXT_NAV_TAB_LOCK		global.__gui_nav_tab_lock
__TEXT_NAV_TAB_LOCK = 0;

#macro AUDIO_CHANNELS_HTML		16
#macro AUDIO_CHANNELS_WINMAC	200
#macro AUDIO_CHANNELS_OTHER		64

function gui_runtime_config() constructor {
	construct(gui_runtime_config);

	tooltip_last_shown			= -1;
	tooltip_delay_frames		= TOOLTIP_DELAY_FRAMES;

	text_cursor_blink_speed		= TEXT_CURSOR_BLINK_SPEED;
	text_key_repeat_delay		= TEXT_KEY_REPEAT_DELAY;
	text_key_repeat_interval	= TEXT_KEY_REPEAT_INTERVAL;

	mouse_double_click_speed	= MOUSE_DBL_CLICK_SPEED_MS;

	// Those members exist in html only and are set by the BrowserGameController
	canvas_left		= 0;
	canvas_top		= 0;
	
	if (IS_HTML) {
		canvas_width  = browser_width;
		canvas_height = browser_height;
	} else {
		canvas_width  = APP_SURF_WIDTH;
		canvas_height = APP_SURF_HEIGHT;
	}
	// set up sound channels based on platform
	audio_channel_num(IS_HTML ? AUDIO_CHANNELS_HTML : 
		(is_any_of(os_type, os_windows, os_macosx) ? AUDIO_CHANNELS_WINMAC : AUDIO_CHANNELS_OTHER));

	/// @func					gui_scale_set(xscale = 1, yscale = 1)
	/// @desc				set ui scale to those multipliers
	/// @param {real=1} xscale
	/// @param {real=1} yscale
	static gui_scale_set = function(xscale = 1, yscale = 1) {
		display_set_gui_maximize(xscale, yscale);
	}
	
	/// @func					gui_scale_disable_maximize
	/// @desc				disables blackborder drawing of the ui
	static gui_scale_disable_maximize = function() {
		display_set_gui_maximize(-1, -1);
	}
	
}

GUI_RUNTIME_CONFIG = new gui_runtime_config();
