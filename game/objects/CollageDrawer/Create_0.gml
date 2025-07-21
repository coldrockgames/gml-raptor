/// @desc methods
/*
	CollageDrawer helper object for the Canvas library by @tabularelf.
*/
event_inherited();

collage			= undefined;
sprite			= undefined;
image_count		= 1;
drawable		= false;

// animation timing
__time			= 0;
__time_step		= 0;
__sub_idx		= 0;
__sub_idx_prev	= 0;

#region Collider functionality
__is_parent		= false;
__collider		= undefined;

set_parent = function(_parent) {
	if (IS_HTML) {
		__is_parent = true;
		return; // TODO: HTML-MASKS mask not supported already posted to log
	}
	
	// Am I the collider child?
	if (_parent == undefined) {
		var me = self;
		__collider = instance_create(x, y, depth, CollageDrawer, {
			collage_parent: me,
			visible: false,
			add_to_savegame: false,
		});
		__is_parent = true;
		if (vsget(self, "outliner") != undefined)
			outliner.set_sprite_source(__collider);
	}
}

if (!SAVEGAME_LOAD_IN_PROGRESS)
	set_parent(vsgetx(self, "collage_parent"));

__collide_with		= undefined;
__collide_with_cbs	= undefined;
__collision_list	= __is_parent ? undefined : ds_list_create();
__collision_count	= 0;

/// @func	add_collision(_instance_or_type, _callback_or_state)
/// @desc	Add a collision registration with the specified instance or type
///			The callback gets invoked, when a collision happens.
///			GameMaker does not allow to trigger the internal "Collision->Type" 
///			event, so for the CollageDrawer, you have to take this approach.
///			"self" and "other" are set correctly as usual.
add_collision = function(_instance_or_type, _callback_or_state) {
	if (!__is_parent) {
		collage_parent.add_collision(_instance_or_type, _callback_or_state);
		return;
	}
	__collide_with		??= [];
	__collide_with_cbs	??= {};
	if (!array_contains(__collide_with, _instance_or_type)) {
		array_push(__collide_with, _instance_or_type);
		var cb = vsgetx(__collide_with_cbs, typename_of(_instance_or_type), []);
		array_push(cb, _callback_or_state);
	}
}

/// @func	remove_collision(_instance_or_type)
/// @desc	Remove a collision registration with the specified instance or type
remove_collision = function(_instance_or_type) {
	if (!__is_parent) {
		collage_parent.remove_collision(_instance_or_type);
		return;
	}
	if (__collide_with != undefined && array_contains(__collide_with, _instance_or_type)) {
		array_remove(__collide_with, _instance_or_type);
		struct_remove(__collide_with_cbs, typename_of(_instance_or_type));
	}
}

/// @func	clear_collisions()
/// @desc	Clears all registered collisions
clear_collisions = function() {
	if (!__is_parent) {
		collage_parent.clear_collisions();
		return;
	}
	__collide_with		= undefined;
	__collide_with_cbs	= undefined;
}

/// @func	__perform_collision(_with)
__perform_collision = function(_with) {
	gml_pragma("forceinline");
	
	var type = typename_of(_with);
	var tree = object_tree(_with);
	var names = struct_get_names(__collide_with_cbs);
	for (var i = 0, len = array_length(names); i < len; i++) {
		var n = names[@i];
		var cbs = __collide_with_cbs[$ n];
		if (array_contains(tree, n)) {
			for (var j = 0, jen = array_length(cbs); j < jen; j++) {
				var cb = cbs[@j];
				if (is_string(cb)) states.set_state(cb); else cbs[@j]();
			}
		}
	}
}

#endregion

/// @func	set_sprite(_collage_name, _sprite_name)
/// @desc	Assign a new sprite to use or undefined to clear.
///			This function requires a valid collage assigned.
set_sprite = function(_collage_name, _sprite_name) {
	if (collage == undefined || collage_name != _collage_name) {
		collage	= COLLAGE.get(collage_name);
		if(collage != undefined) 
			collage_name = _collage_name;
		else
			return;
	}
	
	sprite	= undefined;
	if (!string_is_empty(_sprite_name)) {
		sprite_name	= _sprite_name;
		sprite		= collage.GetImageInfo(sprite_name);
		if (sprite != undefined) {
			image_count	= sprite.GetCount();
			__time_step	= sprite.GetSpeed() > 0 ? (1000000 / sprite.GetSpeed()) : 0;
		}
	}
	
	drawable = (sprite != undefined && __is_parent);
	if (drawable && __collider != undefined) {
		__collider.sprite_index = COLLAGE.get_sprite(sprite_name).mask_sprite;
	}
};

__draw_self = function() {
	gml_pragma("forceinline");
	CollageDrawImageExt(
		sprite, 
		__sub_idx, 
		x, 
		y, 
		image_xscale, 
		image_yscale, 
		image_angle, 
		image_blend, 
		image_alpha
	);
}

// in some games, this gets re-parented to OutlineObject, which
// has a __draw method in-between for the outline
// this ensures, __draw exists
vsgetx(self, "__draw", __draw_self);
vsgetx(self, "draw_on_gui", false);

__async_load_complete = function() {
	if (__is_parent)
		set_sprite(collage_name, sprite_name);
}

__async_load_complete(); // try to show immediately


