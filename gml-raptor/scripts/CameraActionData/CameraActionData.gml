/*
	camera_action_data
	
	Controller class for all camera flights.
	Do not instantiate directly, use the methods in RoomController to launch camera effects:
	- screen_shake
	- zoom_to
	- zoom_by
	- move_to
	- move_by
	
*/

/// @func camera_action_data(cam_index, frames, script_to_call, enqueue_if_running = false, _is_zoom = false)
/// @param {int} cam_index
/// @param {real} frames
/// @param {asset} script_to_call
/// @param {bool=false} enqueue_if_running
function camera_action_data(cam_index, frames, script_to_call, enqueue_if_running = false, _is_zoom = false) constructor {
	camera_index					= cam_index;
	camera_align					= cam_align.top_left;
	camera_xstart					= camera_get_view_x(view_camera[camera_index]);
	camera_ystart					= camera_get_view_y(view_camera[camera_index]);
	restore_target					= camera_get_view_target(view_camera[camera_index]);
	total_frames					= frames;
	current_frame					= 0;
	elapsed							= 0;
	callback						= script_to_call;
	started_callback				= undefined;
	finished_callback				= undefined;
	__internal_finished_callback	= undefined;
	completed						= false;
	enqueued						= false;
	is_zoom							= _is_zoom;
	first_call						= true;
	stop_at_room_borders			= true;

	/*
		About AnimactionCurves:
		By default, a linear interpolation happens (acLinearMove)
		Change it to whatever interpolation you desire.
		Adapt the channel names for x/y if the curve uses different channel names
		The anim_curve_step gets updated every step BEFORE the runtime of the
		camera action is invoked, and contains the current values for x/y of the curve
		SEE camera_action_move or _zoom for implementation examples.
	*/
	anim_curve = acLinearMove;
	anim_curve_channel_x = "x";
	anim_curve_channel_y = "y";
	anim_curve_step = {x: 0, y: 0, xprevious: 0, yprevious: 0};

	/// @func		set_anim_curve(curve, x_channel_name = "x", y_channel_name = "y")
	/// @desc	Assigns a different AnimCurve than the default LinearCurve to this camera action.
	///			The curve must provide the channels named in the x_ and y_channel_name parameters and
	///			the value range must be 0..1, where 0 meanse "0%" and 1 means "100%" of distance done.
	///			This function returns self to make it chainable.
	/// @param {AnimCurve} curve 	The AnimCurve to use.
	/// @param {string} x_channel_name	Name of the channel for the x-coordinate
	/// @param {string} y_channel_name	Name of the channel for the y-coordinate
	/// @returns {camera_action_data} struct Self, to be chainable.
	static set_anim_curve = function(curve, x_channel_name = "x", y_channel_name = "y") {
		anim_curve = curve;
		anim_curve_channel_x = x_channel_name;
		anim_curve_channel_y = y_channel_name;
		return self;
	}

	/// @func		set_finished_callback(callback)
	/// @desc	Set any function as callback when this camera action is finished.
	///					The callback will receive 1 parameter: this camera action
	static set_finished_callback = function(callback) {
		finished_callback = callback;
		return self;
	}

	/// @func set_stop_at_room_borders(_stop)
	/// @desc By default this is true (same as in the "Eye" object), but you
	///				 can turn it off with this function, to allow the camera to look
	///				 outside of the room.
	static set_stop_at_room_borders = function(_stop) {
		stop_at_room_borders = _stop;
		return self;
	}

	static __add_or_enqueue = function(enqueue_if_running = false) {
		var rv = (is_zoom ? 0 : __CAMERA_RUNTIME.get_first_free_camera_action());
		var existing = __CAMERA_RUNTIME.has_camera_action_with(callback);
		var enqueue = (enqueue_if_running && existing);

		if (enqueue) {
			array_push(__CAMERA_RUNTIME.camera_action_queue, self);
			var queue_length = array_length(__CAMERA_RUNTIME.camera_action_queue);
			rv = -1;
			enqueued = true;
		} else {
			if (!existing) {
				if (is_zoom) {
					array_insert(__CAMERA_RUNTIME.active_camera_actions,0,self);
					for (var i = 1; i < array_length(__CAMERA_RUNTIME.active_camera_actions); i++) {
						var a = __CAMERA_RUNTIME.active_camera_actions[@i];
						if (a != undefined)
							a.__internal_index++;
					}
				} else
					__CAMERA_RUNTIME.active_camera_actions[rv] = self;
			} else
				rv = -1;
		}

		return rv;
	}

	__internal_index = __add_or_enqueue(enqueue_if_running);

	static __step = function() {
		current_frame++;
		elapsed = min(1, current_frame / total_frames);
		
		var xcurve = animcurve_get_channel(anim_curve, anim_curve_channel_x);
		var ycurve = animcurve_get_channel(anim_curve, anim_curve_channel_y);
		anim_curve_step.xprevious = anim_curve_step.x;
		anim_curve_step.yprevious = anim_curve_step.y;
		anim_curve_step.x = animcurve_channel_evaluate(xcurve, elapsed);
		anim_curve_step.y = animcurve_channel_evaluate(ycurve, elapsed);
		
		completed = (elapsed >= 1);
	}

	static abort = function() { 
		with(ROOMCONTROLLER) {
			__CAMERA_RUNTIME.active_camera_actions[@ other.__internal_index] = undefined;
		}
		// invoke finished_callback (if available)
		if (__internal_finished_callback != undefined)	
			__internal_finished_callback(self);
			
		if (finished_callback != undefined) {
			var me = self;
			run_delayed(ROOMCONTROLLER, 1, function(_data) {
				_data.cb(_data.arg);
			}, {
				cb: finished_callback,
				arg: me,
			});
		}
		
		// start next from queue (if available)
		var i = 0; repeat(array_length(__CAMERA_RUNTIME.camera_action_queue)) {
			var entry = __CAMERA_RUNTIME.camera_action_queue[@ i];
			if (entry.callback == callback) {
				entry.__internal_index = entry.__add_or_enqueue();
				entry.enqueued = false;
				array_delete(__CAMERA_RUNTIME.camera_action_queue, i, 1);
				break;
			}
			i++;
		}
		return self;
	}
}

