/// @ignore
/// feather ignore all
function __CanvasAppSurf() {
	var _inst = new Canvas(surface_get_width(application_surface), surface_get_height(application_surface));
	_inst.__isAppSurf = true;
	with(_inst) {
		var _func = function() {
			if (application_surface_is_enabled()) {
				__surface = application_surface;
			} 
		}
		
		__status = CanvasStatus.HAS_DATA;
		__Init();
		UpdateCache();
		
		time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, _func, [], -1));
	}
	return _inst;
}