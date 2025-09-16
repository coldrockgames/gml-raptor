/// @desc stop emission

if (!SAVEGAME_SAVE_IN_PROGRESS && !SAVEGAME_LOAD_IN_PROGRESS)
	stop();

if (emitter_mode == emitter_render.local) {
	// local systems do not destroy the global particle types!
	__my_partsys.__cleanup_system_and_emitters();
	__my_partsys = undefined;
}

event_inherited();
