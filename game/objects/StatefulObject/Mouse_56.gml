/// @desc state ev:global_left_released
event_inherited();

// global events will only stop delivering if this object is disabled or not touchable
// but they are immune to any mouse-coordinates or uniqueness of mouse_events
if (!SELF_IS_INTERACTIVE) exit;
states.set_state("ev:global_left_released");