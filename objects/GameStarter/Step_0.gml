/// @description run async_looper
event_inherited();

// as long as the game returns true, we stay on this screen
wait_for_loading_screen = (
	(first_step && __invoke_starting_callback()) ||
	ASYNC_OPERATION_RUNNING || 
	(!trampoline_done && async_looper(async_looper_data, loading_screen_frame) == true)
);

loading_screen_frame++;
