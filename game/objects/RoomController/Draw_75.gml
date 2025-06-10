/// @desc 

if (ACTIVE_TRANSITION != undefined) {
	with (ACTIVE_TRANSITION) {
		if (__ACTIVE_TRANSITION_STEP == 0) out_draw_gui(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_draw_gui();
	}
}

if (!global.__debug_shown) exit;
drawDebugInfo();
