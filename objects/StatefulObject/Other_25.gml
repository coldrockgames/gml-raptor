/// @desc onGameLoaded & state ev:user_15

// Inherit the parent event
event_inherited();
// restore our data from the savegame
states.data					= __RAPTORDATA.states.state_data;
states.__allow_re_enter		= __RAPTORDATA.states.__allow_re_enter;
states.__state_frame		= __RAPTORDATA.states.__state_frame;
states.__objectpool_paused	= __RAPTORDATA.states.__objectpool_paused;
// Restore the active state
if (!string_is_empty(__RAPTORDATA.states.state_name))
	states.active_state = states.get_state(__RAPTORDATA.states.state_name);

protect_ui_events			= __RAPTORDATA.protect_ui_events;
mouse_events_are_unique		= __RAPTORDATA.mouse_events_are_unique;

states.set_state("ev:user_15");
