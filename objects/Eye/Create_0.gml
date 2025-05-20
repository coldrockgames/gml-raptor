/// @desc 


// Inherit the parent event
event_inherited();

data.camera_index = camera_index;
data.is_attached = false;
data.attached_to = noone;

__camview_x = 0;
__camview_y = 0;

__parallax_ids = [];
if (parallax_enabled) {
	if (array_length(parallax_layers) > 0 &&
		array_length(parallax_layers) == array_length(parallax_factors)) {
		__parallax_ids = array_create(array_length(parallax_layers));
		array_foreach(parallax_layers, function(_item, _idx) {
			__parallax_ids[@_idx] = layer_get_id(_item);
		});
	} else {
		parallax_enabled = false;
		wlog($"** WARNING ** Eye object had parallax enabled but no layers defined or layers and factors do not match!");
		wlog($"Eye has disabled parallax");
	}
}

__update_camera = function() {
	my_cam			= view_camera[data.camera_index];
	my_cam_width	= camera_get_view_width(CAM) / 2;
	my_cam_height	= camera_get_view_height(CAM) / 2;
}

align_to_attached = function() {
	if (stop_at_room_borders) {
		x = min(room_width  - my_cam_width , max(my_cam_width , data.attached_to.x));
		y = min(room_height - my_cam_height, max(my_cam_height, data.attached_to.y));
	} else {
		x = data.attached_to.x;
		y = data.attached_to.y;
	}
	__camview_x = x - my_cam_width;
	__camview_y = y - my_cam_height;
	camera_set_view_pos(my_cam, __camview_x, __camview_y);
	
	if (parallax_enabled) apply_parallax();
}

apply_parallax = function() {
	array_foreach(__parallax_ids, function(_item, _idx) {
		layer_x(_item, __camview_x * (1 - parallax_factors[@_idx]));
		layer_y(_item, __camview_y * (1 - parallax_factors[@_idx]));
	});
}

/// @func		attach_to(_instance)
/// @desc	Attach the eye to an object (or noone).
///					As long as the eye is attached, the eye (and so the camera)
///					will follow the attached object, keeping it in the center of the screen.
attach_to = function(_instance) {
	data.attached_to = _instance;
	data.is_attached = (_instance != undefined && _instance != noone);
	if (is_enabled && data.is_attached) align_to_attached();
}

/// @func	set_camera_index(_index)
set_camera_index = function(_index) {
	data.camera_index = _index;
	__update_camera();
}

/// @func	get_camera_index()
get_camera_index = function() {
	return data.camera_index;
}

__update_camera();
