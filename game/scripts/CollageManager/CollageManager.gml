/*
    CollageManager: Builder Pattern for managing collages
*/

#macro COLLAGE			global.__collage
#macro __COLLAGE_CACHE	global.__collage_cache
#macro ENSURE_COLLAGE	if (vsget(global, "__collage") == undefined) \
							global.__collage = new CollageManager(); \
						if (vsget(global, "__collage_cache") == undefined) global.__collage_cache = {};
ENSURE_COLLAGE;

/// @func	CollageManager()
/// @desc	Constructor for the CollageManager, 
///			provides a fluent API for creating and manipulating collages
function CollageManager() constructor {
    construct(CollageManager);
	
	// A CollageAsyncManager instance if html/async mode
	__async_handler		= undefined;
	
	// builder components
	__last_collage		= undefined;
	__last_spritesheet	= undefined;
	__last_sprite		= undefined;
	
	__spritesheets		= {};
	__sprites			= {};
	
	#region Collage Management
	
	/// @func	for_collage(_name)
	/// @desc	Begin a chain for the collage identified by _name
	static for_collage = function(_name) {
		if (!string_is_empty(__last_collage))
			finish_batch();
		
	    __last_collage = _name;

        return vsget(__COLLAGE_CACHE, __last_collage) != undefined ? start_batch() : self;
	};

	/// @func	create(_width = 4096, _height = 4096, _crop = __COLLAGE_DEFAULT_CROP, _margin = 0, _optimize = __COLLAGE_DEFAULT_OPTIMIZE)
	/// @desc	Create a new collage with the specified data,
	///			ONLY IF IT DOES NOT ALREADY EXIST!
	///			To recreate a collage, use .destroy().create()
	///			NOTE: This function also starts batching mode.
	static create = function(
		_width = 4096, _height = 4096, 
		_crop = __COLLAGE_DEFAULT_CROP, 
		_margin = 0, 
		_optimize = __COLLAGE_DEFAULT_OPTIMIZE) {
		
		if (vsget(__COLLAGE_CACHE, __last_collage) == undefined) {
	        __COLLAGE_CACHE[$ __last_collage] = new Collage(
				__last_collage, 
				_width, 
				_height, 
				_crop, 
				_margin, 
				_optimize
			);
			dlog($"Collage '{__last_collage}' created with dimensions {_width}x{_height}");
		}
		return start_batch();
	}

	/// @func	destroy()
	/// @desc	Destroys the currently selected collage
	static destroy = function() {
        if (vsget(__COLLAGE_CACHE, __last_collage) != undefined) {
			__COLLAGE_CACHE[$ __last_collage].Destroy();
			struct_remove(__COLLAGE_CACHE, __last_collage);
			__last_collage = undefined;
			dlog($"Collage '{__last_collage}' destroyed");
		}
		return self;
	}

	/// @func	clear()
	/// @desc	Remove all images and reset the selected collage
	static clear = function() {
        __COLLAGE_CACHE[$ __last_collage].Clear();
        return self;
    }

	/// @func	get(_collage_name)
	/// @desc	Retrieve the collage instance stored as _collage_name
	///			NOTE: This retrieves the collage instance from the original library
	static get = function(_collage_name) {
        return vsget(__COLLAGE_CACHE, _collage_name);
    }

	/// @func	exists(_collage_name)
	/// @desc	Checks whether a collage with the specified name exists
	static exists = function(_collage_name) {
		return vsget(__COLLAGE_CACHE, __last_collage) != undefined;
	}

	/// @func	sprite_exists(_name)
	/// @desc	Check whether a sprite with the given name exists in the collage
	static sprite_exists = function(_name) {
        return __COLLAGE_CACHE[$ __last_collage].Exists(_name);
    }

	/// @func	sprite_sheet_exists(_name) 
	static sprite_sheet_exists = function(_name) {
		return vsget(__spritesheets, _name) != undefined;
	}

	/// @func	push_to_vram()
	/// @desc	Preload all texture pages of the current collage into graphics card memory
	static push_to_vram = function() {
		dlog($"Uploading collage '{__last_collage}' to VRAM");
        __COLLAGE_CACHE[$ __last_collage].PrefetchPages();
        return self;
    }
	
	/// @func	remove_from_vram()
	/// @desc	Free memory on the graphics card by unloading all pages of this collage
	static remove_from_vram = function() {
		dlog($"Removing collage '{__last_collage}' from VRAM");
        __COLLAGE_CACHE[$ __last_collage].FlushPages();
        return self;
    }

    /// @func   cache()
    /// @desc   Cache all texture pages of the current collage for faster access
    static cache = function() {
		gml_pragma("forceinline");
        return __COLLAGE_CACHE[$ __last_collage].Cache();
    }

	/// @func	is_waiting_for_async_images()
	/// @desc	Returns whether any async manager still waiting for images to be loaded
	static is_waiting_for_async_images = function() {
		gml_pragma("forceinline");
		return __async_handler != undefined;
	}

	/// @func	build()
	/// @desc	build all the data into texture pages
	static build = function() {
		if (!__any_collage_waiting()) 
			__finalize_build();
		return self;
	}
	
	static __finalize_build = function() {
		__build_now();
		__build_collision_masks();
		__signal_all_drawers();
		__delete_temp_sprites();
	}
	
	static __build_now = function() {
		var names = struct_get_names(__spritesheets);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var n = names[@i];
			__spritesheets[$ n].__build_now();
		}
		finish_batch();
		dlog($"Collage '{__last_collage}' built with {array_length(get_sprite_names())} sprites and {get_page_count()} pages");
		__async_handler_finished();		
	}	
	#endregion
	
	#region Batch Functions
	/// @func	start_batch()
	/// @desc	Begin a batch on the selected collage
	static start_batch = function() {
		finish_batch();
		__COLLAGE_CACHE[$ __last_collage].StartBatch();
	    return self;
	}

	/// @func	clear_batch()
	/// @desc	Clear the current batch on the selected collage
	static clear_batch = function() {
		if (is_in_batch_mode()) {
			__COLLAGE_CACHE[$ __last_collage].ClearBatch();
		}
	    return self;
	}

	/// @func	finish_batch(_crop = true)
	/// @desc	Finish the current batch for the selected collage,
	///			optionally crop any unused space around the textures (default: true)
	static finish_batch = function(_crop = true) {
		if (is_in_batch_mode()) {
			__COLLAGE_CACHE[$ __last_collage].FinishBatch();
		}
	    return self;
	}

	/// @func	is_in_batch_mode() 
	static is_in_batch_mode = function() {
		return __COLLAGE_CACHE[$ __last_collage].__state == CollageBuildStates.BATCHING;
	}
	#endregion
	
	#region Async Management
	static __get_async_handler = function() {
		if (__async_handler == undefined)
			__async_handler = instance_create(0, 0, 0, CollageAsyncManager);
			
		return __async_handler;
	}
	
	static __any_collage_waiting = function() {
		var any_waiting = false;
		var names = struct_get_names(__COLLAGE_CACHE);
		for (var i = 0, len = array_length(names); i < len; i++) {
			dlog($"CollageManager checking collage {(i + 1)} of {len} for async state");
			var n = names[@i];
			var item = __COLLAGE_CACHE[$ n];
			if (item.GetStatus() == CollageStatus.WAITING_ON_FILES) {
				dlog($"Collage {(i + 1)} of {len} is still waiting");
				any_waiting = true;
				break;
			}
		}
		return any_waiting;
	}
	
	static __async_handler_finished = function() {
		var waiting = __any_collage_waiting();
		if (!waiting) {
			dlog($"All collages are ready, shutting down async handler");
			if (__async_handler != undefined) {
				__async_handler = undefined;
				__finalize_build();
			}
		}
		return !waiting;
	}
	
	static __signal_all_drawers = function() {
		var drawer_count = instance_number(CollageDrawer);
		var names = struct_get_names(__COLLAGE_CACHE);
		dlog($"CollageManager signalling {drawer_count} drawers 'async_load_complete'");
		for (var i = 0, len = array_length(names); i < len; i++) {
			var n = names[@i];
			with(CollageDrawer) {
				if (collage_name == n) {
					dlog($"CollageManager signalling drawer {MY_NAME} '{collage_name}.{sprite_name}' for async finished");
					__async_load_complete();
				}
			}
		}
	}
	
	static __delete_temp_sprites = function() {
		var names = struct_get_names(__spritesheets);
		for (var i = 0, len = array_length(names); i < len; i++) {
			var n = names[@i];
			var item = __spritesheets[$ n];
			item.__delete_temp_sprite();
		}
	}
	
	static __build_collision_masks = function() {
		var names = struct_get_names(__sprites);
		dlog($"CollageManager building collision masks for {array_length(names)} sprites");
		for (var i = 0, len = array_length(names); i < len; i++) {
			var n = names[@i];
			__sprites[$ n].build();
		}
	}
	
	#endregion
	
	#region Asset Methods
	/// @func	add_spritesheet(_name, _filename)
	/// @desc	Add a new SpriteSheet to the collage
	static add_spritesheet = function(_name, _filename) {
		if (vsget(__COLLAGE_CACHE, __last_collage == undefined))
			throw($"add_spritesheet failed: No collage is set");

		dlog($"Collage '{__last_collage}' creating sprite sheet '{_name}' from '{_filename}'");
        return new CollageSpriteSheet(__COLLAGE_CACHE[$ __last_collage], _name, _filename);
    }

	/// @func	add_sprite(_name, _index, _separate_texture = false)
	/// @desc	Add an existing sprite to the collage
	///			The _index parameter must be a valid sprite_index known to the game, not a filename!
	static add_sprite = function(_name, _index, _separate_texture = false) {
		var col = __COLLAGE_CACHE[$ __last_collage];
		var spr = sprite_get_info(_index);
		var sprfps = spr.frame_speed;
		if (spr.frame_type == spritespeed_framespergameframe)
			sprfps *= game_get_speed(gamespeed_fps);
		__sprites[$ _name] = 
			new CollageSprite(col, _name, spr.num_subimages, sprfps)
				.set_collage_data(col.AddSprite(
					_index,
					_name,
					false,
					sprite_get_xoffset(_index),
					sprite_get_yoffset(_index),
					_separate_texture
				)
				.Keep()
	        )
		;
        return self;
    }

	/// @func	add_file(_name, _filename, _xorigin = 0, _yorigin = 0, _remove_back = false, _smooth = false, _separate_texture = false)
	/// @desc	Add a new single frame sprite from an external image file to the collage 
	static add_file = function(
		_name, _filename, 
		_xorigin = 0, _yorigin = 0, 
		_remove_back = false, _smooth = false, 
		_separate_texture = false) {
		
		var col = __COLLAGE_CACHE[$ __last_collage];

        __sprites[$ _name] = 
			new CollageSprite(col, _name, 1, 0)
				.set_collage_data(col.AddFile(
					_filename, _name, 1,
					_remove_back, _smooth,
					_xorigin, _yorigin,
					_separate_texture
				)
				.Keep()
			)
		;
		__get_async_handler();
        return self;
    }

	/// @func	add_file_strip(_name, _filename, _frame_count = 1, _fps = 0, _xorigin = 0, _yorigin = 0, _remove_back = false, _smooth = false, _separate_texture = false)
	/// @desc	Add a new sprite to the collage from a filestrip image file
	static add_file_strip = function(_name, _filename, _frame_count = 1, _fps = 0,
		_xorigin = 0, _yorigin = 0, 
		_remove_back = false, _smooth = false, 
		_separate_texture = false) {
		
		var col = __COLLAGE_CACHE[$ __last_collage];

        __sprites[$ _name] = 
			new CollageSprite(col, _name, _frame_count, _fps)
				.set_collage_data(col.AddFileStrip(
		            _filename, _name, _frame_count,
					_remove_back, _smooth,
					_xorigin, _yorigin,
					_separate_texture
		        )
				.Keep()
				.SetSpeed(_fps)
				.SetSpeedType(gamespeed_fps)
			)
		;
		__get_async_handler();
        return self;
    }
    
	/// @func	add_surface(_name, _filename, _xorigin = 0, _yorigin = 0, _remove_back = false, _smooth = false, _separate_texture = false)
	/// @desc	Add a new single frame sprite to the collage from a surface
	static add_surface = function(
		_name, _surface, 
		_xorigin = 0, _yorigin = 0, 
		_remove_back = false, _smooth = false, 
		_separate_texture = false) {
			
		var col = __COLLAGE_CACHE[$ __last_collage];

        __sprites[$ _name] = 
			new CollageSprite(col, _name, 1, 0)
				.set_collage_data(col.AddSurface(
		            _surface, _name,
					0, 0, 
					surface_get_width(_surface), 
					surface_get_height(_surface),
					_remove_back, _smooth,
					_xorigin, _yorigin,
					_separate_texture
		        )
				.Keep()
			)
		;		
        return self;
    }
	
	/// @func	add_surface_part(_name, _surface, _x, _y, _w, _h, _xorigin = 0, _yorigin = 0, _remove_back = false, _smooth = false, _separate_texture = false)
	/// @desc	Add a new single frame sprite to the collage from a part of a surface
	static add_surface_part = function(
		_name, _surface, 
		_x, _y, _w, _h,
		_xorigin = 0, _yorigin = 0, 
		_remove_back = false, _smooth = false, 
		_separate_texture = false) {
			
		var col = __COLLAGE_CACHE[$ __last_collage];

        __sprites[$ _name] = 
			new CollageSprite(col, _name, 1, 0)
				.set_collage_data(col.AddSurface(
		            _surface, _name,
					_x, _y, _w, _h,
					_remove_back, _smooth,
					_xorigin, _yorigin,
					_separate_texture
		        )
				.Keep()
			)
		;		
        return self;
    }
	
	/// @func	add_surface_strip(_name, _surface, _frame_count = 1, _fps = 0, _xorigin = 0, _yorigin = 0, _remove_back = false, _smooth = false, _separate_texture = false)
	/// @desc	Add a new single frame sprite to the collage from a surface
	static add_surface_strip = function(
		_name, _surface, _frame_count = 1, _fps = 0,
		_xorigin = 0, _yorigin = 0, 
		_remove_back = false, _smooth = false, 
		_separate_texture = false) {
			
		var col = __COLLAGE_CACHE[$ __last_collage];

		// for a surface strip we need to tweak a bit and call private methods
		// in collage...
		var coldata = col.AddSurface(
		    _surface, _name,
			0, 0, 
			surface_get_width(_surface), 
			surface_get_height(_surface),
			_remove_back, _smooth,
			_xorigin, _yorigin,
			_separate_texture
		)
		.Keep()
		.SetSpeed(_fps)
		.SetSpeedType(gamespeed_fps);
		
		coldata.__subImages = _frame_count;
		coldata.__isCopy	= false;
		col.__InternalAddFileStrip(coldata, _remove_back, _smooth, _xorigin, _yorigin, _separate_texture);

        __sprites[$ _name] = 
			new CollageSprite(col, _name, _frame_count, _fps)
				.set_collage_data(coldata)
		;		
        return self;
    }	
	#endregion
	
	#region Texture Information Methods
	/// @func	get_texture_page(_index)
	/// @desc	Return the texture page at the given index from the current collage
	static get_texture_page = function(_index) {
        return __COLLAGE_CACHE[$ __last_collage].GetTexturePage(_index);
    }

	/// @func	get_texture(_index)
	/// @desc	Return the texture (surface) of the page at the given index
	static get_texture = function(_index) {
        return __COLLAGE_CACHE[$ __last_collage].GetTexture(_index);
    }

	/// @func	get_page_count()
	/// @desc	Return the number of texture pages in the current collage
	static get_page_count = function() {
        return __COLLAGE_CACHE[$ __last_collage].GetCount();
    }

	/// @func	get_image_array(_sorted = false)
	/// @desc	Return an array of all image objects in the collage; optionally sorted
	static get_image_array = function(_sorted = false) {
        return __COLLAGE_CACHE[$ __last_collage].ImagesToArray(_sorted ?? false);
    }

	/// @func	get_sprite_names()
	/// @desc	Return an array of all sprite names in the collage
	static get_sprite_names = function() {
        return __COLLAGE_CACHE[$ __last_collage].ImagesNamesToArray();
    }

	/// @func	get_sprite_sheet_names()
	/// @desc	Return the names of all sprite sheets known to the manager
	static get_sprite_sheet_names = function() {
        return struct_get_names_ex(__spritesheets);
    }

	/// @func	get_sprite(_sprite_name)
	/// @desc	Retrieve the sprite with the specified name
	///			or undefined, if not found
	static get_sprite = function(_sprite_name) {
		return vsget(__sprites, _sprite_name);
	}

	/// @func	get_sprite_sheet(_spritesheet_name)
	/// @desc	Retrieve the sprite with the specified name
	///			or undefined, if not found
	static get_sprite_sheet = function(_spritesheet_name) {
		return vsget(__spritesheets, _spritesheet_name);
	}

	#endregion

}
