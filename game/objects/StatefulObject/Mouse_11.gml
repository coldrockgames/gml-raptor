/// @desc state ev:mouse_leave
event_inherited();

mouse_is_over = false;

if (__shall_forward_mouse_event("ev:mouse_leave")) {
	
	// Send the mouse_enter to the next topmost stateful now
	// If multiple objects overlap, they would not get a new "mouse_enter" event otherwise
	// IN ADDITION, there are childs, supporting "draw_on_gui" which might block the mouse_enter
	// event if their gui_events are protected. 
	// We want to force it, so temporary, we disable the protection
	// MEASURE THIS BEFORE SENDING THE MOUSE_LEAVE AS THIS COULD REORDER DEPTH!!
	var nextone = get_topmost_instance_at(CTL_MOUSE_X, CTL_MOUSE_Y, StatefulObject);
	if (!is_null(nextone)) {
		states.set_state("ev:mouse_leave");
		with(nextone) {
			var p = protect_ui_events;
			protect_ui_events = false;
			event_perform(ev_mouse, ev_mouse_enter);
			protect_ui_events = p;
		}
	} else
		states.set_state("ev:mouse_leave");
}
