/*
    The Collider script is a set of functions that can help you determine,
	whether a collision event occurs for the first time or is ongoing.
	
	If the same collision appeared last frame, it is considered ongoing.
	The functions have no arguments, they use the keywords "self" and "other",
	as you would in a collision event, that's why they are global functions and
	not a constructor/class - to make sure, self and other point to the colliding 
	instances.
*/

#macro __COLLIDER_CACHE		global.__collider_cache
__COLLIDER_CACHE = {};

/// @func collider_first()
/// @desc Checks, if this is the first collision between self and other
///		  (means: there has not been the same collision in the previous frame),
///		  and returns true, if that's the case
function collider_first() {
	var key  = $"{MY_NAME}_{name_of(other)}";
	var last = vsget(__COLLIDER_CACHE, key, -2);
	struct_set(__COLLIDER_CACHE, key, GAME_FRAME);
	return last < GAME_FRAME - 1;
}

/// @func collider_cleanup()
/// @desc This function is called in the "Room End" event of the RoomController.
///		  It removes all cached collisions and works like a full reset.
function collider_cleanup() {
	__COLLIDER_CACHE = {};
}