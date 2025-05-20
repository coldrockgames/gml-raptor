/*
	Holds a 2D Coordinate pair (x,y)
*/

/// @func					Coord2(xp, yp)
/// @param {real} xp
/// @param {real} yp
/// @returns {Coord2}
function Coord2(xp = 0, yp = 0) constructor {
	construct(Coord2);
	
	set(xp, yp);
	
	/// @func	clone2()
	/// @desc	Clones this as Coord2
	static clone2 = function() {
		return new Coord2(x, y);
	}
	
	/// @func	set(xp, yp)
	/// @desc	set both values in one step
	/// @param {real} xp
	/// @param {real} yp
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static set = function(xp, yp) {
		x = xp;
		y = yp;
		return self;
	}
	
	/// @func	mul(factor_x, factor_y)
	/// @desc	multiply both values in one step
	/// @param {real} factor_x
	/// @param {real} factor_y
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static mul = function(factor_x, factor_y) {
		x *= factor_x;
		y *= factor_y;
		return self;
	}
	
	/// @func	mul_xy(factor)
	/// @desc	multiply both values in one step
	/// @param {real} factor
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static mul_xy = function(factor) {
		x *= factor;
		y *= factor;
		return self;
	}

	/// @func	plus(other_coord2)
	/// @desc	Add the values of other_coord2 into this one
	/// @param {Coord2} other_coord2
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static plus = function(other_coord2) {
		x += other_coord2.x;
		y += other_coord2.y;
		return self;
	}
	
	/// @func	minus(other_coord2)
	/// @desc	Subtract the values in other_coord2 from this one
	/// @param {Coord2} other_coord2
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static minus = function(other_coord2) {
		x -= other_coord2.x;
		y -= other_coord2.y;
		return self;
	}

	/// @func	add(add_x, add_y)
	/// @desc	add a value to the current values
	/// @param {real} add_x
	/// @param {real} add_y
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static add = function(add_x, add_y) {
		x += add_x;
		y += add_y;
		return self;
	}

	/// @func	add_xy(value)
	/// @desc	add the same value to the current values
	/// @param {real} value
	/// @returns {Coord2} self for command chaining (fluent syntax)
	static add_xy = function(value) {
		x += value;
		y += value;
		return self;
	}

	/// @func	length_xy()
	/// @desc	2D-hypotenuse
	/// @returns {real} length			
	static length_xy = function() { return sqrt(sqr(x) + sqr(y)); }
	
	/// @func	angle_xy()
	/// @desc	gets alpha (angle from horizontal to hypo). 0 degrees is right ccw
	static angle_xy = function() {
		return point_direction(0, 0, x, y);
	}
	
	/// @func	distance_to_coord2(other_Coord2)
	/// @desc	distance between two vectors
	/// @param {Coord2} other_Coord2
	/// @returns {Coord2}	new Coord2
	static distance_to_coord2 = function(other_coord2) {
		return point_distance(x, y, other_coord2.x, other_coord2.y);
	}
	
	/// @func	distance_to_xy(xp, yp)
	/// @desc	distance between vector and point
	/// @param {real} xp
	/// @param {real} yp
	/// @returns {Coord2}	new Coord2
	static distance_to_xy = function(xp, yp) { 
		return point_distance(x, y, xp, yp);
	}
	
	/// @func	equals_coord2(other_coord2)
	/// @desc	true, if both, x and y match	
	/// @returns {bool}			
	static equals_coord2 = function(other_coord2) {
		return (x == other_coord2.x) && (y == other_coord2.y);
	}
	
	/// @func	equals_xy(xp, yp)
	/// @desc	true, if both, x and y match	
	/// @returns {bool}			
	static equals_xy = function(xp, yp) {
		return (x == xp) && (y == yp);
	}
	
	toString = function() {
		return $"{x}/{y}";
	}
}
