/// @desc state ev:left_released
event_inherited();
if (protect_ui_events) GUI_EVENT_MOUSE;

if (__shall_forward_mouse_event("ev:left_released"))
	states.set_state("ev:left_released");
