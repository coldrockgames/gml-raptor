/// @desc scribblelize text

#macro __CONTROL_NEEDS_LAYOUT (__force_redraw || x != xprevious || y != yprevious || \
							__last_text != text || sprite_index != __last_sprite_index || \
							sprite_width != __last_sprite_width || sprite_height != __last_sprite_height)

#macro __CONTROL_TEXT_CHANGED (__scribble_text == undefined || __last_text != text)

#macro __CONTROL_DRAWS_SELF (control_tree_layout == undefined || \
							(control_tree != undefined && control_tree.parent_tree == undefined))

event_inherited();
// UI Controls render in a different color
DEBUG_FRAME_COLOR = c_orange;

gui_mouse = new GuiMouseTranslator();
mouse_is_over = false;
__mouse_text_scale = 1.0;
__mouse_events_locked = false; // if rendered in a container, container draws first

edges = new Edges(self);
nine_slice_data = new Rectangle(0, 0, sprite_width, sprite_height);

control_tree = vsgetx(self, "control_tree", undefined);
control_tree_layout = vsgetx(self, "control_tree_layout", undefined);
data.__raptordata.client_area = new Rectangle(0, 0, sprite_width, sprite_height);

/// @func	get_gui_world_offset(_coord2 = undefined)
/// @desc	if this control draws on gui, you can get the offset
///			between gui position and current room position (camera)
///			of this control.
///			To do something on the world/room position of this control,
///			do it at x + offset.x
get_gui_world_offset = function(_coord2 = undefined) {
	var rv = _coord2 ?? new Coord2();
	if (SELF_DRAW_ON_GUI) translate_gui_to_world(x, y, rv).add(-x, -y);
	else rv.set(0, 0);
	return rv;
}

/// @func	get_gui_world_offset_x()
/// @desc	x offset only, see get_gui_world_offset() description
get_gui_world_offset_x = function() {
	return SELF_DRAW_ON_GUI ? translate_gui_to_world_x(x) - x : 0;
}

/// @func	get_gui_world_offset_y()
/// @desc	y offset only, see get_gui_world_offset() description
get_gui_world_offset_y = function() {
	return SELF_DRAW_ON_GUI ? translate_gui_to_world_y(y) - y : 0;
}

/// @func update_client_area()
update_client_area = function() {
	data.__raptordata.client_area.set(0, 0, sprite_width, sprite_height);
}

/// @func set_startup_size()
/// @desc Set the initial size of the control based on the max value of
///				 startup_width/height, min_width/height and designer width/height (room editor)
set_startup_size = function() {
	if (sprite_index == -1) return;
	scale_sprite_to(
		max(startup_width , sprite_width , min_width),
		max(startup_height, sprite_height, min_height)
	);
}

/// @func set_client_area(_width, _height, _is_also_min_size = true)
set_client_area = function(_width, _height, _is_also_min_size = true) {
	scale_sprite_to(_width, _height);
	if (_is_also_min_size) {
		min_width = sprite_width;
		min_height = sprite_height;
	}
	update_startup_coordinates();
	update_client_area();
	force_redraw();
	on_client_area_changed();
}

/// @func on_client_area_changed()
on_client_area_changed = function() {}

/// @func update_startup_coordinates()
/// @desc Invoke this if you did create the control dynamically at runtime 
///				 to set the current position as the startup position after placing it in the scene
update_startup_coordinates = function() {
	__startup_x			= x;
	__startup_y			= y;
	__startup_xscale	= image_xscale;
	__startup_yscale	= image_yscale;
	__startup_mycenterx	= SELF_VIEW_CENTER_X;
	__startup_mycentery	= SELF_VIEW_CENTER_Y;
	__startup_myright	= SELF_VIEW_RIGHT_EDGE;
	__startup_mybottom	= SELF_VIEW_BOTTOM_EDGE;
}
set_startup_size();
update_startup_coordinates();

__last_sprite_index				= undefined;
__last_sprite_width				= sprite_width;
__last_sprite_height			= sprite_height;
__last_text						= "";
__scribble_text					= undefined;
__text_x						= 0;
__text_y						= 0;
__text_width					= 0;
__text_height					= 0;
__text_anim_running				= false;
__text_transform_running		= false;
animated_text_color				= text_color;
animated_draw_color				= draw_color;

__first_scribble_render			= true;
__force_redraw					= true;	 // first draw is forced
__force_redraw_text_only		= false; // flag for mouse_enter/leave event which just trigger coloring

