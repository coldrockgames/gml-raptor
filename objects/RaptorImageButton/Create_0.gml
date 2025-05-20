/// @desc 

var w = (startup_width  >= 0 ? startup_width  : sprite_width);
var h = (startup_height >= 0 ? startup_height : sprite_height);
sprite_index = sprite_to_use ?? sprite_index;
scale_sprite_to(w, h);

// Inherit the parent event
event_inherited();

onSkinChanged = function(_skindata) {
	_baseControl_onSkinChanged(_skindata, function() {
		if (sprite_to_use != undefined) replace_sprite(sprite_to_use);
		__set_default_image();
	});
}

__apply_autosize_alignment = function() {
}

__apply_post_positioning = function() {
}
