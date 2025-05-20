/// @func					layer_set_all_visible(wildcard, vis)
/// @desc				Sets the visible state of all layers where the name matches
///								the specified wildcard.
///								Wildcard character is '*'. It can be at the beginning, the end or both.
/// @param {string}	wildcard			The layer name or wildcard (name* or *name) to set visibility for
/// @param {bool}	vis					Visible yes/no
/// @param {bool}	object_activation	if true, all objects on this layer will be 
///										activated/deactivated according to vis
/// @returns {[mindepth,maxdepth]} An array containing the min and max depth of affected layers
function layer_set_all_visible(wildcard, vis, object_activation = true) {
	var max_depth = DEPTH_TOP_MOST;
	var min_depth = DEPTH_BOTTOM_MOST;
	var ldepth = 0;
	var layers = layer_get_all();
	for (var i = 0; i < array_length(layers); i++) {
		var lid = layers[i];
		var lname = layer_get_name(lid);
		
		if (string_match(lname, wildcard)) {
			if (object_activation && vis) {
				vlog($"Activating layer {lid} ('{lname}')");
				instance_activate_layer(lid);
			}
			layer_set_visible(lid, vis);
			ldepth = layer_get_depth(lid);
			min_depth = min(min_depth, ldepth);
			max_depth = max(max_depth, ldepth);
			if (object_activation && !vis) {
				vlog($"Deactivating layer {lid} ('{lname}')");
				instance_deactivate_layer(lid);
			}
			dlog($"Setting layer visibility: layer='{lname}'; visible={vis};");
		}
	}
	return [min_depth, max_depth];
}

/// @func	layer_set_background_color(_layer_name_or_id, _color)
/// @desc	Set the blend color of a BACKGROUND layer
/// @param {id|string}	layername_or_id	The name or the id of the background layer
/// @param {color}		_color			The color to set
function layer_set_background_color(_layer_name_or_id, _color) {
	var lay_id = is_string(_layer_name_or_id) ? layer_get_id(_layer_name_or_id) : _layer_name_or_id;
	layer_background_blend(layer_background_get_id(lay_id), _color);
}

/// @func	layer_set_background_sprite(_layer_name_or_id, _sprite_index)
/// @desc	Set the sprite of a BACKGROUND layer
/// @param {id|string}		layername_or_id	The name or the id of the background layer
/// @param {sprite_index}	_sprite_index	The sprite to set
function layer_set_background_sprite(_layer_name_or_id, _sprite_index) {
	var lay_id = is_string(_layer_name_or_id) ? layer_get_id(_layer_name_or_id) : _layer_name_or_id;
	layer_background_sprite(layer_background_get_id(lay_id), _sprite_index);
}
