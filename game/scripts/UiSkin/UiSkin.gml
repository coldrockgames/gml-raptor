/*
    Holds the data for one single ui skin.
	Creating a skin is very easy: Just assign the sprite you wish to use to each control
	in the list below.
	
	Activate/Switch skins through the UiSkinManager.
	NOTE: Unlike Themes, does NOT require a room_restart to become active!
*/

function UiSkin(_name = "default") constructor {
	construct(UiSkin);
	ENSURE_THEMES;
	
	__tree_cache = {};
	
	name = _name;
	
	skin = {};
	
	/// @func delete_map()
	static delete_map = function() {
		skin = {};
		__tree_cache = {};
	}
	
	/// @func skin_exists(_inst_or_type)
	static skin_exists = function(_inst_or_type) {
		var typename = 
			is_object_instance(_inst_or_type) ? 
			name_of(_inst_or_type, false) : 
			object_get_name(_inst_or_type)
		;
		return struct_exists(skin, typename);
	}
	
	/// @func apply_skin(_instance)
	static apply_skin = function(_instance) {
		if (!instance_exists(_instance)) 
			return;
		
		var skindata = __get_inherited_skindata(_instance);
		if (skindata == undefined) 
			return;
			
		with(_instance) {
			// ATTENTION! if != false does NOT mean if true!! (undefined is also != false!)
			if (onSkinChanging(skindata) != false) {
				integrate_skin_data(skindata);
				onSkinChanged(skindata);
			}
		}
	}
	
	/// @func	__get_inherited_skindata(_instance)
	static __get_inherited_skindata = function(_inst_or_type) {
		var typename = 
			is_object_instance(_inst_or_type) ? 
			name_of(_inst_or_type, false) : 
			object_get_name(_inst_or_type)
		;
		
		if (struct_exists(__tree_cache, typename))
			return __tree_cache[$ typename];
				
		var rv = {};
		var item;
		var hasone = false;
		
		var tree = object_tree(_inst_or_type);
		array_reverse_ext(tree);
		for (var i = 0, len = array_length(tree); i < len; i++) {
			item = tree[@i];
			if (struct_exists(skin, item)) {
				struct_join_into(rv, deep_copy(skin[$ item]));
				hasone |= (array_length(struct_get_names(rv)) > 0);
			}
		}

		if (!hasone) rv = undefined;
		__tree_cache[$ typename] = rv;
		
		return rv;
	}

	/// @func inherit_skin(_skin_name)
	/// @desc Copy all values of the specified skin to the current skin
	static inherit_skin = function(_skin_name) {
		var src = UI_SKINS.get_skin(_skin_name);
		if (src != undefined) {
			var names = struct_get_names(src.skin);
			for (var i = 0, len = array_length(names); i < len; i++) {
				var key = names[@i];
				skin[$ key] = src.skin[$ key];
			}
		} else
			elog($"** ERROR ** UiSkin could not inherit skin '{_skin_name}' into '{name}' (SKIN-NOT-FOUND)");
	}

}