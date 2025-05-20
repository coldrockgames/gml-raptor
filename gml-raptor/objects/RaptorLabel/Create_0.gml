/// @desc word_wrap and sprite remove

__original_dim = new SpriteDim(sprite_index);

event_inherited();

/// @func update_client_area()
update_client_area = function() {
	if (control_tree_layout == undefined || !remove_sprite_at_runtime || autosize) {
		data.__raptordata.client_area.set(0, 0, sprite_width, sprite_height);
		return;
	}
	
	data.__raptordata.client_area.set(0, 0, max(sprite_width, __text_width), max(sprite_height, __text_height));
	scale_sprite_to(
		data.__raptordata.client_area.width,
		data.__raptordata.client_area.height);
}

check_remove_sprite = function() {
	if (remove_sprite_at_runtime) {
		var w = (startup_width  >= 0 ? startup_width  : sprite_width);
		var h = (startup_height >= 0 ? startup_height : sprite_height);
		sprite_index = spr1pxTrans;
		image_xscale = w;
		image_yscale = h;
		__startup_xscale = w;
		__startup_yscale = h;
	}
}
check_remove_sprite();

onSkinChanged = function(_skindata) {
	set_startup_size();
	update_startup_coordinates();
	check_remove_sprite();
}

scribble_add_text_effects = function(scribbletext) {
	if (word_wrap)
		scribbletext.wrap(nine_slice_data.width);
}

__adopt_object_properties = function() {
	if (adopt_object_properties == adopt_properties.alpha ||
		adopt_object_properties == adopt_properties.full) {
		__scribble_text.blend(image_blend, image_alpha);
	}
	if (adopt_object_properties == adopt_properties.full) {
		if (remove_sprite_at_runtime) 
			__scribble_text.transform(
				sprite_width / __original_dim.width, 
				sprite_height / __original_dim.height, 
				image_angle
			);
		else
			__scribble_text.transform(image_xscale, image_yscale, image_angle);
	}
}

