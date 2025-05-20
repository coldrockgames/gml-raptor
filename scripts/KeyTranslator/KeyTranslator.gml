/*
    Translate the current keyboard_key to a string.
	This code is taken from @JujuAdams & Contributors input-library and modified
	to fit the needs of my internal platform for specific cases (like the StatefulObject).
	
	Credits to @JujuAdams & Contributors at github!
*/

// Those macros are also taken from input but renamed to avoid conflicts if the game uses input library too
#macro __KEY_TRANSLATE_DESKTOP  ((os_type == os_macosx) || (os_type == os_linux) || (os_type == os_windows))
#macro __KEY_TRANSLATE_APPLE    ((os_type == os_macosx) || (os_type == os_ios)   || (os_type == os_tvos))

#macro __KEY_TRANSLATE_OPERAGX  (os_type == os_operagx)
#macro __KEY_TRANSLATE_WEB      ((os_browser != browser_not_a_browser) || __KEY_TRANSLATE_OPERAGX)

#macro __KEY_TRANSLATE_PHYS_KEYBOARD (__KEY_TRANSLATE_DESKTOP || __KEY_TRANSLATE_WEB || (os_type == os_switch) || (os_type == os_uwp))

/// @func keyboard_to_string()
/// @desc translate the current keyboard_key to a string that is
///				 as-equal-as-possible to the gamemaker constant names (like vk_home)
function keyboard_to_string(_key_to_translate = undefined) {
	if (_key_to_translate == "") return "";
	var _key = _key_to_translate == undefined ? keyboard_key : _key_to_translate;
	if (_key == undefined) return "";

	if ((_key >= ord("A")) && (_key <= ord("Z")))
    {
        //Latin letters
        return chr(_key);
    }
    else if (_key >= ord("0")) && (_key <= ord("9"))
    {
        //Top row numbers
        return chr(_key);
    }
    else 
    {
        //Universal non-UTF8 keycodes
        switch(_key)
        {             
            case vk_up:			return "vk_up";    
            case vk_down:		return "vk_down";  
            case vk_left:		return "vk_left";  
            case vk_right:		return "vk_right"; 
            
            case vk_escape:		return "vk_escape";   
            case vk_backspace:	return "vk_backspace";
            case vk_space:		return "vk_space";    
            case vk_tab:		return "vk_tab";      
            case vk_enter:		return "vk_enter";    
        }
        
        //Apple Web exceptions
        if (__KEY_TRANSLATE_APPLE && __KEY_TRANSLATE_WEB)
        {
            switch(_key)
            {
                case 12: return "vk_numlock";   
                case 92: return "vk_meta1";		
                case 93: return "vk_meta2";		
            }
        }
        
        //Switch exceptions
        if (os_type == os_switch)
        {
            switch(_key)
            {
                case 107: return "+"; 
                case 109: return "-"; 
                case 110: return "."; 
            }
        }

        //Desktop platform non-UTF8 keycodes
        if (__KEY_TRANSLATE_PHYS_KEYBOARD)
        {
            //Common function row (F1 - F10)
            if ((_key >= vk_f1) && (_key <= vk_f10))
            {
                return ("F" + string(1 + _key - vk_f1));
            }

            switch(_key)
            {                 
                //Symbols
                case 186: return ";";  
                case 188: return ",";  
                case 190: return ".";  
                case 191: return "/";  
                case 219: return "[";  
                case 220: return "\\"; 
                case 221: return "]";  
            
                //Control
                case  93: return "vk_menu";      
                case 144: return "vk_numlock";   
                case 145: return "vk_scrollock"; 
                                                   
                //Command pairs
                case vk_ralt: return SEPARATE_LALT_RALT_KEYS ? "vk_ralt" : "vk_alt";
                case vk_lalt: return SEPARATE_LALT_RALT_KEYS ? "vk_lalt" : "vk_alt";
                case vk_alt:  return "vk_alt";

                case vk_rshift: return SEPARATE_LSHIFT_RSHIFT_KEYS ? "vk_rshift" : "vk_shift";
                case vk_lshift: return SEPARATE_LSHIFT_RSHIFT_KEYS ? "vk_lshift" : "vk_shift";
                case vk_shift:  return "vk_shift"; 
            
                case vk_rcontrol: return SEPARATE_LCONTROL_RCONTROL_KEYS ? "vk_rcontrol" : "vk_control";
                case vk_lcontrol: return SEPARATE_LCONTROL_RCONTROL_KEYS ? "vk_lcontrol" : "vk_control";
                case vk_control:  return "vk_control"; 
                
                //Numpad
                case vk_numpad0:  return "vk_numpad0";	
                case vk_numpad1:  return "vk_numpad1";	
                case vk_numpad2:  return "vk_numpad2";	
                case vk_numpad3:  return "vk_numpad3";	
                case vk_numpad4:  return "vk_numpad4";	
                case vk_numpad5:  return "vk_numpad5";	
                case vk_numpad6:  return "vk_numpad6";	
                case vk_numpad7:  return "vk_numpad7";	
                case vk_numpad8:  return "vk_numpad8";	
                case vk_numpad9:  return "vk_numpad9";	
                case vk_divide:   return "vk_divide";	
                case vk_decimal:  return "vk_decimal";	
                case vk_multiply: return "vk_multiply"; 
                case vk_add:      return "vk_add";		
                case vk_subtract: return "vk_subtract"; 

                //Misc.
                case 20:			 return "vk_capslock";    
                case vk_home:        return "vk_home";        
                case vk_end:         return "vk_end";         
                case vk_insert:      return "vk_insert";      
                case vk_delete:      return "vk_delete";      
                case vk_pagedown:    return "vk_pagedown";    
                case vk_pageup:      return "vk_pageup";      
                case vk_printscreen: return "vk_printscreen"; 
                case vk_pause:       return "vk_pause";		  
            }
        }
        
        //Per platform non-UTF8
        var _platform = os_type;

        //Browsers normalize keycodes across platforms
        //See https://github.com/wesbos/keycodes/blob/gh-pages/scripts.js        
        if (__KEY_TRANSLATE_WEB) _platform = "browser";
        
        switch(_platform)
        {
            //UWP uses select keycodes to reflect gamepad input
            //by default this behaviour is ignored (INPUT_IGNORE_RESERVED_KEYS_LEVEL > 0)              
            case os_uwp:
               switch(_key)      
               {
                   case 195: return "gamepad_face_south"; 
                   case 196: return "gamepad_face_east";  
                   case 197: return "gamepad_face_west";  
                   case 198: return "gamepad_face_north"; 
											
                   case 200: return "gamepad_shoulder_l"; 
                   case 199: return "gamepad_shoulder_r"; 
                   case 201: return "gamepad_trigger_l";  
                   case 202: return "gamepad_trigger_r";  
											
                   case 208: return "gamepad_select";	  
                   case 207: return "gamepad_start";	  
											
                   case 209: return "gamepad_thumbstick_l_click"; 
                   case 210: return "gamepad_thumbstick_r_click"; 
											
                   case 203: return "gamepad_dpad_up";    
                   case 204: return "gamepad_dpad_down";  
                   case 205: return "gamepad_dpad_left";  
                   case 206: return "gamepad_dpad_right"; 
											
                   case 214: return "gamepad_thumbstick_l_left";  
                   case 213: return "gamepad_thumbstick_l_right"; 
                   case 211: return "gamepad_thumbstick_l_up";    
                   case 212: return "gamepad_thumbstick_l_down";  
													   
                   case 218: return "gamepad_thumbstick_r_left";  
                   case 217: return "gamepad_thumbstick_r_right"; 
                   case 215: return "gamepad_thumbstick_r_up";    
                   case 216: return "gamepad_thumbstick_r_down";  
               }
                
            //UWP also uses Windows case
            case os_windows:
            case "browser":
                //F11 - F32
                if ((_key >= vk_f11) && (_key <= vk_f1 + 31))
                {
                    return "F" + string(_key - vk_f1 + 1);
                }
            
                switch(_key)
                {
                    case 187: return "="; 
                    case 189: return "-"; 
                    case 192: return "`"; 
                    case 222: return "'"; 
            
                    case 12:  return "vk_clear"; 
                    
                    case 91: return "vk_meta1";  
                    case 92: return "vk_meta2";  
                }
            break;
            
            case os_macosx:
                switch(_key)      
                {
                    case 128: return "F11"; 
                    case 129: return "F12"; 
                    
                    case 24:  return "=";   
                    case 109: return "-";   
                    case 222: return "'";   
                    
                    //Swapped on Mac
                    case 91:  return "vk_meta1"; 
                    case 92:  return "vk_meta2"; 
                }
            break;
            
            case os_linux:
                switch(_key)      
                {
                    case 128: return "F11"; 
                    case 129: return "F12"; 
                    
                    case 187: return "="; 
                    case 189: return "-"; 
                    case 192: return "'"; 
                    case 223: return "`"; 
                    
                    case 91:  return "vk_meta1"; 
                    case 92:  return "vk_meta2"; 
                }
            break;
            
            case os_android:
                switch(_key)      
                {
                    case 10: return "vk_enter";
                }
            break;
            
            case os_switch:
                switch(_key)
                {
                    case 2: case 3: case 4: 
                    case 5: case 6: case 7:
                        return string(_key);
                    
                    case 128: return "F11"; 
                    case 129: return "F12"; 
                }
            break;
        }
        
        return chr(_key); //Default to UTF8 character
    }
	
}