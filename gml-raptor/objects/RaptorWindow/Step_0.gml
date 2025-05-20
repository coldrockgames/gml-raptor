/// @desc perform drag/size change

event_inherited();

if (draw_on_gui)
	gui_mouse.check_gui_mouse_clicks();

if (!CTL_MOUSE_HAS_MOVED) exit;

if (__in_drag_mode) {
	__dx = CTL_MOUSE_DELTA_X;
	__dy = CTL_MOUSE_DELTA_Y;
	x += __dx;
	y += __dy;
	control_tree.move_children(__dx, __dy);
} else if (__in_size_mode) {
	control_tree.move_children_after_sizing(__do_sizing());
} else if (mouse_is_over && window_is_sizable) {
	__find_sizing_area();
}
