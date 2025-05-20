/*
    Contains transition classes that transfer from one room to another.
	There is a base class __RoomTransition common for all transitions.
	They are executed (depending on type of transition) in either one of the
	step events or in one of the draw events of the ROOMCONTROLLER.
	
	Transitions always have 2 parts: an "_out" part (ending the current room)
	and an "_in" part (showing the new room).
	Both parts are controlled by the ROOMCONTROLLER.
	The _out part is handled by the current ROOMCONTROLLER and the _in part
	from the new ROOMCONTROLLER in the next room.
*/


function __RoomTransition(_target_room, _need_fx_layer, _data = undefined) : DataBuilder() constructor {
	
	data			= _data ?? {};
	
	source_room		= room;
	target_room		= _target_room;
	need_fx_layer	= _need_fx_layer;
	
	in_step			= EMPTY_FUNC;
	in_draw			= EMPTY_FUNC;
	in_draw_gui		= EMPTY_FUNC;
	
	out_step		= EMPTY_FUNC;
	out_draw		= EMPTY_FUNC;
	out_draw_gui	= EMPTY_FUNC;

	fx				= undefined;
	frame_counter	= 0;

	draw_x			= 0;
	draw_y			= 0;
	draw_width		= CAM_WIDTH ;
	draw_height		= CAM_HEIGHT;

	static __create_fx_layer = function() {
		fx_layer = (need_fx_layer ? layer_create(ROOMCONTROLLER.depth + 1) : undefined);
		if (fx_layer != undefined && fx != undefined)
			layer_set_fx(fx_layer, fx);
	}

	static __destroy_fx_layer = function() {
		if (fx_layer != undefined && layer_exists(fx_layer))
			layer_destroy(fx_layer);
	}

	/// @func	do_transit()
	/// @desc	Perform transit to next room
	static do_transit = function() {
		dlog($"Out-Animation finished for transit to '{room_get_name(target_room)}'");
		__ACTIVE_TRANSITION_STEP = 1;
		frame_counter = 0;
		__destroy_fx_layer();
		if (target_room != room)
			room_goto(target_room);
	}

	/// @func	transit_finished()
	/// @desc	Call this, when transit is done
	static transit_finished = function() {
		dlog($"Transit to '{room_get_name(target_room)}' finished");
		ACTIVE_TRANSITION		 = undefined;
		__ACTIVE_TRANSITION_STEP = -1;
		TRANSITION_RUNNING = false;
		__destroy_fx_layer();
		with(ROOMCONTROLLER) onTransitFinished(other.data);
	}

	/// @func	get_app_canvas()
	/// @desc	Copy the app surface to a canvas
	static get_app_canvas = function() {
		var rv = new Canvas(APP_SURF_WIDTH, APP_SURF_HEIGHT);
		rv.Start();
		rv.CopySurface(application_surface, 0, 0);
		rv.Finish();
		return rv;
	}

	__create_fx_layer();
}

/// @func	FadeTransition(_target_room, _fade_out_frames, _fade_in_frames, _data = undefined) : __RoomTransition(_target_room, true, _data)
function FadeTransition(_target_room, _fade_out_frames, _fade_in_frames, _data = undefined) : __RoomTransition(_target_room, true, _data) constructor {
		
	fx = fx_create("_filter_tintfilter");
	layer_set_fx(fx_layer, fx);

	fade_out_frames = (_fade_out_frames > 0 ? _fade_out_frames : 1);
	fade_in_frames  = (_fade_in_frames > 0 ? _fade_in_frames : 1);
	
	running = 1;
	
	in_step = function() {
		running = clamp((frame_counter / fade_in_frames), 0, 1);
		fx_set_parameter(fx, "g_TintCol", [running, running, running, 1]);
		if (frame_counter >= fade_in_frames) {
			transit_finished();
		}
	}
	
	out_step = function() {
		running = clamp(1 - (frame_counter / fade_out_frames), 0, 1);
		fx_set_parameter(fx, "g_TintCol", [running, running, running, 1]);
		if (frame_counter >= fade_out_frames) {
			running = 0;
			do_transit();
		}
	}
	
	out_step();
}

