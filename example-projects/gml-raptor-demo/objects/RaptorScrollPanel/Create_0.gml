/// @description create scrollbars
event_inherited();

enum mouse_drag {
	none,
	left,
	middle,
	right
}

__base_draw_instance = __draw_instance;

__get_scissor		= !IS_HTML;
__scissor			= undefined;
__vscroll			= { value: 0, value_percent: 0, min_value: 0, max_value: 100, is_enabled: true, shown_range: -1, last_range: -1, };
__hscroll			= { value: 0, value_percent: 0, min_value: 0, max_value: 100, is_enabled: true, shown_range: -1, last_range: -1, };
__ap_default		= [0, 0];		// app pos
__ap				= __ap_default;	// app pos
__aw				= 0;			// app width
__ah				= 0;			// app height
__clipw				= 0;
__cliph				= 0;
__drag_xmax			= 0;
__draw_ymax			= 0;
__mouse_delta		= 0;
__mouse_multi		= mouse_drag_inverted ? mouse_drag_multiplier : -mouse_drag_multiplier;
__scale_x			= 1;
__scale_y			= 1;
__html_y_flip		= 0;
__html_y_offset		= 0;
__html_y_sizing		= (__get_scissor ? 1 : -1);

__scrolldim			= new SpriteDim(object_get_sprite(Scrollbar));
__hbarsize			= (horizontal_scrollbar ? __scrolldim.height : 0);
__vbarsize			= (vertical_scrollbar ? __scrolldim.height : 0);
					
content				= undefined;
draw_method			= undefined

/// @func	set_content(_instance, _custom_draw_method = undefined)
/// @desc	sets the content instance for this scroll panel.
///			You may supply a method name in the instance to draw the
///			instance, if you have some custom draw mechanism.
///			If you don't specify one, GameMaker's "draw_self()"
///			method will be used to draw the clipped content.
///			By default, the "__draw_self()" of raptor's control classes
///			will be detected and invoked, you don't need to specify a
///			custom draw, when setting any raptor control as content.
set_content = function(_instance, _custom_draw_method = undefined) {
	if (!is_child_of(_instance, _baseControl)) {
		instance_destroy(_instance);
		throw("ScrollPanel accepts only raptor controls (child of _baseControl) as children!");
	}

	clear_content();
	content = _instance;
	draw_method = (_custom_draw_method ?? vsget(content, "__draw_self")) ?? draw_self;
	content.parent_scrollpanel = self;
	content.depth = depth + 1;
	return self;
}

/// @func	set_content_object(_object_type, _init_struct = undefined, _custom_draw_method = undefined)
/// @desc	Convenience shortcut to set the content through an object type
///			This method will call "instance_create" on the object type for you and supply the init struct.
set_content_object = function(_object_type, _init_struct = undefined, _custom_draw_method = undefined) {
	return set_content(instance_create(0,0,0, _object_type, _init_struct), _custom_draw_method);
}

/// @func	clear_content()
/// @desc	Removes the content object
clear_content = function() {
	if (content != undefined) {
		content.parent_scrollpanel = undefined;
		instance_destroy(content);
		content = undefined;
	}
	return self;
}

/// @func mouse_over_content()
/// @desc Determines, whether the mouse is currently over the clipping area
mouse_over_content = function() {
	return point_in_rectangle(
		CTL_MOUSE_X, CTL_MOUSE_Y,
		SELF_VIEW_LEFT_EDGE, 
		SELF_VIEW_TOP_EDGE,
		SELF_VIEW_LEFT_EDGE + __clipw * (draw_on_gui ? UI_CAM_TO_VIEW_FACTOR_X : 1) - 1, 
		SELF_VIEW_TOP_EDGE  + __cliph * (draw_on_gui ? UI_CAM_TO_VIEW_FACTOR_Y : 1) - 1
	);
}

__update_scroller = function(_inst, _by) {
	if (!instance_exists(_inst) || !_inst.is_enabled) return;
	_inst.value = clamp(_inst.value + _by, 0, 100);
	_inst.value_percent = (_inst.value - _inst.min_value) / _inst.max_value;
}

