/// @desc state ev:right_released

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_right_release);
else 
	event_inherited();
