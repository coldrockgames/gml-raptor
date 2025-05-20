/*
    Configure system-wide UI behavior in this file.
*/

// Tooltip timing
#macro TOOLTIP_DELAY_FRAMES				30
				
// Text input configuration (all values are frames)
#macro TEXT_CURSOR_BLINK_SPEED			30
#macro TEXT_CURSOR_WIDTH				4
#macro TEXT_KEY_REPEAT_DELAY			30
#macro TEXT_KEY_REPEAT_INTERVAL			(room_speed / 30)

// Mouse double click configuration (MS = milliseconds)
#macro MOUSE_DBL_CLICK_SPEED_MS			500

// SHIFT, ALT and CONTROL KEYS
// These macros define, how the keytranslator for key press events
// handles the left and right modifier keys.
// If set to false, no difference is made between "left" and "right" key
// (like the left control key and the right control key on the keyboard)
// and you will receive a "vk_control" key press from the translator.
// If set to true, each key has its own event
#macro SEPARATE_LALT_RALT_KEYS			false
#macro SEPARATE_LSHIFT_RSHIFT_KEYS		false
#macro SEPARATE_LCONTROL_RCONTROL_KEYS	false
