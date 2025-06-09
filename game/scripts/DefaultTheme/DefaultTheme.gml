/*
    Raptor's neutral default theme.
	
	D O   N O T   D E L E T E   T H I S   T H E M E !
	It is set/added to the ThemeManager in the raptor core when the game starts.
	You may adapt the color values in here at will, or simply derive your own theme and just use
	this file as a template. Whatever you do, just do not delete this one here!
	
	For more information, look at the raptor wiki:
	https://github.com/coldrockgames/gml-raptor/wiki/UI-Themes
*/

function DefaultTheme(_name = "default") : UiTheme(_name) constructor {

	// "Your" colors
	main			= CI_GLOBAL_MAIN;
	bright			= CI_GLOBAL_BRIGHT;
	dark			= CI_GLOBAL_DARK;
	accent			= CI_GLOBAL_ACCENT;

	// Greyscales
	white			= CI_GLOBAL_WHITE;
	black			= CI_GLOBAL_BLACK;
	shadow			= CI_GLOBAL_SHADOW;

	// UI controls
	control_back	= CI_GLOBAL_CONTROL_BACK;
	control_dark	= CI_GLOBAL_CONTROL_DARK;
	control_bright	= CI_GLOBAL_CONTROL_BRIGHT;
	control_text	= CI_GLOBAL_CONTROL_TEXT;
	window_back		= CI_GLOBAL_WINDOW_BACK;
	window_focus	= CI_GLOBAL_WINDOW_FOCUS;

}

