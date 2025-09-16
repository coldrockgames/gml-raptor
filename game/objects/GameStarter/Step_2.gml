// spinner rotation and position
if (trampoline_done) exit;

spinner_frame_counter = (spinner_frame_counter + 1) % 48;
spinner_rotation = -45 * floor(spinner_frame_counter / 6);
spinner_x = VIEW_WIDTH - spinner_w - 16;
spinner_y = VIEW_HEIGHT - spinner_h - 16;

if (game_init_step && first_step) {
	async_wait_timeout = max(async_wait_timeout, async_min_wait_time);
	game_init_step = false;
	if (vsgetx(GAMESETTINGS, "first_start", true)) {
		window_center();
		GAMESETTINGS.first_start = false;
	}
}
first_step = false;

if (wait_for_loading_screen) exit;
if (wait_for_async_tasks && async_wait_timeout > 0) {
	async_wait_counter++;
	if (async_wait_counter >= async_wait_timeout)
		wait_for_async_tasks = false;
	else
		exit;
}

if (!wait_for_async_tasks && !trampoline_done) {
	
	if (async_min_wait_time > 0 && async_wait_counter < async_min_wait_time) {
		draw_spinner = true;
		async_wait_counter++;
		exit;
	}
	
	ilog($"Loading screen async tasks finished after {loading_screen_frame} frames");
	
	visible = false; // turn off the draw event to save this now unneccesary funct
	draw_spinner = false;
	trampoline_done = true;
	
	if (PARTICLES_SCAN_ON_STARTUP)
		ilog($"ParticleLoader loaded {array_length(struct_get_names(PARTICLES))} particle(s)");

	if (goto_room_after_init != undefined) {
		vlog($"GameStarter trampoline to next room");
		pool_clear_all();
		
		call_later(2, time_source_units_frames, function() {
			invoke_if_exists(self, async_looper_finished, async_looper_data);
			if (fade_in_frames_first_room != 0) {
				ROOMCONTROLLER.transit(new FadeTransition(goto_room_after_init,0,fade_in_frames_first_room));
			} else
				room_goto(goto_room_after_init);
		}, false);
	} else {
		call_later(2, time_source_units_frames, function() {
			invoke_if_exists(self, async_looper_finished, async_looper_data);
		}, false);
	}
}
