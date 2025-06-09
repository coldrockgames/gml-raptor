/// @desc pooling
event_inherited();

#macro __RAPTOR_SPRITE_ANIM_POOL		"__raptor_sprite_anims"

onPoolActivate = function(_data) {
	sprite_index	= -1;
	image_index		= vsget(_data, "image_index",  0		);
	image_angle		= vsget(_data, "image_angle",  0		);
	image_speed		= vsget(_data, "image_speed",  1		);
	image_alpha		= vsget(_data, "image_alpha",  1		);
	image_blend		= vsget(_data, "image_blend",  c_white	);
	image_xscale	= vsget(_data, "image_xscale", 1		);
	image_yscale	= vsget(_data, "image_yscale", 1		);
}

onPoolDeactivate = function(_data) {
	sprite_index = -1;
	image_index = 0;
}
