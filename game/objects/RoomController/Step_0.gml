/// @desc update anims & state machines

// optimize to death - only enter process if any are in list
if (ANIMATIONS.__listcount > 0)		ANIMATIONS.process_all();
if (STATEMACHINES.__listcount > 0)	STATEMACHINES.process_all();
if (BINDINGS.__listcount > 0)		BINDINGS.process_all("update_binding");
