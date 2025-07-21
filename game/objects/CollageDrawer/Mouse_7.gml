/// @desc state ev:left_released

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_left_release);
else 
	event_inherited();
