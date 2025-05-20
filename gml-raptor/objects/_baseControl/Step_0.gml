/// @desc gui_mouse handling

if (is_enabled && draw_on_gui && GUI_MOUSE_HAS_MOVED && !__INSTANCE_UNREACHABLE)
	gui_mouse.update_gui_mouse_over();
