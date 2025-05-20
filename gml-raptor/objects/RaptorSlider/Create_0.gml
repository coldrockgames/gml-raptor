/// @desc DOCS inside!

/*
	A note on the on_value_changed callback:
	This function receives two parameters: new_value, old_value
	so you can always see, which value has been active before the change, in case you need it.
	
	There is also a variable value_percent available which holds the percentage_of_max of the current value.
	The value_percent ranges from 0 to 1, so for display you should multiply it by 100.
*/

#macro __SLIDER_IN_FOCUS		global.__slider_in_focus
__SLIDER_IN_FOCUS				= undefined;

#macro __SLIDER_DEFAULT_KNOB_ANIM_TIME	6

enum slider_autotext {
	none = 0,
	text_is_value = 1,
	text_is_percent = 2
}

enum slider_text {
	h_above = 1,
	h_below = 2,
	v_left  = 4,
	v_right = 8
}

event_inherited();

value_percent			= 0;
shown_range				= -1;

__range_scale			= 1;
__vertical_zero_is_top	= false;
__text_dims				= scribble_measure_text(string(max_value));
__text_xoffset_mod		= 0;
__text_yoffset_mod		= 0;

__knob_dims				= new SpriteDim(knob_sprite);
__knob_grabbed			= false;
__knob_scroll_anim_time	= __SLIDER_DEFAULT_KNOB_ANIM_TIME;

__knob_x				= 0;
__knob_y				= 0;
__knob_rel_x			= 0;
__knob_rel_y			= 0;
__knob_new_x			= 0;
__knob_new_y			= 0;
__value_offset			= 0;
__new_value_offset		= 0;
__last_value_offset		= 0;

__mouse_over_knob		= false;
__initial_value_set		= false;
__outside_knob_cursor	= window_get_cursor();
__tilesize				= 0;
__old_value				= -1;

xcheck					= CTL_MOUSE_X;
ycheck					= CTL_MOUSE_Y;
__is_topmost			= false;
__over_before			= false;

/// @func pre_calculate_knob()
pre_calculate_knob = function() {
	var w = (startup_width  >= 0 ? startup_width  : sprite_width);
	var h = (startup_height >= 0 ? startup_height : sprite_height);

	if (orientation_horizontal) {
		sprite_index = if_null(rail_sprite_horizontal, sprite_index);
		__knob_rel_x = __knob_dims.origin_x + sprite_xoffset + nine_slice_data.left;
		__knob_rel_y = __knob_dims.origin_y + sprite_yoffset + nine_slice_data.get_center_y() - __knob_dims.center_y;
		//__tilesize = (nine_slice_data.width - __knob_dims.width * knob_xscale) / (max_value - min_value)
	} else {
		sprite_index = if_null(rail_sprite_vertical, sprite_index);
		__knob_rel_x = __knob_dims.origin_x + sprite_xoffset + nine_slice_data.get_center_x() - __knob_dims.center_x;
		__knob_rel_y = __knob_dims.origin_y + sprite_yoffset + nine_slice_data.top;
		//__tilesize = (nine_slice_data.height - __knob_dims.height * knob_yscale) / (max_value - min_value);
	}
	calculate_knob_size();
	scale_sprite_to(w, h);

	__value_offset = floor((value - min_value) * __tilesize);
	__last_value_offset = __value_offset;
	if (orientation_horizontal) {
		__knob_x = x + __knob_rel_x + __value_offset;
		__knob_y = y + __knob_rel_y;
	} else {
		__knob_x = x + __knob_rel_x;
		__knob_y = __vertical_zero_is_top ?
			y + __knob_rel_y + __value_offset :
			y + __knob_rel_y + nine_slice_data.height - __knob_dims.height - __value_offset;
	}

}

onSkinChanged = function(_skindata) {
	_baseControl_onSkinChanged(_skindata, pre_calculate_knob);
	update_client_area();
}

update_client_area = function() {
	if (orientation_horizontal)
		data.__raptordata.client_area.set(0, 0, sprite_width, sprite_height + __text_dims.y);
	else 
		data.__raptordata.client_area.set(0, 0, sprite_width + __text_dims.x, sprite_height);
}

