/// @desc methods

/*
	CanvasDrawer helper object for the Canvas library by @tabularelf.
	Acts like a normal sprite object, but is based on a Canvas as image source.
	
	ABOUT THE ORIGIN
	The origin used here is based upon the number keypad on your keyboard!
	Just look at your keys, and you know, which number to use.
	1 = bottom left, 5 = middle center, 9 = top right ... got it?
	0 is used as "custom" origin. This is the only number where the additional
	parameters you see in the functions (origin_custom_x and origin_custom_y)
	are used.
	DEFAULT ORIGIN IS 7 (top left) which is also GameMaker default unless you changed that.
*/
event_inherited();

canvas			 = undefined;

__clone			 = undefined;
__subimages		 = [0];
__subimage_count = 1;
__subimage_width = canvas_width;
__time			 = 0;
__time_step		 = 0;
__sub_idx		 = 0;
__sub_idx_prev	 = 0;
__drawable		 = false;
__draw_origin_x	 = 0;
__draw_origin_y	 = 0;

/// @func __set_origin_offsets(origin, custom_x, custom_y)
__set_origin_offsets = function(origin, custom_x, custom_y) {
	canvas_origin			= origin;
	canvas_origin_custom_x	= custom_x;
	canvas_origin_custom_y	= custom_y;
	
	var w  = __subimage_width;
	var h  = canvas_height;
	var cx = w / 2;
	var cy = h / 2;
	
	switch (origin) {
		case 0:		
			__draw_origin_x = custom_x; 
			__draw_origin_y = custom_y; 
			break;
		case 1:		__draw_origin_x =  0; __draw_origin_y =  h; break;
		case 2:		__draw_origin_x = cx; __draw_origin_y =  h; break;
		case 3:		__draw_origin_x =  w; __draw_origin_y =  h; break;
		case 4:		__draw_origin_x =  0; __draw_origin_y = cy; break;
		case 5:		__draw_origin_x = cx; __draw_origin_y = cy; break;
		case 6:		__draw_origin_x =  w; __draw_origin_y = cy; break;
		case 7:		__draw_origin_x =  0; __draw_origin_y =  0; break;
		case 8:		__draw_origin_x = cx; __draw_origin_y =  0; break;
		case 9:		__draw_origin_x =  w; __draw_origin_y =  0; break;
		default:	__draw_origin_x =  0; __draw_origin_y =  0; break;
	}
}

/// @func __draw()
__draw = function() {
	if (__subimage_count == 1)
		canvas.Draw(x - __draw_origin_x, y - __draw_origin_y);
	else
		// _left, _top, _width, _height, _x, _y
		canvas.DrawPart(__subimages[@ __sub_idx], 0, __subimage_width, canvas_height, x - __draw_origin_x, y - __draw_origin_y);
}

/// @func create_canvas(width, height, origin = 7, origin_custom_x = 0, origin_custom_y = 0)
/// @desc Create a new Canvas instance. The method returns the created Canvas.
create_canvas = function(width, height, origin = 7, origin_custom_x = 0, origin_custom_y = 0) {
	
	free_canvas();
	
	canvas					= new Canvas(width, height, true);
	__drawable				= true;
	canvas_width			= width;
	canvas_height			= height;
	__set_origin_offsets(origin, origin_custom_x, origin_custom_y);
	
	return canvas;
}

/// @func free_canvas()
/// @desc Release the canvas
free_canvas = function() {
	if (__clone != undefined) {
		__clone.free();
		__clone = undefined;
		canvas  = undefined;
	} else if (canvas != undefined) {
		canvas.Free();
		canvas = undefined;
	}
	__drawable = false;
}

/// @func set_canvas(_canvas, origin = 7, origin_custom_x = 0, origin_custom_y = 0, _sub_image_count = 1, _animation_fps = 0)
/// @desc Assign an already existing canvas to this drawer.
///				 NOTE: If the _canvas supplied is not a valid Canvas instance, the entire function is ignored.
set_canvas = function(_canvas, origin = 7, origin_custom_x = 0, origin_custom_y = 0, _sub_image_count = 1, _animation_fps = 0) {
	if (CanvasIsCanvas(_canvas)) {	
		free_canvas();
		canvas = _canvas;
		__set_origin_offsets(origin, origin_custom_x, origin_custom_y);	
		__drawable = (canvas != undefined);
	}
}

/// @func set_animation(sub_image_count, frames_per_second)
/// @desc Set animation frames and speed
set_animation = function(sub_image_count, frames_per_second) {
	sub_images			= sub_image_count;
	animation_fps		= frames_per_second;
	__time_step			= animation_fps > 0 ? (1000000 / animation_fps) : 0;
	__subimages			= [];
	__subimage_count	= sub_image_count;
	
	__subimage_width = floor(canvas_width / sub_images);
	var xp = 0; repeat(sub_image_count) {
		array_push(__subimages, xp);
		xp += __subimage_width;
	}
}

/// @func clone_sprite(_sprite, _frame = -1)
/// @desc Clones a sprite asset into a surface and sets the subimages and animation 
///				 based on the sprite's data. Let frame be -1 to clone all frames or set a desired frame to clone
clone_sprite = function(_sprite, _frame = -1) {
	free_canvas();
	
	__clone			= sprite_to_canvas(_sprite, _frame);
	__drawable		= true;
	canvas			= __clone.canvas;
	canvas_width	= canvas.GetWidth();
	canvas_height	= canvas.GetHeight();
	
	__set_origin_offsets(0, sprite_get_xoffset(_sprite), sprite_get_yoffset(_sprite));
	set_animation(__clone.image_count, __clone.animation_fps);
	return canvas;
}

canvas = (canvas_width > 0 && canvas_height > 0) ? 
	create_canvas(canvas_width, canvas_height, canvas_origin, canvas_origin_custom_x, canvas_origin_custom_y) : 
	undefined;
