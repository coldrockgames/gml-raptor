/*
	CoordTranslator - translate gui to world coordinates and vice versa
*/

#region GUI TO WORLD
/// @func	translate_gui_to_world(gui_x, gui_y, coord2 = undefined)
/// @desc	translate the specified ui coordinates to the current
///			camera's view world coordinates.
///			The optional coord2 parameter can be used to fill
///			an existing instance of Coord2 with the values and
///			therefore avoid creating new instances.
///			Consider this for performance and GC.
function translate_gui_to_world(gui_x, gui_y, coord2 = undefined) {
	coord2 ??= new Coord2();

	var xfac = UI_VIEW_TO_CAM_FACTOR_X * UI_SCALE;
	var yfac = UI_VIEW_TO_CAM_FACTOR_Y * UI_SCALE;
	with (coord2) set(
		CAM_LEFT_EDGE + gui_x * xfac, 
		CAM_TOP_EDGE  + gui_y * yfac
	);
		
	return coord2;
}

/// @func	translate_gui_to_world_x(gui_x)
/// @desc	translate the specified ui x-coordinate to the current
///			camera's view world coordinate.
function translate_gui_to_world_x(gui_x) {
	gml_pragma("forceinline");
	return CAM_LEFT_EDGE + gui_x * UI_VIEW_TO_CAM_FACTOR_X * UI_SCALE;
}

/// @func	translate_gui_to_world_y(gui_x)
/// @desc	translate the specified ui y-coordinate to the current
///			camera's view world coordinate.
function translate_gui_to_world_y(gui_y) {
	gml_pragma("forceinline");
	return CAM_TOP_EDGE + gui_y * UI_VIEW_TO_CAM_FACTOR_Y * UI_SCALE;
}


/// @func	translate_gui_to_world_abs(gui_x, gui_y, coord2 = undefined)
/// @desc	translate the specified ui coordinates to world coordinates.
///			This function ignores camera and view! It just converts from one
///			coordinate space to another.
///			The optional coord2 parameter can be used to fill
///			an existing instance of Coord2 with the values and
///			therefore avoid creating new instances.
///			Consider this for performance and GC.
function translate_gui_to_world_abs(gui_x, gui_y, coord2 = undefined) {
	coord2 ??= new Coord2();

	var xfac = UI_VIEW_TO_CAM_FACTOR_X * UI_SCALE;
	var yfac = UI_VIEW_TO_CAM_FACTOR_Y * UI_SCALE;
	with (coord2) set(
		gui_x * xfac, 
		gui_y * yfac
	);
		
	return coord2;
}
#endregion

#region WORLD TO GUI
/// @func	translate_world_to_gui(world_x, world_y, coord2 = undefined)
/// @desc	translate the specified world coordinates to gui coordinates.
///			The optional coord2 parameter can be used to fill
///			an existing instance of Coord2 with the values and
///			therefore avoid creating new instances.
///			Consider this for performance and GC.
function translate_world_to_gui(world_x, world_y, coord2 = undefined) {
	coord2 ??= new Coord2();
		
	var xfac = UI_CAM_TO_VIEW_FACTOR_X  / UI_SCALE;
	var yfac = UI_CAM_TO_VIEW_FACTOR_Y / UI_SCALE;
	with (coord2) set(
		(world_x - CAM_LEFT_EDGE) * xfac, 
		(world_y - CAM_TOP_EDGE)  * yfac
	);
		
	return coord2;
}

/// @func	translate_world_to_gui_x(world_x)
/// @desc	translate the specified world x-coordinate to a	ui space coordinate.
function translate_world_to_gui_x(world_x) {
	gml_pragma("forceinline");
	return (world_x - CAM_LEFT_EDGE) * UI_CAM_TO_VIEW_FACTOR_X / UI_SCALE;
}

/// @func	translate_world_to_gui_y(world_y)
/// @desc	translate the specified world y-coordinate to a	ui space coordinate.
function translate_world_to_gui_y(world_y) {
	gml_pragma("forceinline");
	return (world_y - CAM_TOP_EDGE) * UI_CAM_TO_VIEW_FACTOR_Y / UI_SCALE;
}

/// @func	translate_world_to_gui_abs(world_x, world_y, coord2 = undefined)
/// @desc	translate the specified world coordinates to gui coordinates.
///			This function ignores camera and view! It just converts from one
///			coordinate space to another.
///			The optional coord2 parameter can be used to fill
///			an existing instance of Coord2 with the values and
///			therefore avoid creating new instances.
///			Consider this for performance and GC.
function translate_world_to_gui_abs(world_x, world_y, coord2 = undefined) {
	coord2 ??= new Coord2();
	
	var xfac = UI_CAM_TO_VIEW_FACTOR_X / UI_SCALE;
	var yfac = UI_CAM_TO_VIEW_FACTOR_Y / UI_SCALE;
	with (coord2) set(
		world_x * xfac, 
		world_y * yfac
	);
		
	return coord2;
}
#endregion
