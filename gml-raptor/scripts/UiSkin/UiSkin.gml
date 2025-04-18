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
	
	asset_skin = {};
		
	asset_skin[$ "CheckBox"]			= { sprite_index: sprDefaultCheckbox }
	asset_skin[$ "InputBox"]			= { sprite_index: sprDefaultInputBox }
	asset_skin[$ "Label"]				= { sprite_index: sprDefaultLabel	 }
	asset_skin[$ "MouseCursor"]			= { 
 											sprite_index: sprDefaultMouseCursor,
											mouse_cursor_sprite: sprDefaultMouseCursor,
 											mouse_cursor_sprite_sizing: sprDefaultMouseCursorSizing
 										  }
	asset_skin[$ "Panel"]				= { sprite_index: spr1pxTrans			}
	asset_skin[$ "RadioButton"]			= { sprite_index: sprDefaultRadioButton	}
	asset_skin[$ "Slider"]				= { 
											sprite_index: sprDefaultSliderRailH,
											rail_sprite_horizontal: sprDefaultSliderRailH,
											rail_sprite_vertical: sprDefaultSliderRailV,
											knob_sprite: sprDefaultSliderKnob
										  }
	asset_skin[$ "Scrollbar"]			= { 
											sprite_index: sprDefaultScrollbarRailH,
											rail_sprite_horizontal: sprDefaultScrollbarRailH,
											rail_sprite_vertical: sprDefaultScrollbarRailV,
											knob_sprite: sprDefaultScrollbarKnob
										  }
	asset_skin[$ "TextButton"]			= { sprite_index: sprDefaultButton	}
	asset_skin[$ "ImageButton"]			= { sprite_index: sprDefaultButton	}
	asset_skin[$ "Tooltip"]				= { sprite_index: sprDefaultTooltip	}
	asset_skin[$ "Window"]				= { 
											sprite_index: sprDefaultWindow,
											window_x_button_object: WindowXButton,
											titlebar_height: 34
										  }
	asset_skin[$ "WindowXButton"]		= { sprite_index: sprDefaultXButton	}
	asset_skin[$ "MessageBoxWindow"]	= { 
											sprite_index: sprDefaultWindow,
											window_x_button_object: MessageBoxXButton,
											titlebar_height: 34
										  }
	asset_skin[$ "MessageBoxXButton"]	= { sprite_to_use: sprDefaultXButton }
	
	/// @func delete_map()
	static delete_map = function() {
		asset_skin = {};
		__tree_cache = {};
	}

	/// @func	get_inherited_skindata(_instance)
	static get_inherited_skindata = function(_inst_or_type) {
		var typename = 
			is_object_instance(_inst_or_type) ? 
			name_of(_inst_or_type, false) : 
			typename_of(_inst_or_type)
		;
		
		if (struct_exists(__tree_cache, typename))
			return __tree_cache[$ typename];
			
		var rv = {};
		var item;
		var haveone = false;
		
		var tree = object_tree(_inst_or_type);
		array_reverse_ext(tree);
		for (var i = 0, len = array_length(tree); i < len; i++) {
			item = tree[@i];
			if (struct_exists(asset_skin, item)) {
				struct_join_into(rv, asset_skin[$ item]);
				haveone |= (array_length(struct_get_names(rv)) > 0);
			}
		}

		if (!haveone) rv = undefined;
		__tree_cache[$ typename] = rv;
		return rv;
	}

	/// @func apply_skin(_instance)
	static apply_skin = function(_instance) {
		var skindata = get_inherited_skindata(_instance);
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
			var names = struct_get_names(src.asset_skin);
			for (var i = 0, len = array_length(names); i < len; i++) {
				var key = names[@i];
				asset_skin[$ key] = src.asset_skin[$ key];
			}
		} else
			elog($"** ERROR ** UiSkin could not inherit skin '{_skin_name}' into '{name}' (SKIN-NOT-FOUND)");
	}

}