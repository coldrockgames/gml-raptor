/*
    Helper functions for sprites and objects
*/

/// @func	instance_create(xp, yp, layer_name_or_depth, object, struct = undefined)
/// @desc	Convenience function to avoid that nasty switching between 
///			instance_create_layer and instance_create_depth.
///			Should've been always like that... supply a string to create the instance
///			on a named layer or supply an integer to create it on a specified depth
function instance_create(xp, yp, layer_name_or_depth, object, struct = undefined) {
	layer_name_or_depth = if_null(layer_name_or_depth, 0);
	if (struct == undefined)
		return is_string(layer_name_or_depth) ?
			instance_create_layer(xp, yp, layer_name_or_depth, object) :
			instance_create_depth(xp, yp, layer_name_or_depth, object);
	else
		return is_string(layer_name_or_depth) ?
			instance_create_layer(xp, yp, layer_name_or_depth, object, struct) :
			instance_create_depth(xp, yp, layer_name_or_depth, object, struct);
}

/// @func	instance_clone(_instance = self, layer_name_or_depth = undefined, struct = undefined)
/// @desc	Clones an instance and returns the clone.
///			"Cloning" for this function means:
///			* A new instance of the same type is created at the same position and layer/depth
///			* The Create event will run normally on the clone
///			* "green" variables (x,y,scale,rotation,blend,alpha,...) are copied to the clone
///			* All other variable values are *not* copied
function instance_clone(_instance = self, layer_name_or_depth = undefined, struct = undefined) {
	var rv;
	with (_instance) {
		var myname = object_get_name(object_index);
		var idx = asset_get_index(myname);
		rv = instance_create(x, y, layer_name_or_depth ?? (layer != -1 ? layer_get_name(layer) : depth), idx, struct);
		rv.sprite_index = sprite_index;
		rv.image_alpha  = image_alpha;
		rv.image_angle  = image_angle;
		rv.image_blend  = image_blend;
		rv.image_index  = image_index;
		rv.image_speed  = image_speed;
		rv.image_xscale = image_xscale;
		rv.image_yscale = image_yscale;
		rv.direction	= direction;
		rv.speed		= speed;
	}
	return rv;
}

/// @func	is_object_instance(_inst)
/// @desc	Checks whether a variable holds a living (not deactivated) object instance
function is_object_instance(_inst) {
	if (is_null(_inst) || (typeof(_inst) != "ref" && (is_real(_inst) || is_string(_inst))))
		return false;
	
	return	!is_string(_inst) &&
			!is_array(_inst) &&
			real(_inst) >= 100000 &&
			(typeof(_inst) == "ref" || is_struct(_inst) || instance_exists(_inst)) &&
			struct_exists(_inst, "id") && 
			struct_exists(_inst, "object_index") && 
			!is_null(object_get_name(vsget(_inst, "object_index")));
}

/// @func	is_dead_object_instance(_inst)
/// @desc	Checks whether a variable holds a dead/destroyed object instance pointer
function is_dead_object_instance(_inst) {
	return	!is_null(_inst) && 
			!is_string(_inst) &&
			!is_array(_inst) &&
			real(_inst) >= 100000 &&
			(typeof(_inst) == "ref" || vsget(_inst, "id") || vsget(_inst, "object_index")) &&
			!instance_exists(_inst)
			;
}

/// @func	scale_sprite_to(target_width, target_height)
/// @desc	Scale an instances' sprite so that it has the desired dimensions.
function scale_sprite_to(target_width, target_height) {
	if (sprite_index == -1 || sprite_index == noone) {
		image_xscale = 1;
		image_yscale = 1;
		return;
	}
	var w1 = sprite_get_width(sprite_index);
	var h1 = sprite_get_height(sprite_index);
	image_xscale = target_width / w1;
	image_yscale = target_height / h1;
}

/// @func	scale_sprite_aspect_width(new_width)
/// @desc	Scale an instances' sprite to a new width by keeping the aspect ratio
///			(this means, the yscale will be calculated based on the new xscale)
function scale_sprite_aspect_width(new_width) {
	if (sprite_index == -1 || sprite_index == noone) {
		image_xscale = 1;
		image_yscale = 1;
		return;
	}
	var w1 = sprite_get_width(sprite_index);
	image_xscale = new_width / w1;
	image_yscale = image_xscale;
}

