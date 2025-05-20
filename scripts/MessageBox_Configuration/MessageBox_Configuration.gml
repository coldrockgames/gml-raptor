/*
    This script holds all macros to define behavior and optics of
	the MessageBox system.
*/

// This layer is used for all message boxes.
// Leave this macro here even if you don't use messageboxes, otherwise you get a compile error
#macro MESSAGEBOX_LAYER					"MessageBox"

// Asset name of the Window, Button and Label objects to use for Messageboxes
#macro MESSAGEBOX_WINDOW				MessageBoxWindow
#macro MESSAGEBOX_BUTTON				MessageBoxTextButton
#macro MESSAGEBOX_TEXT_LABEL			MessageBoxLabel

// Element dimensions
#macro MESSAGEBOX_INNER_MARGIN			32
#macro MESSAGEBOX_BUTTON_SPACE			12
#macro MESSAGEBOX_BUTTON_MIN_WIDTH		128
#macro MESSAGEBOX_BUTTON_MIN_HEIGHT		40

// If this is undefined, the scribble_default_font will be used.
// You set the scribble_default_font in the onGameStart method in the Game_Configuration
// With this macro you can assign any different font for the messagebox (text + buttons)
// and the title bar.
// NOTE: This setting is a STRING, not a font resource. Specify "fntText", not fntText!
#macro MESSAGEBOX_FONT					undefined
#macro MESSAGEBOX_TITLE_FONT			MESSAGEBOX_FONT
