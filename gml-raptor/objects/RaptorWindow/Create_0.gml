/// @desc override draw_self (window)

/*
	Rules for the "size direction" variable are like the numpad on keyboard:
	
		7  8  9
		+-----+
		|     |
	  4 |     | 6
		|     |
		+-----+
		1  2  3
	
	if size direction != 0, then odd directions (1,3,7,9) cause the diagonal arrow to appear,
	4 and 6 the horizontal one and 2 and 8 the vertical one
*/

event_inherited();

#macro __CONTROL_TITLE_CHANGED (__scribble_text == undefined || __last_title != title)

#macro __MOUSE_OVER_FOCUS_WINDOW		(__RAPTOR_FOCUS_WINDOW != undefined && __RAPTOR_FOCUS_WINDOW.mouse_is_over)

#macro __RAPTOR_WINDOW_FOCUS_CHANGE_RUNNING		global.__raptor_window_focus_change_running
#macro __RAPTOR_FOCUS_WINDOW					global.__raptor_focus_window
__RAPTOR_WINDOW_FOCUS_CHANGE_RUNNING	= false;
__RAPTOR_FOCUS_WINDOW					= undefined;

__RAPTORDATA.has_focus		= false;
__RAPTORDATA.creation_depth	= depth;
__RAPTORDATA.focus_index	= -1;

if (window_is_sizable && image_number > 2)
	image_index = 2;

title				= LG_resolve(title);

__container			= self;
__can_draw_focus	= image_number > image_index;

__last_title		= "";
__title_x			= 0;
__title_y			= 0;
__scribble_title	= undefined;

__in_drag_mode		= false;
__drag_rect			= new Rectangle();

onSkinChanged = function(_skindata) {
	_baseControl_onSkinChanged(_skindata);
	create_x_button();
	text = LG_resolve(text);
	title = LG_resolve(title);
	__check_center_on_open();
}

/// @func is_focus_window()
is_focus_window	= function() {
	return __RAPTORDATA.has_focus;
}

/// @func center_on_screen()
center_on_screen = function() {
	x = (draw_on_gui ? UI_VIEW_CENTER_X : VIEW_CENTER_X) - SELF_CENTER_X;
	y = (draw_on_gui ? UI_VIEW_CENTER_Y : VIEW_CENTER_Y) - SELF_CENTER_Y;
	control_tree.update_render_area();
}

__check_center_on_open = function() {
	if ((!add_to_savegame || !SAVEGAME_LOAD_IN_PROGRESS) && center_on_open) {
		center_on_screen();
		update_startup_coordinates();
	}
}
__check_center_on_open();

#region x-button

__x_button			= undefined;
__x_button_closing	= undefined;
__have_x_button		= false;

create_x_button = function() {
	if (__have_x_button && instance_exists(__x_button)) {
		if (__x_button.object_index == window_x_button_object)
			return;
		else
			instance_destroy(__x_button);
	}
	if (window_x_button_visible && !is_null(window_x_button_object)) {
		__have_x_button = true;
		__x_button = instance_create(0, 0, MY_LAYER_OR_DEPTH, window_x_button_object);
		__x_button.attach_to_window(self);
		__x_button_closing = __x_button.on_left_click;
		__x_button.on_left_click = function(sender) {
			// This is the original left click handler on the x button that might have been set
			// at design time but was overwritten by this function
			if (!is_null(__x_button_closing))
				__x_button_closing(__x_button);
			// Launch the closing callback set on the window
			close();
		}
	}
}
create_x_button();

/// @func get_x_button()
get_x_button = function() { 
	return __x_button; 
}

#endregion

#region sizable window
__size_rect_top		= new Rectangle();
__size_rect_bottom	= new Rectangle();
__size_rect_left	= new Rectangle();
__size_rect_right	= new Rectangle();
__mouse_has_moved	= false;
__in_destroy		= false;
__in_size_mode		= false;
__size_direction	= 0;

// _rc = raptor cursor:Image index of the sizable sprite
__size_images_rc	= [-1,3,1,2,0,-1,0,2,1,3];
// _dc = default cursor (gamemaker cr_ constants)
__size_images_dc	= [cr_default,cr_size_nesw,cr_size_ns,cr_size_nwse,cr_size_we,cr_default,cr_size_we,cr_size_nwse,cr_size_ns,cr_size_nesw];