__disabled_text_surface			= undefined;
__disabled_text_surface_width	= 0;
__disabled_text_surface_height	= 0;
__disabled_text_offset_x		= 0;
__disabled_text_offset_y		= 0;
__disabled_text_backup_x		= 0;
__disabled_text_backup_y		= 0;

__animate_draw_color = function(_to) {
	if (__first_scribble_render || color_anim_frames <= 0) {
		animated_draw_color = _to;
		return;
	}

	animation_abort(self, "__raptor_draw_color_anim", false);
	animation_run(self, 0, color_anim_frames, __raptorAcControlColorAnim,,,{
			fromcol: animated_draw_color,
			tocol: _to
		})
		.set_name("__raptor_draw_color_anim")
		.set_function("anim_draw", function(value) {
			owner.animated_draw_color = merge_color(data.fromcol, data.tocol, value);
		})
		.add_finished_trigger(function(_data) {
			animated_draw_color = _data.tocol;
		});
}

__animate_text_color = function(_to) {
	if (color_anim_frames == 0) {
		animated_text_color = _to;
		return;
	}
	
	__text_anim_running = true;
	animation_abort(self, "__raptor_text_color_anim", false);
	animation_run(self, 0, color_anim_frames, __raptorAcControlColorAnim,,,{
			fromcol: animated_text_color,
			tocol: _to
		})
		.set_name("__raptor_text_color_anim")
		.set_function("anim_draw", function(value) {
			owner.animated_text_color = merge_color(data.fromcol, data.tocol, value);
		})
		.add_finished_trigger(function(_data) {
			animated_text_color = _data.tocol;
			__text_anim_running = false;
		});
}

__animate_text_transform = function(_to_size, _to_angle) {
	var _sizediff = _to_size - __mouse_text_scale;
	var _anglediff = _to_angle - text_angle;
	if (color_anim_frames == 0 || (_sizediff == 0 && _anglediff == 0)) {
		__mouse_text_scale = _to_size;
		text_angle = _to_angle;
		return;
	}
	
	__text_transform_running = true;
	animation_abort(self, "__raptor_text_transform_anim", false);
	animation_run(self, 0, color_anim_frames, __raptorAcControlColorAnim,,,{
			sizediff:	_sizediff,
			fromsize:	__mouse_text_scale,
			tosize:		_to_size,
			anglediff:	_anglediff,
			fromangle:	text_angle,
			toangle:	_to_angle
		})
		.set_name("__raptor_text_transform_anim")
		.set_function("anim_draw", function(value) {
			owner.__mouse_text_scale = data.fromsize + value * data.sizediff;
			owner.text_angle = data.fromangle + value * data.anglediff;
		})
		.add_finished_trigger(function(_data) {
			__mouse_text_scale = _data.tosize;
			__text_transform_running = false;
		});
}

cleanup_disabled_text_surface = function() {
	if (__disabled_text_surface == undefined) return;
	
	__disabled_text_surface.Free();
	__disabled_text_surface			= undefined;
	__disabled_text_surface_width	= 0;
	__disabled_text_surface_height	= 0;
}

__container = undefined; // if this is part of a window, it's the parent container
/// @func get_window()
/// @desc If this control is embedded in a window, this function returns
///				 the window instance, otherwise undefined
get_window = function() {
	if (__container != undefined)
		return __container.control_tree.get_root_control();
	return undefined;
}

/// @func is_window_hidden()
/// @desc If this control is embedded in a window, this function returns
///			the window's LAYER_OR_OBJECT_HIDDEN state 
is_window_hidden = function() {
	var w = get_window();
	if (w != undefined && w != self) {
		with(w)
			return __LAYER_OR_OBJECT_HIDDEN;
	}
	return false;
}

/// @func get_window_tree()
/// @desc If this control is embedded in a window, this function returns
///				 the root tree of the control hierarchy
get_window_tree = function() {
	if (__container != undefined)
		return __container.control_tree.__root_tree;
	return undefined;
}

/// @func get_parent()
/// @desc If this control is embedded in a control tree, this function returns
///				 the parent control of this one (i.e. a Panel or something similar)
get_parent = function() {
	if (__container != undefined)
		return __container;//.control_tree.control;
	return undefined;
}

/// @func get_parent_tree()
/// @desc If this control is embedded in a control tree, this function returns
///				 the parent control tree of this one
get_parent_tree = function() {
	if (__container != undefined)
		return __container.control_tree;//.parent_tree;
	return undefined;
}

