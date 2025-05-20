/// @desc invoke on_middle_click

if (SKIP_EVENT_MOUSE || click_event_finished || !await_click) exit;

perform_middle_click();