__draw_instance = function(_force = false) {
	if (!visible || is_null(content)) return;
	
	if (!__get_scissor) {
		// in html we have flipped y
		__html_y_flip	= (-y + 2 * __hbarsize) * __scale_y;
		__html_y_offset	= __hbarsize;
	}
	
	__clipw = sprite_width  - __vbarsize;
	__cliph = sprite_height - __hbarsize;
	
	__drag_xmax = content.sprite_width  - __clipw;
	__drag_ymax = content.sprite_height - __cliph;

	// how many % of the content size is the mouse delta?
	if (__mouse_delta) {
		drag_xoffset = clamp(drag_xoffset + CTL_MOUSE_DELTA_X * mouse_drag_multiplier, -__drag_xmax, 0);
		drag_yoffset = clamp(drag_yoffset + CTL_MOUSE_DELTA_Y * mouse_drag_multiplier, -__drag_ymax, 0);
		__hscroll.value_percent = (__drag_xmax > 0 ? (-drag_xoffset / __drag_xmax) : 0);
		__vscroll.value_percent = (__drag_ymax > 0 ? (-drag_yoffset / __drag_ymax) : 0);
		__hscroll.value = ceil(__hscroll.value_percent * 100);
		__vscroll.value = ceil(__vscroll.value_percent * 100);
	} else {
		drag_xoffset = -__drag_xmax * __hscroll.value_percent;
		drag_yoffset = -__drag_ymax * __vscroll.value_percent;
	}
	
	__hscroll.is_enabled = (__drag_xmax > 0);
	__vscroll.is_enabled = (__drag_ymax > 0);
	
	if (!__hscroll.is_enabled) { 
		drag_xoffset = __clipw / 2 - content.sprite_width  / 2;
	} else { 
		__hscroll.shown_range = sprite_width  / content.sprite_width;
		if (__hscroll.shown_range != __hscroll.last_range) {
			__hscroll.last_range = __hscroll.shown_range;
			__hscroll.calculate_knob_size();
		}
	}
	
	if (!__vscroll.is_enabled) { 
		drag_yoffset = __cliph / 2 - content.sprite_height / 2;
	} else { 
		__vscroll.shown_range = sprite_height / content.sprite_height;
		if (__vscroll.shown_range != __vscroll.last_range) {
			__vscroll.last_range = __vscroll.shown_range;
			__vscroll.calculate_knob_size();
		}
	}
	
	content.x = x + content.sprite_xoffset + drag_xoffset;
	content.y = y + content.sprite_yoffset + drag_yoffset;
	with(content)
		if (SELF_HAVE_MOVED && control_tree != undefined)
			control_tree.move_children(SELF_MOVE_DELTA_X, SELF_MOVE_DELTA_Y);

	// calculate scissor multiplier based on draw mode
	__ap = application_get_position();
	__aw			= __ap[2] - __ap[0] + 1;
	__ah			= __ap[3] - __ap[1] + __html_y_sizing;
	
	if (draw_on_gui) {
		__scale_x		= __aw / UI_VIEW_WIDTH ;
		__scale_y		= __ah / UI_VIEW_HEIGHT;
		__draw_x		= x * UI_VIEW_TO_CAM_FACTOR_X;
		__draw_y		= y * UI_VIEW_TO_CAM_FACTOR_Y;
		__clipw		   *= UI_VIEW_TO_CAM_FACTOR_X;
		__cliph		   *= UI_VIEW_TO_CAM_FACTOR_Y;
		//__cliph		   -= __html_y_offset;
	} else {
		__scale_x		= __aw / APP_SURF_WIDTH ;
		__scale_y		= __ah / APP_SURF_HEIGHT;
		__draw_x		= x;
		__draw_y		= y;
	}
	
	__base_draw_instance(_force);
	if (__get_scissor)
		__scissor = gpu_get_scissor();
	//dlog($"SCISSOR DEBUG: {(__draw_x * __scale_x + __ap[0])}/{(__draw_y * __scale_y + __ap[1])}, {ceil(__clipw * __scale_x)}x{ceil(__cliph * __scale_y)}");
	//dlog($"SCISSOR DEBUG: {__draw_x} * {__scale_x}, {__draw_y} * {__scale_y}");
	gpu_set_scissor(
		__draw_x * __scale_x + __ap[0], 
		(__draw_y - __html_y_offset) * __scale_y + __ap[1] + __html_y_flip, 
		ceil(__clipw * __scale_x), 
		ceil(__cliph * __scale_y)
	);
	with(content) {
		other.draw_method();
		//if (other.draw_method != undefined) other.draw_method(); else draw_self();
	}
	if (__get_scissor)
		gpu_set_scissor(__scissor.x, __scissor.y, __scissor.w, __scissor.h);
	else
		gpu_set_scissor(0, 0, GUI_RUNTIME_CONFIG.canvas_width, GUI_RUNTIME_CONFIG.canvas_height);
}

if (vertical_scrollbar)
	__vscroll = control_tree
	.add_control(Scrollbar, {
		last_range: -1,
		orientation_horizontal: false,
		startup_width: __vbarsize,
		startup_height: sprite_height - (horizontal_scrollbar ? __hbarsize : 0) + 1,
		wheel_scroll_lines: wheel_scroll_lines,
	})
	.set_align(fa_top, fa_right)
	.set_anchor(anchor.top | anchor.bottom)
	.set_name("vscroll")
	.get_instance()
	;

if (horizontal_scrollbar)
	__hscroll = control_tree
	.add_control(Scrollbar, {
		last_range: -1,
		orientation_horizontal: true,
		startup_width: sprite_width - (vertical_scrollbar ? __vbarsize : 0) + 1,
		startup_height: __hbarsize,
		wheel_scroll_lines: wheel_scroll_lines,
	})
	.set_align(fa_bottom, fa_left)
	//.set_anchor(anchor.left | anchor.right) // seems to not in html5...
	.set_name("hscroll")
	.get_instance()
	;
	
control_tree.build();
