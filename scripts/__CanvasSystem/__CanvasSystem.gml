/// @ignore
/// feather ignore all
function __CanvasSystem() {
	static _inst = new (function() constructor {
		if (__CANVAS_ENABLE_GARBAGE_COLLECTOR) {
			refList = ds_list_create();
			GCList = ds_list_create();
			time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, method(self, __CanvasGC), [], -1));
			time_source_start(time_source_create(time_source_global, 15, time_source_units_frames, method(self, __CanvasCleanupQueue), [], -1));
		}
		
		supportsFormats = true;
		
		try {
			var _result = surface_rgba8unorm;
		} catch(_ex) {
			supportsFormats = false;	
		}
	})();
	
	return _inst;
} 

#macro __CANVAS_CREDITS "@TabularElf - https://tabelf.link/"
#macro __CANVAS_VERSION "v2.2.0"
#macro __CANVAS_ON_WEB (os_browser != browser_not_a_browser)
__CanvasTrace(__CANVAS_VERSION + " initalized! Created by " + __CANVAS_CREDITS);

#macro __CANVAS_HEADER_SIZE_V2 7
#macro __CANVAS_HEADER_SIZE_V1 5

// We have this set to 2 to handle older Canvas versions
#macro __CANVAS_HEADER_VERSION 2 

enum CanvasStatus {
	NO_DATA,
	IN_USE,
	HAS_DATA,
	HAS_DATA_CACHED
}