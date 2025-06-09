/// @desc destroy state machine

// Inherit the parent event
event_inherited();

if (variable_instance_exists(self, "states") && states != undefined) {
	states.destroy();
}

