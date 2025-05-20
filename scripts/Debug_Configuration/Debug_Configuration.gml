/*
	Invoked in every end_draw event from the base room controller, if all of these conditions are met:
	
	- The current RoomController object is a child of RoomController and is visible
	- DEBUG_MODE_ACTIVE = true; (activates toggling debug info with the F12 key)
	- global.__debug_shown is true (toggled by the F12 key)
	
	(c)2022- coldrock.games, @grisgram at github
*/
// Feather ignore all in ./*

#macro DEBUG_VIEW_TOGGLE_KEY				"F12"

// When the debug gets opened, which panels shall become visible?
#macro DEBUG_VIEW_SHOW_RAPTOR_PANEL			true
#macro DEBUG_VIEW_SHOW_CAMERA_PANEL			true

/// @func	drawDebugInfo()
/// @desc	Use this function to draw anything to the screen each frame.
///			Example: Use draw_text() to print some debug output (if you don't want to use a debug view)
///			NOTE: debug views are supported on windows only! 
///			This function is mainly used to print debug output to HTML/JavaScript/Mobile targets!
function drawDebugInfo() {
	// This is a demo debug output when you press F12 
	// to print the size of the processing queues of the active RoomController
	// in HTML mode only, as raptor will open a custom debug view when running windows
	if (IS_HTML) {
		draw_text(16, 160, string_concat(
			"Bindings: ", BINDINGS.size(),
			"\nAnimations: ", ANIMATIONS.size(),
			"\nStatemachines: ", STATEMACHINES.size(),
			$"\nBroadcasts: {BROADCASTER.dump_to_string()}",
			$"\nMouse:\nRM: {MOUSE_X}/{MOUSE_Y}",
			$"\nUI: {GUI_MOUSE_X}/{GUI_MOUSE_Y}",
			//$"\nBC:\n{dump_array(BROADCASTER.receivers, false)}",
		));
	}
}

/// @func	onDebugViewStarted()
/// @desc	Invoked when in Debug mode and the user presses F12
///			Often this method contains a "if (room == ...)" or a switch over the rooms
///			To show/hide specific debug elements for each room
function onDebugViewStarted() {
	// Another example: You may modify even the room, when debug view is opened
	//if (room == rmPlay) {
	//	layer_set_visible("DebugMode", true);
	//}
}

/// @func	onDebugViewClosed()
/// @desc	Invoked when in Debug mode and the user presses F12
///			Often this method contains a "if (room == ...)" or a switch over the rooms
///			To show/hide specific debug elements for each room
function onDebugViewClosed() {	
	//if (room == rmPlay) {
	//	layer_set_visible("DebugMode", false);
	//}
}
