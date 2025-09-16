/*
    This file contains functions that will be invoked 
	when raptor saves the game settings.
	
	Add any keys you like to the provided _settings struct.
*/

/// @func	on_game_settings_created(_settings)
/// @desc	Invoked when a new game settings class has been created.
///			This happens on first start of the game.
///			Add your default settings here.
function on_game_settings_created(_settings) {
}

/// @func	on_game_settings_loaded(_settings)
/// @desc	Invoked after settings have been loaded from disk.
function on_game_settings_loaded(_settings) {
}

/// @func	on_game_settings_saving(_settings)
/// @desc	Invoked before the settings file is written to disk.
function on_game_settings_saving(_settings) {
}
