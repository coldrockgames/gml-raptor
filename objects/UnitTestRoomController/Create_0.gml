/// @description onTransitFinished override
event_inherited();

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
