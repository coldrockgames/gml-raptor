/// @desc state ev:middle_pressed

if (!__is_parent)
	with (collage_parent) event_perform(ev_mouse, ev_middle_press);
else 
	event_inherited();
