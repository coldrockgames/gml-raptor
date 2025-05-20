/// @desc hotkey watcher
if (hotkey_only_when_topmost) GUI_EVENT_NO_MOUSE;

event_inherited();

var ks = keyboard_to_string();

if (is_null(ks) || (hotkey_only_when_topmost && !is_topmost(x,y))) exit;

check_for_hotkey(ks);