/// @func check_mouse_over_knob()
check_mouse_over_knob = function() {
	xcheck = CTL_MOUSE_X;
	ycheck = CTL_MOUSE_Y;

	__over_before = __mouse_over_knob;
	__is_topmost = is_topmost(xcheck, ycheck);
	
	__mouse_over_knob = __is_topmost &&
		(is_between(xcheck, __knob_x - __knob_dims.origin_x * knob_xscale, __knob_x - __knob_dims.origin_x * knob_xscale + __knob_dims.width  * knob_xscale) &&
		 is_between(ycheck, __knob_y - __knob_dims.origin_y * knob_yscale, __knob_y - __knob_dims.origin_y * knob_yscale + __knob_dims.height * knob_yscale));

	if (__mouse_over_knob != __over_before) {
		if (__mouse_over_knob) {
			if (on_mouse_enter_knob != undefined) on_mouse_enter_knob();
		} else {
			if (on_mouse_leave_knob != undefined) on_mouse_leave_knob();
		}
	}
}

/// @func check_knob_grabbed()
check_knob_grabbed = function() {
	if (__knob_grabbed || mouse_is_over || __mouse_over_knob) {
		
		if (mouse_check_button(mb_left)) {
			if (__knob_grabbed || __is_topmost) {
				if (orientation_horizontal) {
					set_value(
						min_value 
						+ round((xcheck - (__knob_dims.width * knob_xscale) / 2 - x - nine_slice_data.left) / __tilesize)
					);
				} else {
					if (__vertical_zero_is_top)
						set_value(
							min_value 
							+ round((ycheck - (__knob_dims.height * knob_yscale) / 2 - y - nine_slice_data.top) / __tilesize)
						);
					else
						set_value(
							min_value 
							+ round((y + nine_slice_data.top + nine_slice_data.height - ycheck - (__knob_dims.height * knob_yscale) / 2) / __tilesize)
						);
				}
			}
		} else
			__knob_grabbed = false;
	}
}

/// @func calculate_value_percent()
calculate_value_percent = function() {
	value_percent = (value - min_value) / max_value;
}

/// @func set_value()
set_value = function(new_value) {
	__old_value = value;
	value = clamp(new_value, min_value, max_value);
	calculate_value_percent();
	if (value != __old_value) {
		if (auto_text == slider_autotext.text_is_value)		text = string(round(value)); else
		if (auto_text == slider_autotext.text_is_percent)	text = string_format(value_percent * 100,3,0) + "%"; else
		if (auto_text == slider_autotext.none)				text = "";
		
		if (__initial_value_set && on_value_changed != undefined) on_value_changed(value, __old_value);
		__initial_value_set = true; // this skips the FIRST value assignment on creation
	}
}

/// @func set_range(_min, _max)
/// @desc Set a new min/max value range. 
///				 "value" gets adapted to fit into the new range.
set_range = function(_min, _max) {
	min_value = _min;
	max_value = _max;
	set_value(value); // clamp to the new range
}

/// @func __set_draw_colors()
__set_draw_colors = function() {
	if (draw_color != draw_color_mouse_over) {
		draw_color_mouse_over = draw_color;
	}
}

__apply_post_positioning = function() {
	if (auto_text != slider_autotext.none) {		
		switch(auto_text_position) {
			case slider_text.h_above:	
				__text_x = SELF_VIEW_CENTER_X + text_xoffset;
				__text_y = SELF_VIEW_TOP_EDGE + text_yoffset;
				break;
			case slider_text.h_below:	
				__text_x = SELF_VIEW_CENTER_X + text_xoffset;
				__text_y = SELF_VIEW_BOTTOM_EDGE + text_yoffset;
				break;
			case slider_text.v_left:	
				__text_x = SELF_VIEW_LEFT_EDGE + text_xoffset;
				__text_y = SELF_VIEW_CENTER_Y + text_yoffset;
				break;
			case slider_text.v_right:
				__text_x = SELF_VIEW_RIGHT_EDGE + text_xoffset;
				__text_y = SELF_VIEW_CENTER_Y + text_yoffset;
				break;
		}
	}
}

