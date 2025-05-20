/// @desc event
event_inherited();

if (mouse_wheel_active && (__SLIDER_IN_FOCUS == self || mouse_is_over))
	__change_value_with_arrow(-wheel_scroll_lines, true);