__dx	= 0;
__dy	= 0;
__oldw	= 0;
__oldh	= 0;
__neww	= 0;
__newh	= 0;

__do_sizing = function() {
	if (!__in_size_mode) 
		return false;
	
	var recalc = true;
	__oldw = sprite_width;
	__oldh = sprite_height;
	__neww = sprite_width;
	__newh = sprite_height;
	__dx = CTL_MOUSE_DELTA_X;
	__dy = CTL_MOUSE_DELTA_Y;
	switch (__size_direction) {
		case 1:	__neww -= __dx;	__newh += __dy;	x += __dx;				break;
		case 2:					__newh += __dy;							break;
		case 3:	__neww += __dx;	__newh += __dy;							break;
		case 4:	__neww -= __dx;					x += __dx;				break;
		case 6:	__neww += __dx;											break;
		case 7:	__neww -= __dx;	__newh -= __dy;	x += __dx;	y += __dy;	break;
		case 8:					__newh -= __dy;				y += __dy;	break;
		case 9:	__neww += __dx;	__newh -= __dy;				y += __dy;	break;
		default:
			return;
	}
	
	__apply_window_sizing_size(max(__neww, min_width), max(__newh, min_height));
	
	if (__find_sizing_area() == 0) {
		vlog($"Window resize stopped (min-size)");
		__set_sizing_cursor();
		__apply_window_sizing_size(__oldw, __oldh);
		control_tree.move_children_after_sizing(true);
		__in_size_mode = false;
		return true; // return true to get a final draw outside of this in the Step event
	} else
		return (__neww != __oldw || __newh != __oldh);
}

__apply_window_sizing_size = function(_w, _h) {
	scale_sprite_to(_w, _h);
	update_startup_coordinates();
	update_client_area();
	__setup_drag_rect();
}

// Find the windows' sizing areas
// we need to check all 4 borders and in each of them the adjacent sides to find the diagonals
__find_sizing_area = function() {
	if (!__RAPTORDATA.has_focus) return;
	__dx = CTL_MOUSE_X;
	__dy = CTL_MOUSE_Y;
	
	if (__size_rect_top.intersects_point(__dx, __dy)) {
		
		if (__size_rect_left.intersects_point(__dx, __dy)) __size_direction = 7;
		else if (__size_rect_right.intersects_point(__dx, __dy)) __size_direction = 9;
		else
			__size_direction = 8;
			
	} else if (__size_rect_bottom.intersects_point(__dx, __dy)) {
		
		if (__size_rect_left.intersects_point(__dx, __dy)) __size_direction = 1;
		else if (__size_rect_right.intersects_point(__dx, __dy)) __size_direction = 3;
		else 
			__size_direction = 2;
		
	} else if (__size_rect_left.intersects_point(__dx, __dy)) {
		
		if (__size_rect_top.intersects_point(__dx, __dy)) __size_direction = 7;
		else if (__size_rect_bottom.intersects_point(__dx, __dy)) __size_direction = 1;
		else
			__size_direction = 4;

	} else if (__size_rect_right.intersects_point(__dx, __dy)) {

		if (__size_rect_top.intersects_point(__dx, __dy)) __size_direction = 9;
		else if (__size_rect_bottom.intersects_point(__dx, __dy)) __size_direction = 3;
		else
			__size_direction = 6;

	} else
		__size_direction = 0;
	
	__set_sizing_cursor();
	return __size_direction;
}

__set_sizing_cursor = function() {
	if (!__RAPTORDATA.has_focus) return;
	if (MOUSE_CURSOR != undefined)
		if (__size_direction == 0)
			MOUSE_CURSOR.set_cursor(mouse_cursor_type.pointer);
		else
			MOUSE_CURSOR.set_cursor(mouse_cursor_type.sizing, __size_images_rc[@__size_direction]);
	else
		window_set_cursor(__size_images_dc[@__size_direction]);
}