/// @func	PixelateTransition(_target_room, _fade_out_frames, _fade_in_frames, _max_pixelation, _data = undefined) : __RoomTransition(_target_room, true, _data)
function PixelateTransition(_target_room, _fade_out_frames, _fade_in_frames, _max_pixelation, _data = undefined) : __RoomTransition(_target_room, true, _data) constructor {
	fx = fx_create("_filter_pixelate");
	layer_set_fx(fx_layer, fx);

	fade_out_frames = (_fade_out_frames > 0 ? _fade_out_frames : 1);
	fade_in_frames  = (_fade_in_frames > 0 ? _fade_in_frames : 1);
	max_pixelation  = _max_pixelation;
	
	running = 1;
	
	in_step = function() {
		running = clamp(1 - (frame_counter / fade_in_frames), 0, 1);
		fx_set_parameter(fx, "g_CellSize", max_pixelation * running);
		if (frame_counter >= fade_in_frames) {
			transit_finished();
		}
	}
	
	out_step = function() {
		running = clamp((frame_counter / fade_out_frames), 0, 1);
		fx_set_parameter(fx, "g_CellSize", max_pixelation * running);
		if (frame_counter >= fade_out_frames) {
			running = 0;
			do_transit();
		}
	}
	
	out_step();
}

/// @func	BlendTransition(_target_room, _blend_frames, _data = undefined) : __RoomTransition(_target_room, false, _data)
function BlendTransition(_target_room, _blend_frames, _data = undefined) : __RoomTransition(_target_room, false, _data) constructor {
	canvas = undefined;
	
	blend_frames = (_blend_frames > 0 ? _blend_frames : 1);
	running		 = 1;
	
	first_in	 = true;
	
	in_draw_gui = function() {
		if (first_in) {
			first_in = false;
			// we need to draw to the NEW camera!
			draw_width		= CAM_WIDTH ;
			draw_height		= CAM_HEIGHT;
		}
		
		running = clamp(1 - (frame_counter / blend_frames), 0, 1);
		canvas.DrawStretchedExt(draw_x, draw_y, draw_width, draw_height, c_white, running);
		if (frame_counter >= blend_frames) {
			canvas.Free();
			transit_finished();
		}
	}
	
	out_draw_gui = function() {
		canvas = get_app_canvas();
		do_transit();
	}
}

/// @func	SlideTransition(_target_room, _slide_frames, _animcurve, _data = undefined) : __RoomTransition(_target_room, false, _data)
function SlideTransition(_target_room, _slide_frames, _animcurve, _data = undefined) : __RoomTransition(_target_room, false, _data) constructor {
	source_canvas	= undefined;
	dest_canvas		= undefined;
	
	animcurve		= animcurve_get_ext(_animcurve);
	values			= animcurve.values;
	slide_frames	= _slide_frames;
	running			= 1;
					
	slide_frames	= _slide_frames;
	first_in		= true;
	
	have_x			= false;
	have_y			= false;
	
	in_draw_gui = function() {
		// a bit explanation here:
		// 1) why "frame_counter - 1" in the line below? Because surface in html is delayed 1 frame
		// 2) why "return" in first_in -> for the same reason, we need to skip 1 frame if html
		animcurve.update(max(frame_counter - 1, 0), slide_frames);
		
		if (first_in) {
			first_in = false;
			// we need to draw to the NEW camera!
			draw_width		= CAM_WIDTH ;
			draw_height		= CAM_HEIGHT;
			// 1 frame delay to have gms set up all surfaces in the new room
			// just draw the screenshot from previous room for 1 more frame
			source_canvas.DrawStretchedExt(0, 0, draw_width, draw_height, c_white, 1);
			return;
		}

		if (dest_canvas == undefined) {
			dest_canvas = get_app_canvas();
			have_x = animcurve.channel_exists("x");
			have_y = animcurve.channel_exists("y");
		}
		
		var srcx = draw_width  * (have_x ? values.x() : 0);
		var srcy = draw_height * (have_y ? values.y() : 0);
		var destx = (have_x ? draw_width  : 0); // start outside of the view
		var desty = (have_y ? draw_height : 0);

		if (srcx != 0 || srcy != 0) {
			// draw the new surface only if anything has changed (i.e. not in the first frame)
			if (srcx < 0) destx = srcx + draw_width; else
			if (srcx > 0) destx = srcx - draw_width;
			if (srcy < 0) desty = srcy + draw_height; else
			if (srcy > 0) desty = srcy - draw_height;
		}

		draw_clear_alpha(c_black, 0.0); // in case of an overshoot animation, make sure, the surface is cleared
		source_canvas.DrawStretchedExt(srcx, srcy, draw_width, draw_height, c_white, 1);
		dest_canvas.DrawStretchedExt(destx, desty, draw_width, draw_height, c_white, 1);
		
		if (frame_counter >= slide_frames) {
			source_canvas.Free();
			dest_canvas.Free();
			transit_finished();
		}
	}

	out_draw_gui = function() {
		source_canvas = get_app_canvas();
		do_transit();
	}
	
}