/// @desc state ev:mouse_leave

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_mouse_leave);
else 
	event_inherited();
