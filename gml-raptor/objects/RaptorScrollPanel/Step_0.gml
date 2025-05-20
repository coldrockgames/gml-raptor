/// @description mouse_drag
event_inherited();

if (mouse_drag_mode == mouse_drag.none) {
	__mouse_delta = 0;
	exit;
}

__mouse_delta = 
   (((mouse_drag_mode == mouse_drag.left   && mouse_button == mb_left)   ||
	 (mouse_drag_mode == mouse_drag.middle && mouse_button == mb_middle) ||
	 (mouse_drag_mode == mouse_drag.right  && mouse_button == mb_right)) &&
	 mouse_over_content()) ? 1 : 0;