/// @func				__setup_drag_rect(ninetop)
/// @desc			setup drag and resize rects
/// @param {int} ninetop
__setup_drag_rect = function() {
	var size_offset = (window_is_sizable ? window_resize_border_width : 0);
	__drag_rect.set(
		SELF_VIEW_LEFT_EDGE + size_offset, 
		SELF_VIEW_TOP_EDGE + size_offset, 
		SELF_WIDTH - 2 * size_offset, 
		titlebar_height
	);
	
	__size_rect_top.set(
		SELF_VIEW_LEFT_EDGE, 
		SELF_VIEW_TOP_EDGE, 
		SELF_WIDTH, 
		window_resize_border_width
	);
	
	__size_rect_bottom.set(
		SELF_VIEW_LEFT_EDGE, 
		SELF_VIEW_BOTTOM_EDGE - window_resize_border_width,
		SELF_WIDTH, 
		window_resize_border_width
	);

	__size_rect_left.set(
		SELF_VIEW_LEFT_EDGE,
		SELF_VIEW_TOP_EDGE,
		window_resize_border_width,
		SELF_HEIGHT
	);

	__size_rect_right.set(
		SELF_VIEW_RIGHT_EDGE - window_resize_border_width,
		SELF_VIEW_TOP_EDGE,
		window_resize_border_width,
		SELF_HEIGHT
	);
}

#endregion

#region focus chain

__focus_next_in_chain = function() {
	var win = undefined;
	var maxidx = -1;
	with(RaptorWindow) {
		if (!eq(self, other) && __RAPTORDATA.focus_index > maxidx) {
			maxidx = __RAPTORDATA.focus_index;
			win = self;
		}
	}
	if (maxidx > -1 && win != undefined)
		with(win) take_focus();
}

__reorder_focus_index = function(_old_idx) {
	with(RaptorWindow) {
		if (!eq(self, other) && __RAPTORDATA.focus_index > _old_idx)
			__RAPTORDATA.focus_index--;
	}
	// to avoid a (theoretically possible) endless loop here,
	// we stop after n iterations, where n = instance_number(RaptorWindow)
	var maxiter = instance_number(RaptorWindow);
	var curiter = 0;
	var have_doubles = true;
	while (have_doubles) {
		var seen = [];
		have_doubles = false;
		with(RaptorWindow) {
			if (!array_contains(seen, __RAPTORDATA.focus_index))
				array_push(seen, __RAPTORDATA.focus_index);
			else {
				have_doubles = true;
				__RAPTORDATA.focus_index--;
			}
		}
		// exit after n iterations
		if (++curiter == maxiter)
			break;
	}
	__RAPTORDATA.focus_index = instance_number(RaptorWindow) - 1;
	// last step: set the depth of the windows
	with(RaptorWindow) {
		
		depth = __RAPTORDATA.creation_depth - 3 * __RAPTORDATA.focus_index;
		if (__have_x_button && !is_null(__x_button)) 
			__x_button.depth = depth;
		if (!__in_destroy)
			control_tree.update_children_depth();
	}
	// -- debug output --
	//ilog($"[--- FOCUS INDEX REPORT START ---]");
	//with(RaptorWindow)
	//	ilog($"{__RAPTORDATA.creation_depth} {__RAPTORDATA.focus_index}: {MY_NAME}{(eq(self,other) ? " ** SELF **" : "")}");
	//ilog($"[--- FOCUS INDEX REPORT END   ---]");
}

lose_focus = function() {
	__RAPTORDATA.has_focus = false;
}

