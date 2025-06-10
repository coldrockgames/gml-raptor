/*
    short description here
*/

function RaptorFrameFormatter() : RaptorLogFormatterBase() constructor {

	format_event = function(_level, _message) {
		return $"{GAME_FRAME}: {_level} {_message}";
	}
}