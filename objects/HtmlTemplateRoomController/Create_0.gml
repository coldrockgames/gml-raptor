/// @description onTransitFinished override
event_inherited();

// Invoked, when the transition to this room is finished and
// the scene is visible.
// The _data argument contains the data that has been sent
// when the transition was instantiated in the previous room.
onTransitFinished = function(_data) {
}

// Invoked, when you start loading a game in a different room
// and when this room is the target room of the savegame.
// If something goes wrong during load and object restore,
// this function is invoked.
// The exception has already been written to the error log.
onGameLoadFailed = function(_exception) {
	elog($"**ERROR** Game load failed: {_exception.message}");
}

// Invoked, when the "transit_back" method is called
// _transition_data has these members:
// .cancel (set to true to stay in this room)
// .target_room
// .transition (set a transition to animate room change)
onTransitBack = function(_transition_data) {
}
