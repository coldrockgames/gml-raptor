/// @desc align to my coordinates
event_inherited();

if (__create_init_succeeded) exit;

if (variable_global_exists("__room_particle_system") && !string_is_empty(__my_emitter)) {
	var ps = __get_partsys();
	ps.emitter_move_range_to(__my_emitter, x, y);
}

if (stream_on_create) {
	stream_start_delay = max(stream_start_delay, 1);
	if (stream_start_delay > 0 && DEBUG_LOG_PARTICLES)
		ilog($"{MY_NAME}: Will start streaming in {stream_start_delay} frames");
	run_delayed(self, stream_start_delay, function() { stream(); });
}
