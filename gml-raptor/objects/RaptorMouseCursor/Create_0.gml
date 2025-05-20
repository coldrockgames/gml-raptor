/// @desc DOCS INSIDE!

/*
	There are two ways to work with the custom mouse cursor:
	1) Just drop it on *any* layer in your room (it will adapt its depth automatically)
	2) create an instance in code
	
	The MouseCursor will draw itself in the Draw_GUI_End event, so it is always drawn last.
	The depth will be set to 16000 (top most) upon creation but it will not be checked afterwards.
	If you tinker with the depth of the object it might be drawn below other UI elements, to best approach
	is, to not touch its depth at all.
	
	To change the cursor behavior at runtime:
	- Just assign it a new sprite, like you change any other object in your room
	- Adapt image_blend, scale, rotation freely, it's just a small object that draws at the mouse position,
	  there is no deeper logic behind, so feel free to do what you like with it.
	  
	COMPANION
	---------
	Sometimes, a cursor can have a companion (a second, smaller icon, most of the time displayed bottom-right of
	the mouse cursor). 
	To enable this, use the function set_companion(_sprite). To remove the companion, invoke clear_companion().
	
	NOTE: This will create a second object instance (MouseCursorCompanion) at the same depth of the mouse cursor!
	All animation rules of the sprite will execute, so you can even have animated companions!
	
	To fine control the position of the companion, adapt the companion_offset_x and companion_offset_y variable definitions.
	NOTE: This offset is IN ADDITION to the default position of "right edge, vertical center"!
	
	+-----+  <-- Mouse Cursor
	|     |
	|     +-----+  <-- Companion, vertically centered, at the right edge of the cursor
	|     |     |
	+-----+     |
	      |     |
		  +-----+

	The companion object is pooled, you don't have any performance issues with it, feel free to use it whenever you see fit.
	
	You can create a custom companion object (set MouseCursorCompanion as the parent) if you need more options, like Animations,
	blending or any other things, even particle effects are possible.
	To do this, set the companion_type (also a variable definition, so available at design time) of the mouse cursor to the type
	of object you want to be instantiated when a companion is created.
	
	COMPANION FUNCTIONS
	-------------------
	set_companion(_sprite, _type)	- create a default companion and assign the _sprite to it
									  NOTE: _type is by default undefined, so the setting of the companion_type is used.
	clear_companion()				- remove the companion object
	
*/

// This draw_on_gui here is fake! MouseCursor is *always* draw_on_gui, the
// flag is ignored in the draw cycle of this object.
// It exists for debugging purposes, if you activate debug object frames,
// so the frame drawer finds the cursor on the ui layer and draws a correct frame
draw_on_gui = true;

#macro __RAPTOR_MOUSE_COMPANION_POOL		"__raptor_mouse_companion_pool"

MOUSE_CURSOR			= self;

enum mouse_cursor_type {
	pointer, sizing
}

enum mouse_cursor_sizing {
	we, ns, nwse, nesw, pan
}

event_inherited();

window_set_cursor(cr_none);
// on top of everything else
depth = DEPTH_TOP_MOST;
visible = true;

companion = undefined;

__have_default		= true;
__custom			= undefined;
__now_over_debug	= false;
__prev_over_debug	= false;

onSkinChanging = function(_skindata) {
	__havedefault	= (sprite_index == mouse_cursor_sprite);
	__custom		= sprite_index;
}
 
onSkinChanged = function(_skindata) {
	sprite_index = (__havedefault ? mouse_cursor_sprite : __custom);	
}

__align_to_mouse = function() {
	
	__now_over_debug = global.__debug_shown && is_mouse_over_debug_overlay();
	if (__prev_over_debug != __now_over_debug) {
		__prev_over_debug = __now_over_debug;
		window_set_cursor(__now_over_debug ? cr_default : cr_none);
		visible = !__now_over_debug;
	}
	if (__now_over_debug)
		return;
	
	x = GUI_MOUSE_X;
	y = GUI_MOUSE_Y;

	if (companion != undefined) {
		companion.x = x + sprite_width + companion_offset_x + companion.sprite_xoffset;
		companion.y = y + sprite_height / 2 + companion_offset_y + companion.sprite_yoffset;
	}
}

/// @func set_cursor_custom(_cursor_sprite)
/// @desc	Sets any custom sprite to be the mouse cursor sprite.
///					This will also set "mouse_cursor_type.pointer".
///					To reset to the default pointer cursor, invoke set_cursor(mouse_cursor_type.pointer).
/// @param {sprite_index} _cursor_sprite	The sprite to set as the active mouse cursor
set_cursor_custom = function(_cursor_sprite) {
	sprite_index = _cursor_sprite;
	image_index = 0;
	_mouse_cursor_type = mouse_cursor_type.pointer;
}

/// @func	set_cursor_default()
/// @desc	Reset the mouse cursor to the default pointer sprite
set_cursor_default = function() {
	set_cursor(mouse_cursor_type.pointer);
}

/// @func set_cursor(_mouse_cursor_type, _mouse_cursor_sizing = 0)
set_cursor = function(_mouse_cursor_type, _mouse_cursor_sizing = 0) {
	sprite_index = (_mouse_cursor_type == mouse_cursor_type.pointer ? mouse_cursor_sprite : mouse_cursor_sprite_sizing);
	image_index = _mouse_cursor_sizing;
}

/// @func set_companion(_companion_sprite, _type = undefined)
set_companion = function(_companion_sprite, _type = undefined) {
	if (companion != undefined)
		pool_return_instance(companion);
	
	var typ = _type ?? companion_type;
	companion = pool_get_instance(__RAPTOR_MOUSE_COMPANION_POOL, typ, depth);
	companion.sprite_index = _companion_sprite ?? spr1pxTrans;
		
	return companion;
}

/// @func clear_companion(reset_blend_color = true)
clear_companion = function(reset_blend_color = true) {
	if (companion != undefined) {
		pool_return_instance(companion);
		companion = undefined;
	}
	if (reset_blend_color)
		image_blend = c_white;
}

/// @func destroy()
/// @desc remove this mouse cursor and restore default cursor
destroy = function() {
	window_set_cursor(cr_default);
	MOUSE_CURSOR = undefined;
	instance_destroy(self);
}