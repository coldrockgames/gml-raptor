enum line_mode {
	zero,
	rectangle,
	//manual // TODO implement
};	

/// @func	CollageSpriteSheet(_collage, _name, _filename_or_sprite)
/// @desc	Create a new sprite sheet either from an external file or
///			from an internal sprite (like a tileset)
function CollageSpriteSheet(_collage, _name, _filename_or_sprite) constructor {
	construct(CollageSpriteSheet);
	
	collage					= _collage;
	name					= _name;
	filename				= _filename_or_sprite;

	sprites					= [];

	linemode				= line_mode.zero;
	new_line_start			= 0;

	spritesheet_width		= 0;
	spritesheet_height		= 0;

	sheet_start_x			= 0;
	sheet_start_y			= 0;

	frame_width				= 0;
	frame_height			= 0;

	spritesheet_width		= 0;
	spritesheet_height		= 0;

	xorigin					= 0;
	yorigin					= 0;

	horizontal_alignment	= true;
	remove_back				= false;	
	smooth					= false;
	separate_texture		= false;	

	__temp_sprite_id		= -1;

	// Add ourselves to the sprites collection of the collage manager
	COLLAGE.__spritesheets[$ _name] = self; 

	/// @func	add_sprite(_name, _frame_count, _fps = 0)
	/// @desc	Add a sprite with its frame_count and fps
	static add_sprite = function(_name, _frame_count, _fps = 0) {
		array_push(sprites, 
			new CollageSprite(collage, _name, _frame_count, _fps)
				.set_spritesheet(self)
		);
		return self;
	}

	/// @func	get_sprite(_sprite_name)
	/// @desc	Retrieve the sprite with the specified name from this sheet
	///			or undefined, if not found
	static get_sprite = function(_sprite_name) {
		var spr;
		for (var i = 0, len = array_length(sprites); i < len; i++) {
			spr = sprites[@i];
			if (spr.name == _sprite_name)
				return spr;
		}
		
		return undefined;
	}

	/// @func	get_linear_sprite(_sprite_name) 
	/// @desc	Creates a linear strip from a given sprite and returns 
	///			the sprite.
	///			ATTENTION! You are responsible to sprite_delete() this
	///			sprite, when you no longer need it!
	static get_linear_sprite = function(_sprite_name) {
		var rv		= undefined;
		
		var spr		= get_sprite(_sprite_name);
		var colspr	= collage.GetImageInfo(_sprite_name);
		var surf	= surface_create(frame_width, frame_height);

		var i		= 0;
		surface_set_target(surf);
		repeat(spr.frame_count) {
			draw_clear_alpha(0, 0);
			CollageDrawImageExt(colspr, i++, 0, 0, 1, 1, 0, c_white, 1);
			if (rv == undefined)
				rv = sprite_create_from_surface(
					surf, 
					0, 0, 
					frame_width, frame_height, 
					remove_back, smooth, xorigin, yorigin
				);
			else
				sprite_add_from_surface(
					rv, surf,
					0, 0, frame_width, frame_height, 
					remove_back, smooth
				);
		}
		surface_reset_target();
		
		return rv;
	}

	/// @func	set_start_position(_sheet_start_x = 0, _sheet_start_y = 0)
	/// @desc	Define the x/y position of the first frame in the sheet
	static set_start_position = function(_sheet_start_x = 0, _sheet_start_y = 0) {
		sheet_start_x	= _sheet_start_x;
		sheet_start_y	= _sheet_start_y;
		return self;
	}

	/// @func	set_frame_size(_frame_width = 0, _frame_height = 0)
	/// @desc	Set the frame size for the sprites of this sheet
	static set_frame_size = function(_frame_width = 0, _frame_height = 0) {
		frame_width	= _frame_width;
		frame_height	= _frame_height;
		return self;
	}

	/// @func	set_origins(_xorigin = 0, _yorigin = 0)
	/// @desc	Set the origins of the sprites in this sheet
	static set_origins = function(_xorigin = 0, _yorigin = 0) {
		xorigin	= _xorigin;
		yorigin	= _yorigin;
		return self;
	}

	/// @func	set_alignment(_horizontal_alignment = true)
	/// @desc	Set the sheet alignment horizontal or vertical
	static set_alignment = function(_horizontal_alignment = true) {
		horizontal_alignment = _horizontal_alignment;
		return self;
	}

	/// @func	set_remove_back(_remove_back = false)
	/// @desc	Set whether to remove the background color of the sheet
	static set_remove_back = function(_remove_back = false) {
		remove_back = _remove_back;
		return self;
	}

	/// @func	set_smooth(_smooth = false)
	/// @desc	Set whether GameMaker shall use anti-aliasing when
	///			when removing the background color
	static set_smooth = function(_smooth = false) {
		smooth = _smooth;
		return self;
	}

	/// @func	set_separate_texture(_separate_texture)
	/// @desc	Set to true to assign an exclusive texture page
	///			for this sprite sheet
	static set_separate_texture = function(_separate_texture) {
	    separate_texture = separate_texture;
		return self;
	}

	/// @func	set_line_mode_zero()
	/// @desc	Sets whether the spritesheet starts 
	///			the next line at position 0 (default)
	static set_line_mode_zero = function() {
        linemode = line_mode.zero;
		new_line_start	= 0;
		return self;
    };

	/// @func	set_line_mode_rectangle()
	/// @desc	Sets whether the SpriteSheet starts 
	///			the next line at the start position
	static set_line_mode_rectangle = function() {
        linemode = line_mode.rectangle;
		new_line_start	= horizontal_alignment ? sheet_start_x : sheet_start_y;
        return self;
    };

	/// @func	set_line_mode_manual()
	/// @desc	Manually assign each frame's coordinates
	///			through .add_frame(...)
	static set_line_mode_manual = function() {
		throw("set_line_mode_manual: This function is not yet implemented");
		//__last_spritesheet.set_line_mode(line_mode.manual);
        return self;
    };

	#region build (incl async support)

	/// @func	build()
	/// @desc	Build the sprite sheet now and create the sheet defs
	static build = function() {
		if (is_string(filename)) {
			// load an external file
			if (IS_HTML) __build_async();
			else		 __build_now(sprite_add(filename, 1, remove_back, smooth, xorigin, yorigin));
		} else if (sprite_exists(filename)) {
				__build_now(filename); // use the internal sprite
		} else
			elog($"** ERROR ** CollageSpriteSheet: Sprite or file '{filename}' does not exist!");
			
		return COLLAGE; // return the manager (root object) to allow adding more things
	}

	static __build_async = function() {
		dlog($"SpriteSheet '{name}' is in async mode (HTML), waiting for images to be ready");
		var me = self;
		with (COLLAGE.__get_async_handler()) {
			wait_for_sprite(sprite_add(
				other.filename, 
				1, 
				other.remove_back, 
				other.smooth, 
				other.xorigin, 
				other.yorigin),
				me
			);
		}
	}
	
	static __async_image_received = function(_sprite_id, _filename) {
		dlog($"SpriteSheet '{name}' received async image {_sprite_id} '{_filename}'");
		__temp_sprite_id = _sprite_id;
	}
	
	static __build_now = function(_sprite_id = undefined) {
		if (_sprite_id != undefined) __temp_sprite_id = _sprite_id;
		if (__temp_sprite_id == -1) 
		    throw($"SpriteSheet '{name}' failed to add sprite file: '{filename}'");

		dlog($"SpriteSheet '{name}' is now building");
		spritesheet_width	= sprite_get_width(__temp_sprite_id);
		spritesheet_height	= sprite_get_height(__temp_sprite_id);
		
		var sheetDefs = __set_align_frame();
	
		if (__are_names_unique(sheetDefs)) {
			__do_add_sprite_sheet(__temp_sprite_id, sheetDefs);	
		} else {							 
			__add_spritesheet_with_separated_frames(__temp_sprite_id, sheetDefs)
		}
		
		dlog($"SpriteSheet '{name}' built with {array_length(sprites)} sprites");
	}
	
	static __delete_temp_sprite = function() {
		if (__temp_sprite_id != -1) {
			dlog($"SpriteSheet '{name}' removing temp sprite {__temp_sprite_id}");
			sprite_delete(__temp_sprite_id);
		}
	}
	#endregion
	
	#region private helpers
	
	static __set_align_frame = function() {
		var sheet_defs = [];
		var cur_x = sheet_start_x;
		var cur_y = sheet_start_y;

		var max_x = spritesheet_width;
		var max_y = spritesheet_height;

		for (var i = 0; i < array_length(sprites); i++) {
			var sprite	= sprites[@i];
			var frames	= sprite.frame_count;
			var current	= []; // current sprite only

			while (frames > 0) {
				var span, end_x, end_y;
				var start_x = cur_x;
				var start_y = cur_y;
				
				if (horizontal_alignment) {
					var remaining_px = max_x - cur_x;
					var fit = floor(remaining_px / frame_width);
					if (fit <= 0) {
						// move to next row
						cur_x = new_line_start; //<------------------------ new line
						cur_y += frame_height;
						if (cur_y + frame_height > max_y) break;
						continue;
					}

					span	= min(frames, fit);
					end_x	= cur_x + (span * frame_width) - 1;
					end_y	= cur_y + frame_height - 1;

					cur_x += span * frame_width;
					frames -= span;
				} else {
					var remaining_px = max_y - cur_y;
					var fit = floor(remaining_px / frame_height);
					if (fit <= 0) {
						// move to next column
						cur_y = new_line_start; //<------------------------ new line
						cur_x += frame_width;
						if (cur_x + frame_width > max_x) break;
						continue;
					}

					span = min(frames, fit);
					end_x = cur_x + frame_width - 1;
					end_y = cur_y + (span * frame_height) - 1;
					
					cur_y += span * frame_height;
					frames -= span;
				}
				
				var def = CollageDefineSpriteSheet(
					sprite.name, 
					start_x, 
					start_y, 
					end_x, 
					end_y, 
					sprite.sprite_fps
				);

				array_push(current, def);
				array_push(sheet_defs, def);				
			}
			
			sprite.set_frame_def(current);
		}

		return sheet_defs;
	}
	
	/// @func	__add_spritesheet_with_separated_frames(_sheet_array)
	/// @desc	Adds complex sprite sheets to the Collage system by 
	///			grouping and slicing frame sequences into dedicated surfaces.
	///			If multiple frames belong to the same animation name, 
	///			they are drawn together into a surface,	and a corresponding 
	///			sub-region is defined for each sequence. Single-frame entries are added directly.
	/// @param  {array} _sheet_array An array of frame definitions in the format: [name, x1, y1, x2, y2]
	static __add_spritesheet_with_separated_frames = function(_sprite_id, _sheet_array) {
	    var grouped         = {};
	    var single_defs     = [];
	    var multi_defs      = {};

	    // Group all frames by animation name
	    for (var i = 0; i < array_length(_sheet_array); i++) {
	        var def  = _sheet_array[i];
	        var name = def[0];
	        if (!struct_exists(grouped, name)) {
	            grouped[$ name] = [def];
			} else {
				array_push(grouped[$ name], def);
			}
	    }

	    // Split into single-frame and multi-frame sequences
	    var keys = struct_get_names(grouped);
	    for (var i = 0; i < array_length(keys); i++) {
	        var name    = keys[i];
	        var entries = grouped[$ name];
	        if (array_length(entries) == 1) {
	            array_push(single_defs, entries[0]);
	        } else {
	            multi_defs[$ name] = entries;
	        }
	    }

	    // Add single-frame sequences using the original sprite
	    if (array_length(single_defs) > 0) {
			__do_add_sprite_sheet(_sprite_id, single_defs);
	    }
	
		var multi_keys = struct_get_names(multi_defs);
	
	    // Determine surface size and layout
		var all_groups = [];
		var group_sizes = [];
		var surface_w = 0;
		var surface_h = 0;

		for (var i = 0; i < array_length(multi_keys); i++) {
		    var name    = multi_keys[i];
		    var entries = multi_defs[$ name];
		    var total_w = 0;
		    var total_h = 0;
		    var max_w   = 0;
		    var max_h   = 0;
		    var frames  = [];

		    for (var j = 0; j < array_length(entries); j++) {
		        var e = entries[j];
		        var w = e[3] - e[1] + 1;
		        var h = e[4] - e[2] + 1;

		        total_w += w;
		        total_h += h;
		        max_w = max(max_w, w);
		        max_h = max(max_h, h);

		        array_push(frames, [name, e, w, h]);
		    }

		    array_push(all_groups, frames);

		    if (horizontal_alignment) {
		        array_push(group_sizes, [total_w, max_h]);
		        surface_w = max(surface_w, total_w);
		        surface_h += max_h;
		    } else {
		        array_push(group_sizes, [max_w, total_h]);
		        surface_w += max_w;
		        surface_h = max(surface_h, total_h);
		    }
		}
	
		// Create surface
		var surf = surface_create(surface_w, surface_h);
		surface_set_target(surf);
		draw_clear_alpha(c_white, 0);
		
		var group_rects = __create_multiline_surface(_sprite_id, all_groups, group_sizes);

	
		// Create sheet defs based on grouped bounding boxes
		var multi_sheet_defs = [];
		var group_names = struct_get_names(group_rects);

		for (var i = 0; i < array_length(group_names); i++) {
			var name = group_names[i];
			var r = group_rects[$ name];
			array_push(multi_sheet_defs, CollageDefineSpriteSheet(name, r[0], r[1], r[2], r[3], r[4]));
		}

		surface_reset_target();
	
		var spr = sprite_create_from_surface(
			surf, 0, 0, surface_w, surface_h, remove_back, smooth, xorigin, yorigin);
		
		__do_add_sprite_sheet(spr, multi_sheet_defs);

	    sprite_delete(spr);
	    surface_free(surf);
	}
	
	/// @func	__create_multiline_surface(_all_groups, _group_sizes)
	/// @desc	Creates a surface that combines multiple animation groups into a single layout,
	///			either stacked vertically or horizontally. Each group's frames are drawn in sequence,
	///			and their bounding rectangles are returned for later use with Collage.
	static __create_multiline_surface = function(_sprite_id, _all_groups, _group_sizes) {
		var group_rects = {};
		var cursor_x = 0;
		var cursor_y = 0;
		
		for (var i = 0; i < array_length(_all_groups); i++) {
			var frames = _all_groups[i];
			var name   = frames[0][0]; // all frames in group have same name
			var group_w = _group_sizes[i][0];
			var group_h = _group_sizes[i][1];

			var draw_x = cursor_x;
			var draw_y = cursor_y;

			for (var j = 0; j < array_length(frames); j++) {
				var e  = frames[j][1];
				var w  = frames[j][2];
				var h  = frames[j][3];

				draw_sprite_part(_sprite_id, 0, e[1], e[2], w, h, draw_x, draw_y);

				if (!struct_exists(group_rects, name)) {
				    group_rects[$ name] = [draw_x, draw_y, draw_x + w - 1, draw_y + h - 1, e[5]];
				} else {
				    var r = group_rects[$ name];
				    r[2] = draw_x + w - 1;
				    r[3] = max(r[3], draw_y + h - 1);
				    group_rects[$ name] = r;
				}

				if (horizontal_alignment) {
				    draw_x += w;
				} else {
				    draw_y += h;
				}
			}

			if (horizontal_alignment) {
				cursor_y += group_h;
			} else {
				cursor_x += group_w;
			}
		}

		return group_rects;
	}

	static __do_add_sprite_sheet = function(_spritesheet_id, _defs) {
		collage.AddSpriteSheet(
			_spritesheet_id, 
			_defs, 
			name, 
			frame_width, 
			frame_height, 
			remove_back, 
			smooth, 
			xorigin, 
			yorigin, 
			separate_texture
		);
	}
	
	static __are_names_unique = function(array) {
		var len = array_length(array);
	    for (var i = 0; i < len; i++) {
	        for (var j = 0; j < len; j++) {
	            if (array[i][0] == array[j][0] && i != j) return false;
	        }
	    }
	    return true;
	}
	#endregion
}