/// @func	scale_sprite_aspect_height(new_height)
/// @desc	Scale an instances' sprite to a new height by keeping the aspect ratio
///			(this means, the xscale will be calculated based on the new yscale)
function scale_sprite_aspect_height(new_height) {
	if (sprite_index == -1 || sprite_index == noone) {
		image_xscale = 1;
		image_yscale = 1;
		return;
	}
	var h1 = sprite_get_height(sprite_index);
	image_yscale = new_height / h1;
	image_xscale = image_yscale;
}

/// @func	is_mouse_over(_instance)
/// @desc	Checks whether the current mouse position in the world (_is_gui = false) or
///			in the GUI coordinate space (_is_gui = true) is within the bounds of _instance
///			_is_gui defaults to false, because all controls have their "mouse_is_over" anyway
///			and in normal situations you want to know whether the mouse touches a specific
///			game object, not a control
function is_mouse_over(_instance, _is_gui = false) {
	var xcheck = _is_gui ? GUI_MOUSE_X : MOUSE_X;
	var ycheck = _is_gui ? GUI_MOUSE_Y : MOUSE_Y;
	return position_meeting(xcheck, ycheck, _instance);
}

global.__topmost_instance_finder_list = ds_list_create();
/// @func	get_topmost_instance_at(_x, _y, _obj_type = all)
/// @desc	Gets the topmost object at the specified coordinates
function get_topmost_instance_at(_x, _y, _obj_type = all) {
	ds_list_clear(global.__topmost_instance_finder_list);
	var cnt = instance_position_list(_x, _y, _obj_type, global.__topmost_instance_finder_list, false);
	if (cnt > 0) {
		var mindepth = ds_list_find_value(global.__topmost_instance_finder_list, 0);
		var newdepth = undefined;
		var i = 1;
		repeat(ds_list_size(global.__topmost_instance_finder_list) - 1) {
			newdepth = ds_list_find_value(global.__topmost_instance_finder_list, i);
			if (newdepth.depth < mindepth.depth) mindepth = newdepth;
			i++;
		}
		return mindepth;
	}
	return undefined;
}


/// @func	replace_sprite(replace_with, target_width = -1, target_height = -1, keep_empty = true, keep_size = true, keep_location = true)
/// @desc	Replaces the current sprite with the specified one.
///			The method checks if "replace_with" is undefined or noone,
///			so you don't need to check - just call it.
///			It also takes care about the alignment and scaling by default
///			but this behavior can be turned off through the parameters.
/// @param {sprite_asset} replace_with	The asset to set as the sprite
/// @param {real=-1}	target_width	If set, force a new width after replacing
/// @param {real=-1}	target_height	If set, force a new height after replacing
/// @param {bool=true}	keep_empty		if true, sprite will not be replaced, if current
///										sprite_index == -1
/// @param {bool=true}	keep_size		if true, image scale will be calculated so the object has
///										has the same size as it had with the previous sprite
/// @param {bool=true}	keep_location	if true, x/y will be calculated based on the new sprite's
///										alignment, so the object has the same location as it had 
///										with the previous sprite
function replace_sprite(replace_with, target_width = -1, target_height = -1, 
						keep_empty = true, keep_size = true, keep_location = true) {
							
	if (is_null(replace_with) || (sprite_index == -1 && keep_empty)) {
		sprite_index = -1;
		return;
	}
	
	var sw = 0;
	var sh = 0;
	if (sprite_index != -1) {
		sw = (target_width  >= 0 ? target_width  : sprite_width);
		sh = (target_height >= 0 ? target_height : sprite_height);
	}
		
	if (keep_location) {
		x -= sprite_xoffset;
		y -= sprite_yoffset;
	}
	sprite_index = replace_with;
		
	if (keep_size || target_width  != -1) image_xscale = sw / sprite_get_width(replace_with);
	if (keep_size || target_height != -1) image_yscale = sh / sprite_get_height(replace_with);
			
	if (keep_location) {
		x += sprite_xoffset;
		y += sprite_yoffset;
	}
}

