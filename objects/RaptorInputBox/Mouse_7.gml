/// @desc check for double-click

if (SKIP_EVENT_MOUSE || click_event_finished || !await_click) exit;

if (double_click_counter == 2)
	select_word();

// Inherit the parent event
event_inherited();
