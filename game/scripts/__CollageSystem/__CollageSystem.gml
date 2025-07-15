/// @ignore
/// feather ignore all
enum CollageBuildStates {
	NORMAL,
	BATCHING
}

enum CollageStatus {
	READY,
	WAITING_ON_FILES
}

enum CollageOrigin {
	LEFT = -2716284,
	CENTER,
	RIGHT,
	TOP,
	BOTTOM	
}

enum CollageRPStatus {
	EMPTY,
	BATCHING,
	BATCHED
}

#macro __COLLAGE_CREDITS "@TabularElf - https://tabelf.link/"
#macro __COLLAGE_VERSION "v0.5.0"
show_debug_message("Collage " + __COLLAGE_VERSION + " Initalized! Created by " + __COLLAGE_CREDITS);

/// @ignore
function __CollageSystem() {
	static _inst = undefined;
		// Feather ignore once GM1011
		if (_inst = undefined) {
			_inst = {};
			with(_inst) {
				__CollageTexturePagesMap = {};
				__CollageTexturePagesList = [];
				__CollageImageMap = {};
				__CollageGMSpriteCount = 0;
				__CollageAsyncList = [];
				__CollageTPLoadedList = ds_list_create();
				
				var _i = 0;
				try {
					// Needed as newer versions of GameMaker now break with "unused assets" checked.
					var _sprites = asset_get_ids(asset_sprite);
					repeat(array_length(_sprites)) {
						// Skip sprites created/added on the fly
						if (!string_count("__newsprite", sprite_get_name(_sprites[_i])) > 0) {
							__CollageGMSpriteCount++;	
						}
						_i++;
					}
				} catch(_) {
					while(sprite_exists(_i)) {
						// Skip sprites created/added on the fly
						if (string_count("__newsprite", sprite_get_name(_i)) > 0) {
							break;
						}
						
						__CollageGMSpriteCount = _i++;
					}
				}
				_init = true;
				try {
					time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, function() {
						__CollageTick();
					}, [], -1));
				} catch(_ex) {
					__CollageThrow("This is running on a version older than 2022.5!");	
				}
			}
		}
	
	return _inst;
}
__CollageSystem();
