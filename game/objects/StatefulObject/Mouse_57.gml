/// @desc state ev:global_right_released
event_inherited();

// global events will only stop delivering if this object is disabled
// but they are immune to any mouse-coordinates or uniqueness of mouse_events
if (!is_enabled) exit;
states.set_state("ev:global_right_released");