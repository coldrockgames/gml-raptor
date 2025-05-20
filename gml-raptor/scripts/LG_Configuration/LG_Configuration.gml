/*
	Configure the LG language system with the parameters below.
	
	(c)2022- coldrock.games, @grisgram at github
	Please respect the MIT License for this library: https://opensource.org/licenses/MIT
*/


// this locale MUST exist or the LG system will crash the game.
#macro LG_DEFAULT_LANGUAGE				"en"

// If true, LG_Init() will be called for you with the OS language (if available)
// or the LG_DEFAULT_LANGUAGE as fallback when the game starts.
#macro LG_AUTO_INIT_ON_STARTUP			true

// A sub folder in your working_directory (included files)
// where all locale_*.json files are stored.
// Set it to "" if you store your locale files in included 
// files root.
#macro LG_ROOT_FOLDER					"locale/"

// If you're also using the Scribble library 
// (https://github.com/JujuAdams/Scribble)
// this flag must be true. 
// LG will then NOT replace [[ double brackets 
// with a single [ bracket
// and leave the final formatting to Scribble.
// Set this to false if you don't use Scribble 
// for fancy text rendering (but you SHOULD use it! Honestly!)
#macro LG_SCRIBBLE_COMPATIBLE			true
