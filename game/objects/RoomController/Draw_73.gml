/// @desc object debug frames

if (ACTIVE_TRANSITION != undefined) {
	with (ACTIVE_TRANSITION) {
		if (__ACTIVE_TRANSITION_STEP == 0) out_draw(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_draw();
	}
}

if (CONFIGURATION_DEV) {
	if (!DEBUG_VIEW_SHOWN) exit;
	global.__debug_instance_count = instance_count;

	if (DEBUG_SHOW_OBJECT_FRAMES || DEBUG_SHOW_OBJECT_DEPTH)
		__draw_bbox_rotated(false);
}