/*
    Raptor's default skin.
	
	This script is here for you, so you can see, how you can easily define your own skin:
	Just derive from "UiSkin", give it a name, and set the sprites you want, then add 
	the skin to the UiSkinManager by invoking "UI_SKINS.add_skin(new YourSkin());"
	
	While the sprites used for this default theme are placed in raptor core, I recommend, that
	you create a folder in "skins" for each skin and put your sprites for the skin directly there,
	so it's all in one place.
	
	D O   N O T   D E L E T E   T H I S   S K I N !
	It is set/added to the UiSkinManager in the raptor core when the game starts.
	You may adapt the sprite values in here at will, or simply derive your own skin and just use
	this file as a template. Whatever you do, just do not delete this one here!
	
	HOW TO EXTEND A SKIN WITH NEW OBJECTS
	It's as easy as adding the object's name as key and the sprite to use to the ds_map of the skin.
	Just add it. 
	When you activate a skin, raptor loops through the keys and uses object_set_sprite(...) on each of them!
*/
// Feather disable GM2017

function DefaultSkin(_name = "default") : UiSkin(_name) constructor {
	var window_def = function(xbutton) { 
		return {
			sprite_index: sprDefaultWindow,
			window_x_button_object: xbutton,
			titlebar_height: 34
		};
	}

	asset_skin[$ "CheckBox"]			= { sprite_index: sprDefaultCheckbox }
	asset_skin[$ "InputBox"]			= { sprite_index: sprDefaultInputBox }
	asset_skin[$ "Label"]				= { sprite_index: sprDefaultLabel	 }

	asset_skin[$ "MouseCursor"]			= { 
 											sprite_index: sprDefaultMouseCursor,
											mouse_cursor_sprite: sprDefaultMouseCursor,
 											mouse_cursor_sprite_sizing: sprDefaultMouseCursorSizing
 										  }
	asset_skin[$ "Panel"]				= { sprite_index: spr1pxTrans			}
	asset_skin[$ "RadioButton"]			= { sprite_index: sprDefaultRadioButton }
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
	asset_skin[$ "TextButton"]			= { sprite_index: sprDefaultButton  }
	asset_skin[$ "ImageButton"]			= { sprite_index: sprDefaultButton  }
	asset_skin[$ "Tooltip"]				= { sprite_index: sprDefaultTooltip }
	asset_skin[$ "Window"]				= window_def(WindowXButton);
	asset_skin[$ "MessageBoxWindow"]	= window_def(MessageBoxXButton);
	
	asset_skin[$ "WindowXButton"]		= { sprite_to_use: sprDefaultXButton }
	asset_skin[$ "MessageBoxXButton"]	= { sprite_to_use: sprDefaultXButton }

}

