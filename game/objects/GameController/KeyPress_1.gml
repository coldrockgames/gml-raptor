/// @description debug view toggle?
event_inherited();

if (DEBUG_MODE_ACTIVE) {
	if (DEBUG_VIEW_TOGGLE_KEY == keyboard_to_string()) {
		if (keyboard_check(vk_control)) {
			GAMESETTINGS.reset();
			msg_show_ok("Settings reset", "Settings have been reset!");
		} else {
			toggle_debug_view();
		}
	}
}