#region ScrollPanel integration
__scrollpanel_over_cache = new ExpensiveCache(3);
__scrollpanel_cache = new ExpensiveCache(6);
/// @func get_parent_scrollpanel()
/// @desc If this control (or any of its parents) is embedded in a ScrollPanel, this function returns
///		  the ScrollPanel or undefined
get_parent_scrollpanel = function() {
	if (__scrollpanel_cache.is_valid())
		return __scrollpanel_cache.return_value;
		
	var rv = parent_scrollpanel;
	var up = self;
	var pa = undefined;
	while (rv == undefined) {
		pa = up.get_parent();
		if (pa == undefined || up == pa) break;
		up = pa;
		rv = up.parent_scrollpanel;
	}
	return __scrollpanel_cache.set(rv);
}

/// @func	is_mouse_over_my_scrollpanel_content()
/// @desc	Returns true, if this control is not embedded in a ScrollPanel OR it IS embedded AND 
///			the mouse is currently inside the clipping area of this scroll panel
///			(used in _generic_macros_ for mouse events of child controls in a scrollpanel)
is_mouse_over_my_scrollpanel_content = function() {
	if (__scrollpanel_over_cache.is_valid())
		return __scrollpanel_over_cache.return_value;
		
	var sp = get_parent_scrollpanel();
	return __scrollpanel_over_cache.set(sp == undefined || sp.mouse_over_content());
}
#endregion

/// @func is_topmost()
/// @desc True, if this control is the topmost (= lowest depth) at the specified position
///				 NOTE: This is an override of the method in _raptorBase, which compares against _raptorBase!
///				 This method here shall only check controls (_baseControl) to be more specific in finding topmost

__topmost_list = ds_list_create();
__topmost_cache = new ExpensiveCache();
is_topmost = function(_x, _y) {
	if (__topmost_cache.is_valid()) 
		return __topmost_cache.return_value;
		
	ds_list_clear(__topmost_list);
	__topmost_count = instance_position_list(_x, _y, _baseControl, __topmost_list, true);
	if (__topmost_count > 0) {
		__topmost_mindepth = depth;
		__topmost_runner = undefined;
		for (var i = 0; i < __topmost_count; i++) {
			__topmost_runner = __topmost_list[|i];
			if (vsget(__topmost_runner, "draw_on_gui", false) != draw_on_gui || !__can_touch_this(__topmost_runner)) 
				continue;
			__topmost_mindepth = min(__topmost_mindepth, __topmost_runner.depth);
		}
		return __topmost_cache.set(__topmost_mindepth == depth);
	}
	return __topmost_cache.set(true);
}

/// @func __mouse_enter_topmost_control()
/// @desc Private function invoked from the mouse_leave event
///				 to find other controls at that mouse position and let
///				 the topmost of them receive the enter event
__mouse_enter_topmost_control = function() {
	var have_one = false;
	
	ds_list_clear(__topmost_list);
	if (instance_position_list(CTL_MOUSE_X, CTL_MOUSE_Y, _baseControl, __topmost_list, false) > 0) {
		// pass 1: find topmost depth at this position
		var mindepth = DEPTH_BOTTOM_MOST;
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			if (!__can_touch_this(w)) continue;
			if (!eq(w, self))
				mindepth = min(mindepth, w.depth);
		}
		// pass 2: launch the mouse enter event on all the topmost's
		for (var i = 0, len = ds_list_size(__topmost_list); i < len; i++) {
			var w = __topmost_list[|i];
			if (!__can_touch_this(w)) continue;
			if (w.depth == mindepth && !w.mouse_is_over) {
				with(w) {
					vlog($"{MY_NAME}: onMouseEnter (topmost)");
					mouse_is_over = true;
					__animate_draw_color(draw_color_mouse_over);
					__animate_text_color(text_color_mouse_over);
					force_redraw(false);
					have_one = true;
					break;
				}
			}
		}
	} 
	if (!have_one)
		vlog($"{MY_NAME}: onMouseLeave");
}

onSkinChanged = function(_skindata) {
	_baseControl_onSkinChanged(_skindata);
}
// Hold a reference to the base skin change code 
// for all derived controls
/// @func	_baseControl_onSkinChanged(_skindata, _before_update_coordinates = undefined)
_baseControl_onSkinChanged = function(_skindata, _before_update_coordinates = undefined) {
	animated_text_color = text_color;
	animated_draw_color = draw_color;
	set_startup_size();
	if (_before_update_coordinates != undefined)
		_before_update_coordinates(_skindata);
	update_startup_coordinates();
	force_redraw();	
}

