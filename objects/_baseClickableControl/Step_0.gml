/// @desc align to view

event_inherited();
if (__INSTANCE_UNREACHABLE) exit;

click_event_finished = false;
if (draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();
