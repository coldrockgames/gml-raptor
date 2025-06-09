/// @func					Rectangle(rect_left = 0, rect_top = 0, rect_width = 0, rect_height = 0)
/// @desc				define a rectangle as struct
/// @param {real=0} rect_left
/// @param {real=0} rect_top
/// @param {real=0} rect_width
/// @param {real=0} rect_height
/// @returns {struct}			
function Rectangle(rect_left = 0, rect_top = 0, rect_width = 0, rect_height = 0) constructor {
	construct(Rectangle);
	
	left = rect_left;
	top = rect_top;
	width = rect_width;
	height = rect_height;
	right = get_right();
	bottom = get_bottom();
	
	/// @func					get_right()
	/// @desc				right edge of the rectangle
	static get_right  = function() { return left + width - 1; }
	/// @func					get_bottom()
	/// @desc				bottom edge of the rectangle
	static get_bottom = function() { return top + height - 1; }	
	/// @func					get_diagonal()
	/// @desc				length of the diagonal
	static get_diagonal = function() { return sqrt(sqr(width) + sqr(height)); }
	/// @func					get_center_x()
	/// @desc				left + width / 2
	static get_center_x = function() { return left + width / 2; }
	/// @func					get_center_y()
	/// @desc				top + height / 2
	static get_center_y = function() { return top + height / 2; }
	
	/// @func					set(rect_left, rect_top, rect_width, rect_height)
	/// @desc				set all values in one go
	/// @param {real} rect_left
	/// @param {real} rect_top
	/// @param {real} rect_width
	/// @param {real} rect_height
	static set = function(rect_left, rect_top, rect_width, rect_height) {
		left = rect_left;
		top = rect_top;
		width = rect_width;
		height = rect_height;
		right = get_right();
		bottom = get_bottom();
	}

	/// @func				intersects_rect(other_rect)	
	/// @desc			Determines if the other_rect intersects at least with
	///							one corner with this rect
	/// @param {Rectangle} other_rect
	/// @returns {bool}			true if intersecting
	static intersects_rect = function(other_rect) {
		return rectangle_in_rectangle(
			left, top, left + width - 1, top + height - 1,
			other_rect.left, other_rect.top, 
			other_rect.left + other_rect.width - 1, 
			other_rect.top + other_rect.height - 1) > 0;
	}
	
	/// @func				intersects_point(xp, yp)	
	/// @desc			Determines if the xp/yp intersect this rect
	/// @param {real} xp
	/// @param {real} yp
	/// @returns {bool}			true if intersecting
	static intersects_point = function(xp, yp) {
		return point_in_rectangle(xp, yp, left, top, left + width - 1, top + height - 1);
	}
	
	toString = function() {
		return $"{left}/{top}; {width}x{height}";
	}
}