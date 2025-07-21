/// @desc state ev:right_pressed

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_right_press);
else 
	event_inherited();
