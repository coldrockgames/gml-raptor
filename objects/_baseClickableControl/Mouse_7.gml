/// @desc invoke on_left_click

if (SKIP_EVENT_MOUSE || click_event_finished || !await_click) exit;

perform_left_click();

if (double_click_counter >= 2) 
	perform_double_click();
