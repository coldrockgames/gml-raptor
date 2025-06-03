/*
    Holds the data for one single ui skin.
	Creating a skin is very easy: Just assign the sprite you wish to use to each control
	in the list below.
	
	Activate/Switch skins through the UiSkinManager.
	NOTE: Unlike Themes, does NOT require a room_restart to become active!
*/

#macro __RAPTOR_SKIN_STATE_SIGN					"$"
#macro __RAPTOR_SKIN_STATE_WILDCARD				"$*"
#macro __RAPTOR_SKIN_FLAVOR_DELIMITER			"."
#macro __RAPTOR_SKIN_FLAVOR_CONCATE_DELIMITER	","

function UiSkin(_name = "default") constructor {
	construct(UiSkin);
	ENSURE_THEMES;
	
	__tree_cache = {};
	
	name = _name;
	
	skin = {};
		
	skin[$ "CheckBox"]			= { sprite_index: sprDefaultCheckbox }
	skin[$ "InputBox"]			= { sprite_index: sprDefaultInputBox }
	skin[$ "Label"]				= { sprite_index: sprDefaultLabel	 }
	skin[$ "MouseCursor"]		= { 
 									sprite_index: sprDefaultMouseCursor,
									mouse_cursor_sprite: sprDefaultMouseCursor,
 									mouse_cursor_sprite_sizing: sprDefaultMouseCursorSizing
 								  }
	skin[$ "Panel"]				= { sprite_index: spr1pxTrans			}
	skin[$ "RadioButton"]		= { sprite_index: sprDefaultRadioButton	}
	skin[$ "Slider"]			= { 
									sprite_index: sprDefaultSliderRailH,
									rail_sprite_horizontal: sprDefaultSliderRailH,
									rail_sprite_vertical: sprDefaultSliderRailV,
									knob_sprite: sprDefaultSliderKnob
								  }
	skin[$ "Scrollbar"]			= { 
									sprite_index: sprDefaultScrollbarRailH,
									rail_sprite_horizontal: sprDefaultScrollbarRailH,
									rail_sprite_vertical: sprDefaultScrollbarRailV,
									knob_sprite: sprDefaultScrollbarKnob
								  }
	skin[$ "TextButton"]		= { sprite_index: sprDefaultButton	}
	skin[$ "ImageButton"]		= { sprite_index: sprDefaultButton	}
	skin[$ "Tooltip"]			= { sprite_index: sprDefaultTooltip	}
	skin[$ "Window"]			= { 
									sprite_index: sprDefaultWindow,
									window_x_button_object: WindowXButton,
									titlebar_height: 34
								  }
	skin[$ "WindowXButton"]		= { sprite_index: sprDefaultXButton	}
	skin[$ "MessageBoxWindow"]	= { 
									sprite_index: sprDefaultWindow,
									window_x_button_object: MessageBoxXButton,
									titlebar_height: 34
								  }
	skin[$ "MessageBoxXButton"]	= { sprite_to_use: sprDefaultXButton }
	
	/// @func delete_map()
	static delete_map = function() {
		skin = {};
		__tree_cache = {};
	}

	/// @func	get_inherited_skindata(_instance, _skin_flavor = undefined)
	static get_inherited_skindata = function(_inst_or_type, _skin_flavor = undefined, _skin_state = undefined) {
		var typename = 
			is_object_instance(_inst_or_type) ? 
			name_of(_inst_or_type, false) : 
			object_get_name(_inst_or_type)
		;
		
		var hasstate	= _skin_state  != undefined;
		var hasflavor	= _skin_flavor != undefined;
		
		if (!hasstate) {
			if (hasflavor) {	
				_skin_flavor = string_concat(typename, __RAPTOR_SKIN_FLAVOR_DELIMITER, _skin_flavor);
				if (struct_exists(__tree_cache, _skin_flavor)) 
					return __tree_cache[$ _skin_flavor];
			} else if (struct_exists(__tree_cache, typename))
				return __tree_cache[$ typename];
		} else {
			_skin_state	= string_concat(__RAPTOR_SKIN_STATE_SIGN, _skin_state);
			if (hasflavor) {	
				_skin_flavor = string_concat(typename, __RAPTOR_SKIN_FLAVOR_DELIMITER, _skin_flavor);
				var skin_state = string_concat(_skin_flavor, _skin_state);
				if (struct_exists(__tree_cache, skin_state)) 
					return __tree_cache[$ skin_state];
			} else {
				var skin_state = string_concat(typename, _skin_state);
				if (struct_exists(__tree_cache, skin_state))
					return __tree_cache[$ skin_state];
			}
		}

		var rv = {};
		var item;
		var hasone = false;
		
		var tree = object_tree(_inst_or_type);
		array_reverse_ext(tree);
		for (var i = 0, len = array_length(tree); i < len; i++) {
			item = !hasstate ? tree[@i] : string_concat(tree[@i], _skin_state);
			if (struct_exists(skin, item)) {
				struct_join_into(rv, skin[$ item]);
				hasone |= (array_length(struct_get_names(rv)) > 0);
			}
		}

		if (!hasone) rv = undefined;
		if (hasstate) typename = string_concat(typename, _skin_state);
		__tree_cache[$ typename] = rv;
		
		if (hasflavor) {
			var sub_rv = __get_skin_flavor(_skin_flavor, _skin_state);
			if (hasstate) _skin_flavor = string_concat(_skin_flavor, _skin_state);
			if (sub_rv != undefined) {
				rv = hasone ? struct_join(deep_copy(rv), sub_rv) : sub_rv;
				__tree_cache[$ _skin_flavor] = rv;
			} else
				__tree_cache[$ _skin_flavor] = undefined;
		}	
		
		return rv;
	}
	
	/// @func __get_skin_flavor(_skin_flavor)
	static __get_skin_flavor = function(_skin_flavor, _skin_state = undefined) {
		
		static get_flavor = function(typename, flavor, state = undefined) { 
			return deep_copy(
				struct_get(skin, 
					string_concat(typename, __RAPTOR_SKIN_FLAVOR_DELIMITER, flavor, state ?? "")
				)
			);
		}
				
		var hasstate		= _skin_state != undefined;
		
		if (hasstate && !string_match(_skin_state, __RAPTOR_SKIN_STATE_WILDCARD))
			_skin_state		= string_concat(__RAPTOR_SKIN_STATE_SIGN, _skin_state);

		var parts			= string_split(_skin_flavor, __RAPTOR_SKIN_FLAVOR_DELIMITER,, 1);
		var typename		= parts[0];
		var flavors			= string_split(parts[1], __RAPTOR_SKIN_FLAVOR_CONCATE_DELIMITER);
		var flavor			= undefined;
		var flavor_child	= undefined;
		var flavor_parent	= undefined;
		var rv				= {};
		
		for (var i = 0, len = array_length(flavors); i < len; ++i) {
			flavor = string_trim(flavors[@i]);
			flavor_child = string_concat(
				__RAPTOR_SKIN_FLAVOR_DELIMITER, 
				array_last(string_split(flavor, __RAPTOR_SKIN_FLAVOR_DELIMITER))
			);
			flavor_parent = string_skip_end(flavor, string_length(flavor_child));
			if (flavor_parent != "")
				struct_join_into(
					rv, 
					__get_skin_flavor(
						string_concat(typename, __RAPTOR_SKIN_FLAVOR_DELIMITER, flavor_parent), _skin_state), 
					get_flavor(typename, flavor, _skin_state),
				);
			else 
				struct_join_into(rv, get_flavor(typename, flavor, _skin_state));
		}
		
		return rv;
	}

	/// @func apply_skin(_instance, _skin_flavor = undefined)
	static apply_skin = function(_instance, _skin_flavor = undefined, _skin_state = undefined) {
		var skindata = get_inherited_skindata(_instance, _skin_flavor, _skin_state);
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