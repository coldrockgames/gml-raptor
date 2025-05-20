/// @desc set image_index_default

event_inherited();

__set_default_image = function() {
	if (sprite_index != -1 && image_number >= image_index_default)
		image_index = image_index_default;
}

__set_over_image = function() {
	if (sprite_index != -1 && image_number >= image_index_mouse_over)
		image_index = image_index_mouse_over;
}

__set_down_image = function() {
	if (sprite_index != -1 && image_number >= image_index_mouse_down)
		image_index = image_index_mouse_down;
}

__set_default_image();

onSkinChanged = function(_skindata) {
	_baseControl_onSkinChanged(_skindata, __set_default_image);
}
