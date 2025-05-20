/// @desc suppress parent event if dragging

if (!__in_drag_mode && !__in_size_mode) {
	__size_direction = 0;
	__set_sizing_cursor(0);
	event_inherited();
}

