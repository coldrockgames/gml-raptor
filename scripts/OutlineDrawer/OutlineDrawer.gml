/*
		Outline shader drawer
		---------------------
		
		The shader itself is based on the selective-outline-shader by Juju Adams 
		(https://github.com/JujuAdams/selective-outline) and he also helped me tuning this shader.
		
		Use this class to draw any object with an outline effect based on the set parameters.
		See the DemoTank object in the Demo Project of the original repository at 
		https://github.com/Grisgram/gml-outline-shader-drawer
		
		(c)2022- coldrock.games, @grisgram at github
*/

#macro TEXTURE_PAGE_BORDER_SIZE		2

/// @func	OutlineDrawer(_viewport, _obj, _custom_draw = undefined, _use_bbox = false)
function OutlineDrawer(_viewport, _obj, _custom_draw = undefined, _use_bbox = false) constructor {
	// html flips the final surface vertically... hell knows, why.
	// so, on html we need to draw it upside down.
	__flip_vertical			= (os_browser != browser_not_a_browser);

	viewport			= _viewport;
	camera				= view_get_camera(_viewport);
	obj					= _obj
	custom_draw			= _custom_draw;
	
	shader				= shd_outline;
	u_texel				= shader_get_uniform(shader, "u_vTexel");
	u_outline_color_1	= shader_get_uniform(shader, "u_vOutlineColour1");
	u_outline_color_2	= shader_get_uniform(shader, "u_vOutlineColour2");
	u_thickness			= shader_get_uniform(shader, "u_vThickness");
	u_vPulse			= shader_get_uniform(shader, "u_vPulse");
	
	use_bbox			= _use_bbox;
	pulse_time			= 0;
	pulse_pit			= 0;
	color_1_rgb			= 0;
	color_2_rgb			= 0;
	
	__outline_surface_1 = -1;
	__outline_surface_2 = -1;
	_texture			= undefined;
	_surface_real_w		= 0;
	_surface_real_h		= 0;
	_sprite_l			= 0; 
	_sprite_t			= 0; 
	_camera_xscale		= 1;
	_camera_yscale		= 1;
	_camera_x			= 0;
	_camera_y			= 0;
	_surface_l			= 0;
	_surface_t			= 0;
	_surface_r			= 0;
	_surface_b			= 0;

	bbox_w				= 0;
	bbox_h				= 0;
	bbox_l				= 0;
	bbox_t				= 0;
	
	static __update_surfaces = function() {
		if (!surface_exists(__outline_surface_1)) __outline_surface_1 = surface_create(1, 1);
		if (!surface_exists(__outline_surface_2)) __outline_surface_2 = surface_create(1, 1);
	}

	/// @func	draw_sprite_outline()
	static draw_sprite_outline = function() {
		__update_surfaces();
		
		if (use_bbox || obj.image_angle != 0) {
			bbox_l = obj.bbox_left;
			bbox_t = obj.bbox_top ;
			bbox_w = obj.bbox_right  - bbox_l + 1;
			bbox_h = obj.bbox_bottom - bbox_t + 1;
		} else {
			bbox_l = obj.x - obj.sprite_xoffset + (obj.image_xscale < 0 ? obj.sprite_width  : 0);
			bbox_t = obj.y - obj.sprite_yoffset + (obj.image_yscale < 0 ? obj.sprite_height : 0);
			bbox_w = obj.sprite_width;
			bbox_h = obj.sprite_height;
		}
		
		//Verify the two input surfaces
		if (!surface_exists(__outline_surface_1))
		{
		    show_debug_message("draw_sprite_outline: Surface 1 does not exist!");
		    return false;
		}

		if (!surface_exists(__outline_surface_2))
		{
		    show_debug_message("draw_sprite_outline: Surface 2 does not exist!");
		    return false;
		}

		_surface_real_w = 2 * obj.outline_strength + abs(bbox_w);
		_surface_real_h = 2 * obj.outline_strength + abs(bbox_h);
		
		if ((surface_get_width(__outline_surface_1) < _surface_real_w) || 
			(surface_get_height(__outline_surface_1) < _surface_real_h))
		    surface_resize(__outline_surface_1, _surface_real_w, _surface_real_h);

		if ((surface_get_width(__outline_surface_2) < _surface_real_w) || 
			(surface_get_height(__outline_surface_2) < _surface_real_h))
		    surface_resize(__outline_surface_2, _surface_real_w, _surface_real_h);

		//Find the top-left corner of the sprite's quad, correcting for the sprite's origin
		_sprite_l = obj.x - obj.sprite_xoffset - 1;
		_sprite_t = obj.y - obj.sprite_yoffset - 1;

		//Find the portion of the application surface that we want to borrow
		_camera_xscale = 1;
		_camera_yscale = 1;
		_camera_x      = 0;
		_camera_y      = 0;

		//Correct for the camera if it's been specified
		if (is_real(camera) && (camera >= 0))
		{
		    _camera_xscale = view_wport[viewport] / camera_get_view_width (camera);
		    _camera_yscale = view_hport[viewport] / camera_get_view_height(camera);
		    _camera_x      = camera_get_view_x(camera);
		    _camera_y      = camera_get_view_y(camera);
		}

		//Figure out what part of the application surface we need to chop out
		_surface_l = max(0, _camera_xscale * (bbox_l - _camera_x) - obj.outline_strength);
		_surface_t = max(0, _camera_yscale * (bbox_t - _camera_y) - obj.outline_strength);
		_surface_r = _surface_l + _camera_xscale * _surface_real_w;
		_surface_b = _surface_t + _camera_yscale * _surface_real_h;

		// You can use this draw-block to visualize the edges of the 
		// real object's bbox, the calculated rotated bbox and the surface bbox
		//draw_set_color(c_green);
		//draw_rectangle(obj.bbox_left,obj.bbox_top, obj.bbox_right,obj.bbox_bottom,true);
		//draw_set_color(c_red);
		//draw_rectangle(bbox_l, bbox_t, bbox_l + bbox_w * sign(obj.image_xscale), bbox_t + bbox_h * sign(obj.image_yscale), true);
		//draw_set_color(c_yellow);
		//draw_rectangle(_surface_l, _surface_t, _surface_r, _surface_b, true);
		//draw_set_color(c_white);

		//Draw the sprite to a temporary surface
		//It's possible to avoid using this particular surface if sprites are configured correctly...
		//...but using a surface means you don't need to configure sprites at all
		surface_set_target(__outline_surface_1);
		draw_clear_alpha(c_black, 0.0);
		tmpalpha = obj.image_alpha;
		obj.image_alpha = 1;

		draw_set_color(c_white);
		if (custom_draw != undefined)
			custom_draw(
				obj.sprite_xoffset + TEXTURE_PAGE_BORDER_SIZE + obj.outline_strength + _sprite_l - bbox_l,
				obj.sprite_yoffset + TEXTURE_PAGE_BORDER_SIZE + obj.outline_strength + _sprite_t - bbox_t,
			);
		else
			draw_sprite_ext(obj.sprite_index, obj.image_index,
				obj.sprite_xoffset + TEXTURE_PAGE_BORDER_SIZE + obj.outline_strength + _sprite_l - bbox_l,
				obj.sprite_yoffset + TEXTURE_PAGE_BORDER_SIZE + obj.outline_strength + _sprite_t - bbox_t,
			    obj.image_xscale, obj.image_yscale, obj.image_angle, obj.image_blend, obj.image_alpha
			);

		surface_reset_target();

		//Now we draw to the second surface using our shader
		//The shader samples the sprite surface, looking for an edge
		//Once it finds an edge, it looks at the application surface
		//If the application surface is dark enough, it draws the outline
		//If the shader cannot find an edge, it'll draw the sprite as normal
		surface_set_target(__outline_surface_2);
		draw_clear_alpha(c_black, 0.0);

		pulse_time = (pulse_time + 1) % obj.pulse_frequency_frames;
		shader_set(shader);
		_texture = surface_get_texture(__outline_surface_1);
		texture_set_stage(shader_get_sampler_index(shader, "u_sSpriteSurface"), _texture);
		shader_set_uniform_f(u_texel			, texture_get_texel_width(_texture), texture_get_texel_height(_texture));
		shader_set_uniform_f(u_thickness		, obj.outline_strength, obj.outline_alpha_fading ? 1 : 0); // thickness x, y
		if (obj.pulse_active) {
			color_1_rgb = rgb_of(obj.pulse_color_1);
			color_2_rgb = rgb_of(obj.pulse_color_2);
			shader_set_uniform_f(u_outline_color_1	, color_1_rgb, obj.outline_alpha, tmpalpha); //colour, alpha
			shader_set_uniform_f(u_outline_color_2	, color_2_rgb, obj.outline_alpha, tmpalpha); //colour, alpha
			shader_set_uniform_f(u_vPulse			, obj.pulse_min_strength, obj.pulse_max_strength, obj.pulse_frequency_frames, pulse_time);
		} else {
			color_1_rgb = rgb_of(obj.outline_color);
			shader_set_uniform_f(u_outline_color_1	, color_1_rgb, obj.outline_alpha, tmpalpha); //colour, alpha
			shader_set_uniform_f(u_outline_color_2	, color_1_rgb, obj.outline_alpha, tmpalpha); //colour, alpha
			shader_set_uniform_f(u_vPulse			, obj.outline_strength, obj.outline_strength, 1, 0);
		}
		
		draw_surface_part_ext(application_surface,
			_surface_l, _surface_t,
			_surface_r, _surface_b,
			0, 0,
			1 / _camera_xscale, 1 / _camera_yscale,
			c_white, 1.0);

		shader_reset();
		surface_reset_target();
		
		//Draw surface 2
		if (__flip_vertical) {
			// as we increase the surface only when needed but never shrink (for performance)
			// we need the current_dimensions here for correct rendering in html (surface_get_height)
			draw_surface_ext(__outline_surface_2, 
				bbox_l - obj.outline_strength - 1,
				bbox_t + surface_get_height(__outline_surface_2) - obj.outline_strength - 1,
				1, -1, 0, c_white, 1);
		} else {
			draw_surface_ext(__outline_surface_2, 
				bbox_l - obj.outline_strength - 1, 
				bbox_t - obj.outline_strength - 1,
				1, 1, 0, c_white, 1);
		}

		obj.image_alpha = tmpalpha;
		return true;
	}
}
