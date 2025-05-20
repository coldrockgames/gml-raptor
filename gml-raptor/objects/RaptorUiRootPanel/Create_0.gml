/// @desc event
event_inherited();
depth = DEPTH_BOTTOM_MOST;

__draw_self = function() {
	__draw_instance(__force_redraw);
}

__draw_instance = function(_force = false) {
	update_client_area();

	if (__first_draw || _force)
		control_tree.layout();

	if (!visible) return;

	control_tree.draw_children();
	__first_draw = false;
	__force_redraw = false;
}
