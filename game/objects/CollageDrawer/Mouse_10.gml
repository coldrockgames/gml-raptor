/// @desc state ev:mouse_enter

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_mouse_enter);
else 
	event_inherited();
