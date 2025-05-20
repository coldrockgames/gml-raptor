/// @desc state ev:key_up_?

/*
	The key that got released actually is converted through the KeyTranslator script and this
	creates a readable string for almost all keys that is as-equal-as-possible to the vk_constants.
	
	This event sets the state "ev:key_press_<key>"
	Examples:
	ev:key_up_F1
	ev:key_up_vk_home
	ev:key_up_vk_left
	ev:key_up_numpad0
	...etc...
*/
event_inherited();

if (protect_ui_events) GUI_EVENT_UNTARGETTED;

states.set_state(string_concat("ev:key_up_", keyboard_to_string(keyboard_lastkey)));

