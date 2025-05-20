/// @desc onGameSaving & state ev:user_14

// Inherit the parent event
event_inherited();
// push our data to the savegame
__RAPTORDATA.states = {};
__RAPTORDATA.states.state_data			= states.data;
__RAPTORDATA.states.state_name			= states.get_active_state_name();
__RAPTORDATA.states.__allow_re_enter	= states.__allow_re_enter;
__RAPTORDATA.states.__state_frame		= states.__state_frame;
__RAPTORDATA.states.__objectpool_paused	= states.__objectpool_paused;

__RAPTORDATA.protect_ui_events			= protect_ui_events;
__RAPTORDATA.mouse_events_are_unique	= mouse_events_are_unique;

states.set_state("ev:user_14");
