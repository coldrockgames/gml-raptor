/// @desc invoke on_right_click

if (SKIP_EVENT_MOUSE || click_event_finished || !await_click) exit;

perform_right_click();