/// @func					force_redraw(_redraw_all = true)
/// @desc				force recalculate of all positions next frame
force_redraw = function(_redraw_all = true) {
	__force_redraw = _redraw_all;
	__force_redraw_text_only = !_redraw_all;
	return self;
}

/// @func					scribble_add_text_effects(scribbletext)
/// @desc				called when a scribble element is created to allow adding custom effects.
///								overwrite (redefine) in child controls
/// @param {struct} scribbletext
scribble_add_text_effects = function(scribbletext) {
	// example: scribbletext.blend(c_blue, 1); // where ,1 is alpha
}

/// @func					draw_scribble_text()
/// @desc				draw the text - redefine for additional text effects
draw_scribble_text = function() {
	if (__scribble_text != undefined)
		__scribble_text.draw(__text_x, __text_y);
}

/// @func					__create_scribble_object(align, str)
/// @desc				setup the initial object to work with
/// @param {string} align			
/// @param {string} str			
__create_scribble_object = function(align, str) {
	return scribble(string_concat(align, str), MY_NAME)
			.starting_format(
				font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
				animated_text_color)
			.outline(outline_color)
			.shadow(shadow_color, shadow_alpha);
}

/// @func					__adopt_object_properties()
/// @desc				copy blend, alpha, scale and angle from the object to the text
__adopt_object_properties = function() {	
	if (adopt_object_properties == adopt_properties.alpha ||
		adopt_object_properties == adopt_properties.full) {
		__scribble_text.blend(image_blend, image_alpha);
	}
	if (adopt_object_properties == adopt_properties.full) {
		__scribble_text.transform(image_xscale, image_yscale, image_angle);
	}
}

/// @func					__finalize_scribble_text()
/// @desc				add blend and transforms to the final text
__finalize_scribble_text = function() {
	if (__force_redraw_text_only || __text_anim_running || __text_transform_running || __first_scribble_render) {
		__first_scribble_render = false;
		__scribble_text
			.starting_format(font_to_use == "undefined" ? scribble_font_get_default() : font_to_use, 
							 animated_text_color);
		__force_redraw_text_only = false;
		__scribble_text.transform(__mouse_text_scale, __mouse_text_scale, text_angle);
	}
	
	if (adopt_object_properties != adopt_properties.none)
		__adopt_object_properties();
	scribble_add_text_effects(__scribble_text);
}

/// @func __apply_autosize_alignment()
/// @desc if autosize, this calculates the real text position
__apply_autosize_alignment = function() {
	if		(string_contains(scribble_text_align, "[fa_center]")) x = __startup_mycenterx - sprite_width  / 2;
	else if (string_contains(scribble_text_align, "[fa_right]" )) x = __startup_myright	  - sprite_width;
	if		(string_contains(scribble_text_align, "[fa_middle]")) y = __startup_mycentery - sprite_height / 2;
	else if (string_contains(scribble_text_align, "[fa_bottom]")) y = __startup_mybottom  - sprite_height;	
}

/// @func __apply_post_positioning()
/// @desc invoked after text-positioning is calculated.
///				 if the control renders additional elements (checkbox, radio, etc)
///				 you can modify __text_x and __text_y in this function to finalize text positioning
__apply_post_positioning = function() {
}

