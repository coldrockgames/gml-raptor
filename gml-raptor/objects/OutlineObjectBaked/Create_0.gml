/// @desc bake on first draw
event_inherited();
canvas		= undefined;
dynsprite	= undefined;
origsprite	= sprite_index;

__browser_flip = (os_browser != browser_not_a_browser) ? -1 : 1;

__free = function() {
	if (canvas != undefined)
		canvas.free();
		
	if (dynsprite != undefined) 
		sprite_delete(dynsprite);
}

__create_baked_dynsprite = function() {
	dynsprite = canvas.create_sprite();
	sprite_set_bbox_mode(dynsprite, bboxmode_manual); 
	sprite_set_bbox(dynsprite,
		sprite_get_bbox_left  (sprite_index) + __browser_flip * (2 * outliner.outline_strength + TEXTURE_PAGE_BORDER_SIZE / 2),
		sprite_get_bbox_top   (sprite_index) + __browser_flip * (2 * outliner.outline_strength + TEXTURE_PAGE_BORDER_SIZE / 2),
		sprite_get_bbox_right (sprite_index) + __browser_flip * (2 * outliner.outline_strength + TEXTURE_PAGE_BORDER_SIZE / 2),
		sprite_get_bbox_bottom(sprite_index) + __browser_flip * (2 * outliner.outline_strength + TEXTURE_PAGE_BORDER_SIZE / 2));
}

__get_cached_prebake_sprite = function(cachename) {
	if (variable_struct_exists(__OUTLINE_SHADER_PREBAKE_CACHE, cachename)) {
		canvas		= __OUTLINE_SHADER_PREBAKE_CACHE[$ cachename];
		__create_baked_dynsprite();
		return true;
	}
	return false;
}

/// @func bake()
bake = function() {
	origsprite = sprite_index;
	var cachename = string(sprite_get_name(sprite_index)); // use string(..) because of possible -1 return
	if (cachename == "-1") cachename = "";
	var can_cache = (cachename ?? "") != "";
	if (can_cache) {
		if (__get_cached_prebake_sprite(cachename)) 
			return; // we have it in the cache, no need to process the sprite
			
		show_debug_message($"Pre-Baking sprite '{cachename}' with {image_number} frames");
	} else
		show_debug_message("*WARNING* This sprite can not be cached!");
	
	__free();
	var begintime			= current_time;
	var shader				= shd_outline;
	var u_texel				= shader_get_uniform(shader, "u_vTexel");
	var u_outline_color_1	= shader_get_uniform(shader, "u_vOutlineColour1");
	var u_outline_color_2	= shader_get_uniform(shader, "u_vOutlineColour2");
	var u_thickness			= shader_get_uniform(shader, "u_vThickness");
	var u_vPulse			= shader_get_uniform(shader, "u_vPulse");

	canvas = sprite_to_canvas(sprite_index, -1, outliner.outline_strength + TEXTURE_PAGE_BORDER_SIZE);
	// now bake it with the outliner
	var target = new Canvas(canvas.canvas.GetWidth(), canvas.canvas.GetHeight(), true);
	target.Start();

	shader_set(shader);
	var _texture = canvas.canvas.GetTexture();
	texture_set_stage(shader_get_sampler_index(shader, "u_sSpriteSurface"), _texture);
	shader_set_uniform_f(u_texel			, texture_get_texel_width(_texture), texture_get_texel_height(_texture));
	shader_set_uniform_f(u_outline_color_1	, outliner.outline_color, outliner.outline_alpha); //colour, alpha
	shader_set_uniform_f(u_outline_color_2	, outliner.outline_color, outliner.outline_alpha); //colour, alpha
	shader_set_uniform_f(u_thickness		, outliner.outline_strength, outliner.alpha_fading ? 1 : 0); // thickness x, y
	shader_set_uniform_f(u_vPulse			, outliner.outline_strength, outliner.outline_strength, 1, 0);

	draw_surface(canvas.canvas.GetSurfaceID(), outliner.outline_strength, outliner.outline_strength);

	shader_reset();
	target.Finish();			
	
	// Free the original canvas...
	canvas.canvas.Free();
	// ...and inject the pre-baked
	canvas.canvas = target;
	
	__create_baked_dynsprite();
	
	if (can_cache)
		__OUTLINE_SHADER_PREBAKE_CACHE[$ cachename] = canvas;

	show_debug_message("Pre-Baking took {0}ms", current_time - begintime);
}

__flicker_saver = 0;
__draw = function() {
	if (canvas == undefined) bake();
	var before = sprite_index;
	var after = (is_enabled && (outline_always || (outline_on_mouse_over && mouse_is_over))) ? dynsprite : origsprite;
	var changed = after != before;
	if (__flicker_saver == 0 && changed) {
		__flicker_saver++;
		sprite_index = after;
	} else {
		if (!changed)
			__flicker_saver = max(0, __flicker_saver - 1);
	}

	draw_self();
}

if (sprite_index != -1) bake();