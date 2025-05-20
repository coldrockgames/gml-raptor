/// @desc build object hierarchy
event_inherited();

__first_draw			 = true;
__auto_size_with_content = false;
__mouse_events_locked	 = !container_is_touchable;

if (!is_instanceof(control_tree, ControlTree)) {
	control_tree = construct_or_invoke(control_tree, self);
}
control_tree_layout = new ControlTreeLayout();
control_tree.bind_to(self);

/// @func maximize_on_screen()
maximize_on_screen = function() {
	ilog($"{MY_NAME} maximizing to {(draw_on_gui ? "gui" : "view")} size");
	x = 0;
	y = 0;
	if (draw_on_gui) 
		set_client_area(UI_VIEW_WIDTH, UI_VIEW_HEIGHT);
	else
		set_client_area(VIEW_WIDTH, VIEW_HEIGHT);
	control_tree.layout();
}
if (maximize_on_create) maximize_on_screen();

/// @func get_element(_name)
/// @desc Retrieve a child control by its name. Returns the instance or undefined
get_element = function(_name) {
	return control_tree.get_element(_name);
}

__remove_self = function() {
	if (control_tree.parent_tree != undefined)
		control_tree.parent_tree.remove_control(self);
}

__draw_instance = function(_force = false) {
	update_client_area();

	if (__first_draw || _force) {
		control_tree.layout();
	}

	if (!visible) return;

	__basecontrol_draw_instance(_force);
	control_tree.draw_children();
	
	__first_draw = false;
		
	// this code draws the client area in red, if one day there's a bug with alignment
	//draw_set_color(c_red);
	//draw_rectangle(x+data.__raptordata.client_area.left, y+data.__raptordata.client_area.top, x+data.__raptordata.client_area.get_right(), y+data.__raptordata.client_area.get_bottom(), true);
	//draw_set_color(c_white);
}