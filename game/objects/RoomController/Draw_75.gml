/// @desc 

if (ACTIVE_TRANSITION != undefined) {
	with (ACTIVE_TRANSITION) {
		if (__ACTIVE_TRANSITION_STEP == 0) out_draw_gui(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_draw_gui();
	}
}

if (!DEBUG_VIEW_SHOWN) exit;
drawDebugInfo();

if (CONFIGURATION_DEV && (DEBUG_SHOW_OBJECT_FRAMES || DEBUG_SHOW_OBJECT_DEPTH))
	__draw_bbox_rotated(true);
		