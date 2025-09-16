/// @desc state ev:wheel_up
event_inherited();
if (protect_ui_events) GUI_EVENT_MOUSE;

// global events will only stop delivering if this object is disabled or not touchable
// but they are immune to any mouse-coordinates or uniqueness of mouse_events
if (!SELF_IS_INTERACTIVE) exit;
states.set_state("ev:wheel_up");
