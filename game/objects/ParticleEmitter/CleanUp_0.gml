/// @desc stop emission

if (!SAVEGAME_SAVE_IN_PROGRESS && !SAVEGAME_LOAD_IN_PROGRESS)
	stop();
	
event_inherited();