/// @func calculate_knob_size()
calculate_knob_size = function() {
	if (orientation_horizontal) {
		if (knob_autoscale)	{
			__range_scale = shown_range > 0 ? (nine_slice_data.width * min(0.99, shown_range)) / __knob_dims.width : 1;
			knob_xscale = clamp(
				max(__range_scale, nine_slice_data.width / ((max_value - min_value) + 1)), 
				1, max(__range_scale, nine_slice_data.width / (1.5 * __knob_dims.width))
			);
		}
		__tilesize = (nine_slice_data.width - __knob_dims.width * knob_xscale) / (max_value - min_value);
	} else {
		if (knob_autoscale)	{
			__range_scale = shown_range > 0 ? (nine_slice_data.height * min(0.99, shown_range)) / __knob_dims.height : 1;
			knob_yscale = clamp(
				max(__range_scale, nine_slice_data.height / ((max_value - min_value) + 1)), 
				1, max(__range_scale, nine_slice_data.height / (1.5 * __knob_dims.height))
			);
		}
		__tilesize = (nine_slice_data.height - __knob_dims.height * knob_yscale) / (max_value - min_value);
	}
}

__recalc_knob = false;
__draw_self = function() {
	if (__CONTROL_NEEDS_LAYOUT) {
		__recalc_knob = true;
		if (auto_text != slider_autotext.none) {
			switch(auto_text_position) {
				case slider_text.h_above:	scribble_text_align = "[fa_bottom][fa_center]";	break;
				case slider_text.h_below:	scribble_text_align = "[fa_top][fa_center]";	break;
				case slider_text.v_left:	scribble_text_align = "[fa_middle][fa_right]";	break;
				case slider_text.v_right:	scribble_text_align = "[fa_middle][fa_left]";	break;
			}
		}
	}
	
	__basecontrol_draw_self();
	
	if (__recalc_knob) {
		calculate_knob_size();
		__recalc_knob = false;
	}
}

__draw_instance = function(_force = false) {
	__basecontrol_draw_instance(_force);
		
	__value_offset = floor(__tilesize * (value - min_value));
	if (__value_offset != __last_value_offset && !__knob_grabbed) {
		if (orientation_horizontal) {
			__knob_new_x = x + __knob_rel_x + __value_offset;
			__knob_new_y = __knob_y;
		} else {
			__knob_new_x = __knob_x;
			__knob_new_y = __vertical_zero_is_top ?
				y + __knob_rel_y + __value_offset :
				y + __knob_rel_y + nine_slice_data.height - __knob_dims.height - __value_offset;
		}
		__knob_start_x = __knob_x;
		__knob_start_y = __knob_y;
		__knob_x_dist = __knob_new_x - __knob_x;
		__knob_y_dist = __knob_new_y - __knob_y;
		animation_abort(self, "knob_anim");
		animation_run(self, 0, __knob_scroll_anim_time, acLinearMove)
			.set_function("x", function(v) { with(owner) __knob_x = __knob_start_x + v * __knob_x_dist; })
			.set_function("y", function(v) { with(owner) __knob_y = __knob_start_y + v * __knob_y_dist; })
			.set_name("knob_anim");
			__knob_scroll_anim_time = __SLIDER_DEFAULT_KNOB_ANIM_TIME;
	} else if (!is_in_animation(self)) {	
		if (orientation_horizontal) {
			__knob_x = x + __knob_rel_x + __value_offset;
			__knob_y = y + __knob_rel_y;
		} else {
			__knob_x = x + __knob_rel_x;
			__knob_y = __vertical_zero_is_top ?
				y + __knob_rel_y + __value_offset :
				y + __knob_rel_y + nine_slice_data.height - __knob_dims.height - __value_offset;
		}
	}
	__last_value_offset = __value_offset;
	
	draw_sprite_ext(
		knob_sprite, 0, 
		__knob_x, 
		__knob_y,
		knob_xscale, knob_yscale, 0, (!is_enabled ? THEME_SHADOW : (
		(__mouse_over_knob || (__SLIDER_IN_FOCUS == self && __knob_grabbed)) ? knob_color_mouse_over : draw_color)), 
		image_alpha);
}

__set_draw_colors();
// first, clamp the value in case the dev made a config error (like leaving value at 0 while setting min_value to 1)
// also, avoid division by zero, by setting max_value at least min_value + 1
max_value = max(max_value, min_value + 1);
value = clamp(value, min_value, max_value);
var initval = value;
value++; // just modify the value, so set_value below finds a difference and recalculates
set_value(initval);

// respect the 2 frames delay of the control tree until all sizes are final
run_delayed(self, 2, function(iv) {
	set_value(iv);
	pre_calculate_knob();
}, initval);

pre_calculate_knob();
