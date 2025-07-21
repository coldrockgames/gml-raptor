/*
    One entry of a sprite in a collage
*/

/// @func	CollageSprite(_collage, _name, _frame_count, _fps = 0) 
function CollageSprite(_collage, _name, _frame_count, _fps = 0) constructor {
	construct(CollageSprite);
	
	collage			= _collage;
	name			= _name;
	spritesheet		= undefined;
	frame_count		= _frame_count;
	sprite_fps		= _fps;

	// mask definition
	mask_sprite		= undefined;
	mask_per_frame	= false;
	mask_mode		= bboxmode_automatic; // automatic, gm-default, see gamemaker docs
	mask_type		= bboxkind_rectangular; // gm default
	mask_rect		= [0,0,0,0]; // we need right & bottom, don't use raptor Rectangle here
	tolerance		= 0;

	frame_size		= new Coord2();
	frame_def		= undefined; // if in a spritesheet, we have a frames array
	collage_data	= undefined; // if from a sprite or file, we have original collage data

	// Add ourselves to the sprites collection of the collage manager
	COLLAGE.__sprites[$ _name] = self;

	/// @func	set_spritesheet(_spritesheet)
	static set_spritesheet = function(_spritesheet) {
		spritesheet = _spritesheet;
		return self;
	}

	#region Collision Masks
	static __check_mask_not_precise = function(_shape) {
		if (_shape == bboxkind_precise)
			throw("To set a precise mask on a CollageSprite use set_mask_precise(...)!");
	}

	/// @func	set_mask_automatic(_shape = bboxkind_rectangular, _tolerance = 0) 
	/// @desc	Set automatic collision mask (gamemaker default)
	static set_mask_automatic = function(_shape = bboxkind_rectangular, _tolerance = 0) {
		__check_mask_not_precise();
		mask_per_frame	= false;
		mask_mode		= bboxmode_automatic;
		mask_rect		= [0,0,0,0];
		mask_type		= _shape;
		tolerance		= _tolerance;
		return self;
	}

	/// @func	set_mask_full_image(_shape = bboxkind_rectangular, _tolerance = 0) 
	/// @desc	Set a full-image mask with a shape
	static set_mask_full_image = function(_shape = bboxkind_rectangular, _tolerance = 0) {
		__check_mask_not_precise();
		mask_per_frame	= false;
		mask_mode		= bboxmode_fullimage; 
		mask_rect		= [0,0,0,0];
		mask_type		= _shape;
		tolerance		= _tolerance;
		return self;
	}
	
	/// @func	set_mask_manual(_left, _top, _right, _bottom, _shape = bboxkind_rectangular) 
	/// @desc	Set a manuel mask with border and shape
	static set_mask_manual = function(_left, _top, _right, _bottom, _shape = bboxkind_rectangular) {
		__check_mask_not_precise();
		mask_per_frame	= false;
		mask_mode		= bboxmode_manual; 
		mask_rect		= [_left, _top, _right, _bottom];
		mask_type		= _shape;
		return self;
	}

	/// @func	set_mask_precise(_per_frame = true, _tolerance = 0) 
	/// @desc	Set a precise mask, optionally per frame
	static set_mask_precise = function(_per_frame = true, _tolerance = 0) {
		mask_per_frame	= _per_frame;
		mask_mode		= bboxmode_manual; 
		mask_rect		= [0,0,0,0];
		mask_type		= bboxkind_precise;
		tolerance		= _tolerance;
		return self;
	}
	#endregion
	
	/// @func	set_collage_data(_collage_data)
	/// @desc	Assign original collage-filedata to this sprite
	static set_collage_data = function(_collage_data) {
		collage_data = _collage_data;
		return self;
	}
	
	/// @func	set_frame_def(_frame_def)
	/// @desc	Assign raptor format sheetdef data to this sprite
	static set_frame_def = function(_frame_def) {
		frame_def = _frame_def;
		return self;
	}
	
	/// @func	parent()
	static parent = function() {
		return collage;
	}

	/// @func	build()
	/// @desc	Builds the collision mask of the sprite
	static build = function() {		
		__build_collision_mask();
		return COLLAGE;
	}

	static __build_collision_mask = function() {
		if (IS_HTML) {
			// TODO: HTML-MASKS 
			wlog($"** WARNING ** Collision Masks not supported in HTML5 runtime!");
			return;
		}
		if (spritesheet != undefined) {
			mask_sprite = spritesheet.get_linear_sprite(name);
		} else if (collage_data != undefined) {
			mask_sprite = collage_data.__spriteID
		} else
			throw($"Sprite data error: Sprite '{name}' has neither collage data nor sprite sheet def!");

		dlog($"{MY_CLASS_NAME} '{name}' has mask sprite {mask_sprite}");
		frame_size.set(
			sprite_get_width (mask_sprite),
			sprite_get_height(mask_sprite),
		);

		sprite_collision_mask(
			mask_sprite,
			mask_per_frame,
			mask_mode,
			mask_rect[@0],mask_rect[@1],mask_rect[@2],mask_rect[@3],
			mask_type,
			tolerance * 255.0
		);
	}
}