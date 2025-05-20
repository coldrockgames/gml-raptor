/// @desc state ev:middle_released
event_inherited();
if (protect_ui_events) GUI_EVENT_MOUSE;

if (__shall_forward_mouse_event("ev:middle_released"))
	states.set_state("ev:middle_released");
