/// @desc event
event_inherited();

mouse_wheel_active		= (wheel_scroll_lines > 0);

__vertical_zero_is_top	= true;
__first_value_change	= true;
__next_value_change		= 0;

__mouse_over_minus		= false;
__mouse_over_plus		= false;
__mouse_is_down			= false;

/// @func check_mouse_over_arrows()
check_mouse_over_arrows = function() {
	if (orientation_horizontal) {
		__mouse_over_minus	= mouse_x < x + nine_slice_data.left;
		__mouse_over_plus	= mouse_x > x + nine_slice_data.right;
	} else {
		__mouse_over_minus	= mouse_y < y + nine_slice_data.top;
		__mouse_over_plus	= mouse_y > y + nine_slice_data.bottom;
	}
	
	__mouse_is_down = mouse_check_button(mb_left);	
	if (!__mouse_is_down) {
		__first_value_change = true;
	}
}

/// @func __change_value_with_arrow(_change, _instant = false)
__change_value_with_arrow = function(_change, _instant = false) {
	if (__first_value_change || _instant) {
		__first_value_change = false;
		__next_value_change = 30; // 0.5 seconds
		set_value(value + _change);
	} else {
		if (--__next_value_change <= 0) {
			set_value(value + _change);
			__next_value_change = 8;
		}
	}
}

__slider_check_knob_grabbed = check_knob_grabbed;
check_knob_grabbed = function() {
	check_mouse_over_arrows();
	
	if (__mouse_is_down && __mouse_over_minus) {
		__change_value_with_arrow(-wheel_scroll_lines);
	} else if (__mouse_is_down && __mouse_over_plus) {
		__change_value_with_arrow(wheel_scroll_lines);
	} else 
		__slider_check_knob_grabbed(); // call the base function
}
