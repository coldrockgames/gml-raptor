/*
    One entry of a sprite in a collage
*/

/// @func	CollageSprite(_collage, _name, _frame_count, _fps = 0, _tolerance = 0) 
/// @desc	tolerance is the alpha tolerance level for building the collision mask.
///			Its value ranges from 0..1
function CollageSprite(_collage, _name, _frame_count, _fps = 0, _tolerance = 0) constructor {
	construct(CollageSprite);
	
	collage			= _collage;
	name			= _name;
	spritesheet		= undefined;
	frame_count		= _frame_count;
	sprite_fps		= _fps;

	tolerance		= _tolerance;
	collision_mask	= array_create(frame_count, []); // TODO MASK CREATION

	frame_def		= undefined; // if in a spritesheet, we have a frames array
	collage_data	= undefined; // if from a sprite or file, we have original collage data

	// Add ourselves to the sprites collection of the collage manager
	COLLAGE.__sprites[$ _name] = self;

	/// @func	set_spritesheet(_spritesheet)
	static set_spritesheet = function(_spritesheet) {
		spritesheet = _spritesheet;
		return self;
	}
	
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
		if (spritesheet == undefined && frame_def == undefined && collage_data == undefined) {
			dlog($"Sprite '{name}' has no detailled frame information and can not build a collision mask");
			return;
		}
		if (collage_data != undefined)
			__mask_from_collage_data();
		else
			__mask_from_spritesheet();
	}

	static __mask_from_collage_data = function() {
		dlog($"Sprite '{name}' building mask from collage data");
		for (var i = 0, len = array_length(collision_mask); i < len; i++) {
			var mask = [];
			
			collision_mask[@i] = mask;
		}
	}
	
	static __mask_from_spritesheet = function() {
		dlog($"Sprite '{name}' building mask from spritesheet data");
		for (var i = 0, len = array_length(collision_mask); i < len; i++) {
			var mask = [];
			
			collision_mask[@i] = mask;
		}
	}

}