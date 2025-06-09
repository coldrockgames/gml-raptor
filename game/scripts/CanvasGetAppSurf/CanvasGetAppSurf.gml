/*
    Get a new Canvas instance containing the currently rendered application surface.
	
	Depending on the moment when you invoke this (EndDraw, EndDrawGui, ...) it will hold different content.
*/
/// feather ignore all

/// @function CanvasGetAppSurf()
/// @param {Bool} newAppSurf
/// @return Struct.Canvas
function CanvasGetAppSurf(_new = false) {
	static _appSurf = __CanvasAppSurf();
	
	if (!application_surface_is_enabled()) { 
		__CanvasError("application_surface is disabled! Please enable before using this function!");
	}
	
	if (_new) {
		return new Canvas(
			surface_get_width(application_surface), 
			surface_get_height(application_surface), true)
			.CopySurface(application_surface, 0, 0, false, true);	
	}
	
	return _appSurf;
}
