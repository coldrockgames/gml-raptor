/// @func					Edges(obj)
/// @desc				Reads all the edges of an object, that is:
///								left, top, right, bottom, center x/y, width and height
///								based on the sprite of the object
/// @param {instance} obj
/// @returns {Edges}
function Edges(obj = undefined) constructor {
	construct(Edges);
	
	__inst = obj;
	
	left	 = 0;
	right	 = 0;
	top		 = 0;
	bottom	 = 0;
	center_x = 0;
	center_y = 0;
	width	 = 0;
	height	 = 0;
	
	// ninesliced sub-struct holds the same values but will contain the
	// renderable area only (everything inside the center rect of the nineslice)
	ninesliced = {
		left	 : 0,
		right	 : 0,
		top		 : 0,
		bottom	 : 0,
		center_x : 0,
		center_y : 0,
		width	 : 0,
		height	 : 0,
	};
	
	/// @func		update(nineslicedata = -1)
	/// @desc	re-read the properties of the object
	/// @param			nineslice struct as received from sprite_get_nineslice(...)
	static update = function(nineslicedata = -1) {
		if (__inst == undefined || nineslicedata == undefined)
			return;
			
		with (__inst) {
			other.left		= x - sprite_xoffset;
			other.top		= y - sprite_yoffset;
			other.right		= x + sprite_width  - 1 - sprite_xoffset;
			other.bottom	= y + sprite_height - 1 - sprite_yoffset;
			other.center_x	= x + sprite_width  / 2 - sprite_xoffset;
			other.center_y	= y + sprite_height / 2 - sprite_yoffset;
			other.width		= other.right - other.left + 1;
			other.height	= other.bottom - other.top + 1;

			var si = (sprite_index != -1 ? (nineslicedata != -1 ? nineslicedata : sprite_get_nineslice(sprite_index)) : -1);
			if ((si ?? -1) != -1 && si.enabled) {
				var nineleft = si.left;
				var ninetop = si.top;
				var nineright = si.right;
				var ninebottom = si.bottom;
				other.ninesliced.width		= sprite_width  - nineleft - nineright;
				other.ninesliced.height		= sprite_height - ninetop  - ninebottom;
				other.ninesliced.left		= other.left + nineleft;
				other.ninesliced.top		= other.top + ninetop;
				other.ninesliced.right		= other.right - nineright;
				other.ninesliced.bottom		= other.bottom - ninebottom;
				other.ninesliced.center_x	= x + other.ninesliced.width / 2 + nineleft;
				other.ninesliced.center_y	= y + other.ninesliced.height / 2 + ninetop;
			} else {
				other.ninesliced.width		= other.width;
				other.ninesliced.height		= other.height;
				other.ninesliced.left		= other.left;
				other.ninesliced.top		= other.top;
				other.ninesliced.right		= other.right;
				other.ninesliced.bottom		= other.bottom;
				other.ninesliced.center_x	= other.center_x;
				other.ninesliced.center_y	= other.center_y;				
			}
		}
	}
	
	/// @func		copy_to_nineslice()
	/// @desc	copy the edge data to the ninesliced substruct
	static copy_to_nineslice = function() {
		ninesliced.width	= width;
		ninesliced.height	= height;
		ninesliced.left		= left;
		ninesliced.top		= top;
		ninesliced.right	= right;
		ninesliced.bottom	= bottom;
		ninesliced.center_x	= center_x;
		ninesliced.center_y	= center_y;				
	}
	
	toString = function() {
		return $"Edges l/t/r/b={left}/{top}/{right}/{bottom}, w/h={width}/{height}, center={center_x}/{center_y}";
	}
	
	update();
}