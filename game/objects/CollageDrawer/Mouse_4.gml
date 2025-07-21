/// @desc state ev:left_pressed

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_left_press);
else 
	event_inherited();
