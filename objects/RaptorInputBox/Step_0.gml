/// @desc cursor blink

event_inherited();

if (__TEXT_NAV_TAB_LOCK == id)
	__TEXT_NAV_TAB_LOCK = 0;

if (!__RAPTORDATA.has_focus || __LAYER_OR_OBJECT_HIDDEN || __HIDDEN_BEHIND_POPUP) exit;

if (CTL_MOUSE_HAS_MOVED && mouse_check_button(mb_left))
	__set_cursor_pos_from_click(true);

if (GUI_RUNTIME_CONFIG.text_cursor_blink_speed > 0 && ++__cursor_frame >= GUI_RUNTIME_CONFIG.text_cursor_blink_speed) {
	__cursor_frame = 0;
	__last_cursor_visible = __cursor_visible;
	__cursor_visible = !__cursor_visible;
}

if (__RAPTORDATA.has_focus) {
	if (__wait_for_key_repeat) {
		if (keyboard_key == __repeating_key)
			__key_repeat_frame++;
		
		if (__repeat_interval_mode) {
			if (__key_repeat_frame >= GUI_RUNTIME_CONFIG.text_key_repeat_interval) {
				__key_repeat_frame = 0;
				__do_key_action();
			}
		} else {
			if (__key_repeat_frame >= GUI_RUNTIME_CONFIG.text_key_repeat_delay) {
				__repeat_interval_mode = true;
				__key_repeat_frame = 0;
				__do_key_action();
			}
		}
	}
}