take_focus = function(_only_if_topmost = false) {
	if (__RAPTOR_WINDOW_FOCUS_CHANGE_RUNNING) 
		return;
	
	if (_only_if_topmost) {
		var allwins = ds_list_create();
		if (instance_position_list(CTL_MOUSE_X, CTL_MOUSE_Y, RaptorWindow, allwins, false) > 1) {
			var mindepth = DEPTH_BOTTOM_MOST;
			for (var i = 0, len = ds_list_size(allwins); i < len; i++) {
				var w = allwins[|i];
				with(w) if (__RAPTORDATA.has_focus) continue;
				mindepth = min(mindepth, w.depth);
			}
			ds_list_destroy(allwins);
			if (mindepth != depth)
				return;
		}
	}
	
	vlog($"Window {MY_NAME} taking focus");
	__RAPTOR_WINDOW_FOCUS_CHANGE_RUNNING = true;
	
	with(RaptorWindow) lose_focus();
	__RAPTORDATA.has_focus = true;
	__RAPTOR_FOCUS_WINDOW = self;
	var maxidx = instance_number(RaptorWindow) - 1;
	var myidx = (__RAPTORDATA.focus_index >= 0 ? __RAPTORDATA.focus_index : maxidx);
	__RAPTORDATA.focus_index = maxidx;
	__reorder_focus_index(myidx);
	// this mouse_is_over check is for the case, that a popup (like a MessageBox)
	// was visible on top of self. due to HIDDEN_BEHIND_POPUP, self would not register
	// a mouse_enter when the popup closes. This corrects the bool.
	
	mouse_is_over = point_in_rectangle(
		CTL_MOUSE_X, CTL_MOUSE_Y,
		SELF_VIEW_LEFT_EDGE, SELF_VIEW_TOP_EDGE, 
		SELF_VIEW_RIGHT_EDGE, SELF_VIEW_BOTTOM_EDGE);
		
	__RAPTOR_WINDOW_FOCUS_CHANGE_RUNNING = false;
}
if (!add_to_savegame || !SAVEGAME_LOAD_IN_PROGRESS)
	take_focus(); // we take focus on creation

#endregion

/// @func close()
close = function() {
	dlog($"{MY_NAME} closing");
	invoke_if_exists(self, "on_closing", self);
	__remove_self();
	control_tree.invoke_on_closed();
	control_tree.clear();
	instance_destroy(self);
}

/// @func					scribble_add_title_effects(titletext)
/// @desc				called when a scribble element is created to allow adding custom effects.
///								overwrite (redefine) in child controls
/// @param {struct} titletext
scribble_add_title_effects = function(titletext) {
	// example: titletext.blend(c_blue, 1); // where ,1 is alpha
}

on_client_area_changed = function() {
	__setup_drag_rect();
	control_tree.update_render_area();
}

update_client_area = function() {
	data.__raptordata.client_area.set(
		window_resize_border_width, 
		titlebar_height + window_resize_border_width / 2, 
		sprite_width - 2 * window_resize_border_width,
		sprite_height - titlebar_height - 1.5 * window_resize_border_width);
}

/// @func					__create_scribble_title_object(align, str)
/// @desc				setup the initial object to work with
/// @param {string} align			
/// @param {string} str			
__create_scribble_title_object = function(align, str) {
	return scribble(string_concat(align, str), MY_NAME)
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
				mouse_is_over ? title_color_mouse_over : title_color);
}

/// @func					__finalize_scribble_title()
/// @desc				add blend and transforms to the final text
__finalize_scribble_title = function() {
	if (__force_redraw_text_only) {
		__scribble_title
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
							 mouse_is_over ? title_color_mouse_over : title_color);
	}
	scribble_add_title_effects(__scribble_title);
}

