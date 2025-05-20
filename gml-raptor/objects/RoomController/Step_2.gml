/// @desc update active camera actions

/*
	END STEP: All objects are placed, now move the camera
*/

// ATTENTION! i < array_length is a MUST here, as the abort() resizes the array!
for (var i = 0; i < array_length(__CAMERA_RUNTIME.active_camera_actions); i++) {
	__current_cam_action = __CAMERA_RUNTIME.active_camera_actions[@ i];
	if (__current_cam_action != undefined) {
		with (__current_cam_action) {
			if (current_frame == 0 && started_callback != undefined)
				started_callback(self);
				
			__step();
			callback(self);
			
			if (completed) 
				abort();
		}
	}
}

if (ACTIVE_TRANSITION != undefined) {
	with (ACTIVE_TRANSITION) {
		frame_counter++;
		if (__ACTIVE_TRANSITION_STEP == 0) out_step(); else 
		if (__ACTIVE_TRANSITION_STEP == 1) in_step();
	}
}
