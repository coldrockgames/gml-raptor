/// @ignore
/// feather ignore all
function __CanvasSurfFormat(_value) {
	static _inst = new (function() constructor {
		self[$ surface_rgba8unorm] = "surface_rgba8unorm";
		self[$ surface_r8unorm]  = "surface_r8unorm";
		self[$ surface_rg8unorm] = "surface_rg8unorm";
		self[$ surface_rgba4unorm] = "surface_rgba4unorm";
		self[$ surface_rgba16float] = "surface_rgba16float";
		self[$ surface_r16float] = "surface_r16float";
		self[$ surface_rgba32float] = "surface_rgba32float";
		self[$ surface_r32float] = "surface_r32float";
	})();
	
	return _inst[$ string(_value)] ?? _value;
}