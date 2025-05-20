/*
	Holds a 3D Coordinate (x,y,z)
*/

/// @func	Coord3(xp, yp, zp)
/// @param {real} xp
/// @param {real} yp
/// @param {real} zp
/// @returns {Coord3}
function Coord3(xp = 0, yp = 0, zp = 0) : Coord2(xp, yp) constructor {
	construct(Coord3);
	
	z = zp;

	/// @func	clone3()
	/// @desc	Clones this as Coord3
	static clone3 = function() {
		return new Coord3(x, y, z);
	}

	/// @func	set(xp, yp, zp)
	/// @desc	set all values in one step
	/// @param {real} xp
	/// @param {real} yp
	/// @param {real} zp
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static set = function(xp, yp, zp) {
		x = xp;
		y = yp;
		z = zp;
		return self;
	}

	/// @func	mul(factor_x, factor_y, factor_z)
	/// @desc	multiply all values in one step
	/// @param {real} factor_x
	/// @param {real} factor_y
	/// @param {real} factor_z
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static mul = function(factor_x, factor_y, factor_z) {
		x *= factor_x;
		y *= factor_y;
		z *= factor_z;
		return self;
	}
	
	/// @func	mul_xyz(factor)
	/// @desc	multiply all values in one step
	/// @param {real} factor
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static mul_xyz = function(factor) {
		x *= factor;
		y *= factor;
		z *= factor;
		return self;
	}

	/// @func	add(factor_x, factor_y)
	/// @desc	add a value to the current values
	/// @param {real} add_x
	/// @param {real} add_y
	/// @param {real} add_z
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static add = function(add_x, add_y, add_z) {
		x += add_x;
		y += add_y;
		z += add_z;
		return self;
	}

	/// @func	add_xyz(factor_x, factor_y)
	/// @desc	add the same value to the current values
	/// @param {real} value
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static add_xyz = function(value) {
		x += value;
		y += value;
		z += value;
		return self;
	}

	/// @func	plus(other_coord3)
	/// @desc	Add the values of other_coord3 into this one
	/// @param {Coord3} other_coord3
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static plus = function(other_coord3) {
		x += other_coord3.x;
		y += other_coord3.y;
		z += other_coord3.z;
		return self;
	}
	
	/// @func	minus(other_coord3)
	/// @desc	Subtract the values in other_coord3 from this one
	/// @param {Coord3} other_coord3
	/// @returns {Coord3} self for command chaining (fluent syntax)
	static minus = function(other_coord3) {
		x -= other_coord3.x;
		y -= other_coord3.y;
		z -= other_coord3.z;
		return self;
	}

	/// @func	length_xyz()
	/// @desc	3D-hypotenuse
	/// @returns {real} length			
	static length_xyz = function() { 
		return point_distance_3d(0, 0, 0, x, y, z);
	}
	
	/// @func	distance_to_coord3(other_Coord3)
	/// @desc	distance between two vectors
	/// @param {Coord3} other_Coord3
	/// @returns {Coord3}	new Coord3
	static distance_to_coord3 = function(other_coord3) {
		return point_distance_3d(x, y, z, other_coord3.x, other_coord3.y, other_coord3.z);
	}
	
	/// @func	distance_to_xyz(xp, yp, zp)
	/// @desc	distance between vector and point in 3D space
	/// @param {real} xp
	/// @param {real} yp
	/// @param {real} zp
	/// @returns {Coord3}	new Coord3
	static distance_to_xyz = function(xp, yp, zp) { 
		return point_distance_3d(x, y, z, xp, yp, zp);
	}

	/// @func	equals_xyz(xp, yp, zp)
	/// @desc	true, if all, x, y and z match	
	/// @returns {bool}			
	static equals_xyz = function(xp, yp, zp) {
		return (x == xp) && (y == yp) && (z == zp);
	}
	
	/// @func	equals_coord3(other_coord3)
	/// @desc	true, if all, x, y and z match	
	/// @returns {bool}			
	static equals_coord3 = function(other_coord3) {
		return (x == other_coord3.x) && (y == other_coord3.y) && (z == other_coord3.z);
	}

	toString = function() {
		return $"{x}/{y}/{z}";
	}
}