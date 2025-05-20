/// @func	SpriteDim(sprite)
/// @desc	Scan a sprite's width and height (asset dimensions)
/// @param {asset} sprite
function SpriteDim(sprite = -1) constructor {
	construct(SpriteDim);
	
	static empty_nineslice = {
		left: 0,
		top: 0,
		right: 0,
		bottom: 0,
		enabled: 0,
		tilemode: [0,0,0,0,0]
	};
	
	if (sprite != -1) {
		width			= sprite_get_width(sprite);
		height			= sprite_get_height(sprite);
		image_count		= sprite_get_info(sprite).num_subimages;
		center_x		= width / 2;
		center_y		= height / 2;
		origin_x		= sprite_get_xoffset(sprite);
		origin_y		= sprite_get_yoffset(sprite);
		nineslice		= sprite_get_nineslice(sprite);
		if (nineslice == -1)
			nineslice	= empty_nineslice;
	} else {
		width		= 1;
		height		= 1;
		image_count = 1;
		center_x	= 0.5;
		center_y	= 0.5;
		origin_x	= 0;
		origin_y	= 0;
		nineslice	= empty_nineslice;
	}

	toString = function() {
		return $"{width}x{height}";
	}
}

