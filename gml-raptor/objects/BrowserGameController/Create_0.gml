/// @desc Watch browser window size changes

event_inherited();

__active = IS_HTML;

curr_width = browser_width;
curr_height = browser_height;

//if (__active)
//	browser_scrollbars_enable();

/// @func					update_canvas()
/// @desc				Update the browser canvas
update_canvas = function() {
	if (!__active)
		return;
		
	curr_width = browser_width;
	curr_height = browser_height;

	var rw = browser_width;
	var rh = browser_height;

	var newwidth, newheight;
	var scale = min(rw / VIEW_WIDTH, rh / VIEW_HEIGHT);
	
	// find best-fit option
	newwidth = VIEW_WIDTH * scale;
	newheight = VIEW_HEIGHT * scale;
	if (newwidth > rw || newheight > rh) {
		scale = rh / VIEW_HEIGHT;
		newwidth = VIEW_WIDTH * scale;
		newheight = VIEW_HEIGHT * scale;
	}
	
	// resize application_surface, if needed
	if (application_surface_is_enabled()) {
		surface_resize(application_surface, newwidth, newheight);
	}

	// set window size to screen pixel size:
	var canvleft = rw / 2 - newwidth / 2;
	var canvtop = rh / 2 - newheight / 2;
	window_set_size(newwidth, newheight);
	window_set_position(canvleft, canvtop);

	// set canvas size to page pixel size:
	browser_stretch_canvas(newwidth, newheight);

	if (IS_HTML) {
		//GUI_RUNTIME_CONFIG.gui_scale_set(scale, scale);
		GUI_RUNTIME_CONFIG.canvas_left	 = canvleft;
		GUI_RUNTIME_CONFIG.canvas_top	 = canvtop;
		GUI_RUNTIME_CONFIG.canvas_width  = newwidth;
		GUI_RUNTIME_CONFIG.canvas_height = newheight;
	}
}

update_canvas();