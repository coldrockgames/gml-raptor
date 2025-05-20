/// @desc setup button

event_inherited();

sprite_index = if_null(sprite_to_use, sprite_index);

message_window = undefined;

__window_right = 0;
__window_top = 0;
__nine_slice_calculated = false;
__nine_right = 0;
__nine_top = 0;
 
onSkinChanged = function(_skindata) {
	_baseControl_onSkinChanged(_skindata, update_position);
}

/// @func attach_to_window(_window)
attach_to_window = function(_window) {
	message_window = _window;
	if (is_null(message_window) || !is_child_of(message_window, RaptorWindow)) {
		instance_destroy(self);
		return;
	}
	draw_on_gui = _window.draw_on_gui;
}

update_position = function() {
	with (message_window) {
		if (!other.__nine_slice_calculated) {
			var nine = sprite_get_nineslice(sprite_index);
			if (nine != -1) {
				other.__nine_right = nine.right;
				other.__nine_top = nine.top;
			}
			other.__nine_slice_calculated = true;
		}
		other.depth = depth;
		other.__window_right = SELF_VIEW_RIGHT_EDGE - other.__nine_right;
		other.__window_top = SELF_VIEW_TOP_EDGE + titlebar_height / 2;
	}

	x = __window_right + x_button_xoffset;
	y = __window_top + x_button_yoffset;
}