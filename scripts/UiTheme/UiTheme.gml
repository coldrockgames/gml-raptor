/*
    Holds the color values for one single ui theme.
*/

// The default colors of raptor3
#macro CI_GLOBAL_MAIN					#4080FF
#macro CI_GLOBAL_BRIGHT					#60AAFF
#macro CI_GLOBAL_DARK					#3060DD
#macro CI_GLOBAL_ACCENT					#8080FF
										
#macro CI_GLOBAL_WHITE					#FAFAFA
#macro CI_GLOBAL_BLACK					#070707
#macro CI_GLOBAL_SHADOW					#808080
#macro CI_GLOBAL_SHADOW_ALPHA			0.75
#macro CI_GLOBAL_OUTLINE				CI_GLOBAL_BLACK
										
#macro CI_GLOBAL_CONTROL_DARK			#A0A0A0
#macro CI_GLOBAL_CONTROL_BACK			#C0C0C0
#macro CI_GLOBAL_CONTROL_BRIGHT			#E0E0E0
#macro CI_GLOBAL_CONTROL_TEXT			CI_GLOBAL_BLACK
#macro CI_GLOBAL_WINDOW_BACK			CI_GLOBAL_WHITE
#macro CI_GLOBAL_WINDOW_FOCUS			CI_GLOBAL_MAIN

// Variables to store the active theme
// These MUST be one variable per color! Otherwise, the ui system would not be able
// to use these macros in their color defaults in the variable definitions
#macro THEME_MAIN					global.__ci_theme_main
#macro THEME_BRIGHT					global.__ci_theme_bright
#macro THEME_DARK					global.__ci_theme_dark
#macro THEME_ACCENT					global.__ci_theme_accent
										
#macro THEME_WHITE					global.__ci_theme_white
#macro THEME_BLACK					global.__ci_theme_black
#macro THEME_SHADOW					global.__ci_theme_shadow
#macro THEME_SHADOW_ALPHA			global.__ci_theme_shadow_alpha
#macro THEME_OUTLINE				global.__ci_theme_outline

#macro THEME_CONTROL_DARK			global.__ci_theme_control_dark
#macro THEME_CONTROL_BACK			global.__ci_theme_control_back
#macro THEME_CONTROL_BRIGHT			global.__ci_theme_control_bright
#macro THEME_CONTROL_TEXT			global.__ci_theme_control_text
#macro THEME_WINDOW_BACK			global.__ci_theme_window_back
#macro THEME_WINDOW_FOCUS			global.__ci_theme_window_focus

/// @func UiTheme(_name = "default")
/// @desc create a new ui theme.
///				 NOTE: If the name already exists, when you add it to the UiThemeManager,
///				 the existing theme will be overwritte by the added theme!
///				 After the constructor ran, the new theme is initialized with raptor's default colors,
///				 and you can use the "set_colors" function to define (main, bright, dark, accent)
///				 and "set_grayscales" to define (white, black, outline, shadow, shadow_alpha) colors.
///				 But the best way is to derive your own theme from this and just set the colors you wish.
function UiTheme(_name = "default") constructor {
	construct(UiTheme);

	name = _name;
	
	main			= CI_GLOBAL_MAIN;
	bright			= CI_GLOBAL_BRIGHT;
	dark			= CI_GLOBAL_DARK;
	accent			= CI_GLOBAL_ACCENT;
					
	white			= CI_GLOBAL_WHITE;
	black			= CI_GLOBAL_BLACK;
	shadow			= CI_GLOBAL_SHADOW;
	shadow_alpha	= CI_GLOBAL_SHADOW_ALPHA;
	outline			= CI_GLOBAL_OUTLINE;

	control_back	= CI_GLOBAL_CONTROL_BACK;
	control_dark	= CI_GLOBAL_CONTROL_DARK;
	control_bright	= CI_GLOBAL_CONTROL_BRIGHT;
	control_text	= CI_GLOBAL_CONTROL_TEXT;
	window_back		= CI_GLOBAL_WINDOW_BACK;
	window_focus	= CI_GLOBAL_WINDOW_FOCUS;

	/// @func set_colors(_main, _bright, _dark, _accent)
	static set_colors = function(_main, _bright, _dark, _accent) {
		main	= _main;
		bright	= _bright;
		dark	= _dark;
		accent	= _accent;
	}
	
	/// @func set_grayscales(_white, _black, _outline, _shadow, _shadow_alpha)
	static set_grayscales = function(_white, _black, _outline, _shadow, _shadow_alpha) {
		white		 = _white;
		black		 = _black;
		outline		 = _outline;
		shadow		 = _shadow;
		shadow_alpha = _shadow_alpha;
	}

	/// @func set_control_colors(_control_back, _dark, _bright, _text, _window_back, _window_focus)
	static set_control_colors = function(_control_back, _dark, _bright, _text, _window_back, _window_focus) {
		control_back	= _control_back;
		control_dark	= _dark;
		control_bright	= _bright;
		control_text	= _text;
		window_back		= _window_back;
		window_focus	= _window_focus;
	}
}