/// @func					__draw_self()
/// @desc				invoked from draw or drawGui
__draw_self = function() {
	var was_forced = __force_redraw;
	
	if (__CONTROL_NEEDS_LAYOUT || __last_title != title || __first_draw) {
		__force_redraw = false;

		__scribble_title = (__CONTROL_TITLE_CHANGED ? __create_scribble_title_object(scribble_title_align, title) : __scribble_title);
		__finalize_scribble_title();

		__scribble_text = (__CONTROL_TEXT_CHANGED ? __create_scribble_object(scribble_text_align, text) : __scribble_text);
		__finalize_scribble_text();
		__text_width	= __scribble_text.get_width();
		__text_height	= __scribble_text.get_height();
		
		var nineleft = 0, nineright = 0, ninetop = 0, ninebottom = 0, distx = 0, disty = 0;
		var nine = -1;
		if (sprite_index != -1) {
			nine = sprite_get_nineslice(sprite_index);
			if (nine != -1) {
				nineleft = nine.left;
				nineright = nine.right;
				ninetop = nine.top;
				ninebottom = nine.bottom;
			}

			distx = nineleft + nineright;
			disty = ninetop + ninebottom;
			image_xscale = max(__startup_xscale, (max(min_width, max(__scribble_text.get_width(),  __scribble_title.get_width()))  + distx) / sprite_get_width(sprite_index));
			image_yscale = max(__startup_yscale, (max(min_height,max(__scribble_text.get_height(), __scribble_title.get_height())) + disty) / sprite_get_height(sprite_index));

			__setup_drag_rect();
			edges.update(nine);
			nine_slice_data.set(nineleft, ninetop, sprite_width - distx, sprite_height - disty);
		} else {
			// No sprite - update edges by hand
			edges.left = x;
			edges.top = y;
			edges.width  = text != "" ? __scribble_text.get_width() : 0;
			edges.height = text != "" ? __scribble_text.get_height() : 0;
			edges.right = edges.left + edges.width - 1;
			edges.bottom = edges.top + edges.height - 1;
			edges.center_x = x + edges.width / 2;
			edges.center_y = y + edges.height / 2;
			edges.copy_to_nineslice();
		}
		
		__text_x = edges.ninesliced.center_x + text_xoffset;
		__text_y = edges.ninesliced.center_y + text_yoffset;
		// text offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_text_align) != 0) __text_x = edges.ninesliced.left   + text_xoffset;
		else if (string_pos("[fa_right]",  scribble_text_align) != 0) __text_x = edges.ninesliced.right  - text_xoffset;
		if      (string_pos("[fa_top]",    scribble_text_align) != 0) __text_y = edges.ninesliced.top    + text_yoffset;
		else if (string_pos("[fa_bottom]", scribble_text_align) != 0) __text_y = edges.ninesliced.bottom - text_yoffset;

		__title_x = SELF_VIEW_CENTER_X + title_xoffset;
		__title_y = SELF_VIEW_TOP_EDGE + titlebar_height / 2 + title_yoffset; // title aligned to titlebar_height by default
		// title offset behaves differently when right or bottom aligned
		if      (string_pos("[fa_left]",   scribble_title_align) != 0) __title_x = edges.ninesliced.left   + title_xoffset;
		else if (string_pos("[fa_right]",  scribble_title_align) != 0) __title_x = edges.ninesliced.right  - title_xoffset;
		if      (string_pos("[fa_top]",    scribble_title_align) != 0) __title_y = SELF_VIEW_TOP_EDGE      + title_yoffset;
		else if (string_pos("[fa_bottom]", scribble_title_align) != 0) __title_y = titlebar_height         - title_yoffset;

		__last_text				= text;
		__last_sprite_index		= sprite_index;
		__last_sprite_width		= sprite_width;
		__last_sprite_height	= sprite_height;
		__last_title			= title;
		
		update_client_area();
		if (__have_x_button) 
			with(__x_button) update_position();
	} else {
		__finalize_scribble_title();
		__finalize_scribble_text();
	}

	if (was_forced || __CONTROL_DRAWS_SELF)
		__draw_instance();
}

__draw_instance = function(_force = false) {
	
	update_client_area();
	if (!visible) return;

	if (sprite_index != -1) {
		image_blend = animated_draw_color;
		draw_self();
		
		if (__RAPTORDATA.has_focus && __can_draw_focus)
			draw_sprite_ext(sprite_index, image_index + 1, x, y, image_xscale, image_yscale, image_angle, focus_border_color, image_alpha);
		if (!is_null(__x_button)) with(__x_button) {
			__draw_self();
		}
	}
	
	if (text  != "") __scribble_text .draw(__text_x,  __text_y );
	if (title != "") __scribble_title.draw(__title_x, __title_y);

	if (__first_draw || _force) {
		control_tree.layout();
		invoke_if_exists(self, "on_opening", self);
	}

	control_tree.draw_children();
	
	if (__first_draw) {
		__first_draw = false;
		control_tree.invoke_on_opened();
		// unlock mouse events for all children
		run_delayed(self, 1, function() {
			with (_baseContainerControl)
				if (get_window() == other) __mouse_events_locked = false;
		});
	}
	
	// this code draws the client area in red, if one day there's a bug with alignment
	//draw_set_color(c_red);
	//draw_rectangle(x+data.__raptordata.client_area.left, y+data.__raptordata.client_area.top, x+data.__raptordata.client_area.get_right(), y+data.__raptordata.client_area.get_bottom(), true);
	
	//draw_set_color(c_yellow);
	//draw_rectangle(control_tree.render_area.left, control_tree.render_area.top, control_tree.render_area.get_right(), control_tree.render_area.get_bottom(), true);
	
	//draw_set_color(c_white);
}