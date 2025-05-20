/// @desc check coordinates (GUI_EVENT_MOUSE)
event_inherited();

GUI_EVENT_UNTARGETTED;

if (draw_on_gui && CTL_MOUSE_HAS_MOVED)
	gui_mouse.check_gui_mouse_clicks();

check_mouse_over_knob();

if (__SLIDER_IN_FOCUS == self) 
	check_knob_grabbed();
