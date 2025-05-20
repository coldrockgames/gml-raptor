/// @desc suppress parent event if dragging

GUI_EVENT_MOUSE;

if (!__in_drag_mode && !__in_size_mode) {
	event_inherited();
}

