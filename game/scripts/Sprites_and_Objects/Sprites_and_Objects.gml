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
	var skin = SKIN.__get_inherited_skindata(object);
	if (skin != undefined) {
		struct = struct_enrich_into({}, struct, skin);
		struct_set(struct, __RAPTOR_PRE_SKIN_APPLY, true);
	}

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
	if (is_null(_inst) || is_string(_inst) || is_array(_inst) || is_bool(_inst) || is_callable(_inst)) 
		return false;

	// normalize instance-refs (structs) as id, if available
	// HTML-effect: if '_inst' is just a real number here, nothing bad happens
	if (is_struct(_inst) || vsget(_inst, "id") != undefined) {
		if (real(_inst) >= 100000 && variable_struct_exists(_inst, "id")) _inst = _inst.id; 
		else 
			return false;
	}

	// Definitive Probe: make a probe in a with-statement
	// (with only succeeds if the object can be "entered", i.e. has a scope)
	var probe = _inst;
	try { 
		with (probe)
			if (id == probe) return true; 
	} catch (_) { 
		return false; 
	}
	return false;	
}

/// @func	is_dead_object_instance(_inst)
/// @desc	Checks whether a variable holds a dead/destroyed object instance pointer
function is_dead_object_instance(_inst) {
	if (is_null(_inst) || is_string(_inst) || is_array(_inst) || is_bool(_inst) || is_callable(_inst)) 
		return false;

	// normalize instance-refs (structs) as id, if available
	if (is_struct(_inst) || vsget(_inst, "id") != undefined) {
		if (variable_struct_exists(_inst, "id")) _inst = _inst.id; 
		else 
			return false;
	}
	return real(_inst) >= 100000 && !instance_exists(_inst);
}

/// @func	get_sprite_scale_for(_target_width, _target_height, _into = undefined)
/// @desc	Calculates the required x/y scale for the sprite to reach the desired width/height.
///			Result is written to _into_coord2 (if supplied) and returned as Coord2.
function get_sprite_scale_for(_target_width, _target_height, _into = undefined) {
	_into ??= new Coord2(1, 1);
	if (sprite_index > 0) {
		var w1 = sprite_get_width(sprite_index);
		var h1 = sprite_get_height(sprite_index);
		_into.set(_target_width / w1, _target_height / h1);
	}
	return _into;
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
/// @func	get_topmost_instance_at(_x, _y, _obj_type = all, _ignore_types = undefined, _ignore_instances = undefined, _draw_on_gui = undefined)
/// @desc	Gets the topmost object at the specified coordinates.
///			In addition, you may specify an array of types and/or instances, 
///			which shall be ignored,	as well as force the "draw_on_gui" to be 
///			either ignored too (default, undefined) or to have a specific value (true or false).
function get_topmost_instance_at(_x, _y, _obj_type = all, _ignore_types = undefined, _ignore_instances = undefined, _draw_on_gui = undefined) {
	static default_mindepth = { depth: DEPTH_BOTTOM_MOST };
	
	ds_list_clear(global.__topmost_instance_finder_list);
	var cnt = instance_position_list(_x, _y, _obj_type, global.__topmost_instance_finder_list, false);
	if (cnt > 0) {
		var any_found		= false;
		var mindepth		= default_mindepth;
		var newdepth		= undefined;
		var i				= 0;
		var tree			= undefined;
		var tree_found		= false;;
		
		repeat(cnt) {
			tree_found = false;
			newdepth = ds_list_find_value(global.__topmost_instance_finder_list, i);
			if (_ignore_types != undefined) {
				tree = object_tree(newdepth, false);
				for (var j = 0, jen = array_length(tree); j < jen; j++) {
					if (array_contains(_ignore_types, tree[@j])) {
						tree_found = true;
						break;
					}
				}
			}
			if (!tree_found &&
				(_ignore_instances == undefined || !array_contains(_ignore_instances, newdepth.id)) && 
				(_draw_on_gui == undefined || vsget(newdepth, "draw_on_gui") == _draw_on_gui) &&
				newdepth.depth < mindepth.depth) {
					any_found = true;
					mindepth = newdepth;
				}
			i++;
		}
		return any_found ? mindepth : undefined;
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

