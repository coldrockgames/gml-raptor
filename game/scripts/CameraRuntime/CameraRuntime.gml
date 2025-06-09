/*
    internal runtime singleton implementation for the camera effects
*/

#macro __CAMERA_RUNTIME		__camera_runtime()

function __camera_runtime() {	
	static inst = undefined;
	
	if (inst == undefined) {
		inst = {
			active_camera_actions: array_create(1, undefined),
			camera_action_queue: [],

			get_first_free_camera_action: function() {
				freeidx = -1;
				var i = 0; repeat(array_length(active_camera_actions)) {
					if (active_camera_actions[i] == undefined) {
						freeidx = i;
						break;
					}
					i++;
				}
				if (freeidx == -1) {
					freeidx = array_length(active_camera_actions);
					array_push(active_camera_actions, undefined);
				}
				if (freeidx == 0 && array_length(active_camera_actions) > 1)
					active_camera_actions = array_create(1, undefined); // shrink the array if necessary
				return freeidx;
			},
			
			get_zoom_action: function() {
				var first = active_camera_actions[@0];
				if (first != undefined && first.is_zoom)
					return first;
				return undefined;
			},

			has_camera_action_with:  function(script_to_call) {
				var i = 0; repeat(array_length(active_camera_actions)) {
					var action = active_camera_actions[i++];
					if (action != undefined && action.callback == script_to_call && !action.completed)
						return true;
				}
				return false;
			},
		
		};
	}
	
	return inst;
}