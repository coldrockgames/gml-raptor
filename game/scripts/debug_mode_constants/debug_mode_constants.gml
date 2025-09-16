// Control the debug mode of the game
												
#macro DEBUG_MODE_ACTIVE						true
#macro CONFIGURATION_DEV						true
#macro CONFIGURATION_BETA						false
#macro CONFIGURATION_RELEASE					false
												
#macro beta:DEBUG_MODE_ACTIVE					false
#macro beta:CONFIGURATION_DEV					false
#macro beta:CONFIGURATION_BETA					true
#macro beta:CONFIGURATION_RELEASE				false
												
#macro release:DEBUG_MODE_ACTIVE				false
#macro release:CONFIGURATION_DEV				false
#macro release:CONFIGURATION_BETA				false
#macro release:CONFIGURATION_RELEASE			true

#macro CONFIGURATION_NAME						"dev"
#macro beta:CONFIGURATION_NAME					"beta"
#macro release:CONFIGURATION_NAME				"prod"

gml_release_mode(!DEBUG_MODE_ACTIVE);

#macro DEBUG_DEFAULT_FRAME_COLOR_WORLD			global.__debug_default_frame_color_world
#macro DEBUG_DEFAULT_FRAME_COLOR_UI				global.__debug_default_frame_color_ui
#macro DEBUG_DEFAULT_FRAME_COLOR_OVER			global.__debug_default_frame_color_over
#macro DEBUG_DEFAULT_FRAME_COLOR_CONTAINER		global.__debug_default_frame_color_container

#macro DEBUG_FRAME_COLOR						__raptor_debug_frame_color
#macro DEBUG_FRAME_COLOR_OVER					__raptor_debug_frame_color_over

#macro DEBUG_FRAME_COLOR_STR					"__raptor_debug_frame_color"
#macro DEBUG_FRAME_COLOR_OVER_STR				"__raptor_debug_frame_color_over"

#macro DEBUG_VIEW_SHOWN							global.__debug_shown
#macro DEBUG_SHOW_OBJECT_FRAMES					global.__debug_show_object_frames
#macro DEBUG_SHOW_OBJECT_DEPTH					global.__debug_show_object_depth
#macro DEBUG_MODE_WINDOW_WIDTH					global.__debug_mode_window_width
#macro DEBUG_MODE_WINDOW_HEIGHT					global.__debug_mode_window_height

DEBUG_SHOW_OBJECT_FRAMES			= false;
DEBUG_SHOW_OBJECT_DEPTH				= false;
DEBUG_MODE_WINDOW_WIDTH				= 1280;
DEBUG_MODE_WINDOW_HEIGHT			= 720;

DEBUG_DEFAULT_FRAME_COLOR_WORLD		= c_green;
DEBUG_DEFAULT_FRAME_COLOR_UI		= c_orange;
DEBUG_DEFAULT_FRAME_COLOR_OVER		= c_fuchsia;
DEBUG_DEFAULT_FRAME_COLOR_CONTAINER	= c_red;

DEBUG_VIEW_SHOWN					= false;
global.__debug_check_done			= false;

function check_debug_mode() {
	if (DEBUG_MODE_ACTIVE && !global.__debug_check_done) {
		global.__debug_check_done = true;
		if (code_is_compiled() && !CONFIGURATION_UNIT_TESTING)
			show_message(string_concat(
				"*************************************************\n",
				"***                                              \n",
				"***  D E B U G   M O D E   I S   A C T I V E     \n",
				"***                                              \n",
				"*************************************************\n"));
	}
}

/// @func	assert_debug_if_false(condition, error_message)
/// @desc	Launches a messagebox if condition is false
function assert_debug_if_false(condition, error_message) {
	if (DEBUG_MODE_ACTIVE && !condition) {
		msg_show_ok("Debug error message", error_message);
		return true;
	}
	return false;
}

/// @func	assert_debug_if_true(condition, error_message)
/// @desc	Launches a messagebox if condition is true
function assert_debug_if_true(condition, error_message) {
	if (DEBUG_MODE_ACTIVE && condition) {
		msg_show_ok("Debug error message", error_message);
		return true;
	}
	return false;
}

