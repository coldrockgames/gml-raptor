/// @desc state ev:middle_released

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_middle_release);
else 
	event_inherited();