/// @func					__draw_self()
/// @desc				invoked from draw or drawGui
__draw_self = function() {
	var was_forced = __force_redraw;
		
	if (__CONTROL_NEEDS_LAYOUT) {
		__force_redraw = false;

		if (x != xprevious || y != yprevious) 
			update_startup_coordinates();

		if (sprite_index == -1)
			word_wrap = false; // no wrapping on zero-size objects
		
		if (__CONTROL_TEXT_CHANGED || was_forced) {
			if (__disabled_text_surface != undefined) 
				cleanup_disabled_text_surface();
			__scribble_text = __create_scribble_object(scribble_text_align, text);
		}
		
		__finalize_scribble_text();
		__text_width	= __scribble_text.get_width();
		__text_height	= __scribble_text.get_height();

		var nineleft = 0, nineright = 0, ninetop = 0, ninebottom = 0;
		var nine = -1;
		if (sprite_index != -1 && sprite_index != noone) {
			nine = sprite_get_nineslice(sprite_index);
			if (nine != -1 && nine.enabled) {
				nineleft	= nine.left;
				nineright	= nine.right;
				ninetop		= nine.top;
				ninebottom	= nine.bottom;
			}
			var distx		= text_xoffset + nineleft + nineright;
			var disty		= text_yoffset + ninetop + ninebottom;
		
			if (autosize) {
				image_xscale = max(__startup_xscale, (max(min_width, __text_width)  + distx) / sprite_get_width(sprite_index));
				image_yscale = max(__startup_yscale, (max(min_height,__text_height) + disty) / sprite_get_height(sprite_index));
				__apply_autosize_alignment(distx, disty);
			}
			edges.update(nine);
			nine_slice_data.set(nineleft, ninetop, sprite_width - distx, sprite_height - disty);
			
		} else {
			// No sprite - update edges by hand
			edges.left = x;
			edges.top = y;
			edges.width  = text_xoffset + (text != "" ? __text_width : 0);
			edges.height = text_yoffset + (text != "" ? __text_height : 0);
			edges.right = edges.left + edges.width - 1;
			edges.bottom = edges.top + edges.height - 1;
			edges.center_x = x + edges.width / 2;
			edges.center_y = y + edges.height / 2;
			edges.copy_to_nineslice();
		}
		
		__text_x = edges.ninesliced.center_x + text_xoffset;
		__text_y = edges.ninesliced.center_y + text_yoffset;

		// text offset behaves differently when right or bottom aligned
		if      (string_contains(scribble_text_align, "[fa_left]"  )) __text_x = edges.ninesliced.left   + text_xoffset;
		else if (string_contains(scribble_text_align, "[fa_right]" )) __text_x = edges.ninesliced.right  - text_xoffset;
		if      (string_contains(scribble_text_align, "[fa_top]"   )) __text_y = edges.ninesliced.top    + text_yoffset;
		else if (string_contains(scribble_text_align, "[fa_bottom]")) __text_y = edges.ninesliced.bottom - text_yoffset;

		__apply_post_positioning();

		__last_text				= text;
		__last_sprite_index		= sprite_index;
		__last_sprite_width		= sprite_width;
		__last_sprite_height	= sprite_height;
		update_client_area();
		
	} else
		__finalize_scribble_text();

	if (was_forced || __CONTROL_DRAWS_SELF)
		__draw_instance(was_forced);
}

/// @func __draw_instance(_force = false)
__draw_instance = function(_force = false) {
	//update_client_area();
	if (!visible) return;
	
	if (sprite_index != -1) {
		if (is_enabled) {
			image_blend = animated_draw_color;
			draw_self();
		} else {
			shader_set(DisabledShader);
			draw_self();
			shader_reset();
		}
	}
	
	if (text != "") {
		if (is_enabled) {
			// cleanup so the next disable will create a new surface (contents might have changed)
			if (__disabled_text_surface != undefined) 
				cleanup_disabled_text_surface();
				
			draw_scribble_text();
		} else {
			if (__disabled_text_surface == undefined) {
				__text_transform_running = false;
				animation_abort_all(self);
				__scribble_text.transform(1, 1, text_angle);
				
				if (__disabled_text_surface_height == 0) {
					__disabled_text_surface_width = __scribble_text.get_width();
					__disabled_text_surface_height = __scribble_text.get_height();
				}
				__disabled_text_surface = new Canvas(
					__disabled_text_surface_width, 
					__disabled_text_surface_height);
				
				__disabled_text_offset_x = 0;
				__disabled_text_offset_y = 0;
				
				if      (string_contains(scribble_text_align, "[fa_center]")) __disabled_text_offset_x = __disabled_text_surface_width / 2;
				else if (string_contains(scribble_text_align, "[fa_right]" )) __disabled_text_offset_x = __disabled_text_surface_width;
				if      (string_contains(scribble_text_align, "[fa_middle]")) __disabled_text_offset_y = __disabled_text_surface_height / 2;
				else if (string_contains(scribble_text_align, "[fa_bottom]")) __disabled_text_offset_y = __disabled_text_surface_height;

				__disabled_text_backup_x = __text_x;
				__disabled_text_backup_y = __text_y;
				__text_x = __disabled_text_offset_x;
				__text_y = __disabled_text_offset_y;
				
				__disabled_text_surface.Start();
				draw_scribble_text();
				__disabled_text_surface.Finish();
				__text_x = __disabled_text_backup_x;
				__text_y = __disabled_text_backup_y;
			}

			shader_set(DisabledShader);
			__disabled_text_surface.Draw(__text_x - __disabled_text_offset_x, __text_y - __disabled_text_offset_y);
			shader_reset();
		}
	}
}

// These pointers hold a "copy" to the original __draw_self/__draw_instance functions, so any
// object deriving from this can still reach the original draw methods.
__basecontrol_draw_self		= __draw_self;
__basecontrol_draw_instance = __draw_instance;
