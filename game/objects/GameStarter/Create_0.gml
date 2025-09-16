/// @desc 

#macro GAMESTARTER		global.__gamestarter
GAMESTARTER				= self;

__FAKE_GAMECONTROLLER;

__reset = function() {
	// spinner animation
	spinner_font			= undefined;
	spinner_sprite			= sprLoadingSpinner;
	spinner_frame_counter	= 0;
	spinner_rotation		= 0;
	spinner_x				= 0;
	spinner_y				= 0;
	spinner_w				= sprite_get_width(spinner_sprite);
	spinner_h				= sprite_get_height(spinner_sprite);
	spinner_text			= "Connecting to server...";

	async_looper			= onLoadingScreen;
	async_looper_data		= {};
	async_looper_starting	= onLoadingScreenStarting;
	async_looper_finished	= onLoadingScreenFinished;
	async_wait_timeout		= -1;
	async_wait_counter		= 0;
	draw_spinner			= false; // true while waiting for min-time
	wait_for_async_tasks	= false;
	wait_for_loading_screen = false;
	loading_screen_frame	= 0;

	trampoline_done			= false;

	game_init_step			= false;
	first_step				= true;
}
__reset();
game_init_step = true;

__original_first_room = goto_room_after_init; // backup for reinit

/// @func	run_async_loop(_started_callback = undefined, _looper = undefined, _finished_callback = undefined, _task_data = undefined, _target_room_after = undefined, _transition = undefined)
/// @desc	Runs the specified (_looper) async loading loop, like the one at game start (onLoadingScreen).
///			If no _looper is specified, this function fires the entire async-startup chain 
///			(onLoadingScreen) again, but NOT the onGameStart callback.
///			Use this for language swaps or larger async loading done in the
///			onLoadingScreen callback.
///			Specify any data struct as _looper_data to have it sent to the looper function as
///			third argument. This way you can transport any information to the looper function.
///			If you supply any room, then this function will return to rmStartup, to show
///			the initial loading screen (black with spinner), before returning to the desired
///			room. If you specify nothing, the game stays in the current room and the spinner
///			is just shown as overlay while loading.
run_async_loop = function(
	_started_callback	= undefined,
	_looper				= undefined, 
	_finished_callback	= undefined, 
	_task_data			= undefined, 
	_target_room_after	= undefined, 
	_transition			= undefined) {
		
	__reset();
	async_min_wait_time		= 0;
	draw_spinner			= true;
	async_looper_starting	= _started_callback;
	async_looper			= _looper ?? EMPTY_FUNC;
	async_looper_finished	= _finished_callback;
	async_looper_data		= _task_data;
	visible					= true;
	
	if (_target_room_after != undefined || _transition != undefined) {		
		goto_room_after_init = _target_room_after != undefined ? _target_room_after : __original_first_room;
		ilog($"Running GLOBAL ASYNC LOOP with room change to '{room_get_name(goto_room_after_init)}'");
		if (_transition != undefined) {
			_transition.target_room = rmStartup;
			ROOMCONTROLLER.transit(_transition);
		} else
			room_goto(rmStartup);
	} else {
		goto_room_after_init = undefined;
		ilog($"Running GLOBAL ASYNC LOOP in current room");
	}
}

__invoke_starting_callback = function() {
	
	// Scan on startup for all particles?
	if (PARTICLES_SCAN_ON_STARTUP && game_init_step) {
		ENSURE_PARTICLES;
		ilog($"ParticleLoader is auto-loading particles from '{PARTICLES_ROOT_FOLDER}'");
		PARTICLES = directory_read_data_tree(PARTICLES_ROOT_FOLDER, FILE_EXTENSIONS.particle_file);
	}
	
	invoke_if_exists(self, async_looper_starting, async_looper_data);
	return true; // to make the if... in the step event continue
}

/// @func show_loading_text(_lg_string)
/// @desc Show a string left of the spinner on the game-start loading screen
show_loading_text = function(_lg_string) {
	spinner_text = LG_resolve(_lg_string);
}

// Inherit the parent event
event_inherited();

