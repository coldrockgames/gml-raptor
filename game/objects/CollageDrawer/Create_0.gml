/// @desc methods
/*
	CollageDrawer helper object for the Canvas library by @tabularelf.
*/
event_inherited();

collage			= undefined;
sprite			= undefined;
image_count		= 1;
drawable		= false;

// animation timing
__time			= 0;
__time_step		= 0;
__sub_idx		= 0;
__sub_idx_prev	= 0;

/// @func	set_sprite(_collage_name, _sprite_name)
/// @desc	Assign a new sprite to use or undefined to clear.
///			This function requires a valid collage assigned.
set_sprite = function(_collage_name, _sprite_name) {
	if (collage == undefined || collage_name != _collage_name) {
		collage	= COLLAGE.get(collage_name);
		if(collage != undefined) 
			collage_name = _collage_name;
		else
			return;
	}
	
	sprite	= undefined;
	if (!string_is_empty(_sprite_name)) {
		sprite_name	= _sprite_name;
		sprite		= collage.GetImageInfo(sprite_name);
		if (sprite != undefined) {
			image_count	= sprite.GetCount();
			__time_step	= sprite.GetSpeed() > 0 ? (1000000 / sprite.GetSpeed()) : 0;
		}
	}
	
	drawable = (sprite != undefined);
};

/// @func __draw()
__draw = function() {
    if (sprite == undefined) return;  // Falls kein Sprite gesetzt wurde, nichts zeichnen.
	
	CollageDrawImageExt(
		sprite, 
		__sub_idx, 
		x, 
		y, 
		image_xscale, 
		image_yscale, 
		image_angle, 
		image_blend, 
		image_alpha
	);
}

__async_load_complete = function() {
	set_sprite(collage_name, sprite_name);
}

__async_load_complete(); // try to show immediately