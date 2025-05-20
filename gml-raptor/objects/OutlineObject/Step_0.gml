/// @desc gui_mouse handling
event_inherited();

if (is_enabled && draw_on_gui && !__INSTANCE_UNREACHABLE) {
	if (GUI_MOUSE_HAS_MOVED)
		gui_mouse.update_gui_mouse_over();
	gui_mouse.check_gui_mouse_clicks();
}
