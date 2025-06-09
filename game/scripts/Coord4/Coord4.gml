/*
	Holds a 4D Coordinate (x,y,z,w)
*/

/// @func	Coord4(xp, yp, zp, wp)
/// @param {real} xp
/// @param {real} yp
/// @param {real} zp
/// @param {real} wp
/// @returns {Coord4}
function Coord4(xp = 0, yp = 0, zp = 0, wp = 0) : Coord3(xp, yp, zp) constructor {
	construct(Coord4);
	
	w = wp;

	/// @func	clone4()
	/// @desc	Clones this as Coord4
	static clone4 = function() {
		return new Coord4(x, y, z, w);
	}

	/// @func	set(xp, yp, zp, wp)
	/// @desc	set all values in one step
	/// @param {real} xp
	/// @param {real} yp
	/// @param {real} zp
	/// @param {real} wp
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static set = function(xp, yp, zp, wp) {
		x = xp;
		y = yp;
		z = zp;
		w = wp;
		return self;
	}

	/// @func	mul(factor_x, factor_y, factor_z, factor_w)
	/// @desc	multiply all values in one step
	/// @param {real} factor_x
	/// @param {real} factor_y
	/// @param {real} factor_z
	/// @param {real} factor_w
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static mul = function(factor_x, factor_y, factor_z, factor_w) {
		x *= factor_x;
		y *= factor_y;
		z *= factor_z;
		w *= factor_w;
		return self;
	}
	
	/// @func	mul_xyz(factor)
	/// @desc	multiply all values in one step
	/// @param {real} factor
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static mul_xyzw = function(factor) {
		x *= factor;
		y *= factor;
		z *= factor;
		w *= factor;
		return self;
	}

	/// @func	add(add_x, add_y, add_z, add_w)
	/// @desc	add a value to the current values
	/// @param {real} add_x
	/// @param {real} add_y
	/// @param {real} add_z
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static add = function(add_x, add_y, add_z, add_w) {
		x += add_x;
		y += add_y;
		z += add_z;
		w *= add_w;
		return self;
	}

	/// @func	add_xyz(value)
	/// @desc	add the same value to the current values
	/// @param {real} value
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static add_xyzw = function(value) {
		x += value;
		y += value;
		z += value;
		w += value;
		return self;
	}

	/// @func	plus(other_coord4)
	/// @desc	Add the values of other_coord4 into this one
	/// @param {Coord4} other_coord4
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static plus = function(other_coord4) {
		x += other_coord4.x;
		y += other_coord4.y;
		z += other_coord4.z;
		w += other_coord4.w;
		return self;
	}
	
	/// @func	minus(other_coord3)
	/// @desc	Subtract the values from other_coord4 in this one
	/// @param {Coord4} other_coord4
	/// @returns {Coord4} self for command chaining (fluent syntax)
	static minus = function(other_coord4) {
		x -= other_coord4.x;
		y -= other_coord4.y;
		z -= other_coord4.z;
		w -= other_coord4.w;
		return self;
	}

	/// @func	length_xyz()
	/// @desc	4D-hypotenuse
	/// @returns {real} length			
	static length_xyzw = function() { return sqrt(sqr(length_xyz()) + sqr(w)); }
	
	/// @func	distance_to_coord4(other_Coord4)
	/// @desc	distance between two vectors
	/// @param {Coord4} other_Coord4
	/// @returns {Coord4}	new Coord4
	static distance_to_coord4 = function(other_coord4) {
		return new Coord4(abs(x - other_coord4.x), abs(y - other_coord4.y), abs(z - other_coord4.z), abs(w - other_coord4.w));
	}
	
	/// @func	distance_to_xyzw(xp, yp, zp, wp)
	/// @desc	distance between vector and point in 4D space
	/// @param {real} xp
	/// @param {real} yp
	/// @param {real} zp
	/// @param {real} wp
	/// @returns {Coord4}	new Coord4
	static distance_to_xyzw = function(xp, yp, zp, wp) { 
		return new Coord4(abs(x - xp), abs(y - yp), abs(z - zp), abs(w - wp));
	}

	/// @func	equals_xyzw(xp, yp, zp, wp)
	/// @desc	true, if all, x, y, z and w match	
	/// @returns {bool}			
	static equals_xyzw = function(xp, yp, zp, wp) {
		return (x == xp) && (y == yp) && (z == zp) && (w == wp);
	}
	
	/// @func	equals_coord4(other_coord4)
	/// @desc	true, if all, x, y, z and w match	
	/// @returns {bool}			
	static equals_coord4 = function(other_coord4) {
		return (x == other_coord4.x) && (y == other_coord4.y) && (z == other_coord4.z) && (w == other_coord4.w);
	}

	toString = function() {
		return $"{x}/{y}/{z}/{w}";
	}
}